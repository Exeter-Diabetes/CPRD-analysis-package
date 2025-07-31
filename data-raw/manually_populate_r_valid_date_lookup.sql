# Making valid_date_lookup

## Diabetes 2020 download
set role 'role_full_admin';

#drop table if exists cprd_data.r_valid_date_lookup;

create table cprd_data.r_valid_date_lookup as select c.patid, min_dob, gp_end_date, ons_death, hes_death_all, hes_death_nph_filtered,
least(if(gp_end_date is null,str_to_date('1/1/2050','%d/%m/%Y'),gp_end_date), 
if(ons_death is null,str_to_date('1/1/2050','%d/%m/%Y'),ons_death)) as gp_ons_end_date,
least(if(cprd_ddate is null,str_to_date('1/1/2050','%d/%m/%Y'),cprd_ddate), 
if(ons_death is null,str_to_date('1/1/2050','%d/%m/%Y'),ons_death)) as gp_ons_death_date,
least(if(gp_end_date is null,str_to_date('1/1/2050','%d/%m/%Y'),gp_end_date), 
if(ons_death is null,str_to_date('1/1/2050','%d/%m/%Y'),ons_death),
if(hes_death_all is null,str_to_date('1/1/2050','%d/%m/%Y'),hes_death_all)) as gp_ons_hes_all_end_date,
least(if(gp_end_date is null,str_to_date('1/1/2050','%d/%m/%Y'),gp_end_date), 
if(ons_death is null,str_to_date('1/1/2050','%d/%m/%Y'),ons_death),
if(hes_death_nph_filtered is null,str_to_date('1/1/2050','%d/%m/%Y'),hes_death_nph_filtered)) as gp_ons_hes_nph_filtered_end_date from
(select patid, min_dob, least(if(cprd_ddate is null,str_to_date('1/1/2050','%d/%m/%Y'),cprd_ddate), 
if(regenddate is null,str_to_date('1/1/2050','%d/%m/%Y'),regenddate), 
if(lcd is null,str_to_date('1/1/2050','%d/%m/%Y'),lcd)) as gp_end_date, cprd_ddate from 
(select a.patid, if(a.mob is NULL, str_to_date(concat('1/1/',a.yob),'%d/%m/%Y'), str_to_date(concat('1/',a.mob,'/',a.yob),'%d/%m/%Y')) as min_dob, a.cprd_ddate, a.regenddate, b.lcd from cprd_data.patient a left join cprd_data.practice b on a.pracid=b.pracid)
as T1)
as c left join (select patid, if(dod is null, dor, dod) as ons_death from cprd_data.ons_death) d on c.patid=d.patid left join 
(select patid, min(discharged) as hes_death_all from cprd_data.hes_hospital where dismeth=4 and disdest=79 group by patid)
e on c.patid=e.patid left join
(select patid, min(hes_death) as hes_death_nph_filtered from
(select f.patid, n_patid_hes, hes_death from cprd_data.hes_patient f inner join
(select patid, discharged as hes_death from cprd_data.hes_hospital where dismeth=4 and disdest=79)
g on f.patid=g.patid where n_patid_hes<=20)
as T2 group by patid)
h on c.patid=h.patid ENGINE=MyISAM;

update cprd_data.r_valid_date_lookup set gp_ons_death_date=NULL where gp_ons_death_date=str_to_date('1/1/2050','%d/%m/%Y');

select * from cprd_data.r_valid_date_lookup where year(gp_ons_end_date)=2050 or year(gp_ons_death_date)=2050 or year(gp_ons_hes_all_end_date)=2050 or year(gp_ons_hes_nph_filtered_end_date)=2050;
# None

select max(gp_ons_end_date), max(gp_ons_death_date), max(gp_ons_hes_all_end_date), max(gp_ons_hes_all_end_date) from cprd_data.r_valid_date_lookup;
# All which use gp_end_date are 15/10/2020; gp_ons_death_date = 16/11/2020

create unique index x_patid_r_valid_date_lookup on cprd_data.r_valid_date_lookup (patid);
create index x_gp_end_date_r_valid_date_lookup on cprd_data.r_valid_date_lookup (gp_end_date);
create index x_ons_death_r_valid_date_lookup on cprd_data.r_valid_date_lookup (ons_death);
create index x_hes_death_all_r_valid_date_lookup on cprd_data.r_valid_date_lookup (hes_death_all);
create index x_hes_death_nph_filtered_r_valid_date_lookup on cprd_data.r_valid_date_lookup (hes_death_nph_filtered);
create index x_gp_ons_end_date_r_valid_date_lookup on cprd_data.r_valid_date_lookup (gp_ons_end_date);
create index x_gp_ons_death_date_r_valid_date_lookup on cprd_data.r_valid_date_lookup (gp_ons_death_date);
create index x_gp_ons_hes_all_end_date_r_valid_date_lookup on cprd_data.r_valid_date_lookup (gp_ons_hes_all_end_date);
create index x_gp_ons_hes_nph_filtered_end_date_r_valid_date_lookup on cprd_data.r_valid_date_lookup (gp_ons_hes_nph_filtered_end_date);




# Full 2021 download

set role 'role_full_admin';

drop table if exists full_cprd_data.r_valid_date_lookup;

create table full_cprd_data.r_valid_date_lookup as select patid, min_dob,
least(if(cprd_ddate is null,str_to_date('1/1/2050','%d/%m/%Y'),cprd_ddate), 
if(regenddate is null,str_to_date('1/1/2050','%d/%m/%Y'),regenddate), 
if(lcd is null,str_to_date('1/1/2050','%d/%m/%Y'),lcd)) as gp_end_date from 
(select a.patid, if(a.mob is NULL, str_to_date(concat('1/1/',a.yob),'%d/%m/%Y'), str_to_date(concat('1/',a.mob,'/',a.yob),'%d/%m/%Y')) as min_dob, a.cprd_ddate, a.regenddate, b.lcd from full_cprd_data.patient a left join full_cprd_data.practice b on a.pracid=b.pracid) as T1 ENGINE=MyISAM;


create unique index x_patid_r_valid_date_lookup on full_cprd_data.r_valid_date_lookup (patid);
create index x_gp_end_date_r_valid_date_lookup on full_cprd_data.r_valid_date_lookup (gp_end_date);



# 2024 dementia download (do without ONS linked data although applying for this later)

set role 'role_full_admin';

drop table if exists cprd_dementia_data.r_valid_date_lookup;

create table cprd_dementia_data.r_valid_date_lookup ENGINE=MyISAM as select patid, min_dob,
least(if(cprd_ddate is null,str_to_date('1/1/2050','%d/%m/%Y'),cprd_ddate), 
if(regenddate is null,str_to_date('1/1/2050','%d/%m/%Y'),regenddate), 
if(lcd is null,str_to_date('1/1/2050','%d/%m/%Y'),lcd)) as gp_end_date from 
(select a.patid, if(a.mob is NULL, str_to_date(concat('1/1/',a.yob),'%d/%m/%Y'), str_to_date(concat('1/',a.mob,'/',a.yob),'%d/%m/%Y')) as min_dob, a.cprd_ddate, a.regenddate, b.lcd from cprd_dementia_data.patient a left join cprd_dementia_data.practice b on a.pracid=b.pracid) as T1;

create unique index x_patid_r_valid_date_lookup on cprd_dementia_data.r_valid_date_lookup (patid);
create index x_gp_end_date_r_valid_date_lookup on cprd_dementia_data.r_valid_date_lookup (gp_end_date);




# Feb 2024 diabetes download (do without ONS linked data)

set role 'role_full_admin';

drop table if exists cprd_feb24dm_data.r_valid_date_lookup;

create table cprd_feb24dm_data.r_valid_date_lookup ENGINE=MyISAM as select patid, min_dob,
least(if(regenddate is null,str_to_date('30/11/2023','%d/%m/%Y'),regenddate), 
if(lcd is null,str_to_date('30/11/2023','%d/%m/%Y'),lcd)) as gp_end_date from 
(select a.patid, if(a.mob is NULL, str_to_date(concat('1/1/',a.yob),'%d/%m/%Y'), str_to_date(concat('1/',a.mob,'/',a.yob),'%d/%m/%Y')) as min_dob, a.cprd_ddate, a.regenddate, b.lcd from cprd_feb24dm_data.patient a left join cprd_feb24dm_data.practice b on a.pracid=b.pracid) as T1;

create unique index x_patid_r_valid_date_lookup on cprd_feb24dm_data.r_valid_date_lookup (patid);
create index x_gp_end_date_r_valid_date_lookup on cprd_feb24dm_data.r_valid_date_lookup (gp_end_date);



# 2024 depression download (do without ONS linked data)

set role 'role_full_admin';

drop table if exists cprd_feb24depression_data.r_valid_date_lookup;

create table cprd_feb24depression_data.r_valid_date_lookup ENGINE=MyISAM as select patid, min_dob,
least(if(regenddate is null,str_to_date('30/11/2023','%d/%m/%Y'),regenddate), 
if(lcd is null,str_to_date('30/11/2023','%d/%m/%Y'),lcd)) as gp_end_date from 
(select a.patid, if(a.mob is NULL, str_to_date(concat('1/1/',a.yob),'%d/%m/%Y'), str_to_date(concat('1/',a.mob,'/',a.yob),'%d/%m/%Y')) as min_dob, a.cprd_ddate, a.regenddate, b.lcd from cprd_feb24depression_data.patient a left join cprd_feb24depression_data.practice b on a.pracid=b.pracid) as T1;

create unique index x_patid_r_valid_date_lookup on cprd_feb24depression_data.r_valid_date_lookup (patid);
create index x_gp_end_date_r_valid_date_lookup on cprd_feb24depression_data.r_valid_date_lookup (gp_end_date);



# 2024 diabetes download (do without ONS linked data, and don't use cprd_ddate)

set role 'role_full_admin';

drop table if exists cprd_jun24dm_data.r_valid_date_lookup;

create table cprd_jun24dm_data.r_valid_date_lookup ENGINE=MyISAM as select patid, min_dob,
least(if(regenddate is null,str_to_date('31/05/2024','%d/%m/%Y'),regenddate), 
if(lcd is null,str_to_date('31/05/2024','%d/%m/%Y'),lcd)) as gp_end_date from 
(select a.patid, if(a.mob is NULL, str_to_date(concat('1/1/',a.yob),'%d/%m/%Y'), str_to_date(concat('1/',a.mob,'/',a.yob),'%d/%m/%Y')) as min_dob, a.regenddate, b.lcd from cprd_jun24dm_data.patient a left join cprd_jun24dm_data.practice b on a.pracid=b.pracid) as T1;

create unique index x_patid_r_valid_date_lookup on cprd_jun24dm_data.r_valid_date_lookup (patid);
create index x_gp_end_date_r_valid_date_lookup on cprd_jun24dm_data.r_valid_date_lookup (gp_end_date);



# 2024 non-diabetes download (do without ONS linked data, and don't use cprd_ddate)

set role 'role_full_admin';

drop table if exists cprd_jun24nondm_data.r_valid_date_lookup;

create table cprd_jun24nondm_data.r_valid_date_lookup ENGINE=MyISAM as select patid, min_dob,
least(if(regenddate is null,str_to_date('31/05/2024','%d/%m/%Y'),regenddate), 
if(lcd is null,str_to_date('31/05/2024','%d/%m/%Y'),lcd)) as gp_end_date from 
(select a.patid, if(a.mob is NULL, str_to_date(concat('1/1/',a.yob),'%d/%m/%Y'), str_to_date(concat('1/',a.mob,'/',a.yob),'%d/%m/%Y')) as min_dob, a.regenddate, b.lcd from cprd_jun24nondm_data.patient a left join cprd_jun24nondm_data.practice b on a.pracid=b.pracid) as T1;

create unique index x_patid_r_valid_date_lookup on cprd_jun24nondm_data.r_valid_date_lookup (patid);
create index x_gp_end_date_r_valid_date_lookup on cprd_jun24nondm_data.r_valid_date_lookup (gp_end_date);

