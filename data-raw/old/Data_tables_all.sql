##NB: for Practice and Staff tables, 'females' and 'males' files are duplicates of each other


#Consultation table
CREATE TABLE CPRD_2020.Consultation 
(patid BIGINT UNSIGNED,
consid BIGINT UNSIGNED NOT NULL,
pracid MEDIUMINT,
consdate DATE,
enterdate DATE,
staffid BIGINT,
conssourceid BIGINT,
cprdconstype SMALLINT,
consmedcodeid BIGINT,
PRIMARY KEY (consid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/december_2020_IDs/Feb21_test_delete/test_consultation.txt'
INTO TABLE CPRD_2020.Consultation
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, consid, pracid, @orig_consdate, @orig_enterdate, @orig_staffid, @orig_conssourceid, @orig_cprdconstype, @orig_consmedcodeid)
SET consdate = STR_TO_DATE(NULLIF(@orig_consdate,''),'%d/%m/%Y'),
enterdate = STR_TO_DATE(@orig_enterdate,'%d/%m/%Y'),
staffid = NULLIF(@orig_staffid,''),
conssourceid = NULLIF(@orig_conssourceid,''),
cprdconstype = NULLIF(@orig_cprdconstype,''),
consmedcodeid = NULLIF(@orig_consmedcodeid,'');



#Drug Issue table
CREATE TABLE CPRD_2020.Drug_Issue 
(patid BIGINT UNSIGNED,
issueid BIGINT UNSIGNED NOT NULL,
pracid MEDIUMINT,
probobsid BIGINT UNSIGNED,
drugrecid BIGINT UNSIGNED,
issuedate DATE,
enterdate DATE,
staffid BIGINT,
prodcodeid BIGINT,
dosageid CHAR(64),
quantity DECIMAL(9,3),
quantunitid TINYINT,
duration BIGINT,
estnhscost DECIMAL(10,4),
PRIMARY KEY (issueid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/december_2020_IDs/Feb21_test_delete/test_drug_issue.txt'
INTO TABLE CPRD_2020.Drug_Issue
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, issueid, pracid, @orig_probobsid, @orig_drugrecid, @orig_issuedate, @orig_enterdate, @orig_staffid, prodcodeid, dosageid, quantity, @orig_quantunitid, duration, estnhscost)
SET probobsid = NULLIF(@orig_probobsid,''),
drugrecid = NULLIF(@orig_drugrecid,''),
issuedate = STR_TO_DATE(@orig_issuedate,'%d/%m/%Y'),
enterdate = STR_TO_DATE(@orig_enterdate,'%d/%m/%Y'),
staffid = NULLIF(@orig_staffid,''),
quantunitid = NULLIF(@orig_quantunitid,'');



#Observation table
CREATE TABLE CPRD_2020.Observation
(patid BIGINT UNSIGNED,
consid BIGINT UNSIGNED,
pracid MEDIUMINT,
obsid BIGINT UNSIGNED NOT NULL,
obsdate DATE,
enterdate DATE,
staffid BIGINT,
parentsobsid BIGINT UNSIGNED,
medcodeid BIGINT,
testvalue DECIMAL(19,3),
numunitid BIGINT,
obstypeid MEDIUMINT,
numrangelow DECIMAL(19,3),
numrangehigh DECIMAL(19,3),
probobsid BIGINT UNSIGNED,
PRIMARY KEY (obsid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/december_2020_IDs/Feb21_test_delete/test_observation.txt'
INTO TABLE CPRD_2020.Observation
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, @orig_consid, pracid, obsid, @orig_obsdate, @orig_enterdate, @orig_staffid, @orig_parentsobsid, @orig_medcodeid, @orig_testvalue, @orig_numunitid, obstypeid, @orig_numrangelow, @orig_numrangehigh, @orig_probobsid)
SET consid = NULLIF(@orig_consid,''),
obsdate = STR_TO_DATE(NULLIF(@orig_obsdate,''),'%d/%m/%Y'),
enterdate = STR_TO_DATE(@orig_enterdate,'%d/%m/%Y'),
staffid = NULLIF(@orig_staffid,''),
parentsobsid = NULLIF(@orig_parentsobsid,''),
medcodeid = NULLIF(@orig_medcodeid,''),
testvalue = NULLIF(@orig_testvalue,''),
numunitid = NULLIF(@orig_numunitid,''),
numrangelow = NULLIF(@orig_numrangelow,''),
numrangehigh = NULLIF(@orig_numrangehigh,''),
probobsid = NULLIF(@orig_probobsid,'');



#Patient table
CREATE TABLE CPRD_2020.Patient 
(patid BIGINT UNSIGNED NOT NULL,
pracid MEDIUMINT,
usualgpstaffid BIGINT,
genderid SMALLINT,
yob SMALLINT,
mob TINYINT,
emis_ddate DATE,
regstartdate DATE,
patienttypeid MEDIUMINT,
regenddate DATE,
acceptable BOOL,
cprd_ddate DATE,
PRIMARY KEY (patid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/december_2020_IDs/Feb21_test_delete/test_patient.txt'
INTO TABLE CPRD_2020.Patient
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, pracid, @orig_usualgpstaffid, genderid, yob, @orig_mob, @orig_emis_ddate, @orig_regstartdate, patienttypeid, @orig_regenddate, acceptable, @orig_cprd_ddate)
SET usualgpstaffid = NULLIF(@orig_usualgpstaffid,''),
mob = NULLIF(@orig_mob,''),
emis_ddate = STR_TO_DATE(NULLIF(@orig_emis_ddate,''),'%d/%m/%Y'),
regstartdate = STR_TO_DATE(@orig_regstartdate,'%d/%m/%Y'),
regenddate = STR_TO_DATE(NULLIF(@orig_regenddate,''),'%d/%m/%Y'),
cprd_ddate = STR_TO_DATE(NULLIF(@orig_cprd_ddate,''),'%d/%m/%Y');



#Practice table
CREATE TABLE CPRD_2020.Practice 
(pracid MEDIUMINT NOT NULL,
lcd DATE,
uts DATE,
regionid MEDIUMINT,
PRIMARY KEY (pracid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/december_2020_IDs/Feb21_test_delete/test_practice.txt'
INTO TABLE CPRD_2020.Practice
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(pracid, @orig_lcd, @orig_uts, @orig_regionid)
SET lcd = STR_TO_DATE(@orig_lcd,'%d/%m/%Y'),
uts = STR_TO_DATE(NULLIF(@orig_uts,''),'%d/%m/%Y'),
regionid = NULLIF(@orig_regionid,'');



#Problem table
CREATE TABLE CPRD_2020.Problem
(patid BIGINT UNSIGNED,
obsid BIGINT UNSIGNED NOT NULL,
pracid MEDIUMINT,
parentprobobsid BIGINT UNSIGNED,
probenddate DATE,
expduration MEDIUMINT,
lastrevdate DATE,
lastrevstaffid BIGINT,
parentprobrelid MEDIUMINT,
probstatusid MEDIUMINT,
signid MEDIUMINT,
PRIMARY KEY (obsid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/december_2020_IDs/Feb21_test_delete/test_problem.txt'
INTO TABLE CPRD_2020.Problem
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, obsid, pracid, @orig_parentprobobsid, @orig_probenddate, @orig_expduration, @orig_lastrevdate, @orig_lastrevstaffid, @orig_parentprobrelid, @orig_probstatusid, @orig_signid)
SET parentprobobsid = NULLIF(@orig_parentprobobsid,''),
probenddate = STR_TO_DATE(NULLIF(@orig_probenddate,''),'%d/%m/%Y'),
expduration = NULLIF(@orig_expduration,''),
lastrevdate = STR_TO_DATE(NULLIF(@orig_lastrevdate,''),'%d/%m/%Y'),
lastrevstaffid = NULLIF(@orig_lastrevstaffid,''),
parentprobrelid = NULLIF(@orig_parentprobrelid,''),
probstatusid = NULLIF(@orig_probstatusid,''),
signid = NULLIF(@orig_signid,'');



#Referral table
CREATE TABLE CPRD_2020.Referral
(patid BIGINT UNSIGNED,
obsid BIGINT UNSIGNED NOT NULL,
pracid MEDIUMINT,
refsourceorgid BIGINT,
reftargetorgid BIGINT,
refurgencyid TINYINT,
refservicetypeid TINYINT,
refmodeid TINYINT,
PRIMARY KEY (obsid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/december_2020_IDs/Feb21_test_delete/test_referral.txt'
INTO TABLE CPRD_2020.Referral
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, obsid, pracid, @orig_refsourceorgid, @orig_reftargetorgid, @orig_refurgencyid, @orig_refservicetypeid, @orig_refmodeid)
SET refsourceorgid = NULLIF(@orig_refsourceorgid,''),
reftargetorgid = NULLIF(@orig_reftargetorgid,''),
refurgencyid = NULLIF(@orig_refurgencyid,''),
refservicetypeid = NULLIF(@orig_refservicetypeid,''),
refmodeid = NULLIF(@orig_refmodeid,'');



#Staff table
CREATE TABLE CPRD_2020.Staff 
(staffid BIGINT NOT NULL,
pracid MEDIUMINT,
jobid MEDIUMINT,
PRIMARY KEY (staffid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/december_2020_IDs/Feb21_test_delete/test_staff.txt'
INTO TABLE CPRD_2020.Staff
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(staffid, pracid, @orig_jobid)
SET jobid = NULLIF(@orig_jobid,'');
