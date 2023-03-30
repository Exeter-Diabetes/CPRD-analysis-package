## Low level functions for working with cprd database


# https://github.com/rstudio/pool

## Functions for modifying db based on yanl queries

execSql = function(sqlTemplates, tableName, cmd, params=sqlTemplates$naming, verbose=FALSE, debug=FALSE) {
  env = rlang::caller_env()
  if(verbose) message("executing: ",cmd," for table ",tableName)
  sqlTemplate = sqlTemplates$tables[[tableName]][[cmd]]
  if(identical(sqlTemplate,NULL)) {
    warning(cmd," not defined for ",tableName)
    return(NULL)
  }
  sql = glue::glue_data(params, sqlTemplate,.envir = env)
  if(debug) message("sql: ",sql)
  tmp = tryCatch(
    DBI::dbSendStatement(con,sql),
    error = function(e) {
      message("sql: ",sql)
      stop(e$message)
    })
  return(tmp)
}

buildIndexes = function(sqlTemplates, params=sqlTemplates$naming, verbose=FALSE, debug=FALSE) {
  env = rlang::caller_env()
  if(verbose) message("indexing")
  sqlIndexes = sqlTemplates$indexes
  sqlIndexes =
    unname(sapply(sqlIndexes, function(i) glue::glue_data(.x=params,i,.envir = env)))
  for (sql in sqlIndexes) {
    if (verbose) message("Query: ",sql)
    if (!debug) {
      tryCatch(
        DBI::dbSendStatement(con,sql) %>% DBI::dbClearResult(),
        error = function(e) warning(e)
      )
    }
  }
}

retrieve = function(result) {
  if(identical(result,NULL)) return(null)
  tmp = DBI::dbFetch(result)
  DBI::dbClearResult(result)
  return(tmp)
}

exists = function(result) {
  if(identical(result,NULL)) return(null)
  return(retrieve(result) %>% nrow() > 0)
}

logOutcome = function(result, sourcepath, hash, filedate, tablename) {
  if(identical(result,NULL)) return(null)
  loaddate = dbQuoteDate(Sys.time())
  filedate = dbQuoteDate(filedate)
  success = DBI::dbQuoteLiteral(DBI::ANSI(), DBI::dbHasCompleted(result))
  rowsloaded = DBI::dbQuoteLiteral(DBI::ANSI(), DBI::dbGetRowsAffected(result))
  sourcepath = DBI::dbQuoteString(DBI::ANSI(), sourcepath)
  tablename = DBI::dbQuoteString(DBI::ANSI(), tablename)
  hash = DBI::dbQuoteString(DBI::ANSI(), hash)
  DBI::dbClearResult(result)
  tmp = operationalSql %>% execSql("loadLog","insert")
  tmp %>% DBI::dbClearResult()
}

dbQuoteDate = function(date) {
  dateStr = as.character(date,"%Y-%m-%d %H:%M:%S")
  DBI::SQL(glue::glue("STR_TO_DATE('{dateStr}','%Y-%m-%d %H:%i:%S')"))
}

dbQualifiedTable = function(db, table) {
  DBI::SQL(paste(db, table,sep="."))
}

areYouSure = function(consequence, do, sure=FALSE) {
  if(!sure) {
    user_input <- readline(paste0(consequence, "... are you sure? (y/n) ",collapse = ""))
  } else {
    user_input = "y"
  }
  if(user_input == 'y') do
  else {
    message("cancelled by user.")
  }
}
