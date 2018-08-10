# Throughput Testing on Cruiser13

## Experiment
The file `s3_tester.py` (https://github.ibm.com/ORO/s3_tester) will run on each node of cruiser13 using a DaemonSet. The script was slightly modified to run for 60 seconds instead of 10, and then sleep indefinitely. DaemonSets must necessarily have `restartPolicy: Always`. The indefinitely sleep effectively turns a DaemonSet into a run-once job that deploys on every node. This modification can be found in the image `registry.ng.bluemix.net/dlaas_dev/s3_tester:mgarod`

## Running the Experiment
To run a single DaemonSet: `./run_ds.sh`

To run two DaemonSets, uncomment line 4: `# kubectl apply -f daemon_set2.yml;` in `run_ds.sh`, then run `./run_ds.sh`

## Log files
The script will create 2 log files both containing the timestamp at time of execution, but one prefixed with `clean_`. The unprefixed log is the full log file, effectively `kubectl logs $POD` for every pod launched. The prefixed clean log file is simplified to contain only nodes external IP addresses, followed by their results.

If a node is not followed by a speed, that pod failed to run. Refer to the full log file for details.

## Results - Jan 25th, 2018
Run one daemonset on all cruiser13 nodes (Thu Jan 25 11:57:12 EST 2018)

```
10.176.86.132 284 MB/s
10.176.86.136 320 MB/s
10.176.86.142 down
10.176.86.143 249 MB/s
10.176.86.144 322 MB/s
10.176.86.146 337 MB/s
10.176.86.148 230 MB/s
10.176.86.151 354 MB/s
10.176.86.157 298 MB/s
10.176.86.161 231 MB/s
10.176.86.162 236 MB/s
10.176.86.174 240 MB/s
10.176.86.179 335 MB/s
10.176.86.180 237 MB/s
10.176.86.184 259 MB/s
10.176.86.187 down

mean: 280.86
stdev: 45.68
```

Run two daemonsets on all cruiser13 nodes (Thu Jan 25 12:33:44 EST 2018)

```
10.176.86.132 100 MB/s
10.176.86.132 102 MB/s
10.176.86.136 150 MB/s
10.176.86.136 197 MB/s
10.176.86.142 down
10.176.86.142 down 
10.176.86.143 0 MB/s
10.176.86.143 183 MB/s
10.176.86.144 139 MB/s
10.176.86.144 147 MB/s
10.176.86.146 213 MB/s
10.176.86.146 230 MB/s
10.176.86.148 113 MB/s
10.176.86.148 96 MB/s
10.176.86.151 173 MB/s
10.176.86.151 176 MB/s
10.176.86.157 136 MB/s
10.176.86.157 141 MB/s
10.176.86.161 103 MB/s
10.176.86.161 137 MB/s
10.176.86.162 121 MB/s
10.176.86.162 162 MB/s
10.176.86.174 105 MB/s
10.176.86.174 96 MB/s
10.176.86.179 0 MB/s
10.176.86.179 310 MB/s
10.176.86.180 73 MB/s
10.176.86.180 75 MB/s
10.176.86.184 149 MB/s
10.176.86.184 162 MB/s
10.176.86.187 down
10.176.86.187 down

mean: 135.32
stdev: 63.52
```
