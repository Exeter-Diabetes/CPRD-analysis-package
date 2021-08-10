#Create table for drug issues
CREATE TABLE CPRD_2020.Drug_Issue 
(patid BIGINT UNSIGNED,
issueid BIGINT UNSIGNED,
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


#Insert females data
LOAD DATA INFILE '/home/eem/jmd237/diabetes_dec20/covid_nov20_drug_females.txt'
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



#Insert males data
LOAD DATA INFILE '/home/eem/jmd237/diabetes_dec20/covid_nov20_drug_males.txt'
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
