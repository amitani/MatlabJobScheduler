function s = run_job(ffn,ffn_processing,ffn_done,ffn_error,ffn_delete,L,ffn_watch)
    [pathstr,fn_root,ext]=fileparts(ffn);
    fn=[fn_root ext];
    if(nargin < 2 || isempty(ffn_processing))
        ffn_processing = fullfile(pathstr,'processing',fn);
    end
    if(nargin < 3 || isempty(ffn_done))
        ffn_done = fullfile(pathstr,'done',fn);
    end
    if(nargin < 4 || isempty(ffn_error))
        ffn_error = fullfile(pathstr,'error',fn);
    end
    if(nargin < 5)
        ffn_delete = '';
    end
    if(nargin < 6)
        L = Logger();
    end
    if(nargin < 7)
        ffn_watch = {};
    end
    if(ischar(ffn_watch))
        ffn_watch = {ffn_watch};
    end
    
    s = fastmovefile(ffn,ffn_processing);
    if(~s)
        return;
    end
    
    L.newline('Job started:  %s\n',ffn_processing);
    job=load(ffn_processing);
    
    job.pid = feature('getpid');
    job.time_started = datestr(now,'yyyy-mm-dd-HH-MM-SS-FFF');
    
    if(~isfield(job,'jobs_to_wait'))
        job.jobs_to_wait = {};
    end
    
    L.newline('Job loaded.\n');
    
    undone = false;
    if(~isempty(job.jobs_to_wait) && ~isempty(ffn_watch))
        interval = 0.5;
        max_trial = 100;
        
        for t=1:max_trial
            undone = false;
            for i=1:length(ffn_watch)
                undone_job_fns = fastdir(ffn_watch{i},'\.mat$');
                for j=1:length(undone_job_fns)
                    undone_job_fn = undone_job_fns{j};
                    for k=1:length(job.jobs_to_wait)
                        job_to_wait = job.jobs_to_wait{k};
                        if(~isempty(strfind(undone_job_fn,job_to_wait)))
                            undone = true;
                            L.newline('Jobs not finished. %s, %s, %s, %s',...
                                 ffn_processing, job_to_wait, undone_job_fn, ffn_watch{i});
                            break;
                        end
                    end
                    if(undone)
                        break;
                    end
                end
                if(undone)
                    break;
                end
            end
            
            if(undone)
                L.newline('Jobs not finished. %s',ffn_processing);
                if(t<max_trial)
                    pause(interval*60);
                end
            else
                L.newline('Jobs finished. %s',ffn_processing);
                break;
            end
        end
    end
    
    if(undone)
        output = 'Required jobs not finished.';
        s = 2;
        ffn_final = ffn_error;
    else
        try
            output=evalc(sprintf('%s(job.args{:})',job.func));
            s = 1;
            ffn_final = ffn_done;
        catch err
            output = err;
            s = 2;
            ffn_final = ffn_error;
        end
        L.newline('Job executed. %s',ffn_processing);
    end
    
    job.output = output;
    job.time_ended = datestr(now,'yyyy-mm-dd-HH-MM-SS-FFF');
    
    save(ffn_processing,'-struct','job','-v6');
    
    if(~fastmovefile(ffn_processing,ffn_final))
        warning('Could not move finished job file');
    else
        if(~isempty(ffn_delete))
            delete(ffn_delete);
        end
        L.newline('Done. Saved and Moved to %s\n',ffn_final);
    end
end
