function job_id = queue_job(func,args,jobs_to_wait)
    % path are just for reference. include addpath in the function, or 
    % ask me to add it to default search path.         Aki 04/24/2014
    if(nargin<2)
        args = {};
    end
    if(~iscell(args))
        args={args};
    end
    if(nargin<3)
        jobs_to_wait = {};
    end
    
    [~, job_id] = fileparts(tempname);
    user_name = char(java.lang.System.getProperty('user.name'));
    nowstr = datestr(now,'yyyy-mm-dd-HH-MM-SS-FFF');
    s=struct('func',{func},...
             'args',{args},...
             'jobs_to_wait',{jobs_to_wait},...
             'path',{''},...
             'pwd',{pwd()},...
             'user',{user_name},...
             'matlabroot',{matlabroot()},...
             'queued_version',{version()},...
             'job_id',{job_id},...
             'time_queued',{nowstr});
    fn_job = [user_name '-' nowstr '-' job_id '.mat'];
    [mfilepath,~]=fileparts(mfilename('fullpath'));
    queue_dir = fullfile(mfilepath,'queue');
    if(~java.io.File(queue_dir).exists)
        mkdir(queue_dir);
    end
    ffn_job=fullfile(queue_dir,fn_job);
    save(ffn_job,'-struct', 's');
end
