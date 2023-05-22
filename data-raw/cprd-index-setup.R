#!/usr/bin/env Rscript
# This script loads data from zipped files on the filesystem into the CPRD mysql
# Expects a command line argument "dev" or "prod" which defines which
# database we are using to load the data into
# An optional second command line argument defines the path to the .aurum.yml
# file with database connection details

args = commandArgs(trailingOnly=TRUE)

# Running this as a script on the command line gave me some issues because
# the easybuild system does not correctly configure the libPaths.
# TODO: This is probably possible to fix somehow but results in package version conflicts
.libPaths(c("~/R/x86_64-pc-linux-gnu-library/4.0",
            "/software/easybuild/software/R-bundle-Packages/4.0.3-foss-2020a",
            "/software/easybuild/software/R/4.0.3-foss-2020a/lib64/R/library"))


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
# define the path to the current file
here::i_am("data-raw/cprd-index-setup.R")
setwd(here::here())

# check for dependencies and install them if needed
if (!"config" %in% rownames(installed.packages()))
  install.packages("config", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))
if (!"here" %in% rownames(installed.packages()))
  install.packages("here", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))
if (!"openssl" %in% rownames(installed.packages()))
  install.packages("openssl", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))


source(here::here("R/db-utils.R"))
source(here::here("data-raw/load-utils.R"))

message("Initialising... using config: ",cprdConf,"; option:",cprdEnv)
cfg = config::get(file = cprdConf,config = cprdEnv)

# setup slack bot
if (!is.null(cfg$slackToken)) {
  slackr::slackr_setup(channel = cfg$slackChannel, incoming_webhook_url = cfg$slackWebhook, token = cfg$slackToken)
  Sys.setenv(USE_SLACK = "yes")
} else {
  warning("No slack set up detected.")
}

# connect to the database

con <- DBI::dbConnect(RMariaDB::MariaDB(), user = cfg$user, pass=cfg$password, dbname=cfg$dataDatabase, bigint="integer64")
DBI::dbSendStatement(con,"SET ROLE 'role_cprd_loader'") %>% DBI::dbClearResult()

# This has been set to the maximum in the server config
# sessionConfig = cfg$sessionConfig
# for (name in names(sessionConfig)) {
#   value=sessionConfig[[name]]
#   message("setting option... ",name,": ",value)
#   DBI::dbSendStatement(con,glue::glue("SET {name}={value};", name=name, value=value)) %>% DBI::dbClearResult()
# }

.slack_message(
  sprintf("Initialising indexer: %s",toupper(cprdEnv))
)

if(is.null(cfg$dataDatabase)) stop("config file must define the aurum data database location")
dataDb = cfg$dataDatabase



## Load main sql files from zips ----
dataSql = yaml::read_yaml(here::here("data-raw/data-tables.yaml"))

indexes = DBI::dbSendQuery(con, "SELECT * FROM information_schema.statistics WHERE table_schema = 'full_cprd_data'")
idx = DBI::dbFetch(indexes)
idx_name = idx %>% filter(INDEX_NAME != "PRIMARY") %>% pull(INDEX_NAME)
DBI::dbClearResult(indexes)

sqlTemplates = dataSql
params=sqlTemplates$naming
indexErrors = 0
indexSkips = 0

message("indexing")
sqlIndexes = sqlTemplates$indexes
sqlIndexes = unname(sapply(sqlIndexes, function(i) glue::glue_data(.x=params,i)))
exists = sapply(sqlIndexes, function(x) any(stringr::str_detect(x,idx_name)))

# exists_name = sapply(sqlIndexes, function(x) idx_name[stringr::str_which(x,idx_name)])

.slack_message(
  "Skipping existing indices:",
  paste0(sqlIndexes[exists],collapse="\n")
)

sqlIndexes = sqlIndexes[!exists]
# debug = TRUE
debug = FALSE

last_report = Sys.time()-3600*cfg$reportIndexingProgress
i=0
report = NULL
for (sql in sqlIndexes) {

  #.sleepDuringDay()
  i = i+1
  iname = sql %>% stringr::str_extract("x_.*?\\s") %>% trimws()

  if (as.integer(difftime(Sys.time(),last_report,units = "sec")) >= 3600*cfg$reportIndexingProgress-1) {
    .slack_message(
      if (i == 1) "start indexing." else report,
      sprintf("index progress: %d/%d current: %s", i, length(sqlIndexes), iname)
    )
    last_report = Sys.time()
    report = "\ncompleted: "
  }

  status = tryCatch({
    # there is no way to create an index if exists
    if (!debug) {
      DBI::dbSendStatement(con,sql) %>% DBI::dbClearResult()
    }
    if (i %% 10 == 0) sprintf("%d",i) else "."
    # sprintf("reated index %d/%d: %s\n", i,length(sqlIndexes), sql)

  },
  error = function(e) {
    # ignore duplicate key name errors
    if (!stringr::str_detect(e$message, "Duplicate key name")) {
      indexErrors <<- indexErrors + 1
      return(sprintf("\nskipped index %s\nerror was: %s\n", iname, e$message))
    } else {
      indexSkips <<- indexSkips + 1
      return(NULL)
    }
  }
  )

  report = paste0(report,status,collapse="")



}

.slack_message(
  report,
  "\nindexing complete."
)
