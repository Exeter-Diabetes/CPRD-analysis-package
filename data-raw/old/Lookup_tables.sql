#Medical Dictionary
CREATE TABLE CPRD_2020.lkp_Medical_Dictionary
(medcodeid BIGINT,
term VARCHAR(255),
originalreadcode VARCHAR(100) CHARACTER SET BINARY,
cleansedreadcode VARCHAR(7) CHARACTER SET BINARY,
snomedctconceptid BIGINT UNSIGNED,
snomedctdescriptionid BIGINT UNSIGNED,
releaseid VARCHAR(100),
emiscodecategoryid TINYINT,
PRIMARY KEY (medcodeid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/202005_EMISMedicalDictionary.txt'
INTO TABLE CPRD_2020.lkp_Medical_Dictionary
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(medcodeid, term, originalreadcode, @orig_cleansedreadcode, snomedctconceptid, snomedctdescriptionid, @orig_releaseid, emiscodecategoryid)
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
(genderid TINYINT,
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



#NumUnit
CREATE TABLE CPRD_2020.lkp_NumUnit
(numunitid MEDIUMINT,
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
(obstypeid TINYINT,
description VARCHAR(100),
PRIMARY KEY (obstypeid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/ObsType.txt'
INTO TABLE CPRD_2020.lkp_ObsType
FIELDS TERMINATED BY '\t'
ESCAPED BY '\b'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(obstypeid, description);



#PatientType
CREATE TABLE CPRD_2020.lkp_PatientType
(patienttypeid TINYINT,
description VARCHAR(100),
PRIMARY KEY (patienttypeid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/PatientType.txt'
INTO TABLE CPRD_2020.lkp_PatientType
FIELDS TERMINATED BY '\t'
ESCAPED BY '\b'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patienttypeid, description);



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
ESCAPED BY '\b'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(quantunitid, description);



#Region
CREATE TABLE CPRD_2020.lkp_Region
(regionid TINYINT,
description VARCHAR(100),
PRIMARY KEY (regionid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/home/xic/ky279/202005_Lookups_CPRDAurum/Region.txt'
INTO TABLE CPRD_2020.lkp_Region
FIELDS TERMINATED BY '\t'
ESCAPED BY '\b'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(regionid, description);


