library(tidyverse)
setwd("~/Git/aurum")
if (!"config" %in% rownames(installed.packages()))
install.packages("config", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))
if (!"here" %in% rownames(installed.packages()))
install.packages("here", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))
if (!"openssl" %in% rownames(installed.packages()))
install.packages("openssl", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))
here::i_am("data-raw/cprd-data-setup.R")
source(here::here("R/db-utils.R"))

cfg = config::get(file = "~/.aurum.yaml",config = "dev")
con <- DBI::dbConnect(RMariaDB::MariaDB(), user = cfg$user, pass=cfg$password, dbname=cfg$dataDatabase, bigint="integer64")
DBI::dbSendStatement(con,"SET ROLE 'role_cprd_admin'") %>% DBI::dbClearResult()

operationalSql = yaml::read_yaml(here::here("data-raw/operational-tables.yaml"))

dataDb = cfg$dataDatabase

for(tbl in names(operationalSql$tables)) {
  result = operationalSql %>% execSql(tbl,"create",verbose=TRUE,debug=TRUE)
  message("creating ",tbl,"; success: ",DBI::dbHasCompleted(result))
  result %>% DBI::dbClearResult()
}

log = dplyr::tbl(con, operationalSql$naming$loadStatusTable)

lookupSql = yaml::read_yaml(here::here("data-raw/lookup-tables.yaml"))
refPath = cfg$lookupSourceDirectory

# tbl = names(lookupSql$tables)[[1]]
# path = glue::glue(lookupSql$paths[[tbl]])
# md5 = openssl::md5(path)
# log %>% filter(tablename==tbl & hash==md5)
# md5 = as.character(openssl::md5(path))
# log %>% filter(tablename==tbl & hash==md5)
# log %>% filter(tablename==tbl & hash==md5) %>% nrow()
# log %>% filter(tablename==tbl & hash==md5) %>% count()
# log %>% filter(tablename==tbl & hash==md5) %>% count() %>% pull(n)
# log %>% filter(tablename==tbl & hash==md5) %>% count() %>% pull(n) == 0
# lookupSql$naming[[tbl]] %in% DBI::dbListTables(con) &
# (log %>% filter(tablename==tbl & hash==md5) %>% count() %>% pull(n) != 0))
# lookupSql$naming[[tbl]] %in% DBI::dbListTables(con) &
# (log %>% filter(tablename==tbl & hash==md5) %>% count() %>% pull(n) != 0)

## Loading reference data tables ---
for(tbl in names(lookupSql$tables)) {
  #tbl = names(lookupSql$tables)[[1]]
  path = glue::glue(lookupSql$paths[[tbl]])
  md5 = as.character(openssl::md5(path))
  if (
    lookupSql$naming[[tbl]] %in% DBI::dbListTables(con) & # is the table present?
    (log %>% filter(tablename==tbl & hash==md5) %>% count() %>% pull(n) != 0) # is the table at the same version?
  ) {
    message(tbl, " already exists and file hash has not changed ")
  } else {
    lookupSql %>% execSql(tbl,"drop") %>% DBI::dbClearResult()
    lookupSql %>% execSql(tbl,"create") %>% DBI::dbClearResult()
    lookupSql %>% execSql(tbl,"load") %>% logOutcome(sourcepath = path,hash = md5,tablename = tbl)
    message("creating ",tbl)
  }
}

for(tbl in names(lookupSql$tables)) {
#tbl = names(lookupSql$tables)[[1]]
path = glue::glue(lookupSql$paths[[tbl]])
md5 = as.character(openssl::md5(path))
if (
lookupSql$naming[[tbl]] %in% DBI::dbListTables(con) & # is the table present?
(log %>% filter(tablename==tbl & hash==md5) %>% count() %>% pull(n) != 0) # is the table at the same version?
) {
message(tbl, " already exists and file hash has not changed ")
} else {
lookupSql %>% execSql(tbl,"drop") %>% DBI::dbClearResult()
lookupSql %>% execSql(tbl,"create") %>% DBI::dbClearResult()
lookupSql %>% execSql(tbl,"load") %>% logOutcome(sourcepath = path,hash = md5,tablename = tbl)
message("creating ",tbl)
}
}
for(tbl in names(lookupSql$tables)) {
#tbl = names(lookupSql$tables)[[1]]
path = glue::glue(lookupSql$paths[[tbl]])
md5 = as.character(openssl::md5(path))
if (
lookupSql$naming[[tbl]] %in% DBI::dbListTables(con) & # is the table present?
(log %>% filter(tablename==tbl & hash==md5) %>% count() %>% pull(n) != 0) # is the table at the same version?
) {
message(tbl, " already exists and file hash has not changed ")
} else {
lookupSql %>% execSql(tbl,"drop") %>% DBI::dbClearResult()
lookupSql %>% execSql(tbl,"create") %>% DBI::dbClearResult()
lookupSql %>% execSql(tbl,"load") %>% logOutcome(sourcepath = path,hash = md5,tablename = tbl)
message("creating ",tbl)
}
}
lookupSql = yaml::read_yaml(here::here("data-raw/lookup-tables.yaml"))
refPath = cfg$lookupSourceDirectory
for(tbl in names(lookupSql$tables)) {
#tbl = names(lookupSql$tables)[[1]]
path = glue::glue(lookupSql$paths[[tbl]])
md5 = as.character(openssl::md5(path))
if (
lookupSql$naming[[tbl]] %in% DBI::dbListTables(con) & # is the table present?
(log %>% filter(tablename==tbl & hash==md5) %>% count() %>% pull(n) != 0) # is the table at the same version?
) {
message(tbl, " already exists and file hash has not changed ")
} else {
lookupSql %>% execSql(tbl,"drop") %>% DBI::dbClearResult()
lookupSql %>% execSql(tbl,"create") %>% DBI::dbClearResult()
lookupSql %>% execSql(tbl,"load") %>% logOutcome(sourcepath = path,hash = md5,tablename = tbl)
message("creating ",tbl)
}
}
DBI::dbListTables(con)
log
lookupSql = yaml::read_yaml(here::here("data-raw/lookup-tables.yaml"))
refPath = cfg$lookupSourceDirectory
for(tbl in names(lookupSql$tables)) {
#tbl = names(lookupSql$tables)[[1]]
path = glue::glue(lookupSql$paths[[tbl]])
md5 = as.character(openssl::md5(path))
if (
lookupSql$naming[[tbl]] %in% DBI::dbListTables(con) & # is the table present?
(log %>% filter(tablename==tbl & hash==md5) %>% count() %>% pull(n) != 0) # is the table at the same version?
) {
message(tbl, " already exists and file hash has not changed ")
} else {
lookupSql %>% execSql(tbl,"drop") %>% DBI::dbClearResult()
lookupSql %>% execSql(tbl,"create") %>% DBI::dbClearResult()
lookupSql %>% execSql(tbl,"load") %>% logOutcome(sourcepath = path,hash = md5,tablename = tbl)
message("creating ",tbl)
}
}
cfg$dataSourceDirectories[[0]]
cfg$dataSourceDirectories[0]
cfg$dataSourceDirectories[1]
list.files(path=cfg$dataSourceDirectories[1])
cfg = config::get(file = "~/.aurum.yaml",config = "dev")
list.files(path=cfg$dataSourceDirectories[1])
list.files(path=cfg$dataSourceDirectories)
?list.files
list.files(path=cfg$dataSourceDirectories,full.names = TRUE)
zip = zips[[1]]
zips = list.files(path=cfg$dataSourceDirectories,full.names = TRUE)
zip = zips[[1]]
if (!"zip" %in% rownames(installed.packages()))
install.packages("openssl", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))
lsZip = zip::zip_list(zip)
lsZip
lsZip$filename %>% stringr::str_detect("observation")
lsZip$filename %>% stringr::str_detect("bservation")
"Observation"[2:Inf]
"Observation"[2:]
"Observation"[2]
tail("Observation",-1)
tail("Observation",2)
"Observation" %>% str_sub(2)
dataSql = yaml::read_yaml(here::here("data-raw/data-tables.yaml"))
names(dataSql$tables)
names(dataSql$tables) %>% stringr::str_sub(2)
names(dataSql$tables) %>% stringr::str_sub(2) %>% lapply(~str_detect(lsZip,.))
names(dataSql$tables) %>% stringr::str_sub(2) %>% lapply(function(x) str_detect(lsZip,x))
names(dataSql$tables) %>% stringr::str_sub(2) %>% sapply(function(x) str_detect(lsZip$filename,x))
contents = names(dataSql$tables) %>%
stringr::str_sub(2) %>%
sapply(function(x) str_detect(lsZip$filename,x))
contents = contents %>% as.data.frame() %>% mutate(zipFile = lsZip$filename)
colnames(contents) = names(dataSql$tables)
View(contents)
contents = names(dataSql$tables) %>%
stringr::str_sub(2) %>%
sapply(function(x) str_detect(lsZip$filename,x))
contents = contents %>% as.data.frame()
colnames(contents) = names(dataSql$tables)
contents = contents %>% mutate(zipFile = lsZip$filename)
contents = contents %>% pivot_longer(cols=-zipFile, names_to="table")
lsZip = zip::zip_list(zip)
contents = names(dataSql$tables) %>%
stringr::str_sub(2) %>%
sapply(function(x) str_detect(lsZip$filename,x))
contents = contents %>% as.data.frame()
colnames(contents) = names(dataSql$tables)
contents = contents %>% mutate(zipPath = lsZip$filename)
contents = contents %>% pivot_longer(cols=-zipFile, names_to="table")
contents = contents %>% filter(value) %>% mutate(file = zip)
contents = contents %>% pivot_longer(cols=-zipPath, names_to="table")
contents = contents %>% filter(value) %>% mutate(file = zip)
lsZip
as.Date(lsZip$timestamp)
as.DateTime(lsZip$timestamp)
as.Datetime(lsZip$timestamp)
as.POSIXct(lsZip$timestamp)
zip::unzip()
?zip::unzip
zips = list.files(path=cfg$dataSourceDirectories,full.names = TRUE)
listing = NULL
for (zip in zips) {
zip = zips[[1]]
lsZip = zip::zip_list(zip)
contents = names(dataSql$tables) %>%
stringr::str_sub(2) %>%
sapply(function(x) str_detect(lsZip$filename,x))
contents = contents %>% as.data.frame()
colnames(contents) = names(dataSql$tables)
contents = contents %>% mutate(
zipPath = lsZip$filename,
zipTime = as.POSIXct(lsZip$timestamp)
)
contents = contents %>% pivot_longer(cols=-zipPath, names_to="table")
contents = contents %>% filter(value) %>% mutate(file = zip) %>% select(-value)
listing = listing %>% bind_rows(contents)
}
zips = list.files(path=cfg$dataSourceDirectories,full.names = TRUE)
listing = NULL
for (zip in zips) {
zip = zips[[1]]
lsZip = zip::zip_list(zip)
contents = names(dataSql$tables) %>%
stringr::str_sub(2) %>%
sapply(function(x) str_detect(lsZip$filename,x))
contents = contents %>% as.data.frame()
colnames(contents) = names(dataSql$tables)
contents = contents %>% mutate(
zipPath = lsZip$filename,
zipTime = as.POSIXct(lsZip$timestamp)
)
contents = contents %>% pivot_longer(cols=c(-zipPath,-zipTime), names_to="table")
contents = contents %>% filter(value) %>% mutate(file = zip) %>% select(-value)
listing = listing %>% bind_rows(contents)
}
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
zipPath = lsZip$filename,
zipTime = as.POSIXct(lsZip$timestamp)
)
contents = contents %>% pivot_longer(cols=c(-zipPath,-zipTime), names_to="table")
contents = contents %>% filter(value) %>% mutate(file = zip) %>% select(-value)
listing = listing %>% bind_rows(contents)
}
listing %>% View()
listing %>% glimpse()
tbl = names(lookupSql$tables)[[1]]
path = glue::glue(lookupSql$paths[[tbl]])
path
file.info(path)
tmp = file.info(path)
tmp$ctime
as.POSIXct(file.info(path)$ctime)
operationalSql %>% execSql("loadLog","drop") %>% DBI::dbClearResult()
cfg = config::get(file = "~/.aurum.yaml",config = "dev")
con <- DBI::dbConnect(RMariaDB::MariaDB(), user = cfg$user, pass=cfg$password, dbname=cfg$dataDatabase, bigint="integer64")
DBI::dbSendStatement(con,"SET ROLE 'role_cprd_admin'") %>% DBI::dbClearResult()
operationalSql = yaml::read_yaml(here::here("data-raw/operational-tables.yaml"))
execSql = function(sqlTemplates, tableName, cmd, ..., verbose=FALSE, debug=FALSE) {
env = rlang::caller_env()
tableNames = sqlTemplates$naming
if(verbose) message("executing: ",cmd," for table ",tableName)
sqlTemplate = sqlTemplates$tables[[tableName]][[cmd]]
sql = glue::glue_data(tableNames, sqlTemplate,.envir = env)
if(debug) message("sql: ",sql)
tmp = DBI::dbSendStatement(con,sql)
return(tmp)
}
dataDb = cfg$dataDatabase
operationalSql %>% execSql("loadLog","drop") %>% DBI::dbClearResult()
for(tbl in names(operationalSql$tables)) {
result = operationalSql %>% execSql(tbl,"create",verbose=TRUE,debug=TRUE)
message("creating ",tbl,"; success: ",DBI::dbHasCompleted(result))
result %>% DBI::dbClearResult()
}
log = dplyr::tbl(con, operationalSql$naming$loadStatusTable)

## Load reference data tables ----
# if required...
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
?glue_data
execSql = function(sqlTemplates, tableName, cmd, ..., verbose=FALSE, debug=FALSE) {
env = rlang::caller_env()
tableNames = sqlTemplates$naming
if(verbose) message("executing: ",cmd," for table ",tableName)
sqlTemplate = sqlTemplates$tables[[tableName]][[cmd]]
sql = glue::glue_data(tableNames, sqlTemplate,...,.envir = env)
if(debug) message("sql: ",sql)
tmp = DBI::dbSendStatement(con,sql)
return(tmp)
}
log
glue_data(list(x=1),"{x}",x=2)
glue::glue_data(list(x=1),"{x}",x=2)
glue::glue_data(list(x=1),"{x}")
operationalSql = yaml::read_yaml(here::here("data-raw/operational-tables.yaml"))
tmp = operationalSql %>% execSql("loadLog","isHashLoaded",tablename = "region", hash="020cedcaf36e3b57af41bb9683d42137",debug=TRUE)
operationalSql = yaml::read_yaml(here::here("data-raw/operational-tables.yaml"))
operationalSql %>% execSql("loadLog","isHashLoaded",tablename = "region", hash="020cedcaf36e3b57af41bb9683d42137",debug=TRUE) %>% exists()
log2 = log %>% dplyr::collect()
log2
listing %>% glimpse()
listing = listing %>% mutate(sourcepath = paste0(file,"/",zipPath))
todo = listing %>% anti_join(log2, by=c("table"="tablename","zipTime"="filetime","sourcepath"="sourcepath"))
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
zipPath = lsZip$filename,
filedate = as.POSIXct(lsZip$timestamp)
)
contents = contents %>% pivot_longer(cols=c(-zipPath,-zipTime), names_to="tablename")
contents = contents %>% filter(value) %>% mutate(file = zip) %>% select(-value)
listing = listing %>% bind_rows(contents)
}
listing = listing %>% mutate(sourcepath = paste0(file,"/",zipPath))
log2 = log %>% dplyr::collect()
todo = listing %>% anti_join(log2, by=c("tablename","filedate","sourcepath"))
## Load main sql files from zips ----
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
contents = contents %>% pivot_longer(cols=c(-path,-filedate), names_to="tablename")
contents = contents %>% filter(value) %>% mutate(file = zip) %>% select(-value)
listing = listing %>% bind_rows(contents)
}
listing = listing %>% mutate(sourcepath = paste0(file,"/",path))
log2 = log %>% dplyr::collect()
todo = listing %>% anti_join(log2, by=c("tablename","filedate","sourcepath"))



## load the

dataSql = yaml::read_yaml(here::here("data-raw/data-tables.yaml"))

for (table in names(dataSql$tables)) {
  if (!(dataSql$naming[table] %in% tables))
    dataSql %>% execSql(table,"create") %>% DBI::dbClearResult()
}

## here ----

tmpDir = cfg$buildDirectory
for (i in 1:nrow(todo)) {
  job = todo %>% filter(row_number() == i) %>% as.list()
  inflate1 = zip::unzip(job$file,files = job$path,exdir = tmpDir)
  zip::unzip(job$file,files = job$path,exdir = tmpDir)
  extract1 = paste0(tmpDir,"/",job$path)
  zip::unzip(extract1,exdir = tmpDir)
  files = zip::zip_list(extract1)$filename
  if (length(files)>1) stop("zip file contained more than one file: ",extract1)
  unlink(extract1)
  path = paste0(tmpDir,"/",files)





stageParams = list(dataDb = dataDb, path=path)
stageParams[job$tablename] = "staging"
dataSql %>% execSql(job$tablename, "create",params = stageParams, debug=TRUE) %>% DBI::dbClearResult()
dataSql %>% execSql(job$tablename, "drop",params = stageParams, debug=TRUE) %>% DBI::dbClearResult()
dataSql %>% execSql(job$tablename, "create",params = stageParams, debug=TRUE) %>% DBI::dbClearResult()
Sys.chmod(path)
tmp = dataSql %>% execSql(job$tablename, "load",params = stageParams, debug=TRUE)
md5 = as.character(openssl::md5(path))


}
job
