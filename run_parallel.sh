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

$DIR/job_scheduler/sync.py

QUEUEDIR="$DIR/job_scheduler/queue"
/bin/mkdir -p $QUEUEDIR
/bin/mkdir -p /dev/shm$QUEUEDIR
DONEDIR="$DIR/job_scheduler/queue/done"
/bin/mkdir -p $DONEDIR
ARCHIVEDIR="$DIR/job_scheduler/queue/archive"
/bin/mkdir -p $ARCHIVEDIR
PROCESSINGDIR="$DIR/job_scheduler/queue/processing"
/bin/mkdir -p $PROCESSINGDIR


if [ "$(ls -A $DONEDIR)" ]; then
	echo "Archiving"
	/bin/mv $DONEDIR $ARCHIVEDIR/$DATE
	/bin/mkdir -p $DONEDIR
	/bin/tar -cf $ARCHIVEDIR/$DATE.tar -C $ARCHIVEDIR $DATE --remove-files
fi

echo "Starting $NUM Matlabs"
for i in $(seq $NUM)
do
    echo "Starting MATLAB addpath $DIR;addpath_aki;run_queued_jobs;exit"
	/bin/sleep 5 
    /usr/local/bin/matlab -nodesktop -nosplash -singleCompThread -r "addpath $DIR;addpath_aki;run_queued_jobs;exit" &
done

