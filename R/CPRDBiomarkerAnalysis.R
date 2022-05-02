#### Constructor ----

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

calculate_qrisk2 = function(dataframe, sex, age, ethrisk, town=NULL, smoking, type1, type2, fh_cvd, renal, af, bp_med, rheumatoid_arth, cholhdl, sbp, bmi, surv=NULL) {
  
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
  
  dataframe <- dataframe %>%
    mutate(id_col=row_number())
  
  
  new_dataframe <- dataframe
  
  
  if (deparse(substitute(town)) %in% colnames(new_dataframe)) {
    new_dataframe <- new_dataframe %>% mutate(town_col = ifelse(is.na(!!town_col), 0, !!town_col))
  }
  else {
    new_dataframe <- new_dataframe %>% mutate(town_col=0)
    message("Using average deprivation values as Townsend Deprivation Scores (town) missing")
  }
  
  
  if (deparse(substitute(surv)) %in% colnames(new_dataframe)) {
    new_dataframe <- new_dataframe %>% mutate(surv_col = ifelse(is.na(!!surv_col), 10, !!surv_col))
  }
  else {
    new_dataframe <- new_dataframe %>% mutate(surv_col=10)
    message("Calculating 10-year risk as time period (surv) missing")
  }
  
  
  male_vars <- cbind(sex="male",data.frame(unlist(lapply(aurum::qrisk2Constants$male, function(y) lapply(y, as.numeric)), recursive="FALSE")))
  female_vars <- cbind(sex="female",data.frame(unlist(lapply(aurum::qrisk2Constants$female, function(y) lapply(y, as.numeric)), recursive="FALSE")))
  vars <- rbind(male_vars, female_vars)
  
  to_join_sex_var = deparse(substitute(sex))
  
  new_dataframe <- new_dataframe %>%
    
    inner_join(vars, by=setNames("sex",to_join_sex_var), copy=TRUE) %>%
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
                                (((((((((0.0 + bmi_ethriskarray_val) + bmi_smokearray_val) + ((age1 - bmi_predict_eq_cons1) * bmi_predict_eq_cons2)) + (((age1^2.0) - bmi_predict_eq_cons3) * bmi_predict_eq_cons4))) + (!!bp_med_col * bmi_predict_num10)) + (!!type1_col * bmi_predict_num11)) + (!!type2_col * bmi_predict_num12)) + bmi_predict_eq_cons5),
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
                                (((((((((0.0 + sbp_ethriskarray_val) + sbp_smokearray_val) + (((age1^3.0) - sbp_predict_eq_cons1) * sbp_predict_eq_cons2)) + ((((age1^3.0) * log(age1)) - sbp_predict_eq_cons3) * sbp_predict_eq_cons4))) + (!!bp_med_col * sbp_predict_num10)) + (!!type1_col * sbp_predict_num11)) + (!!type2_col * sbp_predict_num12)) + sbp_predict_eq_cons5),
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
                                    (((((((((0.0 + ratio_ethriskarray_val) + ratio_smokearray_val) + (((age1^ratio_predict_eq_cons1) - ratio_predict_eq_cons2) * ratio_predict_eq_cons3)) + ((((age1^ratio_predict_eq_cons4) * (log(age1) - log(age1^ratio_predict_eq_cons5) + ratio_predict_eq_cons5)) - ratio_predict_eq_cons6) * ratio_predict_eq_cons7))) + (!!bp_med_col * ratio_predict_num10)) + (!!type1_col * ratio_predict_num11)) + (!!type2_col * ratio_predict_num12)) + ratio_predict_eq_cons8),
                                    !!cholhdl_col),
           
           new_bmi_col = ifelse(new_bmi_col>40, 40, new_bmi_col),
           
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
           
           qrisk2_score = 100.0 * (1.0 - (survarray_val^exp(d)))) %>%
    
    select(id_col, qrisk2_score)
  
  
  dataframe <- dataframe %>%
    inner_join(new_dataframe, by="id_col") %>%
    select(-id_col)
  
  message("New column 'qrisk2_score' added")
  
  return(dataframe)
  
}