# MatlabJobScheduler

Job Scheduler written and run in Matlab. 

To schedule jobs, call
 queue_job(function,args)
and
 job_id1=queue_job(function,args)
 job_id2=queue_job(function,args)
 queue_job(function,args,[job_id1 job_id2])
if the jobs have to be run sequentially.

sync.py sync job files to /dev/shm

run_parallel.sh will start multiple matlabs each go through the job files independently.

Inside this, in a unix system, JobList.m checks /dev/shm so call sync.py beforehand, or change JobList.m to check the desired job directory.

Motivation for this is to avoid restarting matlab multiple times with a normal job scheduler because our system Matlab takes a long time to start.

