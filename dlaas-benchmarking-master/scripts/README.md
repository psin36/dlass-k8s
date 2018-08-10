**In this directory:**


**Scripts:**


- dlaas_perf.sh  :  To run this use "./dlaas_perf.sh <config file>"
                  All log, manifest, and result directories will be created as needed.
                  There is a variable called "runAll" that you can set if you want
                  to run all at once, if not "1", then it will only run one train
                  at a time in case of limited resources. This assumes you can
                  run the dlaas command. i.e. env parameters are set, and you
                  can connect to the cluster.
- dlaas_Status.sh : To run this use "./dlaas_Status.sh <searchText>". This will
                  take the searchText and any line from the 'dlaas list' command
                  that contains that text, it will check the status on that job.
                  This assumes you can run the dlaas command. i.e. env
                  parameters are set, and you can connect to the cluster. If a
                  job is COMPLETED, it will return the total images/sec for
                  tensorflow, or the start and end time of caffe. If it is not
                  in a COMPLETED or FAILED status, then it will give what
                  iteration it last printed for either tensorflow or caffe. Any
                  other framework is not supported.
                  NOTE: This uses the 'timeout' command that is only for Linux.
                  If you want to run this on MacOS, change it to 'gtimeout' which
                  you can get with 'brew install coreutils'.


**Template files:**
- tensorflowManifestTemplate.yml  : Used for tensorflow. Change data store as needed.
- caffeManifestTemplate.yml  : Used for caffe. Change data store as needed.
- solverTemplate.prototxt  : Used for caffe. May need to change some values like snapshot.
- trainTemplate.prototxt  : Used for caffe. Change data source as needed as well as anything else.

**Config file:**
- longrun.cfg  : This has a list of training configurations to run.
                 Lines beginning with # are ignored. Header lines should be commented out.
                 The first 14 values of a line of csv should be the same for tensorflow and caffe.
                 The next values after that are specific to either framework.



**Directories created by dlaas_perf.sh script:**
- ../logs         : autorunStatus.log will go here for any output you might want to see later.
- ../manifests    : manifest files created for each run will be created in this directory
- ../trainedresults/caffe        :  Caffe results are downloaded here(maybe deprecated)
- ../trainedresults/tensorflow   :  Tensorflow results are downloaded here(maybe deprecated)

**Directory created by dlaas_Status.sh script:**
- datafiles   : This is where the dlaas logs output will be put into files given
                the name and job id.

**Python Parse and Plotting Scripts**
To parse logs when you have model_id and job is still streaming logs:
python extract_metrics.py <model_id> 1_1.log 1_1.out 0
this will first download the streaming logs in 1_1.log and then produce parsed logs (iteration no, elapsed time, accuracy, loss) as 1_1.out
-----------------------------------------------------
To parse logs when you have downloaded the logs:
python extract_metrics.py dummy 1_1.log 1_1.out 1
This will take log file 1_1.log as input and produce parsed logs (iteration no, elapsed time, accuracy, loss) as 1_1.out
Note that you do not need model_id as you already have the logs. So any dummy value is fine.
----------------------------------------------------
To generate plots:
python plottest1.py
this will generate 4 plots, accuracy vs time, loss vs time, accuracy vs iterations, loss vs iterations, show them and also save them in local folder as jpg.  
