classdef JobList < handle
    properties
        job_fns
    end
    properties%(SetAccess = immutable)
        queue_path
        queue_tmp_path
        L
    end
    methods
        function obj = JobList(queue_path,queue_tmp_path,L)
            if(nargin<1||isempty(queue_path))
                [mfilepath]=fileparts(mfilename('fullpath'));
                obj.queue_path = fullfile(mfilepath,'queue');
            else
                obj.queue_path = queue_path;
            end
            if(nargin<2||isempty(queue_tmp_path))
                if(isunix)
                    obj.queue_tmp_path = fullfile('/dev/shm/', regexp(mfilepath,'[/\\].*','once','match'),'queue');
                else
                    obj.queue_tmp_path = fullfile(tempdir, regexp(mfilepath,'[/\\].*','once','match'),'queue');
                end
            else
                obj.queue_tmp_path = queue_tmp_path;
            end
            if(nargin<3)
                obj.L = Logger();
            else
                obj.L = L;
            end
            rng shuffle
            warning off;
            mkdir(obj.queue_tmp_path);
            mkdir(fullfile(obj.queue_tmp_path,'processing'));
            mkdir(fullfile(obj.queue_tmp_path,'done'));
            mkdir(fullfile(obj.queue_tmp_path,'error'));
            warning on;
        end
        function renew(obj)
            if(~java.io.File(obj.queue_tmp_path).exists)
                mkdir(obj.queue_tmp_path);
            end
            [obj.job_fns] = fastdir(obj.queue_tmp_path,'\.mat$');
        end
        function [ffn, s] = run_next_job(obj)
            while(numel(obj.job_fns)>0 && ...
                    ~java.io.File(fullfile(obj.queue_tmp_path,obj.job_fns{1})).exists)
                obj.job_fns(1)=[];
            end
            if(isempty(obj.job_fns))
                obj.renew();
                obj.L.newline('Read file list.');
            end
            if(isempty(obj.job_fns))
                ffn = '';
                s = 0;
                return;
            end
            
            ffn = fullfile(obj.queue_tmp_path,obj.job_fns{1});
            ffn_processing = fullfile(obj.queue_tmp_path,'processing',obj.job_fns{1});
            ffn_done = fullfile(obj.queue_tmp_path,'done',obj.job_fns{1});
            ffn_error = fullfile(obj.queue_tmp_path,'error',obj.job_fns{1});
            ffn_delete = '';%fullfile(obj.queue_path,obj.job_fns{1});
            
            s = run_job(ffn,ffn_processing,ffn_done,ffn_error,ffn_delete,obj.L, {obj.queue_tmp_path,fullfile(obj.queue_tmp_path,'processing')}); %0:fail, 1:succeed, 2:error
            obj.job_fns(1) = [];
        end
    end
end
