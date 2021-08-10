#Medical Dictionary
CREATE TABLE CPRD_2020.lkp_Medical_Dictionary
(medcodeid BIGINT,
term VARCHAR(255),
originalreadcode VARCHAR(100) CHARACTER SET BINARY,
cleansedreadcode VARCHAR(7) CHARACTER SET BINARY,
snomedctconceptid BIGINT UNSIGNED,
snomedctdescriptionid BIGINT UNSIGNED,
releaseid VARCHAR(100),
emiscodecatid TINYINT,
PRIMARY KEY (medcodeid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/202005_EMISMedicalDictionary.txt'
INTO TABLE CPRD_2020.lkp_Medical_Dictionary
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(medcodeid, term, originalreadcode, @orig_cleansedreadcode, snomedctconceptid, snomedctdescriptionid, @orig_releaseid, emiscodecatid)
SET cleansedreadcode = NULLIF(@orig_cleansedreadcode,''),
releaseid = NULLIF(@orig_releaseid,'');



#Product Dictionary
CREATE TABLE CPRD_2020.lkp_Product_Dictionary
(prodcodeid BIGINT,
dmdid BIGINT UNSIGNED,
termfromemis VARCHAR(255),
productname VARCHAR(999),
formulation VARCHAR(999),
routeofadministration VARCHAR(999),
drugsubstancename VARCHAR(999),
substancestrength VARCHAR(999),
bnfchapter VARCHAR(999),
releaseid VARCHAR(100),
PRIMARY KEY (prodcodeid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/202005_EMISProductDictionary.txt'
INTO TABLE CPRD_2020.lkp_Product_Dictionary
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(prodcodeid, @orig_dmdid, @orig_termfromemis, @orig_productname, @orig_formulation, @orig_routeofadministration, @orig_drugsubstancename, @orig_substancestrength, @orig_bnfchapter, @orig_releaseid)
SET dmdid = NULLIF(@orig_dmdid,''),
termfromemis = @orig_termfromemis,
productname = IF(@orig_productname='',@orig_termfromemis,@orig_productname),
formulation = NULLIF(@orig_formulation,''),
routeofadministration = NULLIF(@orig_routeofadministration,''),
drugsubstancename = NULLIF(@orig_drugsubstancename,''),
substancestrength = NULLIF(@orig_substancestrength,''),
bnfchapter = NULLIF(@orig_bnfchapter,''),
releaseid = NULLIF(@orig_releaseid,'');



#Common Dosages
CREATE TABLE CPRD_2020.lkp_Common_Dosages
(dosageid CHAR(64),
dosage_text VARCHAR(999),
daily_dose DECIMAL(15,9),
dose_number DECIMAL(14,7),
dose_unit VARCHAR(20),
dose_frequency DECIMAL(9,6),
dose_interval DECIMAL(11,8),
choice_of_dose TINYINT,
dose_max_average TINYINT,
change_dose TINYINT,
dose_duration DECIMAL(4,1),
PRIMARY KEY (dosageid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/common_dosages.txt'
INTO TABLE CPRD_2020.lkp_Common_Dosages
FIELDS TERMINATED BY '\t'
ESCAPED BY '\b'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(dosageid, dosage_text, daily_dose, @orig_dose_number, @orig_dose_unit, dose_frequency, dose_interval, choice_of_dose, dose_max_average, change_dose, dose_duration)
SET dose_number = IF(@orig_dose_number > 9999999,NULL,@orig_dose_number),
dose_unit = NULLIF(@orig_dose_unit,'');



#ConsSource
CREATE TABLE CPRD_2020.lkp_ConsSource
(conssourceid BIGINT,
description VARCHAR(100),
PRIMARY KEY (conssourceid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/ConsSource.txt'
INTO TABLE CPRD_2020.lkp_ConsSource
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(conssourceid, description);



#EmisCodeCat
CREATE TABLE CPRD_2020.lkp_EmisCodeCat
(emiscodecatid TINYINT,
description VARCHAR(100),
PRIMARY KEY (emiscodecatid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/EmisCodeCat.txt'
INTO TABLE CPRD_2020.lkp_EmisCodeCat
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(emiscodecatid, description);



#Gender
CREATE TABLE CPRD_2020.lkp_Gender
(genderid SMALLINT,
description VARCHAR(1),
PRIMARY KEY (genderid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/Gender.txt'
INTO TABLE CPRD_2020.lkp_Gender
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(genderid, description);



#JobCat
CREATE TABLE CPRD_2020.lkp_JobCat
(jobcatid MEDIUMINT,
description VARCHAR(100),
PRIMARY KEY (jobcatid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/JobCat.txt'
INTO TABLE CPRD_2020.lkp_JobCat
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(jobcatid, description);



#NumUnit
CREATE TABLE CPRD_2020.lkp_NumUnit
(numunitid BIGINT,
description VARCHAR(100),
PRIMARY KEY (numunitid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/NumUnit.txt'
INTO TABLE CPRD_2020.lkp_NumUnit
FIELDS TERMINATED BY '\t'
ESCAPED BY '\b'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(numunitid, description);



#ObsType
CREATE TABLE CPRD_2020.lkp_ObsType
(obstypeid MEDIUMINT,
description VARCHAR(100),
PRIMARY KEY (obstypeid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/ObsType.txt'
INTO TABLE CPRD_2020.lkp_ObsType
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(obstypeid, description);



#OrgType
CREATE TABLE CPRD_2020.lkp_OrgType
(orgtypeid SMALLINT,
description VARCHAR(100),
PRIMARY KEY (orgtypeid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/OrgType.txt'
INTO TABLE CPRD_2020.lkp_OrgType
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(orgtypeid, description);



#ParentProbRel
CREATE TABLE CPRD_2020.lkp_ParentProbRel
(parentprobrelid MEDIUMINT,
description VARCHAR(100),
PRIMARY KEY (parentprobrelid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/ParentProbRel.txt'
INTO TABLE CPRD_2020.lkp_ParentProbRel
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(parentprobrelid, description);



#PatientType
CREATE TABLE CPRD_2020.lkp_PatientType
(patienttypeid MEDIUMINT,
description VARCHAR(100),
PRIMARY KEY (patienttypeid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/PatientType.txt'
INTO TABLE CPRD_2020.lkp_PatientType
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patienttypeid, description);



#ProbStatus
CREATE TABLE CPRD_2020.lkp_ProbStatus
(probstatusid MEDIUMINT,
description VARCHAR(100),
PRIMARY KEY (probstatusid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/ProbStatus.txt'
INTO TABLE CPRD_2020.lkp_ProbStatus
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(probstatusid, description);



#QuantUnit
CREATE TABLE CPRD_2020.lkp_QuantUnit
(quantunitid SMALLINT,
description VARCHAR(100),
PRIMARY KEY (quantunitid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/QuantUnit.txt'
INTO TABLE CPRD_2020.lkp_QuantUnit
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(quantunitid, description);



#RefMode
CREATE TABLE CPRD_2020.lkp_RefMode
(refmodeid TINYINT,
description VARCHAR(100),
PRIMARY KEY (refmodeid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/RefMode.txt'
INTO TABLE CPRD_2020.lkp_RefMode
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(refmodeid, description);



#RefServiceType
CREATE TABLE CPRD_2020.lkp_RefServiceType
(refservicetypeid TINYINT,
description VARCHAR(100),
PRIMARY KEY (refservicetypeid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/RefServiceType.txt'
INTO TABLE CPRD_2020.lkp_RefServiceType
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(refservicetypeid, description);



#RefUrgency
CREATE TABLE CPRD_2020.lkp_RefUrgency
(refurgencyid TINYINT,
description VARCHAR(100),
PRIMARY KEY (refurgencyid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/RefUrgency.txt'
INTO TABLE CPRD_2020.lkp_RefUrgency
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(refurgencyid, description);



#Region
CREATE TABLE CPRD_2020.lkp_Region
(regionid MEDIUMINT,
description VARCHAR(100),
PRIMARY KEY (regionid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/Region.txt'
INTO TABLE CPRD_2020.lkp_Region
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(regionid, description);



#Sign
CREATE TABLE CPRD_2020.lkp_Sign
(signid MEDIUMINT,
description VARCHAR(100),
PRIMARY KEY (signid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/Sign.txt'
INTO TABLE CPRD_2020.lkp_Sign
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(signid, description);



#VisionToEmisMigrators
CREATE TABLE CPRD_2020.lkp_VisionToEmisMigrators
(gold_pracid SMALLINT,
gold_lcdate DATE,
emis_pracid MEDIUMINT,
emis_join_date DATE,
emis_fdcdate DATE,
PRIMARY KEY (gold_pracid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/VisionToEmisMigrators.txt'
INTO TABLE CPRD_2020.lkp_VisionToEmisMigrators
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(gold_pracid, @orig_gold_lcdate, emis_pracid, @orig_emis_join_date, @orig_emis_fdcdate)
SET gold_lcdate = STR_TO_DATE(@orig_gold_lcdate,'%d/%m/%Y'),
emis_join_date = STR_TO_DATE(@orig_emis_join_date,'%d/%m/%Y'),
emis_fdcdate = STR_TO_DATE(@orig_emis_fdcdate,'%d/%m/%Y');
