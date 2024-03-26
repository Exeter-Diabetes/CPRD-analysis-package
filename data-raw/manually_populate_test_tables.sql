
set role 'role_full_admin';

use cprd_dementia_data;

create table patient_test as select * from patient where patienttypeid=3 and acceptable=1 and (regenddate is null or regenddate>=date("2004-01-01")) and (cprd_ddate is null or cprd_ddate>=date("2004-01-01")) and (regenddate is null or datediff(regenddate, regstartdate)>730) and (cprd_ddate is null or datediff(cprd_ddate, regstartdate)>730) and regstartdate<date("2019-06-01") order by rand() limit 10000;

alter table patient_test add primary key (patid);
create index x_patient_test_pracid on patient_test (pracid);  ##need to run

create table practice_test as select distinct b.* from patient_test a inner join practice b on a.pracid=b.pracid;

alter table practice_test add primary key (pracid);
create index x_practice_test_lcd on practice_test (lcd);
create index x_practice_test_region on practice_test (region);

create table observation_test as select b.* from patient_test a inner join observation b on a.patid=b.patid; #running
select count(*) from observation_test;
# 1,420,646

alter table observation_test add primary key (obsid);
create index x_observation_test_patid on observation_test (patid);
create index x_observation_test_medcodeid on observation_test (medcodeid);
create index x_observation_test_obsdate on observation_test (obsdate);
create index x_observation_test_testvalue on observation_test (testvalue);
create index x_observation_test_numunitid on observation_test (numunitid);

create table drug_issue_test as select b.* from patient_test a inner join drug_issue b on a.patid=b.patid;
select count(*) from drug_issue_test;
# 969,222

alter table drug_issue_test add primary key (issueid);
create index x_drug_issue_test_patid on drug_issue_test (patid);
create index x_drug_issue_test_prodcodeid on drug_issue_test (prodcodeid);
create index x_drug_issue_test_issuedate on drug_issue_test (issuedate);
create index x_drug_issue_test_dosageid on drug_issue_test (dosageid);
create index x_drug_issue_test_quantity on drug_issue_test (quantity);
create index x_drug_issue_test_quantunitid on drug_issue_test (quantunitid);
create index x_drug_issue_test_duration on drug_issue_test (duration);


## Test time to run HbA1c query
select a.* from observation_test a inner join (select codeid from cprd_analysis_dev.code_sets where setname="hba1c") b on a.medcodeid=b.codeid;
# <1 minute

## Test how many with risperidone
select * from drug_issue_test where prodcodeid=1173841000033113 or prodcodeid=1173941000033117 or prodcodeid=1176241000033115 or prodcodeid=1176341000033113 or prodcodeid=1176441000033119 or prodcodeid=1176541000033118 or prodcodeid=1176641000033117 or prodcodeid=1176741000033114 or prodcodeid=1176841000033116 or prodcodeid=1176941000033112 or prodcodeid=1177641000033119 or prodcodeid=1177741000033111 or prodcodeid=2188141000033115 or prodcodeid=2188241000033110 or prodcodeid=2779841000033118 or prodcodeid=2779941000033114 or prodcodeid=2780041000033113 or prodcodeid=2780141000033112 or prodcodeid=2780241000033117 or prodcodeid=2780341000033110 or prodcodeid=2868841000033116 or prodcodeid=2868941000033112 or prodcodeid=2869041000033115 or prodcodeid=2869141000033116 or prodcodeid=3246041000033119 or prodcodeid=3246141000033115 or prodcodeid=4012041000033116 or prodcodeid=4012141000033117 or prodcodeid=4012241000033112 or prodcodeid=4012341000033119 or prodcodeid=13581641000033117;
# 1,101 records

select distinct(patid) from drug_issue_test where prodcodeid=1173841000033113 or prodcodeid=1173941000033117 or prodcodeid=1176241000033115 or prodcodeid=1176341000033113 or prodcodeid=1176441000033119 or prodcodeid=1176541000033118 or prodcodeid=1176641000033117 or prodcodeid=1176741000033114 or prodcodeid=1176841000033116 or prodcodeid=1176941000033112 or prodcodeid=1177641000033119 or prodcodeid=1177741000033111 or prodcodeid=2188141000033115 or prodcodeid=2188241000033110 or prodcodeid=2779841000033118 or prodcodeid=2779941000033114 or prodcodeid=2780041000033113 or prodcodeid=2780141000033112 or prodcodeid=2780241000033117 or prodcodeid=2780341000033110 or prodcodeid=2868841000033116 or prodcodeid=2868941000033112 or prodcodeid=2869041000033115 or prodcodeid=2869141000033116 or prodcodeid=3246041000033119 or prodcodeid=3246141000033115 or prodcodeid=4012041000033116 or prodcodeid=4012141000033117 or prodcodeid=4012241000033112 or prodcodeid=4012341000033119 or prodcodeid=13581641000033117;
# 28 people
