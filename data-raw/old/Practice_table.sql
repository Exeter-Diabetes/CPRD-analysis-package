#Create table
CREATE TABLE CPRD_2020.Practice 
(pracid MEDIUMINT,
lcd DATE,
uts DATE,
region MEDIUMINT,
PRIMARY KEY (pracid))
ENGINE=MYISAM
CHARSET=latin1 COLLATE=latin1_general_ci;


#Insert data (males and females files are the same)
LOAD DATA INFILE '/home/eem/jmd237/diabetes_dec20/covid_nov20_prac_females.txt'
INTO TABLE CPRD_2020.Practice
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(pracid, @orig_lcd, @orig_uts, @orig_region)
SET lcd = STR_TO_DATE(@orig_lcd,'%d/%m/%Y'),
uts = STR_TO_DATE(NULLIF(@orig_uts,''),'%d/%m/%Y'),
region = NULLIF(@orig_region,'');