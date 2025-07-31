set role 'role_full_admin';

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/24_004747_linkage_eligibility_aurum_joined.txt'
INTO TABLE cprd_jun24nondm_data.patids_with_linkage
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, @pracid, @linkyear, @lsoa_e, @sgss_e, @chess_e, @hes_ae_e, @hes_did_e, @cr_e, @sact_e, @rtds_e, @hes_apc_e, @hes_op_e, @ons_death_e);

alter table cprd_jun24nondm_data.patids_with_linkage add column hes_end_date DATE;

update cprd_jun24nondm_data.patids_with_linkage set hes_end_date=STR_TO_DATE("2023-03-31", '%Y-%m-%d');

