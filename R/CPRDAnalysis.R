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

  calculate_qrisk2 = function(dataset, sex, age, ethrisk, townsend=0, smoking, type1, type2, fh_cvd, renal, af, bp_med, rheumatoid_arth, cholhdl, sbp, bmi, surv=10) {
    vars_male <- unlist(lapply(aurum::qrisk2Constants$male, function(y) lapply(y, as.numeric)), recursive=FALSE)
    vars_female <- unlist(lapply(aurum::qrisk2Constants$female, function(y) lapply(y, as.numeric)), recursive=FALSE)
    
    
    
    dataset1 <- dataset %>% dplyr::mutate(m_age1 = age / 10.0,
                                          m_bmi1 = bmi / 10.0,
                                          m_age2 = (m_age1 ^ vars_male$age_cons1) - vars_male$age_cons2,
                                          m_age3 = (m_age2 ^ vars_male$age_cons3) - vars_male$age_cons4,
                                          m_bmi2 = (m_bmi1 ^ -2.0) - vars_male$bmi_cons1,
                                          m_bmi3 = ((m_bmi1 ^ -2.0) * log(m_bmi1)) - vars_male$bmi_cons2,
                                          m_rati1 = cholhdl - vars_male$rati_cons1,
                                          m_sbp1 = sbp - vars_male$sbp_cons1,
                                          m_town1 = town - vars_male$town_cons1,
                                          m_surv_varname = paste0("vars_male$survarray",surv+1),
                                          m_survarray_val = eval(parse(text=m_surv_varname)),
                                          m_ethrisk_varname = paste0("vars_male$ethriskarray",ethrisk+1),
                                          m_ethriskarray_val = eval(parse(text=m_ethrisk_varname)),
                                          m_smoking_varname = paste0("vars_male$smokearray",smoking+1),
                                          m_smokearray_val = eval(parse(text=m_smoking_varname)),
                                          m_d = (((((((((((((((((((((((((((((((((((((((((((0.0 + m_ethriskarray_val) + 
                                                    m_smokearray_val) + 
                                                   (m_age2 * vars_male$eq_cons1)) + 
                                                  (m_age3 * vars_male$eq_cons2)) + 
                                                 (m_bmi2 * vars_male$eq_cons3)) + 
                                                (m_bmi3 * vars_male$eq_cons4)) + 
                                               (m_rati1 * vars_male$num19)) + 
                                              (m_sbp1 * vars_male$num20)) + 
                                             (m_town1 * vars_male$num21)) + 
                                            (af * vars_male$num22)) + 
                                           (rheumatoid_arth * vars_male$num23)) + 
                                          (renal * vars_male$num24)) + 
                                         (bp_med * vars_male$num25)) + 
                                        (type1 * vars_male$num26)) + 
                                       (type2 * vars_male$num27)) + 
                                      (fh_cvd * vars_male$num28)) + 
                                     ((m_age2 * (smoking == 1)) * vars_male$num29)) + 
                                    ((m_age2 * (smoking == 2)) * vars_male$num30)) + 
                                   ((m_age2 * (smoking == 3)) * vars_male$num31)) + 
                                  ((m_age2 * (smoking == 4)) * vars_male$num32)) + 
                                 ((m_age2 * af) * vars_male$num33)) + 
                                ((m_age2 * renal) * vars_male$num34)) + 
                               ((m_age2 * bp_med) * vars_male$num35)) + 
                              ((m_age2 * type1) * vars_male$num36)) + 
                             ((m_age2 * type2) * vars_male$num37)) + 
                            ((m_age2 * m_bmi2) * vars_male$num38)) + 
                           ((m_age2 * m_bmi3) * vars_male$num39)) + 
                          ((m_age2 * fh_cvd) * vars_male$num40)) + 
                         ((m_age2 * m_sbp1) * vars_male$num41)) + 
                        ((m_age2 * m_town1) * vars_male$num42)) + 
                       ((m_age3 * (smoking == 1)) * vars_male$num43)) + 
                      ((m_age3 * (smoking == 2)) * vars_male$num44)) + 
                     ((m_age3 * (smoking == 3)) * vars_male$num45)) + 
                    ((m_age3 * (smoking == 4)) * vars_male$num46)) + 
                   ((m_age3 * af) * vars_male$num47)) + 
                  ((m_age3 * renal) * vars_male$num48)) + 
                 ((m_age3 * bp_med) * vars_male$num49)) + 
                ((m_age3 * type1) * vars_male$num50)) + 
               ((m_age3 * type2) * vars_male$num51)) + 
              ((m_age3 * m_bmi2) * vars_male$num52)) + 
             ((m_age3 * m_bmi3) * vars_male$num53)) + 
            ((m_age3* fh_cvd) * vars_male$num54)) + 
           ((m_age3* m_sbp1) * vars_male$num55)) + 
      ((m_age3* m_town1) * vars_male$num56),
      m_qrisk2_score = 100.0 * (1.0 - (m_survarray_val^exp(m_d))))
    
    dataset1 <- dataset1 %>% select(patid, m_qrisk2_score)
    
    dataset <- dataset %>% left_join(dataset1, by="patid")
    
    return(dataset)
    
  },

  #' @description
  #' Prints the database connection information.
  #' @return nothing.
  print = function() {
    print(paste0("CPRD Analysis: ",self$name))
    super$print()
  }
))
