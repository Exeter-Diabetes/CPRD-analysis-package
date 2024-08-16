
set role 'role_full_admin';

use cprd_jun24dm_data;

create table patient_test ENGINE=MyIsam as select * from patient where patienttypeid=3 and acceptable=1 and (regenddate is null or regenddate>=date("2004-01-01")) and (cprd_ddate is null or cprd_ddate>=date("2004-01-01")) and (regenddate is null or datediff(regenddate, regstartdate)>730) and (cprd_ddate is null or datediff(cprd_ddate, regstartdate)>730) and regstartdate<date("2019-06-01") order by rand() limit 10000;

alter table patient_test add primary key (patid);
create index x_patient_test_pracid on patient_test (pracid);

create table practice_test ENGINE=MyIsam as select distinct b.* from patient_test a inner join practice b on a.pracid=b.pracid;

alter table practice_test add primary key (pracid);
create index x_practice_test_lcd on practice_test (lcd);
create index x_practice_test_region on practice_test (region);

create table observation_test ENGINE=MyIsam as select b.* from patient_test a inner join observation b on a.patid=b.patid;
select count(*) from observation_test;
# 16,400,620

alter table observation_test add primary key (obsid);
create index x_observation_test_patid on observation_test (patid);
create index x_observation_test_medcodeid on observation_test (medcodeid);
create index x_observation_test_obsdate on observation_test (obsdate);
create index x_observation_test_testvalue on observation_test (testvalue);
create index x_observation_test_numunitid on observation_test (numunitid);

create table drug_issue_test ENGINE=MyIsam as select b.* from patient_test a inner join drug_issue b on a.patid=b.patid;
select count(*) from drug_issue_test;
# 4,481,906

alter table drug_issue_test add primary key (issueid);
create index x_drug_issue_test_patid on drug_issue_test (patid);
create index x_drug_issue_test_prodcodeid on drug_issue_test (prodcodeid);
create index x_drug_issue_test_issuedate on drug_issue_test (issuedate);
create index x_drug_issue_test_dosageid on drug_issue_test (dosageid);
create index x_drug_issue_test_quantity on drug_issue_test (quantity);
create index x_drug_issue_test_quantunitid on drug_issue_test (quantunitid);
create index x_drug_issue_test_duration on drug_issue_test (duration);

