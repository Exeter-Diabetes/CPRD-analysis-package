#Create table
CREATE TABLE CPRD_2020.Patient 
(patid BIGINT UNSIGNED,
pracid MEDIUMINT,
usualgpstaffid BIGINT,
gender SMALLINT,
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


#Insert females data
LOAD DATA INFILE '/home/eem/jmd237/diabetes_dec20/covid_nov20_patient_females.txt'
INTO TABLE CPRD_2020.Patient
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, pracid, @orig_usualgpstaffid, gender, yob, @orig_mob, @orig_emis_ddate, @orig_regstartdate, patienttypeid, @orig_regenddate, acceptable, @orig_cprd_ddate)
SET usualgpstaffid = NULLIF(@orig_usualgpstaffid,''),
mob = NULLIF(@orig_mob,''),
emis_ddate = STR_TO_DATE(NULLIF(@orig_emis_ddate,''),'%d/%m/%Y'),
regstartdate = STR_TO_DATE(@orig_regstartdate,'%d/%m/%Y'),
regenddate = STR_TO_DATE(NULLIF(@orig_regenddate,''),'%d/%m/%Y'),
cprd_ddate = STR_TO_DATE(NULLIF(@orig_cprd_ddate,''),'%d/%m/%Y');


#Insert males data
LOAD DATA INFILE '/home/eem/jmd237/diabetes_dec20/covid_nov20_patient_males.txt'
INTO TABLE CPRD_2020.Patient
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, pracid, @orig_usualgpstaffid, gender, yob, @orig_mob, @orig_emis_ddate, @orig_regstartdate, patienttypeid, @orig_regenddate, acceptable, @orig_cprd_ddate)
SET usualgpstaffid = NULLIF(@orig_usualgpstaffid,''),
mob = NULLIF(@orig_mob,''),
emis_ddate = STR_TO_DATE(NULLIF(@orig_emis_ddate,''),'%d/%m/%Y'),
regstartdate = STR_TO_DATE(@orig_regstartdate,'%d/%m/%Y'),
regenddate = STR_TO_DATE(NULLIF(@orig_regenddate,''),'%d/%m/%Y'),
cprd_ddate = STR_TO_DATE(NULLIF(@orig_cprd_ddate,''),'%d/%m/%Y');