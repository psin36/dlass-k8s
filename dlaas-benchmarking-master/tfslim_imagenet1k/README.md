All of these use the [tensorflow-slim code](https://github.ibm.com/deep-learning-platform/dlaas-benchmarking/blob/master/tfslim_imagenet1k/tfslim.zip?raw=true), with various configurations, to compare mounted COS vs local disk in DLaaS

All results are single machine (1 or 2 GPUs), and use TensorFlow 1.5
All tests used the endpoint `https://s3-api.dal-us-geo.objectstorage.service.networklayer.com`, bucket `imagenet-tfrecord`, and imagenet1k data in tfrecord format 

[Previous experiments](https://github.ibm.com/deep-learning-platform/dlaas-benchmarking/blob/master/tfbenchmark_kubestack/Tensorflow-tshirtsize-DLaaS.pptx?raw=true)

Experiments:

| Description | Cluster | Image processing rate | Pointer to details | 
|-------------|---------|-----------------------|--------------------|
| Resnet50, batch128, Local disk | Cruiser10 | 1.6 step/sec | [details](localdisk_batch128.results) |
| Resnet50, batch128, S3FS | Cruiser10 |  1.6 step/sec | [details](cosmount_batch128.results) |
| Resnet50, batch128, NFS | Cruiser10 |  |  |
