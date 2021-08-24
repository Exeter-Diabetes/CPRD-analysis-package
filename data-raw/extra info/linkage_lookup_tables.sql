#acpdisp lookup

CREATE TABLE cprd_data.rl_acpdisp
(acpdisp TINYINT,
description VARCHAR(100),
PRIMARY KEY (acpdisp))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/acpdisp.txt'
INTO TABLE cprd_data.rl_acpdisp
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(acpdisp, description);


#acploc lookup

CREATE TABLE cprd_data.rl_acploc
(acploc TINYINT,
description VARCHAR(300),
PRIMARY KEY (acploc))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/acploc.txt'
INTO TABLE cprd_data.rl_acploc
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(acploc, description);


#acpout lookup

CREATE TABLE cprd_data.rl_acpout
(acpout TINYINT,
description VARCHAR(100),
PRIMARY KEY (acpout))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/acpout.txt'
INTO TABLE cprd_data.rl_acpout
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(acpout, description);


#acpplan lookup

CREATE TABLE cprd_data.rl_acpplan
(acpplan TINYINT,
description VARCHAR(100),
PRIMARY KEY (acpplan))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/acpplan.txt'
INTO TABLE cprd_data.rl_acpplan
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(acpplan, description);


#acpsour lookup

CREATE TABLE cprd_data.rl_acpsour
(acpsour TINYINT,
description VARCHAR(200),
PRIMARY KEY (acpsour))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/acpsour.txt'
INTO TABLE cprd_data.rl_acpsour
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(acpsour, description);


#acpspef lookup

CREATE TABLE cprd_data.rl_acpspef
(acpspef CHAR(4),
description VARCHAR(100),
PRIMARY KEY (acpspef))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/acpspef.txt'
INTO TABLE cprd_data.rl_acpspef
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(acpspef, description);


#admimeth lookup

CREATE TABLE cprd_data.rl_admimeth
(admimeth CHAR(2),
admimeth_type VARCHAR(19),
description VARCHAR(500),
PRIMARY KEY (admimeth))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/admimeth.txt'
INTO TABLE cprd_data.rl_admimeth
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(admimeth,admimeth_type, description);


#admisorc lookup

CREATE TABLE cprd_data.rl_admisorc
(admisorc TINYINT,
description VARCHAR(400),
PRIMARY KEY (admisorc))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/admisorc.txt'
INTO TABLE cprd_data.rl_admisorc
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(admisorc, description);


#ccadmisorc lookup

CREATE TABLE cprd_data.rl_ccadmisorc
(ccadmisorc TINYINT,
description VARCHAR(100),
PRIMARY KEY (ccadmisorc))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/ccadmisorc.txt'
INTO TABLE cprd_data.rl_ccadmisorc
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(ccadmisorc, description);


#ccadmitype lookup

CREATE TABLE cprd_data.rl_ccadmitype
(ccadmitype TINYINT,
description VARCHAR(600),
PRIMARY KEY (ccadmitype))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/ccadmitype.txt'
INTO TABLE cprd_data.rl_ccadmitype
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(ccadmitype, description);


#ccapcrel lookup

CREATE TABLE cprd_data.rl_ccapcrel
(ccapcrel TINYINT,
description VARCHAR(200),
PRIMARY KEY (ccapcrel))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/ccapcrel.txt'
INTO TABLE cprd_data.rl_ccapcrel
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(ccapcrel, description);


#ccdisdest lookup

CREATE TABLE cprd_data.rl_ccdisdest
(ccdisdest TINYINT,
description VARCHAR(100),
PRIMARY KEY (ccdisdest))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/ccdisdest.txt'
INTO TABLE cprd_data.rl_ccdisdest
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(ccdisdest, description);


#ccdisloc lookup

CREATE TABLE cprd_data.rl_ccdisloc
(ccdisloc TINYINT,
description VARCHAR(200),
PRIMARY KEY (ccdisloc))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/ccdisloc.txt'
INTO TABLE cprd_data.rl_ccdisloc
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(ccdisloc, description);


#ccdisstat lookup

CREATE TABLE cprd_data.rl_ccdisstat
(ccdisstat TINYINT,
description VARCHAR(100),
PRIMARY KEY (ccdisstat))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/ccdisstat.txt'
INTO TABLE cprd_data.rl_ccdisstat
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(ccdisstat, description);


#ccsorcloc lookup

CREATE TABLE cprd_data.rl_ccsorcloc
(ccsorcloc TINYINT,
description VARCHAR(200),
PRIMARY KEY (ccsorcloc))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/ccsorcloc.txt'
INTO TABLE cprd_data.rl_ccsorcloc
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(ccsorcloc, description);


#ccunitfun lookup

CREATE TABLE cprd_data.rl_ccunitfun
(ccunitfun TINYINT,
description VARCHAR(100),
PRIMARY KEY (ccunitfun))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/ccunitfun.txt'
INTO TABLE cprd_data.rl_ccunitfun
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(ccunitfun, description);


#classpat lookup

CREATE TABLE cprd_data.rl_classpat
(classpat TINYINT,
description VARCHAR(100),
PRIMARY KEY (classpat))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/classpat.txt'
INTO TABLE cprd_data.rl_classpat
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(classpat, description);


#disdest lookup

CREATE TABLE cprd_data.rl_disdest
(disdest TINYINT,
description VARCHAR(200),
PRIMARY KEY (disdest))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/disdest.txt'
INTO TABLE cprd_data.rl_disdest
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(disdest, description);


#dismeth lookup

CREATE TABLE cprd_data.rl_dismeth
(dismeth TINYINT,
description VARCHAR(100),
PRIMARY KEY (dismeth))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/dismeth.txt'
INTO TABLE cprd_data.rl_dismeth
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(dismeth, description);


#epitype lookup

CREATE TABLE cprd_data.rl_epitype
(epitype TINYINT,
description VARCHAR(300),
PRIMARY KEY (epitype))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/epitype.txt'
INTO TABLE cprd_data.rl_epitype
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(epitype, description);


#firstreg lookup

CREATE TABLE cprd_data.rl_firstreg
(firstreg TINYINT,
description VARCHAR(300),
PRIMARY KEY (firstreg))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/firstreg.txt'
INTO TABLE cprd_data.rl_firstreg
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(firstreg, description);


#gen_ethnicity lookup

CREATE TABLE cprd_data.rl_gen_ethnicity
(gen_ethnicity TINYINT,
description VARCHAR(100),
PRIMARY KEY (gen_ethnicity))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/gen_ethnicity.txt'
INTO TABLE cprd_data.rl_gen_ethnicity
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(gen_ethnicity, description);


#intmanig lookup

CREATE TABLE cprd_data.rl_intmanig
(intmanig TINYINT,
description VARCHAR(100),
PRIMARY KEY (intmanig))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/intmanig.txt'
INTO TABLE cprd_data.rl_intmanig
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(intmanig, description);


#mainspef lookup

CREATE TABLE cprd_data.rl_mainspef
(mainspef CHAR(4),
description VARCHAR(100),
PRIMARY KEY (mainspef))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/mainspef.txt'
INTO TABLE cprd_data.rl_mainspef
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(mainspef, description);


#nhs_indicator lookup

CREATE TABLE cprd_data.rl_nhs_indicator
(nhs_indicator TINYINT,
description VARCHAR(100),
PRIMARY KEY (nhs_indicator))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/nhs_indicator.txt'
INTO TABLE cprd_data.rl_nhs_indicator
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(nhs_indicator, description);


#orgsup lookup

CREATE TABLE cprd_data.rl_orgsup
(orgsup TINYINT,
description VARCHAR(100),
PRIMARY KEY (orgsup))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/orgsup.txt'
INTO TABLE cprd_data.rl_orgsup
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(orgsup, description);


#tretspef lookup

CREATE TABLE cprd_data.rl_tretspef
(tretspef CHAR(4),
description_01Apr2004_onwards VARCHAR(200),
description_up_to_31Mar2004 VARCHAR(100),
PRIMARY KEY (tretspef))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/tretspef.txt'
INTO TABLE cprd_data.rl_tretspef
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(tretspef, description_01Apr2004_onwards, @description_up_to_31Mar2004)
SET description_up_to_31Mar2004 = NULLIF(@description_up_to_31Mar2004,'');


#trustid lookup

CREATE TABLE cprd_data.rl_trustid
(trustid CHAR(3),
description VARCHAR(100),
PRIMARY KEY (trustid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/trustid.txt'
INTO TABLE cprd_data.rl_trustid
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(trustid, description);


#unitbedconfig lookup

CREATE TABLE cprd_data.rl_unitbedconfig
(unitbedconfig TINYINT,
description VARCHAR(400),
PRIMARY KEY (unitbedconfig))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/unitbedconfig.txt'
INTO TABLE cprd_data.rl_unitbedconfig
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(unitbedconfig, description);


