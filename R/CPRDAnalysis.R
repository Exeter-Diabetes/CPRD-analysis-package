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
  
  #' @description only keep measurements with 'acceptable' unit codes (numunitid) for specified biomarker
  #' @param dataset - dataset containing biomarker observations
  #' @param biomrkr - name of biomarker to clean (acr/alt/ast/bmi/creatinine/dbp/fastingglucose/hba1c/hdl/height/ldl/pcr/sbp/totalcholesterol/triglyceride/weight)
  clean_biomarker_units = function(dataset,biomrkr) {
    unit_codes <- cprd$tables$biomarkerAcceptableUnits %>% dplyr::filter(biomarker==local(biomrkr))
    return(
      dataset %>%
        dplyr::inner_join(
          unit_codes,
          by = "numunitid",
          na_matches="na"
        ))
  },
  
  #' @description only keep measurements within acceptable limits for specified biomarker
  #' @param dataset - dataset containing biomarker observations
  #' @param biomrkr - name of biomarker to clean (acr/alt/ast/bmi/creatinine/dbp/fastingglucose/hba1c/hdl/height/ldl/pcr/sbp/totalcholesterol/triglyceride/weight)
  clean_biomarker_values = function(dataset,biomrkr) {
    lower_limit <- cprd$tables$biomarkerAcceptableLimits %>% dplyr::filter(biomarker==local(biomrkr)) %>% dplyr::select(lower_limit)
    lower_lmt <- as.numeric(collect(lower_limit)[[1,1]])
    upper_limit <- cprd$tables$biomarkerAcceptableLimits %>% dplyr::filter(biomarker==local(biomrkr)) %>% dplyr::select(upper_limit)
    upper_lmt <- as.numeric(collect(upper_limit)[[1,1]])
    if (biomrkr=="hba1c") {
      message("clean_biomarker_values will remove HbA1c values which are not in mmol/mol")
    }
    if (biomrkr=="weight") {
      message("clean_biomarker_values uses weight limits for adults")
    }
    if (biomrkr=="height") {
      message("clean_biomarker_values uses height limits for adults")
    }
    message("Values <",lower_lmt, ", >", upper_lmt, " and missing values removed")
    return(
      dataset %>%
            dplyr::filter(testvalue>=lower_lmt & testvalue<=upper_lmt)
        )
  },
  
  #' @description calculates QRISK2-2017 score
  #' @param sex - "male" or "female"
  #' @param age - current age in years
  #' @param ethrisk - QRISK2 ethnicity category: 0=Missing, 1=White, 2=Indian, 3=Pakistani, 4=Bangladeshi, 5=Other Asian, 6=Black Caribbean, 7=Black African, 8=Chinese, 9=Other ethnic group
  #' @param townsend - Townsend Deprivation Index (default 0 i.e. missing)
  #' @param smoking - QRISK2 smoking category: 0=Non-smoker, 1=Ex-smoker, 2=Current light smoker, 3=Current moderate smoker, 4=Current heavy smoker
  #' @param type1 - Type 1 diabetes (binary)
  #' @param type2 - Type 2 diabetes (binary)
  #' @param fh_cvd - family history of premature cardiovascular disease
  #' @param renal - CKD stage 4 or 5
  #' @param af - atrial fibrillation (binary)
  #' @param bp_med - on blood pressure medication (binary)
  #' @param rheumatoid_arth - rheumatoid arthritis (binary)
  #' @param cholhdl - cholesterol:HDL ratio
  #' @param sbp - systolic blood pressure in mmHg
  #' @param bmi - BMI in kg/m2
  #' @param surv - how many years survival to use in model (default 10)

  calculate_qrisk2 = function(sex, age, ethrisk, townsend=0, smoking, type1, type2, fh_cvd, renal, af, bp_med, rheumatoid_arth, cholhdl, sbp, bmi, surv=10) {
    if (sex=="male") {
      vars <- lapply(aurum::qrisk2Constants$male, function(y) lapply(y, as.numeric))
    }
    if (sex=="female") {
        vars <- lapply(aurum::qrisk2Constants$female, function(y) lapply(y, as.numeric))
    }
    vars = unlist(vars, recursive="FALSE")
    age1 = age / 10.0
    bmi1 = bmi / 10.0
    age2 = (age1 ^ vars$age_cons1) - vars$age_cons2
    age3 = (age1 ^ vars$age_cons3) - vars$age_cons4
    bmi2 = (bmi1 ^ -2.0) - vars$bmi_cons1
    bmi3 = ((bmi1 ^ -2.0) * log(bmi1)) - vars$bmi_cons2
    rati1 = cholhdl - vars$rati_cons1
    sbp1 = sbp - vars$sbp_cons1
    town1 = town - vars$town_cons1
    survarray_val = vars$survarray[surv+1]
    ethriskarray_val = vars$ethriskarray[ethrisk+1]
    smokearray_val = vars$smokearray[smoke_cat+1]
    
    d = (((((((((((((((((((((((((((((((((((((((((((0.0 + ethriskarray_val) + 
                                                    smokearray_val) + 
                                                   (age2 * eq_cons1)) + 
                                                  (age3 * eq_cons2)) + 
                                                 (bmi2 * eq_cons3)) + 
                                                (bmi3 * eq_cons4)) + 
                                               (rati1 * num19)) + 
                                              (sbp1 * num20)) + 
                                             (town1 * num21)) + 
                                            (af * num22)) + 
                                           (rheumatoid_arth * num23)) + 
                                          (renal * num24)) + 
                                         (bp_med * num25)) + 
                                        (type1 * num26)) + 
                                       (type2 * num27)) + 
                                      (fh_cvd * num28)) + 
                                     ((age2 * (smoking == 1)) * num29)) + 
                                    ((age2 * (smoking == 2)) * num30)) + 
                                   ((age2 * (smoking == 3)) * num31)) + 
                                  ((age2 * (smoking == 4)) * num32)) + 
                                 ((age2 * af) * num33)) + 
                                ((age2 * renal) * num34)) + 
                               ((age2 * bp_med) * num35)) + 
                              ((age2 * type1) * num36)) + 
                             ((age2 * type2) * num37)) + 
                            ((age2 * num5) * num38)) + 
                           ((age2 * num6) * num39)) + 
                          ((age2 * fh_cvd) * num40)) + 
                         ((age2 * sbp1) * num41)) + 
                        ((age2 * town1) * num42)) + 
                       ((age3 * (smoking == 1)) * num43)) + 
                      ((age3 * (smoking == 2)) * num44)) + 
                     ((age3 * (smoking == 3)) * num45)) + 
                    ((age3 * (smoking == 4)) * num46)) + 
                   ((age3 * af) * num47)) + 
                  ((age3 * renal) * num48)) + 
                 ((age3 * bp_med) * num49)) + 
                ((age3 * type1) * num50)) + 
               ((age3 * type2) * num51)) + 
              ((age3 * num5) * num52)) + 
             ((age3 * num6) * num53)) + 
            ((age3* fh_cvd) * num54)) + 
           ((age3* sbp1) * num55)) + 
      ((age3* town1) * num56)
    
    score = 100.0 * (1.0 - (survarray_val^exp(d)))
    
    return(score)
    
  },

  #' @description
  #' Prints the database connection information.
  #' @return nothing.
  print = function() {
    print(paste0("CPRD Analysis: ",self$name))
    super$print()
  }
))
