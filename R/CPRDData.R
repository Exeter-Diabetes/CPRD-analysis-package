#' Get a handle to the CPRD data databse
#'
#' This function sets up a connection to the cprd data databse, and provides a set of basic functions for manipulating the CPRD
#' @keywords CPRD
#' @export
CPRDData = R6::R6Class("CPRDData", inherit = AbstractCPRDConnection, public=list(

    #### Fields ----

    ## data tables

    #' @field tables - the raw database tables
    tables = list(

      # # consultation - the consultation table
      # consultation = NULL,
      #
      # # drugIssue - the drugIssue table
      # drugIssue = NULL,
      #
      # # observation - the observation table
      # observation = NULL,
      #
      # # patient - the patient table
      # patient = NULL,
      #
      # # practice - the practice table
      # practice = NULL,
      #
      # # referral - the referral table
      # referral = NULL,
      #
      # # staff - the staff table
      # staff = NULL,
      #
      # ## reference data tables
      #
      # # medDict - the medDict table
      # medDict = NULL,
      #
      # # productDict - the productDict table
      # productDict = NULL,
      #
      # # commonDose - the commonDose table
      # commonDose = NULL,
      #
      # # consSource - the consSource table
      # consSource = NULL,
      #
      # # emisCodeCat - the emisCodeCat table
      # emisCodeCat = NULL,
      #
      # # jobCat - the jobCat table
      # jobCat = NULL,
      #
      # # gender - the gender table
      # gender = NULL,
      #
      # # numUnit - the numUnit table
      # numUnit = NULL,
      #
      # # obsType - the obsType table
      # obsType = NULL,
      #
      # # orgType - the orgType table
      # orgType = NULL,
      #
      # # parentProbRel - the parentProbRel table
      # parentProbRel = NULL,
      #
      # # patientType - the patientType table
      # patientType = NULL,
      #
      # # probStatus - the probStatus table
      # probStatus = NULL,
      #
      # # quantUnit - the quantUnit table
      # quantUnit = NULL,
      #
      # # refMode - the refMode table
      # refMode = NULL,
      #
      # # refServiceType - the refServiceType table
      # refServiceType = NULL,
      #
      # # refUrgency - the refUrgency table
      # refUrgency = NULL,
      #
      # # region - the region table
      # region = NULL,
      #
      # # sign - the sign table
      # sign = NULL,
      #
      # # visionToEmisMigrators - the visionToEmisMigrators table
      # visionToEmisMigrators = NULL
    ),

    #### Constructor ----

    #' @description
    #' Create a new CPRD data table connection.
    #' @param cprdEnv a profile for the connection.
    #' @param cprdConf an absolute path to a .aurum.yaml configuration file.
    #' @param cprdConnection if a connection has already been established you can supply it here and it will be used instead. Anything than inherits from AbstractCPRDConnection will work. This is really for internal methods
    #' @param con an existing mysql connection if one exists.
    #' @return A new CPRDData object.
    initialize = function(
        cprdEnv=getOption("cprd.environment",default="test-analysis"),
        cprdConf = getOption("cprd.config",default="~/.aurum.yaml"),
        cprdConnection = NULL
      ) {

        super$initialize(cprdEnv = cprdEnv, cprdConf = cprdConf, cprdConnection = cprdConnection)

      # DBI::dbSendStatement(con,"SET ROLE 'role_cprd_admin'") %>% DBI::dbClearResult()
        dataDb = self$.dataDb
        con = self$.con

        # data tables
        for (tableAlias in names(aurum::dataSql$tables)) {
          message("connecting to... ",tableAlias)
          self$tables[[tableAlias]] = dplyr::tbl(con, dbplyr::in_schema(dataDb, self$.conventions[[tableAlias]]))
        }

        # lookup tables
        for (tableAlias in names(aurum::lookupSql$tables)) {
          message("connecting to... ",tableAlias)
          self$tables[[tableAlias]] = dplyr::tbl(con, dbplyr::in_schema(dataDb, self$.conventions[[tableAlias]]))
        }

        # self$tables$consultation = dplyr::tbl(con, dbplyr::in_schema(dataDb, aurum::dataSql$naming$consultation))
        # self$tables$drugIssue = dplyr::tbl(con, dbplyr::in_schema(dataDb, aurum::dataSql$naming$drugIssue))
        # self$tables$observation = dplyr::tbl(con, dbplyr::in_schema(dataDb, aurum::dataSql$naming$observation))
        # self$tables$patient = dplyr::tbl(con, dbplyr::in_schema(dataDb, aurum::dataSql$naming$patient))
        # self$tables$referral = dplyr::tbl(con, dbplyr::in_schema(dataDb, aurum::dataSql$naming$referral))
        # self$tables$staff = dplyr::tbl(con, dbplyr::in_schema(dataDb, aurum::dataSql$naming$staff))
        # # lookup tables
        # self$tables$medDict = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$medDict))
        # self$tables$productDict = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$productDict))
        # self$tables$commonDose = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$commonDose))
        # self$tables$consSource = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$consSource))
        # self$tables$emisCodeCat = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$emisCodeCat))
        # self$tables$jobCat = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$jobCat))
        # self$tables$gender = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$gender))
        # self$tables$numUnit = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$numUnit))
        # self$tables$obsType = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$obsType))
        # self$tables$orgType = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$orgType))
        # self$tables$parentProbRel = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$parentProbRel))
        # self$tables$patientType = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$patientType))
        # self$tables$probStatus = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$probStatus))
        # self$tables$quantUnit = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$quantUnit))
        # self$tables$refMode = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$refMode))
        # self$tables$refServiceType = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$refServiceType))
        # self$tables$refUrgency = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$refUrgency))
        # self$tables$region = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$region))
        # self$tables$sign = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$sign))
        # self$tables$visionToEmisMigrators = dplyr::tbl(con,dbplyr::in_schema(dataDb, aurum::lookupSql$naming$visionToEmisMigrators))




    },

    #### Factory methods ----

    #' @description Create or retrieve a cprd analysis container.
    #' @param name the name of the analysis - convention dictates this should be a lowercase name with underscores instead of spaces.
    #' @return a cprd analysis container
    analysis = function(name) {
      return(CPRDAnalysis$new(name, cprdData=self, cprdCodeSets = self$codesets()))
    },

    #' @description Retrieve the cprd codesets container.
    #' @return a cprd codesets container
    codesets = function() {
      return(CPRDCodeSets$new(cprdData=self))
    },

    #' @description
    #' Shutdown the connection to the CPRD data table.
    #' @return nothing.
    finalize = function() {
      super$finalize()
      variables = eapply(.GlobalEnv,class)
      for(varName in names(variables)) {
        if("CPRDAnalysis" %in% variables[[varName]]) {rm(list=varName, envir=.GlobalEnv)}
        if("CPRDCodeSets" %in% variables[[varName]]) {rm(list=varName, envir=.GlobalEnv)}
      }
    },

    #' @description
    #' Prints the database connection information.
    #' @return nothing.
    print = function() {
      print("CPRD Data")
      super$print()
    }
))
