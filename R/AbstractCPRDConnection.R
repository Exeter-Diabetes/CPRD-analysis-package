#' Get a handle to the CPRD data databse
#'
#' This function sets up a connection to the cprd data databse, and provides a set of basic functions for manipulating the CPRD
#' @keywords CPRD
#' @export
AbstractCPRDConnection = R6::R6Class("AbstractCPRDConnection", public=list(

  #' @field .con - internal the mySQL connection
  .con = NULL,

  #' @field .profile - internal the connection details
  .profile = NULL,

  #' @field .dataDb - internal the name of the cprd data database
  .dataDb = NULL,

  #' @field .analysisDb - internal the name of the cprd analysis database
  .analysisDb = NULL,

  #' @field .conventions - internal the table naming conventions in the databases
  .conventions = NULL,

  #### Constructor ----

  #' @description
  #' Create a new CPRD data table connection.
  #' @param cprdEnv a profile for the connection.
  #' @param cprdConf an absolute path to a .aurum.yaml configuration file.
  #' @param cprdConnection an existing thing that inherits from AbstractCPRDConnection if one exists.
  #' @return A new AbstractCPRDConnection object.
  initialize = function(
    cprdEnv = getOption("cprd.environment",default="test-analysis"),
    cprdConf = getOption("cprd.config",default="~/.aurum.yaml"),
    cprdConnection = NULL
  ) {

    if(is.null(cprdConnection)) {
      # No existing connection
      message("Initialising... using config: ",cprdConf,"; option: ",cprdEnv)
      if(!file.exists(cprdConf)) stop("config file not found: ",cprdConf)
      cfg = config::get(file = cprdConf,config = cprdEnv)
      # connect to the database
      # TODO: consider managing the database connection with "pool" (https://github.com/rstudio/pool)
      con = DBI::dbConnect(RMariaDB::MariaDB(), username = cfg$user, host=cfg$server, password=cfg$password, port=cfg$port, bigint="integer64")
      self$.profile = cprdEnv
      self$.con = con
      self$.dataDb = cfg$dataDatabase
      self$.analysisDb = cfg$analysisDatabase
      # browser()
      # set up the session config
      for (name in names(cfg$sessionConfig)) {
        value=cfg$sessionConfig[[name]]
        message("setting option... ",name,": ",value)
        DBI::dbSendStatement(con,glue::glue("SET {name}={value};", name=name, value=value)) %>% DBI::dbClearResult()
      }

    } else {
      self$.con = cprdConnection$.con
      self$.profile = cprdConnection$.profile
      self$.dataDb = cprdConnection$.dataDb
      self$.analysisDb = cprdConnection$.analysisDb
    }
    self$.conventions = self$namingConventions()

  },

  #### Factory methods ----

  # data = function() {
  #   return(CPRDData$new(cprdConnection=self))
  # },

  #### internal ---

  #' @description Internal function to switch to an admin role
  enableAdmin = function() {
    DBI::dbSendStatement(self$.con,"SET ROLE 'role_cprd_admin'") %>% DBI::dbClearResult()
  },

  #' @description get the set of table names for this database and analysis.
  #' @param analysisName the prefix for the analysis tables
  namingConventions = function(analysisName = "test") {
    env = rlang::caller_env()
    varsList = c(
      list(
        analysisDb = self$.analysisDb,
        dataDb = self$.dataDb,
        analysis = analysisName
      ),
      aurum::analysisSql$naming,
      aurum::codeSetsSql$naming,
      aurum::dataSql$naming,
      aurum::operationalSql$naming,
      aurum::lookupSql$naming
    )
    varsList = lapply(varsList, function(x) glue::glue_data(.x=varsList,x,.envir = env))
    return(varsList)
  },

  #' @description Internal function to execute an SQL statement provided in the template substituting names as appropriate
  #' @param template an SQL glue template
  #' @param ... additional name=value for the glue substitution
  #' @param analysisName the name of the analysis in progress if there is one
  #' @param varsList (optional) all the names of the various configurable tables
  #' @param debug log the generated SQL
  execSql = function(template, ..., analysisName = "test", varsList = self$namingConventions(analysisName), debug=getOption("cprd.debug",FALSE)) {
    env = rlang::caller_env()
    varsList = lapply(varsList, function(x) DBI::dbQuoteIdentifier(self$.con, x))
    varsList = c(varsList,rlang::list2(...))
    sql = glue::glue_data_sql(.x=varsList, .con=self$.con, template ,.envir = env)
    if(debug) message("sql: ",sql)
    DBI::dbExecute(self$.con,sql)
  },

  #' @description Internal function to execute an SQL statement and fetch the query result provided in the template substituting names as appropriate
  #' @param template an SQL glue template
  #' @param ... additional name=value for the glue substitution
  #' @param analysisName the name of the analysis in progress if there is one
  #' @param varsList (optional) all the names of the various configurable tables
  #' @param debug log the generated SQL
  fetchSql = function(template, ..., analysisName = "test", varsList = self$namingConventions(analysisName), debug=getOption("cprd.debug",FALSE)) {
    env = rlang::caller_env()
    varsList = lapply(varsList, function(x) DBI::dbQuoteIdentifier(self$.con, x))
    varsList = c(varsList,rlang::list2(...))
    sql = glue::glue_data_sql(.x=varsList, .con=self$.con, template ,.envir = env)
    if(debug) message("sql: ",sql)
    return(DBI::dbGetQuery(self$.con,sql))
  },

  #' @description Internal function to execute an SQL statement and wrap the query result in a lazy dataframe from the template substituting names as appropriate
  #' @param template an SQL glue template
  #' @param ... additional name=value for the glue substitution
  #' @param analysisName the name of the analysis in progress if there is one
  #' @param varsList (optional) all the names of the various configurable tables
  #' @param debug log the generated SQL
  lazySql = function(template, ..., analysisName = "test", varsList = self$namingConventions(analysisName), debug=getOption("cprd.debug",FALSE)) {
    # browser()
    env = rlang::caller_env()
    varsList = lapply(varsList, function(x) DBI::dbQuoteIdentifier(self$.con, x))
    varsList = c(varsList,rlang::list2(...))
    sql = glue::glue_data_sql(.x=varsList, .con=self$.con, template ,.envir = env)
    if(debug) message("sql: ",sql)
    return(dplyr::tbl(self$.con,from = dbplyr::sql(sql)))
  },

  #' @description Internal function to append a dataframe to a SQL table
  #' @param df a dataframe
  #' @param table a table name
  #' @param database the database
  appendDf = function(df, table, database = self$.analysisDb) {
    table = self$conv(table)
    #DBI::dbSendQuery(self$.con, paste0("USE ",database)) %>% DBI::dbClearResult()
    #DBI::dbAppendTable(self$.con, name=table, df) %>% DBI::dbClearResult()
    DBI::dbAppendTable(self$.con, name= dbQualifiedTable(database, table), df)
  },

  #' @description Internal function to check if a table exists
  #' @param table a table name
  #' @param database the database
  tableExists = function(table, database=self$.analysisDb) {
    table = self$conv(table)
    DBI::dbExistsTable(self$.con, dbQualifiedTable(database, table))
  },

  conv = function(name) {
    if(name %in% names(self$.conventions)) {
      return(self$.conventions[[name]])
    } else {
      return(name)
    }
  },

  #### Constructor ----

  #' @description
  #' Shutdown the connection to the CPRD data table.
  #' @return nothing.
#  finalize = function() {
#    message("disconnecting from ",self$.dataDb)
#    DBI::dbDisconnect(self$.con)
#    variables = eapply(.GlobalEnv,class)
#    for(varName in names(variables)) {
#      if("tbl_sql" %in% variables[[varName]]) {rm(list=varName, envir=.GlobalEnv)}
#    }
#  },

  #' @description
  #' Prints the database connection information.
  #' @return nothing.
  print = function() {
    print(self$.con)
    invisible(self)
  }
))

