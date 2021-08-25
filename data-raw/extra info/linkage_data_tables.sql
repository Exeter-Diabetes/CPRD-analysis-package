set role 'role_full_admin';

# Linkage availability
CREATE TABLE cprd_data.linkage_availability 
(patid BIGINT UNSIGNED,
hes_e BOOL NOT NULL DEFAULT 0,
death_e BOOL NOT NULL DEFAULT 0,
lsoa_e BOOL NOT NULL DEFAULT 0,
PRIMARY KEY (patid))
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/linkage_data/20_000101_linkage_eligibility_aurum.txt'
INTO TABLE cprd_data.linkage_availability
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, @pracid, @linkdate, hes_e, death_e, @cr_e, lsoa_e, @mh_e);




# CHESS data
CREATE TABLE cprd_data.chess
(patid BIGINT UNSIGNED,
pracid MEDIUMINT,
caseid MEDIUMINT,
n_chess_patid SMALLINT,
trustid SMALLINT,
dateupdated DATE,
weekno TINYINT,
weekofadmission SMALLINT,
yearofadmission SMALLINT,
ageyear SMALLINT,
estimateddateonset DATE,
notknownonset VARCHAR(3),
infectionswabdate DATE,
labtestdate DATE,
typeofspecimen VARCHAR(29),
otherspecimentype VARCHAR(32),
covid19 VARCHAR(3),
influenzaah1n1pdm2009 VARCHAR(3),
influenzaah3n2 VARCHAR(3),
influenzab VARCHAR(3),
influenzaanonsubtyped VARCHAR(3),
influenzaaunsubtypable VARCHAR(3),
rsv VARCHAR(3),
otherresult VARCHAR(3),
admittedfrom VARCHAR(20),
dateadmittedicu DATE,
dateleavingicu DATE,
sbother VARCHAR(128),
sbdate DATE,
ventilatedwhilstadmitted VARCHAR(3),
admissionflu VARCHAR(7),
admissioncovid19 VARCHAR(7),
isviralpneumoniacomplication VARCHAR(3),
isardscomplication VARCHAR(3),
isunknowncomplication VARCHAR(3),
isothercoinfectionscomplication VARCHAR(3),
isothercomplication VARCHAR(3),
issecondarybacterialpneumoniacom VARCHAR(3),
ventilatedwhilstadmitteddays SMALLINT,
patientecmo VARCHAR(3),
wasthepatientadmittedtoicu VARCHAR(7),
organismname VARCHAR(44),
daysecmo SMALLINT,
hospitaladmissiondate DATE,
admissionrsv VARCHAR(7),
respiratorysupportnone VARCHAR(3),
oxygenviacannulaeormask VARCHAR(3),
highflownasaloxygen VARCHAR(3),
noninvasivemechanicalventilation VARCHAR(3),
invasivemechanicalventilation VARCHAR(3),
respiratorysupportecmo VARCHAR(3),
anticovid19treatment VARCHAR(7),
chronicrespiratory VARCHAR(7),
asthmarequiring VARCHAR(7),
chronicheart VARCHAR(7),
chronicrenal VARCHAR(7),
chronicliver VARCHAR(7),
chronicneurological VARCHAR(7),
isdiabetes VARCHAR(7),
diabetestype VARCHAR(8),
immunosuppressiontreatment VARCHAR(7),
immunosuppressiondisease VARCHAR(7),
other VARCHAR(7),
obesityclinical VARCHAR(10),
obesitybmi VARCHAR(9),
pregnancy VARCHAR(7),
gestationweek SMALLINT,
prematurity VARCHAR(7),
hypertension VARCHAR(7),
travelin14days VARCHAR(7),
worksashealthcareworker VARCHAR(7),
contactwithconfirmedcovid19case VARCHAR(7),
finaloutcome VARCHAR(15),
finaloutcomedate DATE,
transferdestination VARCHAR(20),
causeofdeath VARCHAR(25),
hospitaladmissionadmittedfrom VARCHAR(20),
mechanicalinvasiveventilationdur VARCHAR(50),
asymptomatictesting VARCHAR(3),
patientstillonicu VARCHAR(7),
respiratorysupportunknown VARCHAR(3),
seriousmentalillness VARCHAR(7),
priorhospitalattendance VARCHAR(7),
dateofpriorattendance DATE,
admissionnotrelatedtorespiratory VARCHAR(7),
typeorplaceofwork VARCHAR(29),
treatmenttocilizumab VARCHAR(7),
treatmentremdesivir VARCHAR(7),
treatmentother VARCHAR(7),
treatmentconvalescentplasma VARCHAR(7),
primary_key SMALLINT PRIMARY KEY AUTO_INCREMENT)
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/linkage_data/CPRD_aurum_CHESS_March_2021_20_000101.txt'
INTO TABLE cprd_data.chess
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, pracid, caseid, n_chess_patid, trustid, @dateupdated, weekno, @weekofadmission, @yearofadmission, @ageyear, @estimateddateonset, @notknownonset, @infectionswabdate, @labtestdate, typeofspecimen, @otherspecimentype, @covid19, @influenzaah1n1pdm2009, @influenzaah3n2, @influenzab, @influenzaanonsubtyped, @influenzaaunsubtypable, @rsv, @otherresult, @admittedfrom, @dateadmittedicu, @dateleavingicu, @sbother, @sbdate, @ventilatedwhilstadmitted, @admissionflu, @admissioncovid19, @isviralpneumoniacomplication, @isardscomplication, @isunknowncomplication, @isothercoinfectionscomplication, @isothercomplication, @issecondarybacterialpneumoniacom, @ventilatedwhilstadmitteddays, @patientecmo, @wasthepatientadmittedtoicu, @organismname, @daysecmo, @hospitaladmissiondate, @admissionrsv, @respiratorysupportnone, @oxygenviacannulaeormask, @highflownasaloxygen, @noninvasivemechanicalventilation, @invasivemechanicalventilation, @respiratorysupportecmo, @anticovid19treatment, @chronicrespiratory, @asthmarequiring, @chronicheart, @chronicrenal, @chronicliver, @chronicneurological, @isdiabetes, @diabetestype, @immunosuppressiontreatment, @immunosuppressiondisease, @other, @obesityclinical, @obesitybmi, @pregnancy, @gestationweek, @prematurity, @hypertension, @travelin14days, @worksashealthcareworker, @contactwithconfirmedcovid19case, @finaloutcome, @finaloutcomedate, @transferdestination, @causeofdeath, @hospitaladmissionadmittedfrom, @mechanicalinvasiveventilationdur, @asymptomatictesting, @patientstillonicu, @respiratorysupportunknown, @seriousmentalillness, @priorhospitalattendance, @dateofpriorattendance, @admissionnotrelatedtorespiratory, @typeorplaceofwork, @treatmenttocilizumab, @treatmentremdesivir, @treatmentother, @treatmentconvalescentplasma)
SET dateupdated = STR_TO_DATE(NULLIF(@dateupdated,''),'%d/%m/%Y'),
weekofadmission = NULLIF(@weekofadmission,''),
yearofadmission = NULLIF(@yearofadmission,''),
ageyear = IF(@ageyear='' OR @ageyear='-11',NULL,@ageyear),
estimateddateonset = STR_TO_DATE(NULLIF(@estimateddateonset,''),'%d/%m/%Y'),
notknownonset = NULLIF(@notknownonset,''),
infectionswabdate = STR_TO_DATE(NULLIF(@infectionswabdate,''),'%d/%m/%Y'),
labtestdate = IF(@labtestdate='' OR @labtestdate='01/01/2001',NULL,STR_TO_DATE(@labtestdate,'%d/%m/%Y')),
otherspecimentype = NULLIF(@otherspecimentype,''),
covid19 = NULLIF(@covid19,''),
influenzaah1n1pdm2009 = NULLIF(@influenzaah1n1pdm2009,''),
influenzaah3n2 = NULLIF(@influenzaah3n2,''),
influenzab = NULLIF(@influenzab,''),
influenzaanonsubtyped = NULLIF(@influenzaanonsubtyped,''),
influenzaaunsubtypable = NULLIF(@influenzaaunsubtypable,''),
rsv = NULLIF(@rsv,''),
otherresult = NULLIF(@otherresult,''),
admittedfrom = NULLIF(@admittedfrom,''),
dateadmittedicu = STR_TO_DATE(NULLIF(@dateadmittedicu,''),'%d/%m/%Y'),
dateleavingicu = STR_TO_DATE(NULLIF(@dateleavingicu,''),'%d/%m/%Y'),
sbother = NULLIF(@sbother,''),
sbdate = STR_TO_DATE(NULLIF(@sbdate,''),'%d/%m/%Y'),
ventilatedwhilstadmitted = NULLIF(@ventilatedwhilstadmitted,''),
admissionflu = NULLIF(@admissionflu,''),
admissioncovid19 = NULLIF(@admissioncovid19,''),
isviralpneumoniacomplication = NULLIF(@isviralpneumoniacomplication,''),
isardscomplication = NULLIF(@isardscomplication,''),
isunknowncomplication = NULLIF(@isunknowncomplication,''),
isothercoinfectionscomplication = NULLIF(@isothercoinfectionscomplication,''),
isothercomplication = NULLIF(@isothercomplication,''),
issecondarybacterialpneumoniacom = NULLIF(@issecondarybacterialpneumoniacom,''),
ventilatedwhilstadmitteddays = NULLIF(@ventilatedwhilstadmitteddays,''),
patientecmo = NULLIF(@patientecmo,''),
wasthepatientadmittedtoicu = NULLIF(@wasthepatientadmittedtoicu,''),
organismname = NULLIF(@organismname,''),
daysecmo = NULLIF(@daysecmo,''),
hospitaladmissiondate = STR_TO_DATE(NULLIF(@hospitaladmissiondate,''),'%d/%m/%Y'),
admissionrsv = NULLIF(@admissionrsv,''),
respiratorysupportnone = NULLIF(@respiratorysupportnone,''),
oxygenviacannulaeormask = NULLIF(@oxygenviacannulaeormask,''),
highflownasaloxygen = NULLIF(@highflownasaloxygen,''),
noninvasivemechanicalventilation = NULLIF(@noninvasivemechanicalventilation,''),
invasivemechanicalventilation = NULLIF(@invasivemechanicalventilation,''),
respiratorysupportecmo = NULLIF(@respiratorysupportecmo,''),
anticovid19treatment = NULLIF(@anticovid19treatment,''),
chronicrespiratory = NULLIF(@chronicrespiratory,''),
asthmarequiring = NULLIF(@asthmarequiring,''),
chronicheart = NULLIF(@chronicheart,''),
chronicrenal = NULLIF(@chronicrenal,''),
chronicliver = NULLIF(@chronicliver,''),
chronicneurological = NULLIF(@chronicneurological,''),
isdiabetes = NULLIF(@isdiabetes,''),
diabetestype = NULLIF(@diabetestype,''),
immunosuppressiontreatment = NULLIF(@immunosuppressiontreatment,''),
immunosuppressiondisease = NULLIF(@immunosuppressiondisease,''),
other = NULLIF(@other,''),
obesityclinical = NULLIF(@obesityclinical,''),
obesitybmi = NULLIF(@obesitybmi,''),
pregnancy = NULLIF(@pregnancy,''),
gestationweek = NULLIF(@gestationweek,''),
prematurity = NULLIF(@prematurity,''),
hypertension = NULLIF(@hypertension,''),
travelin14days = NULLIF(@travelin14days,''),
worksashealthcareworker = NULLIF(@worksashealthcareworker,''),
contactwithconfirmedcovid19case = NULLIF(@contactwithconfirmedcovid19case,''),
finaloutcome = NULLIF(@finaloutcome,''),
finaloutcomedate = STR_TO_DATE(NULLIF(@finaloutcomedate,''),'%d/%m/%Y'),
transferdestination = NULLIF(@transferdestination,''),
causeofdeath = NULLIF(@causeofdeath,''),
hospitaladmissionadmittedfrom = NULLIF(@hospitaladmissionadmittedfrom,''),
mechanicalinvasiveventilationdur = NULLIF(@mechanicalinvasiveventilationdur,''),
asymptomatictesting = NULLIF(@asymptomatictesting,''),
patientstillonicu = NULLIF(@patientstillonicu,''),
respiratorysupportunknown = NULLIF(@respiratorysupportunknown,''),
seriousmentalillness = NULLIF(@seriousmentalillness,''),
priorhospitalattendance = NULLIF(@priorhospitalattendance,''),
dateofpriorattendance = STR_TO_DATE(NULLIF(@dateofpriorattendance,''),'%d/%m/%Y'),
admissionnotrelatedtorespiratory = NULLIF(@admissionnotrelatedtorespiratory,''),
typeorplaceofwork = NULLIF(@typeorplaceofwork,''),
treatmenttocilizumab = NULLIF(@treatmenttocilizumab,''),
treatmentremdesivir = NULLIF(@treatmentremdesivir,''),
treatmentother = NULLIF(@treatmentother,''),
treatmentconvalescentplasma = NULLIF(@treatmentconvalescentplasma,'');




# HES tables

## hes_patient 
CREATE TABLE cprd_data.hes_patient 
(patid BIGINT UNSIGNED,
pracid MEDIUMINT,
gen_hesid BIGINT UNSIGNED,
n_patid_hes SMALLINT,
gen_ethnicity TINYINT,
match_rank TINYINT,
PRIMARY KEY (patid))
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/linkage_data/hes_patient_20_000101_DM.txt'
INTO TABLE cprd_data.hes_patient
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, pracid, gen_hesid, n_patid_hes, @gen_ethnicity, match_rank)
SET gen_ethnicity = IF(@gen_ethnicity = 'White', 1,
IF(@gen_ethnicity = 'Bl_Carib', 2,
IF(@gen_ethnicity = 'Bl_Afric', 3,
IF(@gen_ethnicity = 'Bl_Other', 4,
IF(@gen_ethnicity = 'Indian', 5,
IF(@gen_ethnicity = 'Pakistani', 6,
IF(@gen_ethnicity = 'Bangladesi', 7,
IF(@gen_ethnicity = 'Oth_Asian', 8,
IF(@gen_ethnicity = 'Chinese', 9,
IF(@gen_ethnicity = 'Mixed', 10,
IF(@gen_ethnicity = 'Other', 11,
IF(@gen_ethnicity = 'Unknown', NULL, NULL))))))))))));


## hes_hospital 
CREATE TABLE cprd_data.hes_hospital
(patid BIGINT UNSIGNED,
spno BIGINT UNSIGNED,
admidate DATE,
discharged DATE,
admimeth CHAR(2),
admisorc TINYINT,
disdest TINYINT,
dismeth TINYINT,
duration MEDIUMINT,
elecdate DATE,
elecdur SMALLINT,
PRIMARY KEY (patid, spno))
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/linkage_data/hes_hospital_20_000101_DM.txt'
INTO TABLE cprd_data.hes_hospital
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, spno, @admidate, @discharged, admimeth, admisorc, disdest, dismeth, @duration, @elecdate, @elecdur)
SET admidate = STR_TO_DATE(NULLIF(@admidate,''),'%d/%m/%Y'),
discharged = STR_TO_DATE(NULLIF(@discharged,''),'%d/%m/%Y'),
duration = NULLIF(@duration,''),
elecdate = STR_TO_DATE(NULLIF(@elecdate,''),'%d/%m/%Y'),
elecdur = NULLIF(@elecdur,'');


## hes_episodes
CREATE TABLE cprd_data.hes_episodes
(patid BIGINT UNSIGNED,
spno BIGINT UNSIGNED,
epikey BIGINT UNSIGNED,
admidate DATE,
epistart DATE,
epiend DATE,
discharged DATE,
eorder SMALLINT,
epidur MEDIUMINT,
epitype TINYINT,
admimeth CHAR(2),
admisorc TINYINT,
disdest TINYINT,
dismeth TINYINT,
mainspef CHAR(3),
tretspef CHAR(3),
pconsult CHAR(16),
intmanig TINYINT,
classpat TINYINT,
firstreg TINYINT,
ethnos TINYINT,
PRIMARY KEY (patid, epikey))
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/linkage_data/hes_episodes_20_000101_DM.txt'
INTO TABLE cprd_data.hes_episodes
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, spno, epikey, @admidate, @epistart, @epiend, @discharged, eorder, @epidur, epitype, admimeth, admisorc, disdest, dismeth, mainspef, tretspef, pconsult, intmanig, classpat, @firstreg, @ethnos)
SET admidate = STR_TO_DATE(NULLIF(@admidate,''),'%d/%m/%Y'),
epistart = STR_TO_DATE(NULLIF(@epistart,''),'%d/%m/%Y'),
epiend = STR_TO_DATE(NULLIF(@epiend,''),'%d/%m/%Y'),
discharged = STR_TO_DATE(NULLIF(@discharged,''),'%d/%m/%Y'),
epidur = NULLIF(@epidur,''),
firstreg = IF(@firstreg='N',1,IF(@firstreg='',NULL,@firstreg)),
ethnos = IF(@ethnos = 'White', 1,
IF(@ethnos = 'Bl_Carib', 2,
IF(@ethnos = 'Bl_Afric', 3,
IF(@ethnos = 'Bl_Other', 4,
IF(@ethnos = 'Indian', 5,
IF(@ethnos = 'Pakistani', 6,
IF(@ethnos = 'Bangladesi', 7,
IF(@ethnos = 'Oth_Asian', 8,
IF(@ethnos = 'Chinese', 9,
IF(@ethnos = 'Mixed', 10,
IF(@ethnos = 'Other', 11,
IF(@ethnos = 'Unknown', NULL, NULL))))))))))));


## hes_diagnosis_epi
CREATE TABLE cprd_data.hes_diagnosis_epi
(patid BIGINT UNSIGNED,
spno BIGINT UNSIGNED,
epikey BIGINT UNSIGNED,
epistart DATE,
epiend DATE,
ICD CHAR(5),
ICDx CHAR(2),
d_order TINYINT,
PRIMARY KEY (patid, epikey, d_order))
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/linkage_data/hes_diagnosis_epi_20_000101_DM.txt'
INTO TABLE cprd_data.hes_diagnosis_epi
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, spno, epikey, @epistart, @epiend, ICD, @ICDx, d_order)
SET epistart = STR_TO_DATE(NULLIF(@epistart,''),'%d/%m/%Y'),
epiend = STR_TO_DATE(NULLIF(@epiend,''),'%d/%m/%Y'),
ICDx = NULLIF(@ICDx,'');


## hes_diagnosis_hosp
CREATE TABLE cprd_data.hes_diagnosis_hosp
(patid BIGINT UNSIGNED,
spno BIGINT UNSIGNED,
admidate DATE,
discharged DATE,
ICD CHAR(5),
ICDx CHAR(2),
primary_key INT PRIMARY KEY AUTO_INCREMENT)
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/linkage_data/hes_diagnosis_hosp_20_000101_DM.txt'
INTO TABLE cprd_data.hes_diagnosis_hosp
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, spno, @admidate, @discharged, ICD, @ICDx)
SET admidate = STR_TO_DATE(NULLIF(@admidate,''),'%d/%m/%Y'),
discharged = STR_TO_DATE(NULLIF(@discharged,''),'%d/%m/%Y'),
ICDx = NULLIF(@ICDx,'');


## hes_primary_diag_hosp
CREATE TABLE cprd_data.hes_primary_diag_hosp
(patid BIGINT UNSIGNED,
spno BIGINT UNSIGNED,
admidate DATE,
discharged DATE,
ICD_PRIMARY CHAR(5),
ICDx CHAR(2),
primary_key INT PRIMARY KEY AUTO_INCREMENT)
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/linkage_data/hes_primary_diag_hosp_20_000101_DM.txt'
INTO TABLE cprd_data.hes_primary_diag_hosp
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, spno, @admidate, @discharged, ICD_PRIMARY, @ICDx)
SET admidate = STR_TO_DATE(NULLIF(@admidate,''),'%d/%m/%Y'),
discharged = STR_TO_DATE(NULLIF(@discharged,''),'%d/%m/%Y'),
ICDx = NULLIF(@ICDx,'');


## hes_procedures_epi
CREATE TABLE cprd_data.hes_procedures_epi
(patid BIGINT UNSIGNED,
spno BIGINT UNSIGNED,
epikey BIGINT UNSIGNED,
admidate DATE,
epistart DATE,
epiend DATE,
discharged DATE,
OPCS CHAR(4),
evdate DATE,
p_order TINYINT,
PRIMARY KEY (patid, epikey, p_order))
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/linkage_data/hes_procedures_epi_20_000101_DM.txt'
INTO TABLE cprd_data.hes_procedures_epi
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, spno, epikey, @admidate, @epistart, @epiend, @discharged, @OPCS, @evdate, p_order)
SET admidate = STR_TO_DATE(NULLIF(@admidate,''),'%d/%m/%Y'),
epistart = STR_TO_DATE(NULLIF(@epistart,''),'%d/%m/%Y'),
epiend = STR_TO_DATE(NULLIF(@epiend,''),'%d/%m/%Y'),
discharged = STR_TO_DATE(NULLIF(@discharged,''),'%d/%m/%Y'),
OPCS=IF(@OPCS='&',NULL,@OPCS),
evdate = STR_TO_DATE(NULLIF(@evdate,''),'%d/%m/%Y');


## hes_acp
CREATE TABLE cprd_data.hes_acp
(patid BIGINT UNSIGNED,
spno BIGINT UNSIGNED,
epikey BIGINT UNSIGNED,
epistart DATE,
epiend DATE,
eorder TINYINT,
epidur SMALLINT,
numacp TINYINT,
acpn TINYINT,
acpstar DATE,
acpend DATE,
acpdur SMALLINT,
intdays SMALLINT,
depdays SMALLINT,
acploc TINYINT,
acpsour TINYINT,
acpdisp TINYINT,
acpout TINYINT,
acpplan TINYINT,
acpspef CHAR(3),
orgsup TINYINT,
primary_key INT PRIMARY KEY AUTO_INCREMENT)
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/linkage_data/hes_acp_20_000101_DM.txt'
INTO TABLE cprd_data.hes_acp
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, spno, epikey, @epistart, @epiend, eorder, @epidur, numacp, @acpn, @acpstar, @acpend, @acpdur, @intdays, @depdays, @acploc, @acpsour, @acpdisp, @acpout, @acpplan, @acpspef, @orgsup)
SET epistart = STR_TO_DATE(@epistart,'%d/%m/%Y'),
epiend = STR_TO_DATE(NULLIF(@epiend,''),'%d/%m/%Y'),
epidur = NULLIF(@epidur,''),
acpn = IF(@acpn='' OR acpn='99',NULL,@acpn),
acpstar = STR_TO_DATE(NULLIF(@acpstar,''),'%d/%m/%Y'),
acpend = STR_TO_DATE(NULLIF(@acpend,''),'%d/%m/%Y'),
acpdur = NULLIF(@acpdur,''),
intdays = NULLIF(@intdays,''),
depdays = NULLIF(@depdays,''),
acploc = NULLIF(@acploc,''),
acpsour = IF(@acpsour='' OR @acpsour='0',NULL,@acpsour),
acpdisp = IF(@acpdisp='' OR @acpdisp='0',NULL,@acpdisp),
acpout = IF(@acpout='' OR @acpout='0',NULL,@acpout),
acpplan = IF(@acpplan='Y',1,IF(@acpplan='N',2,IF(@acpplan='',NULL,@acpplan))),
acpspef = IF(@acpspef='' OR @acpspef='0',NULL,@acpspef),
orgsup = NULLIF(@orgsup,'');


## hes_ccare
CREATE TABLE cprd_data.hes_ccare
(patid BIGINT UNSIGNED,
spno BIGINT UNSIGNED,
epikey BIGINT UNSIGNED,
admidate DATE,
discharged DATE,
epistart DATE,
epiend DATE,
eorder TINYINT,
ccstartdate DATE,
ccstarttime TIME,
ccdisrdydate DATE,
ccdisrdytime TIME,
ccdisdate DATE,
ccdistime TIME,
ccadmitype TINYINT,
ccadmisorc TINYINT,
ccsorcloc TINYINT,
ccdisstat TINYINT,
ccdisdest TINYINT,
ccdisloc TINYINT,
cclev2days SMALLINT,
cclev3days SMALLINT,
bcardsupdays SMALLINT,
acardsupdays SMALLINT,
bressupdays SMALLINT,
aressupdays SMALLINT,
gisupdays SMALLINT,
liversupdays SMALLINT,
neurosupdays SMALLINT,
rensupdays SMALLINT,
dermsupdays SMALLINT,
orgsupmax TINYINT,
ccunitfun TINYINT,
unitbedconfig TINYINT,
bestmatch BOOL DEFAULT NULL,
ccapcrel TINYINT,
primary_key INT PRIMARY KEY AUTO_INCREMENT)
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/linkage_data/hes_ccare_20_000101_DM.txt'
INTO TABLE cprd_data.hes_ccare
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, spno, epikey, @admidate, @discharged, @epistart, @epiend, eorder, @ccstartdate, @ccstarttime, @ccdisrdydate, @ccdisrdytime, @ccdisdate, @ccdistime, @ccadmitype, @ccadmisorc, @ccsorcloc, @ccdisstat, @ccdisdest, @ccdisloc, @cclev2days, @cclev3days, @bcardsupdays, @acardsupdays, @bressupdays, @aressupdays, @gisupdays, @liversupdays, @neurosupdays, @rensupdays, @dermsupdays, @orgsupmax, @ccunitfun, @unitbedconfig, @bestmatch, ccapcrel)
SET admidate = STR_TO_DATE(@admidate,'%d/%m/%Y'),
discharged = STR_TO_DATE(NULLIF(@discharged,''),'%d/%m/%Y'),
epistart = STR_TO_DATE(@epistart,'%d/%m/%Y'),
epiend = STR_TO_DATE(@epiend,'%d/%m/%Y'),
ccstartdate = STR_TO_DATE(@ccstartdate,'%d/%m/%Y'),
ccstarttime = NULLIF(@ccstarttime,''),
ccdisrdydate = STR_TO_DATE(NULLIF(@ccdisrdydate,''),'%d/%m/%Y'),
ccdisrdytime = NULLIF(@ccdisrdytime,''),
ccdisdate = STR_TO_DATE(@ccdisdate,'%d/%m/%Y'),
ccdistime = NULLIF(@ccdistime,''),
ccadmitype = NULLIF(@ccadmitype,''),
ccadmisorc = NULLIF(@ccadmisorc,''),
ccsorcloc = NULLIF(@ccsorcloc,''),
ccdisstat = NULLIF(@ccdisstat,''),
ccdisdest = NULLIF(@ccdisdest,''),
ccdisloc = NULLIF(@ccdisloc,''),
cclev2days = IF(@cclev2days='' OR @cclev2days='999',NULL,@cclev2days),
cclev3days = IF(@cclev3days='' OR @cclev3days='999',NULL,@cclev3days),
bcardsupdays = IF(@bcardsupdays='' OR @bcardsupdays='999',NULL,@bcardsupdays),
acardsupdays = IF(@acardsupdays='' OR @acardsupdays='999',NULL,@acardsupdays),
bressupdays = IF(@bressupdays='' OR @bressupdays='999',NULL,@bressupdays),
aressupdays = IF(@aressupdays='' OR @aressupdays='999',NULL,@aressupdays),
gisupdays = IF(@gisupdays='' OR @gisupdays='999',NULL,@gisupdays),
liversupdays = IF(@liversupdays='' OR @liversupdays='999',NULL,@liversupdays),
neurosupdays = IF(@neurosupdays='' OR @neurosupdays='999',NULL,@neurosupdays),
rensupdays = IF(@rensupdays='' OR @rensupdays='999',NULL,@rensupdays),
dermsupdays = IF(@dermsupdays='' OR @dermsupdays='999',NULL,@dermsupdays),
orgsupmax = NULLIF(@orgsupmax,''),
ccunitfun = NULLIF(@ccunitfun,''),
unitbedconfig = NULLIF(@unitbedconfig,''),
bestmatch = NULLIF(@bestmatch,'');




# IMD tables

## patient_imd2015
CREATE TABLE cprd_data.patient_imd2015
(patid BIGINT UNSIGNED,
pracid MEDIUMINT,
imd2015_10 TINYINT,
PRIMARY KEY (patid))
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/linkage_data/patient_imd2015_20_000101.txt'
INTO TABLE cprd_data.patient_imd2015
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, pracid, @imd2015_10)
SET imd2015_10 = NULLIF(@imd2015_10,'');



## practice_imd
CREATE TABLE cprd_data.practice_imd
(pracid MEDIUMINT,
country VARCHAR(9),
e2015_imd_10 TINYINT,
ni2017_imd_10 TINYINT,
s2016_imd_10 TINYINT,
w2014_imd_10 TINYINT,
PRIMARY KEY (pracid))
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/linkage_data/practice_imd_20_000101.txt'
INTO TABLE cprd_data.practice_imd
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(pracid, country, @e2015_imd_10, @ni2017_imd_10, @s2016_imd_10, @w2014_imd_10)
SET e2015_imd_10 = NULLIF(@e2015_imd_10,''),
ni2017_imd_10 = NULLIF(@ni2017_imd_10,''),
s2016_imd_10 = NULLIF(@s2016_imd_10,''),
w2014_imd_10 = NULLIF(@w2014_imd_10,'');




# ONS death
CREATE TABLE cprd_data.ons_death
(patid BIGINT UNSIGNED,
pracid MEDIUMINT,
gen_death_id BIGINT UNSIGNED,
n_patid_death SMALLINT,
match_rank TINYINT,
dor DATE,
dod DATE,
dod_partial SMALLINT,
nhs_indicator TINYINT,
pod_category VARCHAR(21),
cause VARCHAR(5),
cause1 VARCHAR(5),
cause2 VARCHAR(5),
cause3 VARCHAR(5),
cause4 VARCHAR(5),
cause5 VARCHAR(5),
cause6 VARCHAR(5),
cause7 VARCHAR(5),
cause8 VARCHAR(5),
cause9 VARCHAR(5),
cause10 VARCHAR(5),
cause11 VARCHAR(5),
cause12 VARCHAR(5),
cause13 VARCHAR(5),
cause14 VARCHAR(5),
cause15 VARCHAR(5),
PRIMARY KEY (patid))
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/linkage_data/death_patient_20_000101_DM.txt'
INTO TABLE cprd_data.ons_death
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, pracid, gen_death_id, n_patid_death, match_rank, @dor, @dod, @dod_partial, nhs_indicator, @pod_category, @cause, @cause1, @cause2, @cause3, @cause4, @cause5, @cause6, @cause7, @cause8, @cause9, @cause10, @cause11, @cause12, @cause13, @cause14, @cause15)
SET dor = STR_TO_DATE(@dor,'%d/%m/%Y'),
dod = STR_TO_DATE(NULLIF(@dod,''),'%d/%m/%Y'),
dod_partial = IF(@dod_partial='' OR @dod_partial='--',NULL,SUBSTR(@dod_partial,1,4)),
pod_category = NULLIF(@pod_category,''),
cause = NULLIF(@cause,''),
cause1 = NULLIF(@cause1,''),
cause2 = NULLIF(@cause2,''),
cause3 = NULLIF(@cause3,''),
cause4 = NULLIF(@cause4,''),
cause5 = NULLIF(@cause5,''),
cause6 = NULLIF(@cause6,''),
cause7 = NULLIF(@cause7,''),
cause8 = NULLIF(@cause8,''),
cause9 = NULLIF(@cause9,''),
cause10 = NULLIF(@cause10,''),
cause11 = NULLIF(@cause11,''),
cause12 = NULLIF(@cause12,''),
cause13 = NULLIF(@cause13,''),
cause14 = NULLIF(@cause14,''),
cause15 = NULLIF(@cause15,'');




# SGSS
CREATE TABLE cprd_data.sgss
(patid BIGINT UNSIGNED,
pracid MEDIUMINT,
n_patid_spec SMALLINT,
pseudo_specimen_id MEDIUMINT,
organism_species_name CHAR(33),
lab_report_date DATE,
age_in_years SMALLINT,
reporting_lab_id SMALLINT,
specimen_date DATE,
care_home BOOL DEFAULT NULL,
primary_key SMALLINT PRIMARY KEY AUTO_INCREMENT)
CHARSET=latin1 COLLATE=latin1_general_ci;

LOAD DATA INFILE '/slade/DBs/mysql-files/CPRD/linkage_data/CPRD_SGSS_March_2021_20_000101.txt'
INTO TABLE cprd_data.sgss
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(patid, pracid, n_patid_spec, pseudo_specimen_id, organism_species_name, @lab_report_date, @age_in_years, reporting_lab_id, @specimen_date, @care_home)
SET lab_report_date = STR_TO_DATE(@lab_report_date,'%d/%m/%Y'),
age_in_years = IF(@age_in_years='' OR @age_in_years='-1',NULL,@age_in_years),
specimen_date = STR_TO_DATE(@specimen_date,'%d/%m/%Y'),
care_home = IF(@care_home='FALSE',0,IF(@care_home='TRUE',1,IF(@care_home='',NULL,@care_home)));