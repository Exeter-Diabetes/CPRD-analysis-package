#!/usr/bin/env Rscript
# This script loads data from zipped files on the filesystem into the CPRD mysql
# Expects a command line argument "dev" or "prod" which defines which
# database we are using to load the data into
# An optional second command line argument defines the path to the .aurum.yml
# file with database connection details

args = commandArgs(trailingOnly=TRUE)



# find the cprd environment
if(length(args)<1) {
  cprdEnv=getOption("cprd.environment",default="dev")
} else {
  cprdEnv = args[1]
}
if(!cprdEnv %in% c("dev","prod")) stop("no such environment: ",cprdEnv)

# find the config file
if(length(args) > 1) {
  cprdConf = args[2]
} else {
  cprdConf = getOption("cprd.config",default="~/.aurum.load.yaml")
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

# define the path to the current file
here::i_am("data-raw/cprd-index-setup.R")
source(here::here("R/db-utils.R"))

# connect to the database
message("Initialising... using config: ",cprdConf,"; option:",cprdEnv)
cfg = config::get(file = cprdConf,config = cprdEnv)
con <- DBI::dbConnect(RMariaDB::MariaDB(), user = cfg$user, pass=cfg$password, dbname=cfg$dataDatabase, bigint="integer64")
DBI::dbSendStatement(con,"SET ROLE 'role_cprd_admin'") %>% DBI::dbClearResult()

sessionConfig = cfg$sessionConfig
for (name in names(sessionConfig)) {
  value=sessionConfig[[name]]
  message("setting option... ",name,": ",value)
  DBI::dbSendStatement(con,glue::glue("SET {name}={value};", name=name, value=value)) %>% DBI::dbClearResult()
}



# TODO: make this a command line option
# This drops the log data essentially resetting all progress to zero
# operationalSql %>% execSql("loadLog","drop") %>% DBI::dbClearResult()

if(is.null(cfg$dataDatabase)) stop("config file must define the aurum data database location")
dataDb = cfg$dataDatabase



## Load main sql files from zips ----

dataSql = yaml::read_yaml(here::here("data-raw/data-tables.yaml"))



# indexing
# go through the indexes and create them if they dont already exist
buildIndexes(dataSql, verbose=TRUE)
