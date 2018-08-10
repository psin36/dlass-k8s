# Utility-Image

A Docker image that contains useful tools for debugging/testing micro-services and applications

## Included Packages

1. ansible - automation tool
1. curl - basic http requests
1. dnsutils - includes things like nslookup for dns debugging
1. grpcc - [grpc cli](https://github.com/njpatel/grpcc)
1. iperf - network performance measurement and tuner
1. java - for any necessary java apps
1. mtr - investigates connection between host running mtr and another host
1. netcat - Used for writing and reading from network connections
1. nginx - create webserver for testing routing
1. node(v9.3) - for any necessary nodejs apps 
1. nvidia - testing gpu assignments to containers
1. python - used for basic scripts
1. vim - file editor
1. wget - retrieving web content

## Nvidia Image

Due to the cuda packages being very large and increasing the image size by over 3 times, the image is separate and will be 
