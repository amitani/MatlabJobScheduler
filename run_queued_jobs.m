function run_queued_jobs()
	L=Logger();
    
    job_list = JobList('','',L);
    while(1)
        clk=clock;
        time_to_suspend = 8;
        if(clk(4)>=time_to_suspend && clk(4)<time_to_suspend+2)
            L.newline('It''s %d o''clock. Suspending but %d jobs remained.',time_to_suspend,length(job_list.job_fns));
            break;
        end
        
        [job_ffn, s] = job_list.run_next_job();
        if(isempty(job_ffn))
            L.newline('No job remained. Checking again after 120 mins.');
            pause(2*60*60 + randi(600));
            continue;
        end
        if(s)
            L.newline('Done. %s', job_ffn);
        end
    end
end
