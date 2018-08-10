FROM jfloff/alpine-python:2.7

ADD s3_tester.py /
ADD s3_tester_1min.py /

ENTRYPOINT [ "python", "./s3_tester_1min.py" ]
