All results are single machine (1 or 2 GPUs), and use TensorFlow 1.5
All tests used the endpoint `https://s3-api.dal-us-geo.objectstorage.service.networklayer.com`, bucket `imagenet-tfrecord`, and imagenet1k data in tfrecord format
The benchmark code has been [patched](https://github.ibm.com/deep-learning-platform/dlaas-benchmarking/blob/master/benchmarkpreprocess.patch) from its original form. 

Experiments:

| Description | Cluster | processing rate | GPU utilization | Pointer to details | 
|-------------|---------|-----------------|-----------------|--------------------|
| V100, Resnet50, batch64, Local disk | Cruiser10 | 323.94 | 86.086 | [details](1GPU_30CPU_9G/V100_1GPU_30CPU_9G_tf_resnet50_64.log) |
| V100, Resnet50, batch64, S3FS | Cruiser10 | 291.56 | 81.3051 | [details](1GPU_30CPU_9G/V100_1GPU_30CPU_9G_mcos-v1_tf_resnet50_64.log) |
| 2xV100, Resnet50, batch64, S3FS | Cruiser10 | | | |
| V100, VGG16, batch64, Local disk | Cruiser10 | 212.34 | 93.962 | [details](1GPU_30CPU_9G/V100_1GPU_30CPU_9G_tf_vgg16_64.log) |
| V100, VGG16, batch64, S3FS | Cruiser10 | 187.18 | 91.3616 | [details](1GPU_30CPU_9G/V100_1GPU_30CPU_9G_mcos-v1_tf_vgg16_64.log) |
| 2xV100, VGG16, batch64, S3FS | Cruiser10 | | | |
| V100, Inception3, batch64, Local disk | Cruiser10 | 213.65 | 67.922 | [details](1GPU_30CPU_9G/V100_1GPU_30CPU_9G_tf_inception3_64.log) |
| V100, Inception3, batch64, S3FS | Cruiser10 | 200.95 | 90.2671 | [details](1GPU_30CPU_9G/V100_1GPU_30CPU_9G_mcos-v1_tf_inception3_64.log) |
| 2xV100, Inception3, batch64, S3FS | Cruiser10 | | | |
| V100, Alexnet, batch64, Local disk | Cruiser10 | 867.10 | 27.692 | [details](1GPU_30CPU_9G/V100_1GPU_30CPU_9G_tf_alexnet_64.log) |
| V100, Alexnet, batch64, S3FS | Cruiser10 | 838.29 | 21.9111 | [details](1GPU_30CPU_9G/V100_1GPU_30CPU_9G_mcos-v1_tf_alexnet_64.log) |
| 2xV100, Alexnet, batch64, S3FS | Cruiser10 | | | |

Note that there are MANY MORE results not listed in this table.  You can find them in the various subfolders.