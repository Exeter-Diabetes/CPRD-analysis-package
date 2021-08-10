#Create table
CREATE TABLE CPRD_2020.Observations
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


#Insert females data
LOAD DATA INFILE '/home/eem/jmd237/diabetes_dec20/covid_nov20_obs_females.txt'
INTO TABLE CPRD_2020.Observations
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


#Insert males data
LOAD DATA INFILE '/home/eem/jmd237/diabetes_dec20/covid_nov20_obs_males.txt'
INTO TABLE CPRD_2020.Observations
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