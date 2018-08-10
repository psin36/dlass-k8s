FROM andresvilla/utility-image:latest
MAINTAINER Andres Villa <andresfvilla88@gmail.com>
#Install cuda
COPY cuda-repo-ubuntu1604_9.0.176-1_amd64.deb /opt/cuda-repo-ubuntu1604_9.0.176-1_amd64.deb

RUN dpkg -i /opt/cuda-repo-ubuntu1604_9.0.176-1_amd64.deb \
    && apt-get update \
    && apt-get install -y --allow-unauthenticated \
     cuda \
    && rm -rf /var/lib/apt/lists/*

CMD ["tail", "-F", "-n0", "/etc/hosts"]
