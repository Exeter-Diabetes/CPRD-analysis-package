#!/usr/bin/env Rscript
# This script loads data from zipped files on the filesystem into the CPRD mysql
# This script expects a command line argument "dev" or "prod" which defines which
# database we are using to load the data into (default = "dev")
# An optional second command line argument defines the path to the .aurum.yml
# file with database connection details (default = "~/.aurum.full-load.yaml")

args = commandArgs(trailingOnly=TRUE)

## Setup the loader, get the configuration, initialise the slack bot and connect to the database ----

# Running this as a script on the command line gave me some issues because
# the easybuild system does not correctly configure the libPaths.
# TODO: This is probably possible to fix somehow but results in package version conflicts
.libPaths(c("~/R/x86_64-pc-linux-gnu-library/4.2",
            "/software/easybuild/software/R-bundle-Packages/4.0.3-foss-2020a",
            "/software/easybuild/software/R/4.0.3-foss-2020a/lib64/R/library"))

# find the cprd environment configuration
if(length(args)<1) {
  cprdEnv = getOption("cprd.environment",default="dev")
} else {
  cprdEnv = args[1]
}
if(!cprdEnv %in% c("dev","prod")) stop("no such environment: ",cprdEnv)

# find the config file location
if(length(args) > 1) {
  cprdConf = args[2]
} else {
  cprdConf = getOption("cprd.config.load",default="~/.aurum.full-load.yaml")
}
if(!file.exists(cprdConf)) stop("config file not found: ",cprdConf)

# Check needed libraries are set up and if no set them up:
# check for dependencies and install them if needed
library(tidyverse)
here::i_am("CPRD-analysis-package/data-raw/cprd-data-setup.R")
setwd(here::here())

if (!"config" %in% rownames(installed.packages()))
  install.packages("config", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))
if (!"here" %in% rownames(installed.packages()))
  install.packages("here", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))
if (!"openssl" %in% rownames(installed.packages()))
  install.packages("openssl", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))
if (!"slackr" %in% rownames(installed.packages()))
  install.packages("slackr", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))

# load utilities functions from the rest of the package
source(here::here("CPRD-analysis-package/R/db-utils.R"))
source(here::here("CPRD-analysis-package/R/7zip.R"))
source(here::here("CPRD-analysis-package/data-raw/load-utils.R"))

# load configuration and set up the slack bot.
message("Initialising... using config: ",cprdConf,"; option:",cprdEnv)
cfg = config::get(file = cprdConf,config = cprdEnv)
# setup slack bot
if (!is.null(cfg$slackToken)) {
  slackr::slackr_setup(channel = cfg$slackChannel, incoming_webhook_url = cfg$slackWebhook, token = cfg$slackToken)
  Sys.setenv(USE_SLACK = "yes")
} else {
  warning("No slack set up detected.")
}

# configure halting during daytime
if (isTRUE(cfg$ignoreSleep)) {
  Sys.setenv(IGNORE_SLEEP = "yes")
}

# Send a start message
.slack_message(
  sprintf("Initialising loader: %s",toupper(cprdEnv)),
  sprintf("reference data directory: %s",cfg$lookupSourceDirectory),
  sprintf("table data directory: %s", cfg$dataSourceDirectories)
)

# Connect to the database and switch to the loader role:
con <- DBI::dbConnect(RMariaDB::MariaDB(), user = cfg$user, pass=cfg$password, dbname=cfg$dataDatabase, bigint="integer64", load_data_local_infile = TRUE)
DBI::dbSendStatement(con,"SET ROLE 'role_cprd_loader'") %>% DBI::dbClearResult()



dataDb = cfg$dataDatabase

# sessionConfig = cfg$sessionConfig
# for (name in names(sessionConfig)) {
#  value=sessionConfig[[name]]
#  message("setting option... ",name,": ",value)
#  DBI::dbSendStatement(con,glue::glue("SET {name}={value};", name=name, value=value)) %>% DBI::dbClearResult()
#}

## Setup operation tables including log table ----

# At this point we need to set up and operational tables
# if they do not already exist. This will generally only
# happen on the first run in a fully clean database. This is mainly
# the log table, which will contain the list of files loaded so far from the
# source data and information about the file date and md5 of the files to
# enable identifying files that have already been loaded.

operationalSql = yaml::read_yaml(here::here("CPRD-analysis-package/data-raw/operational-tables.yaml"))

# This drops the log data essentially resetting all progress to zero.
# TODO: make this a command line option
# operationalSql %>% execSql("loadLog","drop") %>% DBI::dbClearResult()

tables = DBI::dbListTables(con)

# This checks what operation tables are defined in operational-tables.yaml
# and creates them
for(tbl in names(operationalSql$tables)) {
  if(
    !is.null(operationalSql$tables[[tbl]][["create"]])
  ) {
    # check table already exists
    if(!operationalSql$naming[tbl] %in% DBI::dbListTables(con)) {
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

# The loader then setup up the reference data tables
# This uses the same approach of lookup-tables.yaml to define the
# file configuration. This allows reference data to be
# The reference data tables are relatively small and their indexing
# is fully defined in the lookup-tables.yaml files and loading happens in
# a single step.

lookupSql = yaml::read_yaml(here::here("CPRD-analysis-package/data-raw/lookup-tables.yaml"))
refPath = cfg$lookupSourceDirectory
for(tbl in names(lookupSql$tables)) {
  #tbl = names(lookupSql$tables)[[1]]
  path = glue::glue(lookupSql$paths[[tbl]])
  filedate = as.POSIXct(file.info(path)$ctime)
  md5 = as.character(as.character(openssl::md5(file(path))))
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

# because the main data files are big and delivered in multiple files we
# load them in chunks. In general it is better to defer indexing until the end.
# The overall process is as a result somewhat complicated.
# In general the steps go like this:

# 1) from all the data files identify chunks to load and which target table to load them to
# 2) compare this to files we have already loaded from the log table to create a todo list
# 3) iterate through this todo list
# 4) extract the file for a chunk from the original data zip file
# 5) load each chunk into a staging table, creating a primary key for the chunk
# 6) append the data from the staging table into the target table
# 7) repeat for next chunk in todo list
# 8) once all chuncks are loaded (or we have hit a configurable limit) create secondary indexes

## Ensure the target tables exist ----

# Unlike the reference data tables at the moment there is no way to
# drop all the data from the data tables. This is partly by design
# as it allows for incremental update of the data if and when an updated
# set of data is provided by rerunning the loader with new files. In this
# situation the relevant rows will be overwritten, but the tables and associated
# indexes will already exist. In general through when installing from a clean
# database then the tables will be created from scratch.

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

## Identify all the files that need loading ----

# The contents of all the files are used to compare to the log of files we
# have already loaded. This allows us to identify chunks that have already been loaded
# The raw data is in zip of zips or in 7z archives as .txt files. First we get a
# listing of contents of all zips including the file dates of the contents, and
# using heurisitics based on the file name we can identify the target table for
# each individual zip.

zips = list.files(path=cfg$dataSourceDirectories,full.names = TRUE)
listing = NULL
for (zip in zips) {
  lsZip = .listZip(zip)
  contents = names(dataSql$tables) %>%
    stringr::str_sub(2) %>%
    sapply(function(x) str_detect(lsZip$filename,stringr::fixed(x,ignore_case=TRUE)))
  contents = contents %>% as.data.frame()
  colnames(contents) = names(dataSql$tables)
  contents = contents %>% mutate(
    path = lsZip$filename,
    filedate = as.POSIXct(lsZip$timestamp)
  )

  # N.B. this uses the name of the file in the ZIP to determine which target table it will
  # load the data into. this will have to be reviewed when additional data sources are being integrated.
  # TODO: check how the hes data files arrive.
  contents = contents %>% pivot_longer(cols=c(-path,-filedate), names_to="tablename")

  contents = contents %>% filter(value) %>% mutate(file = zip) %>% select(-value)
  listing = listing %>% bind_rows(contents)
}

# The chunks of data are csv or txt files which may be zipped in the original uber zip / 7z files.
listing = listing %>%
  mutate(sourcepath = paste0(file,"/",path)) %>%
  filter(fs::path_ext(path) %in% c("zip","csv","txt") )

# The todo list is all files within zips that are not already logged as having been loaded.
# this is determined by finding data chunks where the path and filedate do not match contents
# that have already been loaded.
# While we are at it we sort the todo list into natural order so that hopefully primary keys are
# loaded in sequence. This should reduce primary key indexing time.

log2 = log %>% dplyr::collect()
todo = listing %>%
  dplyr::left_join(log2 %>% filter(success==1), by=c("tablename","sourcepath"), suffix=c("",".log")) %>%
  dplyr::filter(
    is.na(filedate.log) |
    as.numeric(filedate - filedate.log) > 1/24/60/60
  ) %>%
  dplyr::mutate(
    # Zero pad numbers in path to allow natural sorting
    .sort = path %>% stringr::str_replace_all("set([0-9]+)_","set00\\1_") %>% stringr::str_replace_all("set0*([0-9]{3})_","set\\1_")
  ) %>%
  dplyr::arrange(
    tablename,
    .sort
  ) %>%
  dplyr::select(-.sort)

# Post the todo list to slack
if (Sys.getenv("USE_SLACK") == "yes") {
  slackr::slackr_csv(todo, initial_comment = "Queued data files.")
}

.slack_message(
  sprintf("main data load: %d to load",nrow(todo)),
  sprintf("will load: %d",min(nrow(todo),cfg$loadLimit))
)

## Execute each row of todo as job ----

# this cycles through the todo list (up to a cfg$loadLimit max)
# this process will only operate between the hours of 8pm and 8am
# it extracts the data chunk from the zip file.
# loads it into staging table
# and copies that accross to target table. (ultimately using the nae of the data
# chunk and the configuration in data-tables.yaml

tmpDir = cfg$buildDirectory # directory to use for extracting data
todoSize = nrow(todo)
jobSize = min(todoSize,cfg$loadLimit)

tableErrors = 0

for (i in 1:jobSize) {

  # Only work during the night time
  .sleepDuringDay()

  # get details of the next job in terms of data chunk location
  job = todo %>% filter(row_number() == i) %>% as.list()

  # report progress every so often (this is configurable)
  if (i %% cfg$reportProgress == 0) {
    .slack_message(
      sprintf("job load (table %s): %d/%d (total %d)",
        job$tablename,
        i,
        jobSize,
        todoSize
      )
    )
  }

  message(i,"/",nrow(todo)," ",job$file," ",job$path, appendLF=FALSE)

  # unzip the file of interest from the uber zip
  # This may be a zip of zips or a 7z file depending on the nature of the
  # CPRD files given to us. We are extracting just one file from the uber zip
  # based on the path in the todo dataframe. This corresponds to one data chunk relevant
  # to one table.
  extract1 = .doUnzip(job$file,path = job$path,dir = tmpDir)
  message("...unzipped", appendLF=FALSE)

  # If the original data was a zip of zips we get the files contained within the sub zip if exists
  # If the data chunk is not a zip this will do nothing.
  path = .doUnzip(extract1,path = NULL,tmpDir)

  tryCatch({

    if (length(path)>1) stop("second level zip file contained more than one file: ",extract1)

    # sort out permissions
    Sys.chmod(path)

    # metadata for the log table
    md5 = as.character(as.character(openssl::md5(file(path))))

    # load the file from {path} into a staging table with schema
    # defined by job$tablename.
    # The load job occurs in 2 stages. LOAD DATA INFILE, to a staging table
    # then an INSERT IGNORE INTO <dest> SELECT * FROM staging.
    # The staging table has a primary key to make sure this second step is as quick as possible.
    # This is done to allow interruption and resuming and chunk the load into smaller
    # pieces. It is also done to allow overwriting of data.

    stageParams = list(dataDb = dataDb, path=path)
    stageParams[job$tablename] = "staging"

    # get rid of existing staging table
    operationalSql %>% execSql("staging", "drop") %>% DBI::dbClearResult()
    # create a new staging table using the schema for the final target table
    dataSql %>% execSql(job$tablename, "create",params = stageParams) %>% DBI::dbClearResult()
    # load data into the staging table using the load command for the
    dataSql %>% execSql(job$tablename, "load",params = stageParams) %>% DBI::dbClearResult()
    message("...staged", appendLF=FALSE)

    # copy across to target table
    tablename=dataSql$naming[[job$tablename]]

      operationalSql %>%
        execSql("staging", "copyStaging", params=list(
          tablename=tablename)
        ) %>%
        # If successful the load process will log details about the file that was loaded and how many rows were updated
        logOutcome(sourcepath = job$sourcepath, hash=md5,filedate = job$filedate, tablename = tablename)

    message("...loaded")

    # drop staging table
    operationalSql %>% execSql("staging", "drop") %>% DBI::dbClearResult()


  },error = function(e) {

    # somethign went wrong loading this data chunk.
    # We report this via slack but will continue anyway.
    .slack_message(
      sprintf("ERROR loading data into table: %s",job$tablename),
      e$message
    )

    tableErrors = tableErrors + 1

  })

  # clean up extracted files
  unlink(extract1)
  if (path != extract1) unlink(path)

}

# At this stage the data is all loaded (up to the limit defined in the configuration file)

.slack_message(
  sprintf("main data loaded: %d/%d (total %d) items",
      i,
      jobSize,
      todoSize)
)

## Create indexes ----

# The secondary indexing is sometimes going to already have been defined at this stage
# e.g. If a load process completed then they will be created, or if this load is an incremental
# update to an existing database. Because the indexing is time consuming we do not want to repeat it,
# and the existance of the index has been ignored.

# However if this was a load from scratch on an empty database the secondary indexes will not exist.
# We now go through the indexes defined in data-tables.yaml and try to create them one by one.
# if they already exist this will throw an error. We can't really differentiate between this and
# indexing failing due to an error in the SQL, so we have to report it.

# This will result in a

sqlTemplates = dataSql
params=sqlTemplates$naming
indexErrors = 0
indexSkips = 0

message("indexing")
sqlIndexes = sqlTemplates$indexes
sqlIndexes = unname(sapply(sqlIndexes, function(i) glue::glue_data(.x=params,i)))
i=0
report = NULL
for (sql in sqlIndexes) {
  i = i+1
  .sleepDuringDay()

  status = tryCatch({
      # there is no way to create an index if exists
      DBI::dbSendStatement(con,sql) %>% DBI::dbClearResult()
      sprintf("Created index %d/%d: %s", i,length(sqlIndexes))
    },
    error = function(e) {
      # ignore duplicate key name errors
      if (!stringr::str_detect(e$message, "Duplicate key name")) {
        indexErrors <<- indexErrors + 1
        return(sprintf("Skipped index: %d/%d: %s\nError was: %s", i,length(sqlIndexes),sql, e$message))
      } else {
        indexSkips <<- indexSkips + 1
        return(NULL)
      }
    }
  )

  report = paste0(report,status,collapse="\n")

  if (i %% cfg$reportIndexingProgress == 0) {
    .slack_message(
      sprintf("index progress: %d/%d", i, length(sqlIndexes)),
      report
    )
  }

}

# Finish up

# DBI::dbDisconnect(com)

.slack_message(
  "COMPLETE: Loader job complete.",
  sprintf("There were %d table load errors, and %d index creation errors.", tableErrors, indexErrors),
  sprintf("%d indexes already existed.", indexSkips)
)
