#!/bin/bash

framework='tf'
#batch_sizes='1 2 4 8 16 32 64 128'
batch_sizes='64 128'
models='inception3 resnet50 vgg16 alexnet'
#models='resnet50 vgg16 alexnet'
resultdir='/mnt/imagenet-tfrecord-results-pdube-cos/'
gpus=2
for model in $models 
do 
  for batchsize in $batch_sizes
    do 
      out1=${resultdir}P100_${gpus}GPU_16CPU_9G_mcos_${framework}_${model}_${batchsize}_gpu_usage.txt
      out2=${resultdir}P100_${gpus}GPU_16CPU_9G_mcos_${framework}_${model}_${batchsize}.log 
      echo $out1 $out2
      cmd1=coproc nvidia-smi -l 4 > $out1 & 
      cmd2= python scripts/tf_cnn_benchmarks/tf_cnn_benchmarks.py --model=${model} --batch_size=$batchsize --num_batches=2000 --num_gpus=$gpus --data_name=imagenet --print_training_accuracy --data_dir=/mnt/imagenet-tfrecord/ > $out2 
      echo $cmd1 $cmd2 
      eval $cmd2 
      eval $cmd1
      PS=$!
      echo $PS
      kill -9 $PS
    done
done
