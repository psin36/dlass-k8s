FROM tensorflow/tensorflow:nightly-gpu-py3
#FROM tensorflow/tensorflow:1.4.0-gpu-py3
#the latest TF version that we support

RUN apt-get update && apt-get install -y vim curl htop sysstat nethogs

RUN mkdir -p /root/data
COPY data/benchmarks.tar /root/data/benchmarks.tar
RUN cd /root/data/ && tar -xvf benchmarks.tar
WORKDIR /root/data/benchmarks/

