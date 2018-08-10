# This gets built as registry.ng.bluemix.net/dlaas_dev/dlaas-benchmarking:latest

FROM tensorflow/tensorflow:1.5.0-gpu
MAINTAINER Benjamin Herta <bherta@us.ibm.com>

RUN apt-get update && apt-get install -y vim curl htop sysstat nethogs git \
    && rm -rf /var/lib/apt/lists/*

RUN cd /opt && git clone https://github.com/tensorflow/benchmarks.git --recursive --depth 1 -b cnn_tf_v1.5_compatible

ADD benchmarkpreprocess.patch /tmp/benchmarkpreprocess.patch
RUN cd /opt/benchmarks && patch -p 1 < /tmp/benchmarkpreprocess.patch && rm /tmp/benchmarkpreprocess.patch

WORKDIR /opt/benchmarks/
