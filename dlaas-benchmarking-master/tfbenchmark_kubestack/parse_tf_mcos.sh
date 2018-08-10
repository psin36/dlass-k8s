#!/bin/bash

#echo "thpt (images/sec)"
#cat $1 | awk 'BEGIN{count=0;sum=0} {if ($5~"Iteration" && $8~"iter/s,") {count=count+1; split($9,a,"s"); sum=sum+a[1]; print a[1]}} END{print count","sum","sum/count;}'
#cat $1 | awk 'BEGIN{count=0;sum=0} {if ($5~"Iteration" && $8~"iter/s,") {count=count+1; split($9,a,"s"); sum=sum+a[1];}} END{print count","sum","sum/count;}'
#array1=($(ls ./*CPU*))
#echo "${array1[@]}"
cd $1
array=($(ls))
#echo "${array[@]}"
len=${#array[@]}
let len=$len-1
#echo $len
i=0
while [ $i -lt $len ]; do
  #echo "$i: ${array[$i]}"
  #echo "We are here0"
  #echo $i
  string=${array[$i]}
  testseq="log"
  if [[ $string == *$testseq* ]]; then
    #echo $string
    pattern="total images/sec:"
    #echo $pattern
    var="cat $string | grep '$pattern'"
    #echo $var
    st=`eval $var`
    #echo "We are here"
    #echo $st
    j="$st $string"
    thpt=$(echo $j | awk '{split($0,a,":"); split(a[2],d," "); split(d[2],b,"_"); split(b[8],c,".log"); gsub (" ", "",d[1]); print b[1]","int(b[2])","int(b[3])","int(b[4])","b[5]","b[6]","b[7]","c[1]","d[1]}')
    #echo "cmd to execute" 
    #echo $cmd
    #eval $cmd
    IFS='.' read -a myarray <<< "$string"
    string1=${myarray[0]}_gpu_usage.txt
    #echo $string1
    #echo "gpu_usage"
    #cat $2 | awk 'BEGIN{count=0; sum=0} {if($13 ~ "%") {sum = sum+ $13; count=count+1;}} END{print count, sum, sum/count}'
    #gpu=$(cat $string1 | awk 'BEGIN{count=0; sum=0} {if($13 ~ "%") {if(set=0 && $13>0){set=1}if(set=1){sum = sum+ $13; count=count+1;}} END{print sum/count}')
    gpu=$(cat $string1 |  awk 'BEGIN{count=0; sum=0; set=0} {if($13 ~ "%") {if(set==0 && int($13)>0.0){set=1}if(set==1){sum = sum+ $13; count=count+1;}}} END{print sum/count}')
    #echo $gpu
    line=$thpt,$gpu
    echo $line
  fi
  ((i++))
  #echo "We are now here"
  #echo $i
done
cd ..
