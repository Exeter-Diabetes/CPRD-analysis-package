set role 'role_full_admin';

CREATE TABLE IF NOT EXISTS cprd_data.r_biomarker_acceptable_units
(biomarker VARCHAR(20),
numunitid BIGINT)
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/diy_lookups/biomarker_acceptable_units.txt'
INTO TABLE cprd_data.r_biomarker_acceptable_units
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(biomarker, @numunitid)
SET numunitid = NULLIF(@numunitid,'');

CREATE TABLE IF NOT EXISTS cprd_data.r_biomarker_acceptable_limits
(biomarker VARCHAR(20),
lower_limit DECIMAL(8,2),
upper_limit DECIMAL(8,2),
PRIMARY KEY (biomarker))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/diy_lookups/biomarker_acceptable_limits.txt'
INTO TABLE cprd_data.r_biomarker_acceptable_limits
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(biomarker, lower_limit, upper_limit);