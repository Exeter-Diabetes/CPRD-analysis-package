
# Make table of GP record end dates (death, end of registration, last collection from practice)
create table cprd_analysis_dev.gp_valid_dates as select a.patid, yob, mob, cprd_ddate, regenddate, lcd from cprd_data.patient a left join cprd_data.practice b on a.pracid=b.pracid;

# Make table of HES end dates (death) - include n_patid_hes for QC
create table cprd_analysis_dev.hes_valid_dates as select a.patid, n_patid_hes, discharged as hes_death from cprd_data.hes_hospital a inner join cprd_data.hes_patient b on a.patid=b.patid where dismeth=4 and disdest=79;

# Make table of ONS end dates (death)
create table cprd_analysis_dev.ons_valid_dates as select patid, if(dod is null, dor, dod) as ons_death from cprd_data.ons_death;


# Check no duplicates for the same patid
## None for GP or ONS, lots for HES
## Realised some are exact duplicates so removed:
create table cprd_analysis_dev.hes_valid_dates2 as select * from cprd_analysis_dev.hes_valid_dates group by patid, n_patid_hes, hes_death;

## Had a look at whether this is linked to n_patid_hes: 
select n_patid_hes, hes_death_count, count(*) from (Select patid, n_patid_hes, count(*) as hes_death_count from cprd_analysis_dev.hes_valid_dates2 group by patid, n_patid_hes) as T1 group by hes_death_count, n_patid_hes;
### People with 2 deaths: mostly n_patid_hes==1 (71), some 2 (42), a few 3 + 4 (16+3) and one 6
### People with 3 deaths - only 5 people in total
### 2 people with 5 deaths, n_patid_hes==10
### 1 person with 6 deaths, n_patid_hes==3
### Everything > 6 deaths has n_patid_hes > 20 (24 patids)


## If take earliest, see how this compares to gp and ONS data:
create table cprd_analysis_dev.hes_valid_dates3 as select patid, min(hes_death) as hes_death from cprd_analysis_dev.hes_valid_dates2 group by patid;

### New table with GP, earliest HES, ONS
create table cprd_analysis_dev.valid_date_lookup as 
select a.patid, yob, mob, cprd_ddate, regenddate, lcd, hes_death, ons_death from cprd_analysis_dev.gp_valid_dates a left join cprd_analysis_dev.hes_valid_dates3 b on a.patid=b.patid left join cprd_analysis_dev.ons_valid_dates c on a.patid=c.patid;

### Find earliest of GP and ONS
Alter table cprd_analysis_dev.valid_date_lookup add column gp_ons_earliest date;
update cprd_analysis_dev.valid_date_lookup set gp_ons_earliest=LEAST(if(cprd_ddate is null,date("2050-01-01"),cprd_ddate),if(regenddate is null,date("2050-01-01"),regenddate),if(lcd is null,date("2050-01-01"),lcd),if(ons_death is null,date("2050-01-01"),ons_death));

### Find where earliest HES is earlier than gp and ons
select * from valid_date_lookup where hes_death < gp_ons_earliest;
#n=1,851

### But if just look at whether < 100 days earlier:
select * from valid_date_lookup where hes_death < gp_ons_earliest and datediff(gp_ons_earliest,hes_death) > 100;
#n=352

### If discard where n_patid_hes > 20:
create table cprd_analysis_dev.hes_valid_dates4 as select patid, min(hes_death) as hes_death from cprd_analysis_dev.hes_valid_dates2 where n_patid_hes<=20 group by patid;

create table cprd_analysis_dev.valid_date_lookup2 as select a.*, b.hes_death as hes_death_cleaned from cprd_analysis_dev.valid_date_lookup a inner join cprd_analysis_dev.hes_valid_dates4 b on a.patid=b.patid;
# Only includes people with HES death = ~165,000

select * from valid_date_lookup2 where hes_death_cleaned < gp_ons_earliest;
#n=1,830
select * from valid_date_lookup2 where hes_death_cleaned < gp_ons_earliest and datediff(gp_ons_earliest,hes_death_cleaned) > 100;
#n=331

## Not much difference

# Include n_patid_hes in lookup table, then can filter based on this

select * from valid_date_lookup where cprd_ddate!=ons_death;


set role 'role_full_admin';
show full processlist;
kill 15854;
