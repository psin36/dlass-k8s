#!/usr/bin/env bash

is_job_complete()
{
trainingid=$(echo "$1" | grep -o "training-[a-zA-Z0-9\_\-]*")
show="$(dlaas status ${trainingid})"
status="$(echo ${show} | grep -o 'Status_[a-zA-Z0-9]*')"
completed="$(echo ${status} | grep -c 'COMPLETED')"
failed="$(echo $status | grep -c 'FAILED')"
while [[ ${completed} -eq 0  &&  ${failed} -eq 0 ]]
do
    show="$(dlaas status ${trainingid})"
    echo "$trainingid"
    status="$(echo ${show} | grep -o 'Status_[a-zA-Z0-9]*')"
    completed="$(echo $status | grep -c 'COMPLETED')"
    failed="$(echo $status | grep -c 'FAILED')"
    echo "$status"
    sleep 5
done
echo "$status"
return ${completed}
}
(
(resnet50_1gpu="$(dlaas train resnet50-1gpu-batch64.yml tf_cnn_benchmarks.zip)" && is_job_complete "${resnet50_1gpu}") &
(resnet50_2gpu="$(dlaas train resnet50-2gpu-batch64.yml tf_cnn_benchmarks.zip)" && is_job_complete "${resnet50_2gpu}") &
(resnet152_1gpu="$(dlaas train resnet152-1gpu-batch64.yml tf_cnn_benchmarks.zip)" && is_job_complete "${resnet152_1gpu}") &
(resnet152_2gpu="$(dlaas train resnet152-2gpu-batch64.yml tf_cnn_benchmarks.zip)" && is_job_complete "${resnet152_2gpu}") & wait) &&
(
(vgg16_1gpu="$(dlaas train vgg16-1gpu-batch64.yml tf_cnn_benchmarks.zip)" && is_job_complete "${vgg16_1gpu}") &
(vgg16_2gpu="$(dlaas train vgg16-2gpu-batch64.yml tf_cnn_benchmarks.zip)" && is_job_complete "${vgg16_2gpu}") &
(alexnet_1gpu="$(dlaas train alexnet-1gpu-batch64.yml tf_cnn_benchmarks.zip)" && is_job_complete "${alexnet_1gpu}") &
(alexnet_2gpu="$(dlaas train alexnet-2gpu-batch64.yml tf_cnn_benchmarks.zip)" && is_job_complete "${alexnet_2gpu}") & wait
) &&
(
(vgg16_1gpu="$(dlaas train inception3-1gpu-batch64.yml tf_cnn_benchmarks.zip)" && is_job_complete "${vgg16_1gpu}") &
(vgg16_2gpu="$(dlaas train inception3-2gpu-batch64.yml tf_cnn_benchmarks.zip)" && is_job_complete "${vgg16_2gpu}")
)