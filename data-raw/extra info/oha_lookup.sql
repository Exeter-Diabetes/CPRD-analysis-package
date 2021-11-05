set role 'role_full_admin';

CREATE TABLE IF NOT EXISTS cprd_data.r_oha_lookup
(prodcodeid BIGINT UNSIGNED,
INS BOOL,
TZD BOOL,
SU BOOL,
DPP4 BOOL,
MFN BOOL,
GLP1 BOOL,
Glinide BOOL,
Acarbose BOOL,
SGLT2 BOOL,
PRIMARY KEY (prodcodeid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/diy_lookups/oha_lookup.txt'
INTO TABLE cprd_data.r_oha_lookup
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(prodcodeid, INS, TZD, SU, DPP4, MFN, GLP1, Glinide, Acarbose, SGLT2);