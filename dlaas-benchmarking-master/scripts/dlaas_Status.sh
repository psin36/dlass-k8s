#! /bin/bash

#######
#  Usage: dlaas_Status.sh <searchText>
#
#  Created by: Jonathan Samn (jsamn@us.ibm.com)
#######

SCRIPT=`[ "$OSTYPE" = linux-gnu ] && readlink -f "$0" || echo $inputcmd`
basedir=$(dirname "$SCRIPT")
cd $basedir
fullpath=$(pwd)

datadir="$basedir/datafiles"

mkdir -p "$datadir"

pattern=$1
if [ "$pattern" == "" ]; then
  echo "Please enter a search pattern"
  exit
fi


tempfile="listOfJobs.txt"

dlaas list | grep ${pattern} | awk '{print $1","$2","$3}' > ${tempfile}


while IFS=',' read -r -a line || [[ -n "$line" ]]; do
    case "${line[0]}" in
      \#*) continue ;;
      "") continue ;;
    esac
    jobid=${line[0]}
    jobTag=${line[1]}
    jobfw=${line[2]}
    echo ""
    echo "Checking ${jobTag}-${jobid} ..."

    jobStatus=`dlaas status ${jobid} | grep "Training Status is" | awk -F_ '{print $2}'`

    case "${jobStatus}" in
      COMPLETED)
        #Get Stats
        dlaas logs -f ${jobid} > $datadir/${jobTag}-${jobid}.out
        case "${jobfw}" in
          caffe)
              awkcmd='/^.* Starting Optimization$/{print $2}
                      /^.* Snapshotting to binary proto file .*$/{print $2}'
              times=(`awk "$awkcmd" $datadir/${jobTag}-${jobid}.out`)
              echo "DLaaS job ID: ${jobTag} with name: ${jobid}, started: ${times[0]}    stopped: ${times[1]}"
              ;;
          tensorflow)
              results=`cat $datadir/${jobTag}-${jobid}.out | grep "total images/sec:" | awk '{print $5}'`
              if [ "${results}" == "" ]; then
                 echo "DLaaS job ID: ${jobTag} with name: ${jobid}. There is something wrong with the output on this."
              else
                 echo "DLaaS job ID: ${jobTag} with name: ${jobid}, ${results} images/sec"
              fi
              ;;
          *)
              echo "Framework ${jobfw} unknown or not supported yet"
              ;;
        esac
        ;;
        FAILED)
          #This failed
          echo "${jobid} failed. ${jobTag}"
          ;;
        *)
          #Check progress
          unameOut="$(uname -s)"
          case "${unameOut}" in
              Linux*)
                    #Linux
                    timeout 1m dlaas logs -f ${jobid} > $datadir/${jobTag}-${jobid}.out
                    ;;
              Darwin*)
                    # MacOS
                    gtimeout 1m dlaas logs -f ${jobid} > $datadir/${jobTag}-${jobid}.out
                    ;;
              *)
                    ;;
          esac

          iterationNum=0
          case "${jobfw}" in
            caffe)
                iterationNum=`cat $datadir/${jobTag}-${jobid}.out | grep Iteration | tail -n 1 | awk -F"Iteration" '{print $2}' | awk -F"," '{print $1}'`
                ;;
            tensorflow)
                iterationNum=`cat $datadir/${jobTag}-${jobid}.out | grep images/sec | tail -n 1 | awk '{print $3}'`
                ;;
            *)
                echo "Framework ${jobfw} unknown or not supported yet"
                ;;
          esac
          echo "DLaaS job ID: ${jobTag} with name: ${jobid}, has last iteration at ${iterationNum}."
          ;;
      esac
  done < "$tempfile"

exit
