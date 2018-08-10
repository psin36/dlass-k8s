
sh parse_tf.sh 1GPU_30CPU_9G | grep -v "mcos" | grep V100
sh parse_tf_mcos.sh 1GPU_30CPU_9G | grep "mcos" | grep V100
#sh parse_tf.sh 1GPU_30CPU_9G | grep "mcos" | grep V100
#sh parse_tf.sh 2GPU_24CPU_9G | grep "mcos" | grep V100
#sh parse_tf.sh 2GPU_30CPU_9G | grep "mcos" | grep V100
