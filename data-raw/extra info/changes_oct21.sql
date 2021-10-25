set role 'role_full_admin';

update cprd_data.rl_admimeth set `description` = "Planned. A Patient admitted, having been given a date or approximate date at the time that the decision to admit was made. This is usually part of a planned sequence of clinical care determined mainly on social or clinical criteria (e.g. check cystoscopy). A planned admission is one where the date of admission is determined by the needs of the treatment, rather than by the availability of resources. Note that this does not include a transfer from another Hospital Provider (see 81 below)." where admimeth = "13";

update cprd_data.hes_episodes set pconsult=NULL where pconsult="&" or pconsult="99";

select chars, count(*) from (select length(pconsult) as chars from cprd_data.hes_episodes) as t1 group by chars;
