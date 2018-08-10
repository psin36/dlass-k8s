#! /bin/bash

###########
# Usage: dlaas_perf.sh <config_file>
# Created by: Jonathan Samn (jsamn@us.ibm.com)
#
#
###########

inputcmd=$0
SCRIPT=`[ "$OSTYPE" = linux-gnu ] && readlink -f "$0" || echo $inputcmd`
scriptsdir=$(dirname "$SCRIPT")
cd $scriptsdir
fullpath=$(pwd)
logfile="${fullpath}/../logs/autorunStatus.log"

mkdir -p ${fullpath}/../logs
mkdir -p ${fullpath}/../trainedresults/caffe
mkdir -p ${fullpath}/../trainedresults/tensorflow
mkdir -p ${fullpath}/../manifests

#Set to 1 if you want to run as many as possible
runAll=1

# How long to wait between checking status of a job.
recheckStatusTime=5

#export DLAAS_URL=<DLAAS_URL>
#export DLAAS_USERNAME=<DLAAS_USERNAME>
#export DLAAS_PASSWORD=<DLAAS_PASSWORD>

# Check if script used properly.
if [ "$#" -ne "1" ]; then
    echo "ERROR: Illegal number of parameters given."
    exit
elif [ ! -f $1 ]; then
    # Given configuration file does not exist
    echo "ERROR: Configuration file, $1, does not exist."
    exit
else
    configFile=$1
fi

function watchJob {
    local fwType=$1
    local trainingid=$2
    local resultsContainer=$3
    local epURL=$4
    local outputName=$5
    local s3key=$6
    local s3secret=$7
    local status=$(dlaas status $trainingid | grep "Training Status is" | awk -F_ '{print $2}')
    echo "$fwType $trainingid $resultsContainer $epURL $outputName $s3key $s3secret $status" > ${logfile}
    while [[ "${status}" != "" ]]; do
      case "${status}" in
        FAILED)
          echo "Training (${trainingid}) has failed."
          return
          ;;
        COMPLETED)
          echo "Training (${trainingid}) is complete. Downloading results."
          outputfile="${fullpath}/../trainedresults/${fwType}/${outputName}_${trainingid}"
          echo "$outputfile"
          export AWS_ACCESS_KEY_ID=${s3key}
          export AWS_SECRET_ACCESS_KEY=${s3secret}
          case "${fwType}" in
            tensorflow)
              echo "iteration,time,throughput (img/s),loss,top1-accuracy,top5-accuracy" > ${outputfile}.csv
              dlaas logs -f $trainingid > ${outputfile}.log
              startRefTime=`cat ${outputfile}.log | grep "top_5_accuracy" | awk '{print $2}'`
              cat ${outputfile}.log | grep -e "images/sec" | grep -v "shuffle buffer" | grep -v "total" > ${outputfile}.tmp
              while read line; do
                 thistime=`echo $line | awk '{print $2}'`
                 diffTime=$((thistime/1000-startRefTime/1000))
                 echo $line | awk -F" " -v x=$diffTime '{print $3","x","$5","$(NF-2)","$(NF-1)","$NF}' >> ${outputfile}.csv
              done < "${outputfile}.tmp"
              #cat ${outputName}.log | grep -e images/sec | grep -v "shuffle buffer" | grep -v "total" | awk '{print $3","($2-${startRefTime})","$5","$(NF-2)","$(NF-1)","$NF}' >> ${outputName}.csv
              ;;
            caffe)
              #echo "aws --endpoint-url=${epURL} s3 cp s3://${resultsContainer}/${trainingid}/learner-1/training-log.txt ${outputfile}" > ${logfile}
              aws --endpoint-url=${epURL} s3 cp s3://${resultsContainer}/${trainingid}/learner-1/training-log.txt ${outputfile}.log
              echo "python ${fullpath}/extract_metrics.py dummy ${outputfile}.log ${outputfile}.csv 1"
              python ${fullpath}/extract_metrics.py dummy ${outputfile}.log ${outputfile}.csv 1
              ;;
          esac
          return
          ;;
        *)
          sleep ${recheckStatusTime}
          status=$(dlaas status ${trainingid} | grep "Training Status is" | awk -F_ '{print $2}')
          #echo "$(date) Waiting for training to finish." >> $logfile
          ;;
      esac
    done
    echo "Training (${trainingid}) no longer exists. It might have been manually deleted."
    return
}


while IFS=',' read -r -a iarray || [[ -n "$iarray" ]]; do
    case "${iarray[0]}" in
      \#*) continue ;;
      "") continue ;;
    esac
    #BASENAME,framework,frameworkVersion,trainBatchSize,trainIterations,testBatchSize,testIterations,GPUsPerNode,CPUsPerNode,NodeCount,directory,manifestFileBaseName,model,gpuType,[solverFileBaseName,trainValBaseName]
    #BASENAME,framework,frameworkVersion,trainBatchSize,trainIterations,testBatchSize,testIterations,GPUsPerNode,CPUsPerNode,NodeCount,directory,manifestFileBaseName,model,gpuType,variableUpdate
    baseRunName="${iarray[0]// /_}"
    framework=${iarray[1]}
    fwversion=${iarray[2]}
    batchSize=${iarray[3]}
    iterationsSize=${iarray[4]}
    testBatchSize=${iarray[5]}
    testIterationsSize=${iarray[6]}
    gpucount=${iarray[7]}
    cpucount=${iarray[8]}
    memory=${iarray[9]}
    nodecount=${iarray[10]}
    fwdir=${iarray[11]}
    manifestBaseName=${iarray[12]}
    model=${iarray[13]}
    gputype=${iarray[14]}
    precision=${iarray[15]}
    trainDataBucket=${iarray[16]}
    resultsBucket=${iarray[17]}

    # Use this for tracking purposes of how many GPUs actually used.
    actualGPU=$((nodecount*gpucount))

    csvNameTag="${framework}_${fwversion}_${model}_${gputype}_${gpucount}_${cpucount}_${memory}_${batchSize}"
    comboTag="-${gputype}-b${batchSize}-i${iterationsSize}-g${actualGPU}-c${cpucount}-${model}"
    runName="${baseRunName}${comboTag}"

    cd ${fullpath}/../${fwdir}
    manifestFile="${fullpath}/../manifests/${manifestBaseName}${comboTag}.yml"
    cp ${fullpath}/${framework}ManifestTemplate.yml $manifestFile
    gpuselect=""

    case "${gpucount}" in
      1) gpuselect="-gpu 0";;
      2) gpuselect="-gpu 0,1";;
      3) gpuselect="-gpu 0,1,2";;
      4) gpuselect="-gpu all";;
      *) echo "GPU Number not valid";;
    esac
    case "${framework}" in
      caffe)
        mode_replacement=""
        if [ "${precision}" == "mixed" ]; then
            mode_replacement="# Mixed precision\ndefault_forward_type:  FLOAT16\ndefault_backward_type: FLOAT16\ndefault_forward_math:  FLOAT\ndefault_backward_math: FLOAT"
        fi
        # Do not adjust order
        solverFile="${iarray[18]}${comboTag}.prototxt"
        trainValFile="${iarray[19]}${comboTag}.prototxt"

        cp ${fullpath}/solverTemplate.prototxt $solverFile
        sed -i -e "s/<TRAINVALFILE>/${trainValFile}/g" $solverFile
        sed -i -e "s/<TESTITERATIONS>/${testIterationsSize}/g" $solverFile
        sed -i -e "s/<ITERATIONS>/${iterationsSize}/g" $solverFile
        cp ${fullpath}/trainTemplate.prototxt $trainValFile
        sed -i -e "s/<BATCHSIZE>/${batchSize}/g" $trainValFile
        sed -i -e "s/<TESTBATCHSIZE>/${testBatchSize}/g" $trainValFile
        sed -i -e "s/<MODE>/${mode_replacement}/g" $trainValFile

        tmpcmd='caffe train -solver <SOLVERFILE> <GPUSELECT>'
        sed -i -e "s|<COMMAND>|${tmpcmd}|g" $manifestFile
        sed -i -e "s/<GPUSELECT>/${gpuselect}/g" $manifestFile
        sed -i -e "s/<SOLVERFILE>/${solverFile}/g" $manifestFile
        sed -i -e "s/<FWVERSION>/${fwversion}/g" $manifestFile
        sed -i -e "s/<TRAININGDATACONTAINER>/imagenet-data-caffe/g" $manifestFile
        ;;
      tensorflow)
        precFlag=""
        variableUpdate=${iarray[18]}
        if [ "${precision}" == "half" ]; then
          precFlag="--use_fp16=True"
        fi
        #Old tensorflow
        #tmpcmd='echo "TrainingDetails: '${manifestFile}'" > ${RESULT_DIR}/gpu-usage${LEARNER_ID}.txt; cd ./benchmarks-master/scripts/tf_cnn_benchmarks \&\& python tf_cnn_benchmarks.py --local_parameter_device=cpu --num_gpus=<GPUCOUNT> --batch_size=<BATCHSIZE> --num_batches=<ITERATIONS> --model=<MODEL> --data_dir="${DATA_DIR}" --data_name="imagenet" --variable_update=<VAR_UPDATE> --num_intra_threads=4 --num_inter_threads=8 --print_training_accuracy'
        tmpcmd='python tf_cnn_benchmarks.py --local_parameter_device=cpu --num_gpus=<GPUCOUNT> --batch_size=<BATCHSIZE> --num_batches=<ITERATIONS> --model=<MODEL> --data_dir="${DATA_DIR}" --data_name="imagenet" --variable_update=<VAR_UPDATE> --num_intra_threads=4 --num_inter_threads=8 --print_training_accuracy <PRECISION>'
        sed -i -e "s|<COMMAND>|${tmpcmd}|g" $manifestFile
        sed -i -e "s/<BATCHSIZE>/${batchSize}/g" $manifestFile
        sed -i -e "s/<ITERATIONS>/${iterationsSize}/g" $manifestFile
        sed -i -e "s/<FWVERSION>/${fwversion}/g" $manifestFile
        sed -i -e "s/<TRAININGDATACONTAINER>/imagenet-data/g" $manifestFile
        sed -i -e "s/<VAR_UPDATE>/${variableUpdate}/g" $manifestFile
        sed -i -e "s/<PRECISION>/${precFlag}/g" $manifestFile
        ;;
    esac

    # Fill out template
    sed -i -e "s/<NAME>/${runName}/g" $manifestFile
    sed -i -e "s/<FRAMEWORK>/${framework}/g" $manifestFile
    sed -i -e "s/<MODEL>/${model}/g" $manifestFile
    sed -i -e "s/<CPUCOUNT>/${cpucount}/g" $manifestFile
    sed -i -e "s/<LEARNERSCOUNT>/${nodecount}/g" $manifestFile
    sed -i -e "s/<GPUCOUNT>/${gpucount}/g" $manifestFile
    sed -i -e "s/<GPUTYPE>/${gputype}/g" $manifestFile
    sed -i -e "s/<MEMORY>/${memory}/g" $manifestFile
    sed -i -e "s/<TRAINBUCKET>/${trainDataBucket}/g" $manifestFile
    sed -i -e "s/<RESULTSBUCKET>/${resultsBucket}/g" $manifestFile

    #Wait until no current model trainings happening. Don't be greedy
    #modelsRunning=`bx dl list | grep -e DOWNLOADING -e PROCESSING -e PENDING | wc -l | awk '{print $1}'`
    totalModels=`dlaas list | grep training | wc -l`
    totalComplete=`dlaas list | grep training | grep -v "NORMAL_OPERATION" | awk '{print $5}' | sed '/^\s*$/d'| wc -l`

    # Only have one model training running
    #while [[ ${modelsRunning} -gt 0 ]] ;do
    while [[ ${totalModels} -ne ${totalComplete} ]] && [ "$runAll" != 1 ] ;do
      echo "Waiting for model(s) to finish."
      sleep 300
      #modelsRunning=`bx dl list | grep -e DOWNLOADING -e PROCESSING -e PENDING | wc -l | awk '{print $1}'`
      totalModels=`dlaas list | grep training | wc -l`
      totalComplete=`dlaas list | grep training | grep -v "NORMAL_OPERATION" | awk '{print $5}' | sed '/^\s*$/d'| wc -l`
    done

    cd ${fullpath}/..

    #echo "$(date) Run: bx dl train ${fwdir}/$manifestFile ${fwdir}"
    #echo "$(date) Run: bx dl train ${fwdir}/$manifestFile ${fwdir}" >> $logfile
    trainOutput=`dlaas train ${manifestFile} ${fwdir}`
    endpointURL=`cat ${manifestFile} | grep auth_url | awk '{print $2}'`
    s3user=`cat ${manifestFile} | grep user_name | awk '{print $2}'`
    s3pass=`cat ${manifestFile} | grep password | awk '{print $2}'`
    export AWS_ACCESS_KEY_ID=${s3user}
    export AWS_SECRET_ACCESS_KEY=${s3pass}
    #trainOutput=`bx dl train $manifestFile ${fwdir}`
    #FOR DLAAS: Training job created. Training ID is training-GUwund6zg
    modelID=`echo "${trainOutput}" | grep "Training job created." | awk '{print $7}'`
    #For bx dl command:  Look for Model ID:
    #modelID=`echo "${trainOutput}" | grep "Model ID:" | awk '{print $3}'`
    if [ "$modelID" == "" ] ;then
      echo "ERROR: ${trainOutput}" >> $logfile
    else
      echo "$(date) New Model Training Started: $runName $modelID"
      echo "$(date) New Model Training Started: $runName $modelID" >> $logfile
      watchJob ${framework} ${modelID} ${resultsBucket} ${endpointURL} ${csvNameTag} ${s3user} ${s3pass} &
    fi

    # If runAll==1 clear out modelID to skip the while loop and go to the next training
    if [ "$runAll" == 1 ] ; then
      modelID=""
      sleep 10
    fi

    while [ "$modelID" != "" ] ;do
      #For bx dl command:
      #modelStatus=`bx dl list | grep $modelID | awk '{print $4}'`
      #For DLAAS command:
      modelStatus=`dlaas status $modelID | grep "Training Status is" | awk -F_ '{print $2}'`
      echo "$(date) Current status of $modelID: $modelStatus"
      echo "$(date) Current status of $modelID: $modelStatus" >> $logfile
      if [ "$modelStatus" == "" ]; then
        echo "ERROR: $modelID is no longer in the dlaas list and might have been manually deleted. Exiting script."
        exit 1
      fi
      case "${modelStatus}" in
        FAILED)
          #checkFAIL=`curl -u cd629cc7-caed-4785-b92f-d17fad628b15:BABfNGp0Plju -X GET https://stream-s.watsonplatform.net/dlaas-experimental/api/v1/models/${modelID}?version=2017-02-13 | awk -F, {'print $31'} | awk -F: {'print $2'}`
          #if [ "$checkFAIL" == "\"INSUFFICIENT_RESOURCES\"" ] ; then
          #  echo "Not enough resources"
          #fi
          modelID=""
          ;;
        COMPLETED)
          #echo "$(date) Downloading Trained Model for $modelID"
          #echo "$(date) Downloading Trained Model for $modelID" >> $logfile
          #cd ${fullpath}/../trainedresults/${framework}
          #bx dl download --trainedmodel $modelID
          #unzip $modelID-trainedmodel.zip
          #rm $modelID-trainedmodel.zip
          #rm $modelID/*.caffemodel
          #rm $modelID/*.solverstate
          modelID=""
          ;;
        *)
          sleep 300
          echo "$(date) Waiting for training to finish." >> $logfile
          ;;
      esac
    done

done < "${fullpath}/${configFile}"

exit
