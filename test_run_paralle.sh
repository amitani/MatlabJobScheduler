#!/bin/bash
if [ $# -gt 1 ]
then
    DIR=$2
else
    DIR="$( cd -P "$( /usr/bin/dirname "$SOURCE" )" && cd .. && /bin/pwd )"
fi

if [ $# -gt 0 ]
then
    NUM=$1
else
    NUM=12
fi

DATE=$(date +%Y%m%d-%H%M%S)

QUEUEDIR="$DIR/job_scheduler/queue"
DONEDIR="$DIR/job_scheduler/queue/done"
ARCHIVEDIR="$DIR/job_scheduler/queue/archive"
PROCESSINGDIR="$DIR/job_scheduler/queue/processing"


echo "-np $QUEUEDIR/*.mat /dev/shm$QUEUEDIR/"

echo "Starting $NUM Matlabs"
for i in $(seq $NUM)
do
    echo "Starting MATLAB addpath $DIR;addpath_aki;run_queued_jobs;exit"
done

