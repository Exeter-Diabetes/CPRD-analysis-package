set role 'role_full_admin';

drop table cprd_data.rl_icd10_dict;
CREATE TABLE IF NOT EXISTS cprd_data.rl_icd10_dict
(icd10 VARCHAR(6),
alt_code VARCHAR(5),
usage_ VARCHAR(8),
usage_uk TINYINT,
description VARCHAR(200),
modifier_4 VARCHAR(100),
modifier_5 VARCHAR(100),
qualifiers VARCHAR(200),
gender_mask TINYINT,
min_age TINYINT,
max_age TINYINT,
tree_description VARCHAR(200),
PRIMARY KEY (icd10))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/icd10_dict.txt'
INTO TABLE cprd_data.rl_icd10_dict
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(icd10, alt_code, usage_, usage_uk, description, @modifier_4, @modifier_5, @qualifiers, @gender_mask, @min_age, @max_age, @tree_description)
SET modifier_4 = NULLIF(@modifier_4,''),
modifier_5 = NULLIF(@modifier_5,''),
qualifiers = NULLIF(@qualifiers,''),
gender_mask = NULLIF(@gender_mask,''),
min_age = NULLIF(@min_age,''),
max_age = NULLIF(@max_age,''),
tree_description = NULLIF(@tree_description,'');
 

CREATE TABLE IF NOT EXISTS cprd_data.rl_opcs4_dict
(opcs4 VARCHAR(4),
code VARCHAR(5),
description VARCHAR(200),
PRIMARY KEY (opcs4))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/reference-data/linkage_lookups/opcs4_dict.txt'
INTO TABLE cprd_data.rl_opcs4_dict
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(code, opcs4, description);