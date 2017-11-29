#!/usr/bin/python
import os, errno,shutil,inspect 

def silent_makedirs(path):
    try:
        os.makedirs(path)
    except EnvironmentError as e:
        if e.errno != errno.EEXIST:
            raise

def silent_move(src,dst):
    try:
        print 'moving', src, dst
        shutil.move(src,dst)
    except EnvironmentError as e:
        if e.errno != errno.ENOENT:
            raise

def silent_copy2(src,dst):
    try:
        print 'coping', src, dst
        shutil.copy2(src,dst)
    except EnvironmentError as e:
        if e.errno != errno.ENOENT:
            raise

def silent_listdir(path):
    try:
        return os.listdir(path)
    except EnvironmentError as e: 
        if e.errno != errno.ENOENT:
            raise
        else:
            return []

parent_dir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe()))) # script directory

queue_dir = os.path.join(parent_dir,'queue')
done_dir = os.path.join(queue_dir,'done')
error_dir = os.path.join(queue_dir,'error')

tmp_queue_dir = '/dev/shm'+queue_dir
tmp_processing_dir = os.path.join(tmp_queue_dir,'processing')
tmp_done_dir = '/dev/shm'+done_dir
tmp_error_dir = '/dev/shm'+error_dir

silent_makedirs(queue_dir)
silent_makedirs(done_dir)
silent_makedirs(tmp_queue_dir)
silent_makedirs(tmp_processing_dir)
silent_makedirs(tmp_done_dir)

# delete from /dev/shm if the original is deleted
for fn in silent_listdir(tmp_queue_dir):
    if(fn.endswith('.mat')):
        queue_ffn = os.path.join(queue_dir,fn)
        tmp_queue_ffn = os.path.join(tmp_queue_dir,fn)
        if(not(os.path.isfile(queue_ffn))):
            print 'removing', tmp_queue_ffn
            try:
                os.remove(tmp_queue_ffn)
            except EnvironmentError as e:
                if e.errno ==  errno.ENOENT:
                    print 'no file:', tmp_queue_ffn
                elif e.errno == errno.EPERM:
                    print 'cannot remove:', tmp_queue_ffn
                else:
                    print 'ERROR', e

# move done jobs
for fn in silent_listdir(tmp_done_dir):
    if fn.endswith('.mat'):
        queue_ffn = os.path.join(queue_dir,fn)
        done_ffn = os.path.join(done_dir,fn)
        tmp_done_ffn = os.path.join(tmp_done_dir,fn)
        print 'moving', tmp_done_ffn, done_ffn
        try:
            shutil.move(tmp_done_ffn,done_ffn)
        except EnvironmentError as e:
            if e.errno == errno.ENOENT:
                print 'no file:', tmp_done_ffn
            elif e.errno == errno.EPERM:
                print 'cannot overwrite:', done_ffn
            else:
                print 'Error', e
            continue
        print 'removing', queue_ffn
        try:
            os.remove(queue_ffn)
        except EnvironmentError as e:
            if e.errno ==  errno.ENOENT:
                print 'no file:', queue_ffn
            elif e.errno == errno.EPERM:
                print 'cannot remove:', queue_ffn
            else:
                print 'ERROR', e

for fn in silent_listdir(tmp_error_dir):
    if fn.endswith('.mat'):
        queue_ffn = os.path.join(queue_dir,fn)
        error_ffn = os.path.join(error_dir,fn)
        tmp_error_ffn = os.path.join(tmp_error_dir,fn)
        print 'moving', tmp_error_ffn, error_ffn
        try:
            shutil.move(tmp_error_ffn,error_ffn)
        except EnvironmentError as e:
            if e.errno == errno.ENOENT:
                print 'no file:', tmp_error_ffn
            elif e.errno == errno.EPERM:
                print 'cannot overwrite:', error_ffn
            else:
                print 'Error', e
            continue
        print 'removing', queue_ffn
        try:
            os.remove(queue_ffn)
        except EnvironmentError as e:
            if e.errno ==  errno.ENOENT:
                print 'no file:', queue_ffn
            elif e.errno == errno.EPERM:
                print 'cannot remove:', queue_ffn
            else:
                print 'ERROR', e

# copy if not in /dev/shm/queue, /dev/shm/processing, /dev/shm/done (checking order is important)
for fn in silent_listdir(queue_dir):
    if(fn.endswith('.mat')):
        queue_ffn = os.path.join(queue_dir,fn)
        done_ffn = os.path.join(done_dir,fn)
        error_ffn = os.path.join(error_dir,fn)
        tmp_queue_ffn = os.path.join(tmp_queue_dir,fn)
        tmp_processing_ffn = os.path.join(tmp_processing_dir,fn)
        tmp_done_ffn = os.path.join(tmp_done_dir,fn)
        tmp_error_ffn = os.path.join(tmp_error_dir,fn)
        if(not(os.path.isfile(tmp_queue_ffn) or os.path.isfile(tmp_processing_ffn)
                or os.path.isfile(tmp_done_ffn) or os.path.isfile(tmp_error_ffn)
                or os.path.isfile(done_ffn)) or os.path.isfile(error_ffn)):
            silent_copy2(queue_ffn,tmp_queue_ffn)


