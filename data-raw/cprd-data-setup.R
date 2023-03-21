#!/usr/bin/env Rscript
# This script loads data from zipped files on the filesystem into the CPRD mysql
# Expects a command line argument "dev" or "prod" which defines which
# database we are using to load the data into
# An optional second command line argument defines the path to the .aurum.yml
# file with database connection details



args = commandArgs(trailingOnly=TRUE)

# find the cprd environment
if(length(args)<1) {
  cprdEnv = getOption("cprd.environment",default="dev")
} else {
  cprdEnv = args[1]
}
if(!cprdEnv %in% c("dev","prod")) stop("no such environment: ",cprdEnv)

# find the config file
if(length(args) > 1) {
  cprdConf = args[2]
} else {
  cprdConf = getOption("cprd.config.load",default="~/.aurum.load.yaml")
}
if(!file.exists(cprdConf)) stop("config file not found: ",cprdConf)

library(tidyverse)
setwd("~/Git/aurum")
# check for dependencies and install them if needed
if (!"config" %in% rownames(installed.packages()))
  install.packages("config", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))
if (!"here" %in% rownames(installed.packages()))
  install.packages("here", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))
if (!"openssl" %in% rownames(installed.packages()))
  install.packages("openssl", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))
if (!"archive" %in% rownames(installed.packages()))
  install.packages("archive", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))

# define the path to the current file
here::i_am("data-raw/cprd-data-setup.R")
source(here::here("R/db-utils.R"))

# connect to the database
message("Initialising... using config: ",cprdConf,"; option:",cprdEnv)
cfg = config::get(file = cprdConf,config = cprdEnv)
con <- DBI::dbConnect(RMariaDB::MariaDB(), user = cfg$user, pass=cfg$password, dbname=cfg$dataDatabase, bigint="integer64")
DBI::dbSendStatement(con,"SET ROLE 'role_cprd_admin'") %>% DBI::dbClearResult()

# TODO: make this a command line option
# This drops the log data essentially resetting all progress to zero
# operationalSql %>% execSql("loadLog","drop") %>% DBI::dbClearResult()

dataDb = cfg$dataDatabase

sessionConfig = cfg$sessionConfig
for (name in names(sessionConfig)) {
  value=sessionConfig[[name]]
  message("setting option... ",name,": ",value)
  DBI::dbSendStatement(con,glue::glue("SET {name}={value};", name=name, value=value)) %>% DBI::dbClearResult()
}

## Setup operation tables including log table ----

operationalSql = yaml::read_yaml(here::here("data-raw/operational-tables.yaml"))

tables = DBI::dbListTables(con)

for(tbl in names(operationalSql$tables)) {
  if(
    !is.null(operationalSql$tables[[tbl]][["create"]])
  ) {
    # check table already exists
    if(!operationalSql$naming[tbl] %in% tables) {
      result = operationalSql %>% execSql(tbl,"create")
      message("creating ",tbl)
      result %>% DBI::dbClearResult()
    } else {
      message(tbl, " exists")
    }
  }
}

log = dplyr::tbl(con, operationalSql$naming$loadLog)

## Load reference data tables ----
lookupSql = yaml::read_yaml(here::here("data-raw/lookup-tables.yaml"))
refPath = cfg$lookupSourceDirectory
for(tbl in names(lookupSql$tables)) {
  #tbl = names(lookupSql$tables)[[1]]
  path = glue::glue(lookupSql$paths[[tbl]])
  filedate = as.POSIXct(file.info(path)$ctime)
  md5 = as.character(openssl::md5(path))
  if (
    lookupSql$naming[[tbl]] %in% DBI::dbListTables(con) & # is the table present?
    (log %>% filter(tablename==tbl & hash==md5) %>% count() %>% pull(n) != 0) # is the table at the same version?
  ) {
    message(tbl, " already exists and file hash has not changed ")
  } else {
    lookupSql %>% execSql(tbl,"drop") %>% DBI::dbClearResult()
    lookupSql %>% execSql(tbl,"create") %>% DBI::dbClearResult()
    lookupSql %>% execSql(tbl,"load") %>% logOutcome(sourcepath = path,hash = md5, filedate=filedate,tablename = tbl)
    message("creating ",tbl)
  }
}

## Load main sql files from zips ----
dataSql = yaml::read_yaml(here::here("data-raw/data-tables.yaml"))
# ensure tables exist
tables = DBI::dbListTables(con)
for (table in names(dataSql$tables)) {
  if (!(dataSql$naming[table] %in% tables)) {
    message("creating ",table)
    dataSql %>% execSql(table,"create") %>% DBI::dbClearResult()
  } else {
    message(table," exists")
  }
}

# get listing of contents of all zips
# including the file dates of the second level zips
zips = list.files(path=cfg$dataSourceDirectories,full.names = TRUE)
listing = NULL
for (zip in zips) {
  lsZip = zip::zip_list(zip)
  contents = names(dataSql$tables) %>%
    stringr::str_sub(2) %>%
    sapply(function(x) str_detect(lsZip$filename,x))
  contents = contents %>% as.data.frame()
  colnames(contents) = names(dataSql$tables)
  contents = contents %>% mutate(
    path = lsZip$filename,
    filedate = as.POSIXct(lsZip$timestamp)
  )
  # N.B. this uses the name of the file in the ZIP to determine which table it will load the data into.
  # this will have to be reviewed when additional data sources are being integrated.
  contents = contents %>% pivot_longer(cols=c(-path,-filedate), names_to="tablename")
  #TODO: report files for which content type is missing
  contents = contents %>% filter(value) %>% mutate(file = zip) %>% select(-value)
  listing = listing %>% bind_rows(contents)
}
listing = listing %>% mutate(sourcepath = paste0(file,"/",path))
listing %>% write.csv("~/fileContents.csv",)
log2 = log %>% dplyr::collect()

# The todo list is all files within zips that are not already logged as having been loaded.
# where the path and filedate do not match.
todo = listing %>% left_join(log2 %>% filter(success==1), by=c("tablename","sourcepath"), suffix=c("",".log"))
# FIXME: there seems to be some files from listing that get loaded but not subsequently matched.
# browser()
todo = todo %>% dplyr:: filter(is.na(filedate.log) |  abs(as.numeric(filedate - filedate.log)) < 1/24/60/60)
# Think this is maybe to do with tolerances on matching filedate

message("main data load: ",nrow(todo)," to load")
message("will load: ",min(nrow(todo),cfg$loadLimit))

# TODO: we may have to extend this here as we get new data sources
# execute each row of todo as job (up to a cfg$loadLimit max)
tmpDir = cfg$buildDirectory
for (i in 1:min(nrow(todo),cfg$loadLimit)) {
  job = todo %>% filter(row_number() == i) %>% as.list()
  message(i,"/",nrow(todo)," ",job$file," ",job$path)
  # unzip the file of interest from the uber zip
  zip::unzip(job$file,files = job$path,exdir = tmpDir)
  extract1 = paste0(tmpDir,"/",job$path)

  message("...unzipped", appendLF=FALSE)
  # get the files contained within the sub zip
  files = zip::zip_list(extract1)$filename
  if (length(files)>1) stop("zip file contained more than one file: ",extract1)
  # unzip them and delete zip
  zip::unzip(extract1,files = files,exdir = tmpDir)

  # path to extracted file and sort out permissions
  path = paste0(tmpDir,"/",files)
  Sys.chmod(path)

  # metadata for the log table
  # FIXME: Should this be file(path)? is the md5 incorrect? Difficult to go back without a full reload
  browser()
  md5 = as.character(openssl::md5(path))

  # load the file from {path} into a staging table with schema
  # defined by job$tablename
  stageParams = list(dataDb = dataDb, path=path)
  stageParams[job$tablename] = "staging"
  operationalSql %>% execSql("staging", "drop") %>% DBI::dbClearResult()
  dataSql %>% execSql(job$tablename, "create",params = stageParams) %>% DBI::dbClearResult()
  dataSql %>% execSql(job$tablename, "load",params = stageParams) %>% DBI::dbClearResult()
  message("...staged", appendLF=FALSE)

  # copy across to main table
  tablename=dataSql$naming[[job$tablename]]
  operationalSql %>%
    execSql("staging", "copyStaging", params=list(
      tablename=tablename)
      ) %>%
    logOutcome(sourcepath = job$sourcepath, hash=md5,filedate = job$filedate, tablename = tablename)
  message("...loaded")

  # drop staging table
  operationalSql %>% execSql("staging", "drop") %>% DBI::dbClearResult()

  unlink(extract1)
  unlink(path)

}

message("main data loaded: ",i," items")

# indexing
# go through the indexes and create them if they don't already exist
buildIndexes(dataSql,debug=TRUE, verbose=TRUE)
