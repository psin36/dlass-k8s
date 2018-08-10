All of these use the [tf_cnn_benchmarks code](https://github.com/tensorflow/benchmarks/tree/cnn_tf_v1.5_compatible/scripts/tf_cnn_benchmarks), with various configurations to match [previously published data](https://www.tensorflow.org/performance/benchmarks), and to compare mounted COS vs local disk in DLaaS

All results are single machine (1 or 2 GPUs), and use TensorFlow 1.5
All tests used the endpoint `https://s3-api.dal-us-geo.objectstorage.service.networklayer.com`, bucket `imagenet-tfrecord`, and imagenet1k data in tfrecord format
The benchmark code has been [patched](https://github.ibm.com/deep-learning-platform/dlaas-benchmarking/blob/master/tfbenchmark_kubestack/benchmarkpreprocess.patch) from its original form. 

Experiments:

| Description | Cluster | processing rate | GPU utilization | Pointer to details | 
|-------------|---------|-----------------|-----------------|--------------------|
| P100, Resnet50, batch128, Local disk | Cruiser10 | 224 images/sec | | [details](localdisk_batch128.results) |
| P100, Resnet50, batch128, S3FS | Cruiser10 | 185 images/sec | | [details](initial_mountcos.results) |
| P100, Resnet50, batch64, Local disk | Cruiser10 | 217 images/sec | | [details](1GPU_localdisk.results) |
| P100, Resnet50, batch64, S3FS | Cruiser10 | 213 images/sec | | [details](1GPU_mountcos.results) |
| P100, Resnet50, batch64, NFS | Cruiser10 | 217 images/sec | | [details](1GPU_NFS.results) |
| 2xP100, Resnet50, batch64, Local disk | Cruiser10 |  402 images/sec | | [details](2GPU_localdisk.results) |
| 2xP100, Resnet50, batch64, S3FS | Cruiser10 | 387 images/sec | | [details](2GPU_mountcos.results) |
| 2xP100, Resnet50, batch64, NFS | Cruiser10 | 401 images/sec | | [details](2GPU_NFS.results) |
| P100, Resnet50, batch64, S3FS | Cruiser13 | 218.50 images/sec | | [details](Resnet50_1gpu_mountcos_batch64.results) |
| 2xP100, Resnet50, batch64, S3FS | Cruiser13 | 408.41 images/sec | | [details](Resnet50_2gpu_mountcos_batch64.results ) |
| P100, VGG16, batch64, S3FS | Cruiser13 | 143.27 images/sec | | [details](VGG16_1GPU_mountcos_batch64.results) |
| 2xP100, VGG16, batch64, S3FS | Cruiser13 | 252.45 images/sec | | [details](VGG16_2GPU_mountcos_batch64.results) |
| P100, Alexnet, batch64, S3FS | Cruiser13 | 1206.17 images/sec | | [details](Alexnet_1GPU_mountcos_batch64.results) |
| 2xP100, Alexnet, batch64, S3FS | Cruiser13 | 1418.86 images/sec | | [details](Alexnet_2GPU_mountcos_batch64.results)  |
| P100, Resnet152, batch64, S3FS | Cruiser13 | 141.28 images/sec | | [details](Resnet152_1gpu_mountcos_batch64.results) |
| 2xP100, Resnet152, batch64, S3FS | Cruiser13 | 264.16 images/sec | | [details](Resnet152_2gpu_mountcos_batch64.results) |
| P100, Resnet50, batch64, S3FS | Cruiser5 | 203.64 images/sec | | [details](Resnet50_1gpu_batch64_cruiser5.results) |
| 2xP100, Resnet50, batch64, S3FS | Cruiser5 | 386.23 images/sec | | [details](Resnet50_2gpu_batch64_cruiser5.results) |
| P100, VGG16, batch64, S3FS | Cruiser5 | 142.75 images/sec | | [details](Vgg16_1gpu_batch64_cruiser5.results) |
| 2xP100, VGG16, batch64, S3FS | Cruiser5 | 249.75 images/sec | | [details](Vgg16_2gpu_batch64_cruiser5.results) |
| P100, Alexnet, batch64, S3FS | Cruiser5 | 137.46 images/sec | | [details](Alexnet_1gpu_batch64_cruiser5.results) |
| 2xP100, Alexnet, batch64, S3FS | Cruiser5 | 977.13 images/sec | | [details](Alexnet_2gpu_batch64_cruiser5.results)  |
| P100, Resnet152, batch64, S3FS | Cruiser5 | 91.54 images/sec | | [details](Resnet152_1gpu_batch64_cruiser5.results) |
| 2xP100, Resnet152, batch64, S3FS | Cruiser5 | 173.26 images/sec | | [details](Resnet152_2gpu_batch64_cruiser5.results) |
| P100, Resnet152, batch64, S3FS, Synthetic data | Cruiser13 | 92.45 images/sec | | [details](Resnet152_1gpu_mountcos_batch64_synthetic.results) |
| 2xP100, Resnet152, batch64, S3FS, Synthetic data | Cruiser13 | 177.28 images/sec | | [details](Resnet152_2gpu_mountcos_batch64_synthetic.results) |
| P100, Resnet50, batch64, S3FS, Synthetic data | Cruiser13 | 345.94 images/sec | | [details](Resnet50_1gpu_mountcos_batch64_synthetic.results) |
| 2xP100, Resnet50, batch64, S3FS, Synthetic data | Cruiser13 | 433.39 images/sec | | [details](Resnet50_2gpu_mountcos_batch64_synthetic.results) |
| P100, Vgg16, batch64, S3FS, Synthetic data | Cruiser13 | 218.76 images/sec | | [details](Vgg16_1gpu_moutcos_batch64_synthetic.results) |
| 2xP100, Vgg16, batch64, S3FS, Synthetic data | Cruiser13 | 257.34 images/sec | | [details](VGG16_2gpu_mountcos_batch64_synthetic.results) |
| P100, Alexnet, batch64, S3FS, Synthetic data | Cruiser13 | 3178.20 images/sec | | [details](Alexnet_1gpu_mountcos_batch64_synthetic.results) |
| 2xP100, Alexnet, batch64, S3FS, Synthetic data | Cruiser13 | 2896.47 images/sec | | [details](Alexnet_2gpu_mountcos_batch64_synthetic.results) |