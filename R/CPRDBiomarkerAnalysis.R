#' Clean biomarker units: only keep values with acceptable unit codes (includes missing unit code for all)
#' 
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
}


#' Clean biomarker values: only keep values within acceptable limits
#' 
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
}


#' Impute missing predictors for QRISK2 and QDiabetes-HF
#' 
#' @description impute BMI, SBP and chol_HDL ratio where missing for QRISK2-2017 and QDiabetes-HF-2015
#' @param sex_col - column with "male" or "female"
#' @param age_col - column with current age in years
#' @param ethrisk_col - column with QRISK2 ethnicity category: 0=Missing, 1=White, 2=Indian, 3=Pakistani, 4=Bangladeshi, 5=Other Asian, 6=Black Caribbean, 7=Black African, 8=Chinese, 9=Other ethnic group
#' @param smoking_col - column with QRISK2 smoking category: 0=Non-smoker, 1=Ex-smoker, 2=Current light smoker, 3=Current moderate smoker, 4=Current heavy smoker
#' @param type1_col - column with Type 1 diabetes (binary)
#' @param type2_col - column with Type 2 diabetes (binary)
#' @param bp_med_col - column with whether on blood pressure medication (binary)
#' @param cholhdl_col - column with cholesterol:HDL ratio
#' @param sbp_col - column with systolic blood pressure in mmHg
#' @param bmi_col - column with BMI in kg/m2

impute_missing_predictors = function(new_dataframe, sex_col, age_col, ethrisk_col, smoking_col, type1_col, type2_col, cvd_col, bp_med_col, cholhdl_col, sbp_col, bmi_col) {
  
  # Fetch constants from Aurum package
  male_missing_predictors <- cbind(sex="male",data.frame(unlist(lapply(aurum::qMissingPredictors$male, function(y) lapply(y, as.numeric)), recursive="FALSE")))
  female_missing_predictors <- cbind(sex="female",data.frame(unlist(lapply(aurum::qMissingPredictors$female, function(y) lapply(y, as.numeric)), recursive="FALSE")))
  
  missingPredictors <- rbind(male_missing_predictors, female_missing_predictors)
  
  
  # Join constants to data table
  ## copy=TRUE as need to copy constants to MySQL from package
  new_dataframe <- new_dataframe %>%
    inner_join(missingPredictors, by=setNames("sex", deparse(sex_col)), copy=TRUE)

  
  # Calculate missing values
  new_dataframe <- new_dataframe %>%
  
    mutate(age1 = !!age_col / 10.0,
  
           bmi_ethriskarray_val = case_when(
             !!ethrisk_col==0 ~ bmi_predict_ethriskarray1,
             !!ethrisk_col==1 ~ bmi_predict_ethriskarray2,
             !!ethrisk_col==2 ~ bmi_predict_ethriskarray3,
             !!ethrisk_col==3 ~ bmi_predict_ethriskarray4,
             !!ethrisk_col==4 ~ bmi_predict_ethriskarray5,
             !!ethrisk_col==5 ~ bmi_predict_ethriskarray6,
             !!ethrisk_col==6 ~ bmi_predict_ethriskarray7,
             !!ethrisk_col==7 ~ bmi_predict_ethriskarray8,
             !!ethrisk_col==8 ~ bmi_predict_ethriskarray9,
             !!ethrisk_col==9 ~ bmi_predict_ethriskarray10
           ),
           bmi_smokearray_val = case_when(
             !!smoking_col==0 ~ bmi_predict_smokearray1,
             !!smoking_col==1 ~ bmi_predict_smokearray2,
             !!smoking_col==2 ~ bmi_predict_smokearray3,
             !!smoking_col==3 ~ bmi_predict_smokearray4,
             !!smoking_col==4 ~ bmi_predict_smokearray5
           ),
           new_bmi_col = ifelse(is.na(!!bmi_col), 
                                bmi_ethriskarray_val + bmi_smokearray_val + ((age1 - bmi_predict_eq_cons1) * bmi_predict_eq_cons2) + (((age1^2.0) - bmi_predict_eq_cons3) * bmi_predict_eq_cons4) + (!!bp_med_col * bmi_predict_num10) + (!!type1_col * bmi_predict_num11) + (!!type2_col * bmi_predict_num12) + (!!cvd_col * bmi_predict_num13) + bmi_predict_eq_cons5),
                                !!bmi_col),
           
           sbp_ethriskarray_val = case_when(
             !!ethrisk_col==0 ~ sbp_predict_ethriskarray1,
             !!ethrisk_col==1 ~ sbp_predict_ethriskarray2,
             !!ethrisk_col==2 ~ sbp_predict_ethriskarray3,
             !!ethrisk_col==3 ~ sbp_predict_ethriskarray4,
             !!ethrisk_col==4 ~ sbp_predict_ethriskarray5,
             !!ethrisk_col==5 ~ sbp_predict_ethriskarray6,
             !!ethrisk_col==6 ~ sbp_predict_ethriskarray7,
             !!ethrisk_col==7 ~ sbp_predict_ethriskarray8,
             !!ethrisk_col==8 ~ sbp_predict_ethriskarray9,
             !!ethrisk_col==9 ~ sbp_predict_ethriskarray10
           ),
           sbp_smokearray_val = case_when(
             !!smoking_col==0 ~ sbp_predict_smokearray1,
             !!smoking_col==1 ~ sbp_predict_smokearray2,
             !!smoking_col==2 ~ sbp_predict_smokearray3,
             !!smoking_col==3 ~ sbp_predict_smokearray4,
             !!smoking_col==4 ~ sbp_predict_smokearray5
           ),
           new_sbp_col = ifelse(is.na(!!sbp_col),
                                sbp_ethriskarray_val + sbp_smokearray_val + (((age1^3.0) - sbp_predict_eq_cons1) * sbp_predict_eq_cons2) + ((((age1^3.0) * log(age1)) - sbp_predict_eq_cons3) * sbp_predict_eq_cons4) + (!!bp_med_col * sbp_predict_num10) + (!!type1_col * sbp_predict_num11) + (!!type2_col * sbp_predict_num12) + (!!cvd_col * sbp_predict_num13) + sbp_predict_eq_cons5,
                                !!sbp_col),
           
           ratio_ethriskarray_val = case_when(
             !!ethrisk_col==0 ~ ratio_predict_ethriskarray1,
             !!ethrisk_col==1 ~ ratio_predict_ethriskarray2,
             !!ethrisk_col==2 ~ ratio_predict_ethriskarray3,
             !!ethrisk_col==3 ~ ratio_predict_ethriskarray4,
             !!ethrisk_col==4 ~ ratio_predict_ethriskarray5,
             !!ethrisk_col==5 ~ ratio_predict_ethriskarray6,
             !!ethrisk_col==6 ~ ratio_predict_ethriskarray7,
             !!ethrisk_col==7 ~ ratio_predict_ethriskarray8,
             !!ethrisk_col==8 ~ ratio_predict_ethriskarray9,
             !!ethrisk_col==9 ~ ratio_predict_ethriskarray10
           ),
           ratio_smokearray_val = case_when(
             !!smoking_col==0 ~ ratio_predict_smokearray1,
             !!smoking_col==1 ~ ratio_predict_smokearray2,
             !!smoking_col==2 ~ ratio_predict_smokearray3,
             !!smoking_col==3 ~ ratio_predict_smokearray4,
             !!smoking_col==4 ~ ratio_predict_smokearray5
           ),
           new_cholhdl_col = ifelse(is.na(!!cholhdl_col),
                                    ratio_ethriskarray_val + ratio_smokearray_val + (((age1^ratio_predict_eq_cons1) - ratio_predict_eq_cons2) * ratio_predict_eq_cons3) + ((((age1^ratio_predict_eq_cons4) * (log(age1) - log(age1^ratio_predict_eq_cons5) + ratio_predict_eq_cons5)) - ratio_predict_eq_cons6) * ratio_predict_eq_cons7) + (!!bp_med_col * ratio_predict_num10) + (!!type1_col * ratio_predict_num11) + (!!type2_col * ratio_predict_num12) + (!!cvd_col * ratio_predict_num13) + ratio_predict_eq_cons8),
                                    !!cholhdl_col))
           
  
  return(new_dataframe)
  
}


#' Calculate QRISK2-2017
#'
#' @description calculates QRISK2-2017 score
#' @param sex - "male" or "female"
#' @param age - current age in years
#' @param ethrisk - QRISK2 ethnicity category: 0=Missing, 1=White, 2=Indian, 3=Pakistani, 4=Bangladeshi, 5=Other Asian, 6=Black Caribbean, 7=Black African, 8=Chinese, 9=Other ethnic group
#' @param town - Townsend Deprivation Index (default 0 i.e. missing)
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
#' @export

calculate_qrisk2 = function(dataframe, sex, age, ethrisk, town=NULL, smoking, type1, type2, fh_cvd, renal, af, bp_med, rheumatoid_arth, cholhdl, sbp, bmi, surv=NULL) {
  
  
  # Get handles for columns with values in in data table
  sex_col <- as.symbol(deparse(substitute(sex)))
  age_col <- as.symbol(deparse(substitute(age)))
  ethrisk_col <- as.symbol(deparse(substitute(ethrisk)))
  smoking_col <- as.symbol(deparse(substitute(smoking)))
  type1_col <- as.symbol(deparse(substitute(type1)))
  type2_col <- as.symbol(deparse(substitute(type2)))
  fh_cvd_col <- as.symbol(deparse(substitute(fh_cvd)))
  renal_col <- as.symbol(deparse(substitute(renal)))
  af_col <- as.symbol(deparse(substitute(af)))
  bp_med_col <- as.symbol(deparse(substitute(bp_med)))
  rheumatoid_arth_col <- as.symbol(deparse(substitute(rheumatoid_arth)))
  cholhdl_col <- as.symbol(deparse(substitute(cholhdl)))
  sbp_col <- as.symbol(deparse(substitute(sbp)))
  bmi_col <- as.symbol(deparse(substitute(bmi)))
  town_col <- as.symbol(deparse(substitute(town)))
  surv_col <- as.symbol(deparse(substitute(surv)))
  

    # Make unique ID for each row so can join back on later
  dataframe <- dataframe %>%
    mutate(id_col=row_number())
  
  
  # Copy dataframe to new dataframe
  new_dataframe <- dataframe
  
  
  # Add cvd col for missing variables
  new_dataframe <- dataframe %>%
    mutate(new_cvd_col = 0)
  
  cvd_col <- as.symbol("new_cvd_col")
  
  
  # If missing Townsend deprivation index, use '0' i.e. missing
  if (deparse(substitute(town)) %in% colnames(new_dataframe)) {
    new_dataframe <- new_dataframe %>% mutate(town_col = ifelse(is.na(!!town_col), 0, !!town_col))
  }
  else {
    new_dataframe <- new_dataframe %>% mutate(town_col=0)
    message("Using average deprivation values as Townsend Deprivation Scores (town) missing")
  }
  
  
  # If missing survival time, use 10 years
  if (deparse(substitute(surv)) %in% colnames(new_dataframe)) {
    new_dataframe <- new_dataframe %>% mutate(surv_col = ifelse(is.na(!!surv_col), 10, !!surv_col))
  }
  else {
    new_dataframe <- new_dataframe %>% mutate(surv_col=10)
    message("Calculating 10-year risk as time period (surv) missing")
  }
  
  
  # Fetch constants from Aurum package
  male_vars <- cbind(sex="male",data.frame(unlist(lapply(aurum::qrisk2Constants$male, function(y) lapply(y, as.numeric)), recursive="FALSE")))
  female_vars <- cbind(sex="female",data.frame(unlist(lapply(aurum::qrisk2Constants$female, function(y) lapply(y, as.numeric)), recursive="FALSE")))
  vars <- rbind(male_vars, female_vars)

  
  
  # Join constants to data table
  ## copy=TRUE as need to copy constants to MySQL from package
  to_join_sex_var <- deparse(substitute(sex))

  new_dataframe <- new_dataframe %>%
    
    inner_join(vars, by=setNames("sex", to_join_sex_var), copy=TRUE)
    
  
  
  # Fill in missing BMI/SBP/chol:HDL
  
  new_dataframe <- new_dataframe %>%
    
    impute_missing_predictors(sex_col, age_col, ethrisk_col, smoking_col, type1_col, type2_col, bp_med_col, cholhdl_col, sbp_col, bmi_col)
  
  
  # Do calculation
    
  new_dataframe <- new_dataframe %>%
    
    mutate(new_bmi_col = ifelse(new_bmi_col>40, 40, new_bmi_col),
           
           age1 = !!age_col / 10.0,
           bmi1 = new_bmi_col / 10.0,
           age2 = (age1 ^ age_cons1) - age_cons2,
           age3 = (age1 ^ age_cons3) - age_cons4,
           bmi2 = (bmi1 ^ -2.0) - bmi_cons1,
           bmi3 = ((bmi1 ^ -2.0) * log(bmi1)) - bmi_cons2,
           rati1 = new_cholhdl_col - rati_cons1,
           sbp1 = new_sbp_col - sbp_cons1,
           town1 = town_col - town_cons1,
           
           survarray_val = case_when(
             surv_col==0 ~ survarray1,
             surv_col==1 ~ survarray2,
             surv_col==2 ~ survarray3,
             surv_col==3 ~ survarray4,
             surv_col==4 ~ survarray5,
             surv_col==5 ~ survarray6,
             surv_col==6 ~ survarray7,
             surv_col==7 ~ survarray8,
             surv_col==8 ~ survarray9,
             surv_col==9 ~ survarray10,
             surv_col==10 ~ survarray11,
             surv_col==11 ~ survarray12,
             surv_col==12 ~ survarray13,
             surv_col==13 ~ survarray14,
             surv_col==14 ~ survarray15,
             surv_col==15 ~ survarray16
           ),
           
           ethriskarray_val = case_when(
             !!ethrisk_col==0 ~ ethriskarray1,
             !!ethrisk_col==1 ~ ethriskarray2,
             !!ethrisk_col==2 ~ ethriskarray3,
             !!ethrisk_col==3 ~ ethriskarray4,
             !!ethrisk_col==4 ~ ethriskarray5,
             !!ethrisk_col==5 ~ ethriskarray6,
             !!ethrisk_col==6 ~ ethriskarray7,
             !!ethrisk_col==7 ~ ethriskarray8,
             !!ethrisk_col==8 ~ ethriskarray9,
             !!ethrisk_col==9 ~ ethriskarray10
           ),
           
           smokearray_val = case_when(
             !!smoking_col==0 ~ smokearray1,
             !!smoking_col==1 ~ smokearray2,
             !!smoking_col==2 ~ smokearray3,
             !!smoking_col==3 ~ smokearray4,
             !!smoking_col==4 ~ smokearray5
           ),
           
           d = (((((((((((((((((((((((((((((((((((((((((((0.0 + ethriskarray_val) +
                                                           smokearray_val) +
                                                          (age2 * eq_cons1)) +
                                                         (age3 * eq_cons2)) +
                                                        (bmi2 * eq_cons3)) +
                                                       (bmi3 * eq_cons4)) +
                                                      (rati1 * num19)) +
                                                     (sbp1 * num20)) +
                                                    (town1 * num21)) +
                                                   (!!af_col * num22)) +
                                                  (!!rheumatoid_arth_col * num23)) +
                                                 (!!renal_col * num24)) +
                                                (!!bp_med_col * num25)) +
                                               (!!type1_col * num26)) +
                                              (!!type2_col * num27)) +
                                             (!!fh_cvd_col * num28)) +
                                            ((age2 * (!!smoking_col == 1)) * num29)) +
                                           ((age2 * (!!smoking_col == 2)) * num30)) +
                                          ((age2 * (!!smoking_col == 3)) * num31)) + 
                                         ((age2 * (!!smoking_col == 4)) * num32)) + 
                                        ((age2 * !!af_col) * num33)) + 
                                       ((age2 * !!renal_col) * num34)) + 
                                      ((age2 * !!bp_med_col) * num35)) + 
                                     ((age2 * !!type1_col) * num36)) + 
                                    ((age2 * !!type2_col) * num37)) + 
                                   ((age2 * bmi2) * num38)) + 
                                  ((age2 * bmi3) * num39)) + 
                                 ((age2 * !!fh_cvd_col) * num40)) + 
                                ((age2 * sbp1) * num41)) + 
                               ((age2 * town1) * num42)) + 
                              ((age3 * (!!smoking_col == 1)) * num43)) + 
                             ((age3 * (!!smoking_col == 2)) * num44)) + 
                            ((age3 * (!!smoking_col == 3)) * num45)) + 
                           ((age3 * (!!smoking_col == 4)) * num46)) + 
                          ((age3 * !!af_col) * num47)) + 
                         ((age3 * !!renal_col) * num48)) + 
                        ((age3 * !!bp_med_col) * num49)) + 
                       ((age3 * !!type1_col) * num50)) + 
                      ((age3 * !!type2_col) * num51)) + 
                     ((age3 * bmi2) * num52)) + 
                    ((age3 * bmi3) * num53)) + 
                   ((age3 * !!fh_cvd_col) * num54)) + 
                  ((age3 * sbp1) * num55)) + 
             ((age3 * town1) * num56),
           
           qrisk2_score = 100.0 * (1.0 - (survarray_val^exp(d))))
  
  
  # Keep QRISK2 score and unique ID columns only%>%
  new_dataframe <- new_dataframe %>%
    select(id_col, qrisk2_score)

# Join back on to original data table 
  dataframe <- dataframe %>%
    inner_join(new_dataframe, by="id_col") %>%
    select(-id_col)
  
  message("New column 'qrisk2_score' added")
  
  return(dataframe)
  
}


#' Calculate QDiabetes-HF 2015
#' 
#' @description calculates QDiabetes-HF 2015 score
#' @param sex - "male" or "female"
#' @param age - current age in years
#' @param ethrisk - QRISK2 ethnicity category: 0=Missing, 1=White, 2=Indian, 3=Pakistani, 4=Bangladeshi, 5=Other Asian, 6=Black Caribbean, 7=Black African, 8=Chinese, 9=Other ethnic group
#' @param town - Townsend Deprivation Index (default 0 i.e. missing)
#' @param smoking - QRISK2 smoking category: 0=Non-smoker, 1=Ex-smoker, 2=Current light smoker, 3=Current moderate smoker, 4=Current heavy smoker
#' @param duration - diabetes duration: 0=within the last year, 1=1-3 years, 2=4-6 years, 3=7-10 years, 4=11 or more
#' @param type1 - Type 1 diabetes (binary) - otherwise Type 2 assumed
#' @param cvd - history of angina, heart attack or stroke
#' @param af - atrial fibrillation (binary)
#' @param renal - CKD stage 4 or 5
#' @param hba1c - last HbA1c in mmol/mol
#' @param cholhdl - cholesterol:HDL ratio
#' @param sbp - systolic blood pressure in mmHg
#' @param bmi - BMI in kg/m2
#' @param surv - how many years survival to use in model (default 10)
#' @export

calculate_qdiabeteshf = function(dataframe, sex, age, ethrisk, town=NULL, smoking, duration, type1, cvd, af, renal, hba1c, cholhdl, sbp, bmi, surv=NULL) {
  
  
  # Get handles for columns with values in in data table
  sex_col <- as.symbol(deparse(substitute(sex)))
  age_col <- as.symbol(deparse(substitute(age)))
  ethrisk_col <- as.symbol(deparse(substitute(ethrisk)))
  smoking_col <- as.symbol(deparse(substitute(smoking)))
  duration_col <- as.symbol(deparse(substitute(duration)))
  type1_col <- as.symbol(deparse(substitute(type1)))
  cvd_col <- as.symbol(deparse(substitute(cvd)))
  af_col <- as.symbol(deparse(substitute(af)))
  renal_col <- as.symbol(deparse(substitute(renal)))
  hba1c_col <- as.symbol(deparse(substitute(hba1c)))
  cholhdl_col <- as.symbol(deparse(substitute(cholhdl)))
  sbp_col <- as.symbol(deparse(substitute(sbp)))
  bmi_col <- as.symbol(deparse(substitute(bmi)))
  town_col <- as.symbol(deparse(substitute(town)))
  surv_col <- as.symbol(deparse(substitute(surv)))
  
  
  # Make unique ID for each row so can join back on later
  dataframe <- dataframe %>%
    mutate(id_col=row_number())
  
  
  # Copy dataframe to new dataframe
  new_dataframe <- dataframe
  
  
  # Add bp_med and type_2 cols for missing variables
  new_dataframe <- dataframe %>%
    mutate(new_bp_med_col = 0,
           new_type2_col = ifelse(!!type1_col==0, 1, 0))
  
    bp_med_col <- as.symbol("new_bp_med_col")
    type2_col <- as.symbol("new_type2_col")
  
  
  # If missing Townsend deprivation index, use '0' i.e. missing
  if (deparse(substitute(town)) %in% colnames(new_dataframe)) {
    new_dataframe <- new_dataframe %>% mutate(town_col = ifelse(is.na(!!town_col), 0, !!town_col))
  }
  else {
    new_dataframe <- new_dataframe %>% mutate(town_col=0)
    message("Using average deprivation values as Townsend Deprivation Scores (town) missing")
  }
  
  
  # If missing survival time, use 10 years
  if (deparse(substitute(surv)) %in% colnames(new_dataframe)) {
    new_dataframe <- new_dataframe %>% mutate(surv_col = ifelse(is.na(!!surv_col), 10, !!surv_col))
  }
  else {
    new_dataframe <- new_dataframe %>% mutate(surv_col=10)
    message("Calculating 10-year risk as time period (surv) missing")
  }
  
  
  # Fetch constants from Aurum package
  male_vars <- cbind(sex="male",data.frame(unlist(lapply(aurum::qdiabeteshfConstants$male, function(y) lapply(y, as.numeric)), recursive="FALSE")))
  female_vars <- cbind(sex="female",data.frame(unlist(lapply(aurum::qdiabeteshfConstants$female, function(y) lapply(y, as.numeric)), recursive="FALSE")))
  vars <- rbind(male_vars, female_vars)
  
  
  
  # Join constants to data table
  ## copy=TRUE as need to copy constants to MySQL from package
  to_join_sex_var <- deparse(substitute(sex))
  
  new_dataframe <- new_dataframe %>%
    
    inner_join(vars, by=setNames("sex", to_join_sex_var), copy=TRUE)
  
  
  
  # Fill in missing BMI/SBP/chol:HDL
  
  new_dataframe <- new_dataframe %>%
    
    impute_missing_predictors(sex_col, age_col, ethrisk_col, smoking_col, type1_col, type2_col, cvd_col, bp_med_col, cholhdl_col, sbp_col, bmi_col)
  

  
  # Do calculation
  
  new_dataframe <- new_dataframe %>%
    
    mutate(new_bmi_col = ifelse(new_bmi_col>40, 40, new_bmi_col),
           
           bmi1 = new_bmi_col/10,
           bmi2 = (bmi1 ^ bmi_cons1) + bmi_cons4,
           bmi3 = (((bmi1 ^ bmi_cons2) - bmi_cons3) + (log(bmi1) * bmi_cons3) + bmi_cons5),
           
           sbp1 = new_sbp_col/100,
           sbp2 = ((sbp1 ^ sbp_cons1) - sbp_cons2) + (log(sbp1) * sbp_cons2) + sbp_cons5,
           sbp3 = ((sbp1 ^ sbp_cons3) - sbp_cons4) + (log(sbp1) * sbp_cons4) + sbp_cons6,
           
           rati1 = new_cholhdl_col + rati_cons1,
           
           hba1c1 = !!hba1c_col/100,
           hba1c2 = (hba1c1 ^ -2) + hba1c_cons1,
           hba1c3 = ((hba1c1 ^ -2) * log(hba1c1)) + hba1c_cons2,
           
           age1 = !!age_col + age_cons1,
           
           survarray_val = case_when(
             surv_col==0 ~ survarray1,
             surv_col==1 ~ survarray2,
             surv_col==2 ~ survarray3,
             surv_col==3 ~ survarray4,
             surv_col==4 ~ survarray5,
             surv_col==5 ~ survarray6,
             surv_col==6 ~ survarray7,
             surv_col==7 ~ survarray8,
             surv_col==8 ~ survarray9,
             surv_col==9 ~ survarray10,
             surv_col==10 ~ survarray11,
             surv_col==11 ~ survarray12,
             surv_col==12 ~ survarray13,
             surv_col==13 ~ survarray14,
             surv_col==14 ~ survarray15,
             surv_col==15 ~ survarray16
           ),
           
           durationarray_val = case_when(
             !!duration_col==0 ~ durationarray1,
             !!duration_col==1 ~ durationarray2,
             !!duration_col==2 ~ durationarray3,
             !!duration_col==3 ~ durationarray4,
             !!duration_col==4 ~ durationarray5
           ),
           
           ethriskarray_val = case_when(
             !!ethrisk_col==0 ~ ethriskarray1,
             !!ethrisk_col==1 ~ ethriskarray2,
             !!ethrisk_col==2 ~ ethriskarray3,
             !!ethrisk_col==3 ~ ethriskarray4,
             !!ethrisk_col==4 ~ ethriskarray5,
             !!ethrisk_col==5 ~ ethriskarray6,
             !!ethrisk_col==6 ~ ethriskarray7,
             !!ethrisk_col==7 ~ ethriskarray8,
             !!ethrisk_col==8 ~ ethriskarray9,
             !!ethrisk_col==9 ~ ethriskarray10
           ),
           
           smokearray_val = case_when(
             !!smoking_col==0 ~ smokearray1,
             !!smoking_col==1 ~ smokearray2,
             !!smoking_col==2 ~ smokearray3,
             !!smoking_col==3 ~ smokearray4,
             !!smoking_col==4 ~ smokearray5
           ),
           
           a = 0.0 +
             durationarray_val +
             ethriskarray_val +
             smokearray_val +
             (age1 * age_cons2) +
             (bmi2 * bmi_cons6) +
             (bmi3 * bmi_cons7) +
             (hba1c2 * hba1c_cons3) +
             (hba1c3 * hba1c_cons4) +
             (rati1 * rati_cons2) +
             (sbp2 * sbp_cons7) +
             (sbp3 * sbp_cons8) +
             (town_col * town_cons) +
             (!!af_col * af_cons) +
             (!!cvd_col * cvd_cons) +
             (!!renal_col * renal_cons) +
             (!!type1_col * type1_cons),
           
           qdiabeteshf_score = 100.0 * (1.0 - (survarray_val^exp(a))))
  
  
  # Keep QDiabetes-HF score and unique ID columns only%>%
  new_dataframe <- new_dataframe %>%
    select(id_col, new_bmi_col, new_sbp_col, new_cholhdl_col, qdiabeteshf_score)
  
  # Join back on to original data table 
  dataframe <- dataframe %>%
    inner_join(new_dataframe, by="id_col") %>%
    select(-id_col)
  
  message("New column 'qdiabeteshf_score' added")
  
  return(dataframe)
  
}