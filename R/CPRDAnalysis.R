#' Get a handle to the CPRD data databse
#'
#' This function sets up a connection to the cprd data databse, and provides a set of basic functions for manipulating the CPRD
#' @keywords CPRD
#' @export
CPRDAnalysis = R6::R6Class("CPRDAnalysis", inherit = AbstractCPRDConnection, public=list(

  #' @field .data - internal the pointer to the cprdDatabase
  .data = NULL,

  #' @field .codesets - internal the pointer to the cprdCodeSets
  .codesets = NULL,

  #' @field name - the name of the analysis
  name = NULL,

  #' @field tables - the tables defined for this analysis
  tables = list(),

  #### Constructor ----

  #' @description Create a cprd analysis container.
  #' @param name the name of the analysis - convention dictates this should be a lowercase name with underscores instead of spaces.
  #' @param cprdData an existing cprd data container.
  #' @param cprdCodeSets an existing cprd codesets container.
  #' @return A new CPRDAnalysis object.
  initialize = function(name, cprdData, cprdCodeSets) {
    super$initialize(cprdConnection = cprdData)
    self$name = name
    self$.data = cprdData
    self$.codesets = cprdCodeSets

    # DBI::dbSendStatement(con,"SET ROLE 'role_cprd_admin'") %>% DBI::dbClearResult()
    analysisDb = self$.analysisDb
    self$execSql(paste0("USE ",analysisDb,";"))
    con = self$.con
    self$.conventions = super$namingConventions(name)

    for (tableAlias in names(aurum::analysisSql$tables)) {
      if(!self$tableExists(tableAlias)) {
        message("Initialising table: ",tableAlias," as ",self$.conventions[[tableAlias]])
        self$execSql(aurum::analysisSql$tables[[tableAlias]]$create)
      }
      # data tables
      self$tables[[tableAlias]] = dplyr::tbl(con, dbplyr::in_schema(analysisDb, self$.conventions[[tableAlias]]))
    }

  },

  #' @description Get the table names in use within this analysis.
  #' @param ... not used
  namingConventions = function(...) {
    super$namingConventions(analysisName = self$name)
  },

  #' @description Internal function to execute an SQL statement provided in the template substituting names as appropriate
  #' @param template an SQL glue template
  #' @param ... additional name=value for the glue substitution
  execSql = function(template, ...) {
    super$execSql(template, ..., analysisName = self$name, varsList = self$.conventions)
  },

  #' @description Internal function to execute an SQL statement and fetch the query result provided in the template substituting names as appropriate
  #' @param template an SQL glue template
  #' @param ... additional name=value for the glue substitution
  fetchSql = function(template, ...) {
    super$fetchSql(template, ..., analysisName = self$name, varsList = self$.conventions)
  },

  #' @description Internal function to execute an SQL statement and wrap the query result in a lazy dataframe from the template substituting names as appropriate
  #' @param template an SQL glue template
  #' @param ... additional name=value for the glue substitution
  lazySql = function(template, ...) {
    super$lazySql(template, ..., analysisName = self$name, varsList = self$.conventions)
  },

  #' @description delete this analysis. This will affect all users of the CPRD database.
  #' @return the CPRDData root
  delete = function(sure=FALSE) {
    areYouSure("This will delete all the tables associated with this analysis",{
      for (tableAlias in names(aurum::analysisSql$tables)) {
        if(self$tableExists(tableAlias)) {
          message("dropping table: ",self$.conventions[[tableAlias]])
          self$execSql(aurum::analysisSql$tables[[tableAlias]]$drop)
        }
      }
      # TODO: drop temporary analysis tables
      # list all tables, find those that start with paste0(self$name,"_"), drop them.
    },sure)
    return(self$.data)
  },

  #' @description compute a query or retrieve a precomputed query
  #' @param queryDf - a dplyr query dataframe
  #' @param name - the analysis local identifier
  #' @param recompute - force re-computation of the query
  cached = function(queryDf, name, ..., recompute=FALSE) {
    tmpTableName = paste0(self$name,"_",name)
    id = dbplyr::in_schema(self$.analysisDb, tmpTableName)
    # table exists already
    if(!recompute & self$tableExists(tmpTableName, self$.analysisDb)) {
      return(dplyr::tbl(self$.con, id))
    }
    # table exists already but we have to recompute it
    if(recompute & self$tableExists(tmpTableName, self$.analysisDb)) {
      self$execSql(glue::glue_sql("DROP TABLE {tbl};",tbl = id, .con = self$.con))
    }
    # compute table
    # TODO: this assumes the correct database has been selected as default. For some reason (I think a bug in dplyr) if we try and specify
    # the database using in_schema() the resulting query is missing a space between the CREATE TABLE and the table name,
    queryDf %>% dplyr::compute(name=tmpTableName, temporary = FALSE, ...) %>% return()

  },

  #' @description
  #' Prints the database connection information.
  #' @return nothing.
  print = function() {
    print(paste0("CPRD Analysis: ",self$name))
    super$print()
  }
))
