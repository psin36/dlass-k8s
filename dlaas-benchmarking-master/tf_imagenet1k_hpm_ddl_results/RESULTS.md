# DLaaS DDL Benchmarking 

## Environment information:

| Stack      | March Beta | Future|
|:-----------:|:------------:|:-------:|
| Firmware  | x86/NA          |       |
| OS        | Ubuntu 16.04|       |
| Nvidia Driver| 384.111 | |
| CUDA   | 9.0 | |
| cuDNN| 7.0 | |
| nccl | 1.3.x |  |
| MPI | OpenMPI 3.0.0 | |
| TensorFlow | 1.5 | |
| Kub| 1.8.6 | |


## Overview of the experiments:

Below we are conducting three classes of benchmarks.
1. First class is to ensure that the DDL implementation achieves the final accuracy reported in various
papers.
2. Second class, with synthetic data, is to study the networking (Calico and Host) overhead as we scale to multiple GPUs and nodes.
3. And third class, with real data, to understand the scalability with number of GPUs.

All of these experiments use modified [tf_cnn_benchmarks](https://github.ibm.com/mldlppc/TensorFlow-BLC/tree/master-powerai/scripts/hpm_v2_ddl)  code with DDL integration. The results
are using 1, 2, 4, and 8 machines (2 GPUs each) and use Tensorflow 1.5.  The endpoint for object store is: https://s3-api.dal-us-geo.objectstorage.service.networklayer.com, bucket imagenet-tfrecord, and imagenet1k data in tfrecord format.

## Experiments to evaluate end-to-end scaling performance with real data from COS:

All experiments are with Resnet50, TF1.5, DDL, S3FS driver, fixed per GPU batch size 128. They ran only for a few hundred batches.

| Description |  Cluster | processing rate | Scaling efficiency | Pointer to details | Notes |
|-------------|---------|-----------------|-----------------|--------------------| -------- |
| 1 P100  | Prod Cruiser5 | 226 images/sec |  100% | [details](training-log-1GPU.txt)   |
| 2 P100  | Prod Cruiser5 | 426 images/sec | 95% | [details](training-log-2GPUs.txt) |  |
| 4 P100  | Prod Cruiser5 |  704 images/sec | 77% |[details](training-log-4GPUs_rankfile.txt)  | Calico |
| 8 P100  | Prod Cruiser5 |  1368 images/sec | 76% | [details](training-log-8GPUs.txt) |Caclio  |
| 16 P100  | Prod Cruiser5 |  2576 images/sec | 71% | [details](trainining-log-16GPUs.txt) | Calico |


<!-- | 4 P100 (fp16)  | Cruiser10 |  796 images/sec | 88% |[details](training-log-4GPUs-pipe2pack1.txt)  | FP16 uses pack  | -->
<!-- | 8 P100 (fp16)| Cruiser10 |  1549 images/sec | 86% | [details](training-log-8GPUs-pipe2pack1.txt) |  FP16 uses pack | -->
<!--| 16 P100 (fp16) | Cruiser10 |  2928 images/sec | 81% | [details](training-log-16GPUs-pipe2pack1.txt) |  FP16 uses pack | -->

## Experiments for final accuracy:

All experiments are with s3fs, total batch size of 256.

| Description | Cluster | processing rate | top-1 | top-5 | Pointer to details |
|-------------|---------|-----------------|--------|---------|--------------------|
| P100, Resnet50, 2GPUs, batch128  | Cruiser5 | 329 images/sec | 0.7318 | 0.9107 | [training log](training-log-2GPUs-resnet50-128bs-final-accuracy-lr0.1v1.txt) [Evaluation log](evaluation-log-2GPUs-resnet50-128bs-final-accuracy-lr0.1.txt); Note: 2 GPUs on 2 different systems|
| P100, Resnet50, 4GPUs, batch64  | Cruiser10 |  658 images/sec |0.7369  | 0.9144  | [details](training-log-4GPUs-resnet50-final-accuracy-lr0.1v1.txt) |
| P100, Resnet50, 8GPUs, batch32  | Cruiser10 | 744 images/sec | 0.6485  | 0.8624 | [details](training-log-8GPUs-resnet50-final-accuracy-lr0.1v3.txt). Requires experimentation with different learning rate schedules.  |
| P100, VGG16, 8GPUs, batch32  | Cruiser10 | 213 images/sec | 0.6123 | 0.8300 | [details](training-log-8GPUs-VGG16-final-accuracy-lr0.01v3.txt). Requires experimentation with different learning rate schedules. VGG is about 500MB so the communication adds a significant overhead impacting scalablity. |


## Experiments to evaluate network scalability with synthetic data:

All experiments are with Resnet50, TF1.4, DDL, Cruiser10 cluster. They ran only for a few hundred batches.


| Description |  processing rate | Network |  Scaling efficiency | Pointer to details |
|-------------|---------|-----------------|-----------------|--------------------|
| 1 P100  | 220 images/sec | Calico | 100% |  |
| 2 P100  | 424 images/sec | Calico | 95% |  |
| 4 P100  | 652 images/sec | Calico | 74% |  |
| 8 P100  | 1240 images/sec | Calico | 70% | In this experiment, nodes were in two different subnets, causing calico to encapsulate traffic and reduce the bandwidth  |
| 1 P100  | 220 images/sec | Host | 100% |  |
| 2 P100  | 436 images/sec | Host | 99% |  |
| 4 P100  | 764 images/sec | Host | 87% |  |
| 8 P100  | 1408 images/sec | Host | 80% |  |

Next steps: Armada team has found that using multiple streams for communication, an application can use the full 20Gbps bandwidth of the dual
bonded network. Through experimentation, I found that we might be able to get better bandwidth by using these parameters with MPI: `-mca btl_tcp_sndbuf 13107200 -mca btl_tcp_rcvbuf 13107200  -mca btl_tcp_links 16 `. Update OpenMPI to 3.0 and repeat the tests with the optimization parameters.



Next steps: Need Cruiser13 and optimize COS S3FS driver to continue these experiments


=============old information, kept for reference=====================
This repository consists of the benchmark code, experiments conducted and pointers to the results. 

For each experiments, please provide the following information:
 - Experiment description (e.g., DDL with 2 nodes, 4 GPUs to test COS S3FS)
 - Time (GMT)
 - Local disk, NFS or COS. If COS, COS end point
 - Workload being run (e.g., pointer to code)
 - Name of the cruiser cluster
 - Is the cluster behind a vyatta or not?
 - Number of servers
 - IP/DNS of server(s)
 - Pointer to the server nodes with information such as (RAM, CPUs, GPUs, NICs, etc)
 - Results
 - Expected results
 - s3fs configuration
 - Description of data being accessed (bucket, # of objects, size)
 - Brief description of the summary of the experiment 

Experiments:

| Description | Time (GMT) | Storage options (Local, NFS, COS) | workload | Cluster | #of servers | IPs/DNS | Pointer to cluster info | Pointer to results | Expected results | s3fs config | input data set (bucket, # of objects, size) | Briefy summary and next steps |
|--------------|---------|-------------------------------------|----------|---------|-------------|---------|-------------------------|--------------------|--------------------|-----------|---------------------------------------------|------------------------------|
| 1 Node, 1GPU, w. S3FS+TF Native | 1/29/2018: 8:35PM GMT | COS w S3FS | TF1.4+ResNet50 | Cruiser10 | 1 | IP: don't know | https://github.ibm.com/alchemy-netint/network-source/blob/86bd716d38b2f4eabf361091d4e8c32665d7d865/softlayer-data/Acct366226/devices.csv#L47 | imagenet-ddl-results/training-mAAWKMCzg/learner-1/training-logs.txt | Scale as good as local disk | default s3fs config | imagenet-tfrecord | Throughput is 188 images/s, expected 220 images/s. GPU utilization: 83% (see imagenet-ddl-results/training-nGrDnkjkR/nvidia-smi-out.txt). Requires further investigation |
| 1 Node, 2GPU, w. S3FS+DDL | 1/28/2018: 12:35PM GMT | COS w S3FS | DDL+TF1.4+ResNet50 | Cruiser10 | 1 | IP: 10.177.1.181 | https://github.ibm.com/alchemy-netint/network-source/blob/86bd716d38b2f4eabf361091d4e8c32665d7d865/softlayer-data/Acct366226/devices.csv#L47 | imagenet-ddl-results/training-nGrDnkjkR/learner-1/training-logs.txt | Scale as good as local disk | default s3fs config | imagenet-tfrecord | Throughput is about 140 images/s, expected 220 images/s. Low GPU utilization (see imagenet-ddl-results/training-nGrDnkjkR/nvidia-smi-logfile). Requires further investigation |


All results are stored in softlayer object store.

```
      auth_url: https://s3-api.us-geo.objectstorage.service.networklayer.com
      user_name: idd4n47KjaNrJ891JE6S
      password: TPqhRQQGaYW5Ew3qpVT4CdYJhJ1lJgpIYhJPY5Yt
```
