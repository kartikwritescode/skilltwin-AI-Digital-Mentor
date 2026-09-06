[//]: # (this commands keeps the render free tier backend alive by sending a req every 14th min)




-- 1. Enable required extensions for scheduled HTTP calls
create extension if not exists pg_cron;
create extension if not exists pg_net;

-- 2. Schedule a cron job named 'keep-render-alive' every 14 minutes
select cron.schedule(
'keep-render-alive',
'*/14 * * * *',
$$
select net.http_get(
url := 'https://skilltwin-backend.onrender.com/health'
);
$$
);





[//]: # (to check job status / run history)
select * from cron.job_run_details order by start_time desc limit 10;




[//]: # (to stop this )
select cron.unschedule('keep-render-alive');