#!/usr/bin/env Rscript
# This script loads data from zipped files on the filesystem into the CPRD mysql
# Expects a command line argument "dev" or "prod" which defines which
# database we are using to load the data into
# An optional second command line argument defines the path to the .aurum.yml
# file with database connection details
## make yaml data config available as part of package

library(tidyverse)
# setwd("~/Git/aurum")
 setwd("C:/Users/ky279/OneDrive - University of Exeter/CPRD/Exeter_Diabetes_aurum_package")
# check for dependencies and install them if needed
if (!"here" %in% rownames(installed.packages()))
  install.packages("here", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))

# define the path to the current file
here::i_am("data-raw/cprd-config-setup.R")

operationalSql = yaml::read_yaml(here::here("data-raw/operational-tables.yaml"))
lookupSql = yaml::read_yaml(here::here("data-raw/lookup-tables.yaml"))
dataSql = yaml::read_yaml(here::here("data-raw/data-tables.yaml"))
analysisSql = yaml::read_yaml(here::here("data-raw/analysis-tables.yaml"))
codeSetsSql = yaml::read_yaml(here::here("data-raw/codeset-tables.yaml"))
qrisk2Constants = yaml::read_yaml(here::here("data-raw/qrisk2_constants.yaml"))

usethis::use_data(operationalSql,overwrite = TRUE)
usethis::use_data(lookupSql,overwrite = TRUE)
usethis::use_data(dataSql,overwrite = TRUE)
usethis::use_data(analysisSql,overwrite = TRUE)
usethis::use_data(codeSetsSql,overwrite = TRUE)
usethis::use_data(qrisk2Constants,overwrite = TRUE)

# install this version of the setup.
# devtools::install_local(here::here("."))
