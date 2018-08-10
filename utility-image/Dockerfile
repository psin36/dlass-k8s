FROM ubuntu:16.04
MAINTAINER Andres Villa <andresfvilla88@gmail.com>

#Install dependencies
#This is used to generate load on the clients

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
     ansible \
     curl \
     default-jre \
     default-jdk \
     dnsutils \
     iperf \
     iputils-ping \
     kmod \
     mtr \
     netcat \
     nginx \
     nodejs \
     npm \
     openssh-server \
     python \
     python-pip \
     vim \
     wget \
    && rm -rf /var/lib/apt/lists/*

#Install Node 9.x
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -
RUN apt-get update \
    &&apt-get install --no-install-recommends -y \
     nodejs \
    && rm -rf /var/lib/apt/lists/*

#requires unsafe due to npm having permission problems from "unnamed" user
RUN npm install -g grpcc --unsafe

#Upgrade pip
RUN pip install --upgrade pip

CMD ["tail", "-F", "-n0", "/etc/hosts"]
