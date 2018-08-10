#!/usr/bin/env bash
function main() {
    kubectl apply -f daemon_set.yml;
    # kubectl apply -f daemon_set2.yml;
    # 60s for scripts to run + 120s to allow for connection errors
    echo "sleeping 180 seconds...";
    sleep 180;

    # Create the raw log file
    TIMESTAMP=$(date | tr -d ' ');
    TIMESTAMP=${TIMESTAMP//:/_};
    FILENAME="$TIMESTAMP.log";
    echo $TIMESTAMP > $FILENAME;

    PODS=$(kubectl get po -o wide | grep ^s3-ds | awk '{print $1","$7}')
    for x in $PODS; do
        POD=$(echo $x | cut -f1 -d,);
        NODE=$(echo $x | cut -f2 -d,);
        echo $NODE | tee -a $FILENAME;
        kubectl logs po/$POD | tee -a $FILENAME;
    done
    # This is the reduced log, with only node names and result
    CLEAN="clean"_$FILENAME;
    grep -e '^10' -e 'MB/s' $FILENAME | tee -a $CLEAN;
}

function cleanup() {
    DSETS=$(kc get ds | grep ^s3-ds | awk '{print $1}' | xargs);
    kc delete ds DSETS;
    # If a pod is run on a downed node, it will hang up on termination
    kc delete po -l app=s3-ds --grace-period=0 --force;
}

main
cleanup
