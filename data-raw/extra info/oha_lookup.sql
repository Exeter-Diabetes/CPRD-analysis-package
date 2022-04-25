set role 'role_full_admin';

CREATE TABLE IF NOT EXISTS cprd_data.r_oha_lookup
(prodcodeid BIGINT UNSIGNED,
Acarbose BOOL,
DPP4 BOOL,
Glinide BOOL,
GLP1 BOOL,
MFN BOOL,
SGLT2 BOOL,
SU BOOL,
TZD BOOL,
INS BOOL,
drug_substance1 varchar(30),
drug_substance2 varchar(30),
PRIMARY KEY (prodcodeid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/diy_lookups/oha_lookup.txt'
INTO TABLE cprd_data.r_oha_lookup
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(prodcodeid, Acarbose, DPP4, Glinide, GLP1, MFN, SGLT2, SU, TZD, INS, drug_substance1, drug_substance2);