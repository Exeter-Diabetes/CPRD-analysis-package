
# Keep ICD9 and 10 causes separate


# Setup
library(tidyverse)
library(aurum)
rm(list=ls())

cprd = CPRDData$new(cprdEnv = "nondiabetes-jun2024", cprdConf = "~/.aurum.yaml")

cprd$tables$patient <- tbl(cprd$.con, dbplyr::in_schema("cprd_jun24nondm_data", "patient"))
cprd$tables$old_patient <- tbl(cprd$.con, dbplyr::in_schema("cprd_jun24dm_data", "patient"))


# Get raw death data
analysis = cprd$analysis("temporary")
death <- death %>% analysis$cached("ons_death")

analysis = cprd$analysis("ons_death")


# Number of distinct patids
death %>% distinct(patid) %>% count()
#4,256,372

# Number with death date (will remove those without)
death %>% filter(!is.na(reg_date_of_death)) %>% distinct(patid) %>% count()
#4,256,329


# Remove patients from diabetes download (as won't have be in patient table)
death <- death %>% anti_join(cprd$tables$old_patient, by="patid")

death %>% distinct(patid) %>% count()
#3,627,622

death %>% filter(!is.na(reg_date_of_death)) %>% distinct(patid) %>% count()
#3,627,584


# Choose reliable date of death for those with multiple dates, based on cprd_ddate/earliest date where cprd_ddate not available
# Ignore other data associated with incorrect dates
# Remove those with missing death date

closest <- death %>%
  filter(!is.na(reg_date_of_death)) %>%
  group_by(patid, reg_date_of_death) %>%
  summarise(id=n()) %>%
  ungroup() %>%
  group_by(patid) %>%
  mutate(count=n()) %>%
  ungroup() %>%
  filter(count>1) %>%
  inner_join((cprd$tables$patient %>% select(patid, cprd_ddate)), by="patid") %>%
  filter(!is.na(cprd_ddate)) %>%
  mutate(datediff=abs(datediff(cprd_ddate, reg_date_of_death))) %>%
  group_by(patid) %>%
  mutate(min_datediff=min(datediff, na.rm=TRUE)) %>%
  ungroup() %>% filter(datediff==min_datediff) %>%
  select(patid, chosen_date=reg_date_of_death) %>%
  analysis$cached("closest", unique_indexes="patid")

earliest <- death %>%
  filter(!is.na(reg_date_of_death)) %>%
  group_by(patid, reg_date_of_death) %>%
  summarise(id=n()) %>%
  ungroup() %>%
  group_by(patid) %>%
  mutate(count=n()) %>%
  ungroup() %>%
  filter(count>1) %>%
  inner_join((cprd$tables$patient %>% select(patid, cprd_ddate)), by="patid") %>%
  filter(is.na(cprd_ddate)) %>%
  group_by(patid) %>%
  summarise(chosen_date=min(reg_date_of_death, na.rm=TRUE)) %>%
  analysis$cached("earliest", unique_indexes="patid")

chosen_dates <- closest %>% union_all(earliest)

death_multiple_dates <- death %>%
  inner_join(chosen_dates, by="patid") %>%
  filter(chosen_date==reg_date_of_death) %>%
  select(-chosen_date) %>%
  analysis$cached("death_multiple_dates", indexes="patid")

death_single_date <- death %>%
  anti_join(death_multiple_dates, by="patid") %>%
  filter(!is.na(reg_date_of_death)) %>%
  analysis$cached("death_single_date", indexes="patid")

interim_1 <- death_multiple_dates %>%
  union_all(death_single_date) %>%
  analysis$cached("interim_1")

interim_1 %>% distinct(patid) %>% count()
#3,627,584 as above



# Still have multiple rows for some patients with identical reg date of death
# Variables of interest:
## 3 x POD
## ICD10 underlying cause
## ICD10 other cause
## Haven't included which are these are from which record i.e. which were recorded together


# pod_cod
## Convert all communal establishment codes (can't get lookup) to "C"
## Pivot wider to keep multiple values - max is 2
pod_cod <- interim_1 %>%
  mutate(pod_cod=ifelse(is.na(pod_cod), NA,
                        ifelse(pod_cod=="H", "H",
                               ifelse(pod_cod=="E", "E", "C")))) %>%
  filter(!is.na(pod_cod)) %>%
  group_by(patid, pod_cod) %>%
  summarise(id=n()) %>%
  ungroup() %>%
  group_by(patid) %>%
  dbplyr::window_order(pod_cod) %>%
  mutate(id=paste0("pod_cod_", row_number())) %>%
  dbplyr::window_order() %>%
  ungroup() %>%
  pivot_wider(id_cols=patid, names_from=id, values_from=pod_cod) %>%
  analysis$cached("pod_cod", unique_indexes="patid")


# pod_establishment_type
## Pivot wider to keep multiple values - max is 2
pod_establishment_site <- interim_1 %>%
  filter(!is.na(pod_establishment_type)) %>%
  group_by(patid, pod_establishment_type) %>%
  summarise(id=n()) %>%
  ungroup() %>%
  group_by(patid) %>%
  dbplyr::window_order(pod_establishment_type) %>%
  mutate(id=paste0("pod_establishment_type_", row_number())) %>%
  dbplyr::window_order() %>%
  ungroup() %>%
  pivot_wider(id_cols=patid, names_from=id, values_from=pod_establishment_type) %>%
  analysis$cached("pod_establishment_site", unique_indexes="patid")


# pod_nhs_establishment
## Rename to nhs_indicator to match lookup
## Pivot wider to keep multiple values - max is 2
nhs_indicator <- interim_1 %>%
  rename(nhs_indicator=pod_nhs_establishment) %>%
  filter(!is.na(nhs_indicator)) %>%
  group_by(patid, nhs_indicator) %>%
  summarise(id=n()) %>%
  ungroup() %>%
  group_by(patid) %>%
  dbplyr::window_order(nhs_indicator) %>%
  mutate(id=paste0("nhs_indicator_", row_number())) %>%
  dbplyr::window_order() %>%
  ungroup() %>%
  pivot_wider(id_cols=patid, names_from=id, values_from=nhs_indicator) %>%
  analysis$cached("nhs_indicator", unique_indexes="patid")


# Secondary causes of death
## Only include unique values for each patient
## Add decimal points back into ICD10 codes

icd9_secondary_causes_wide <- interim_1 %>%
  select(patid, starts_with("icd9_orig")) %>%
  pivot_longer(cols=c(starts_with("icd9_orig"))) %>%
  filter(!is.na(value)) %>%
  distinct(patid, value) %>%
  group_by(patid) %>%
  dbplyr::window_order(value) %>%
  mutate(id=paste0("cause_icd9_", row_number())) %>%
  dbplyr::window_order() %>%
  ungroup() %>%
  pivot_wider(id_cols="patid", names_from="id", values_from="value") %>%
  analysis$cached("icd9_secondary_causes_wide", unique_indexes="patid")
# max number of causes = 12

icd10_secondary_causes_wide <- interim_1 %>%
  select(patid, starts_with("s_cod_code")) %>%
  pivot_longer(cols=c(starts_with("s_cod_code"))) %>%
  filter(!is.na(value)) %>%
  distinct(patid, value) %>%
  mutate(value=ifelse(nchar(value)==3, value, paste0(substr(value, 1, 3), ".", substr(value, 4, 4)))) %>%
  group_by(patid) %>%
  dbplyr::window_order(value) %>%
  mutate(id=paste0("cause_", row_number())) %>%
  dbplyr::window_order() %>%
  ungroup() %>%
  pivot_wider(id_cols="patid", names_from="id", values_from="value") %>%
  analysis$cached("icd10_secondary_causes_wide", unique_indexes="patid")
# max number of causes = 17


# Underlying cause of death
## Only include unique values for each patient

icd9_underlying_causes_wide <- interim_1 %>%
  select(patid, s_underlying_cod_icd9) %>%
  filter(!is.na(s_underlying_cod_icd9)) %>%
  distinct(patid, s_underlying_cod_icd9) %>%
  group_by(patid) %>%
  dbplyr::window_order(s_underlying_cod_icd9) %>%
  mutate(id=paste0("underlying_cause_icd9_", row_number())) %>%
  dbplyr::window_order() %>%
  ungroup() %>%
  pivot_wider(id_cols="patid", names_from="id", values_from="s_underlying_cod_icd9") %>%
  analysis$cached("icd9_underlying_causes_wide", unique_indexes="patid")
# max number of causes = 2
  
icd10_underlying_causes_wide <- interim_1 %>%
  select(patid, s_underlying_cod_icd10) %>%
  filter(!is.na(s_underlying_cod_icd10)) %>%
  distinct(patid, s_underlying_cod_icd10) %>%
  mutate(s_underlying_cod_icd10=ifelse(nchar(s_underlying_cod_icd10)==3, s_underlying_cod_icd10, paste0(substr(s_underlying_cod_icd10, 1, 3), ".", substr(s_underlying_cod_icd10, 4, 4)))) %>%
  group_by(patid) %>%
  dbplyr::window_order(s_underlying_cod_icd10) %>%
  mutate(id=paste0("underlying_cause_", row_number())) %>%
  dbplyr::window_order() %>%
  ungroup() %>%
  pivot_wider(id_cols="patid", names_from="id", values_from="s_underlying_cod_icd10") %>%
  analysis$cached("icd10_underlying_causes_wide", unique_indexes="patid")
# max number of causes = 3


final <- interim_1 %>%
  distinct(patid, pracid, reg_date_of_death) %>%
  left_join(pod_cod, by="patid") %>%
  left_join(pod_establishment_site, by="patid") %>%
  left_join(nhs_indicator, by="patid") %>%
  left_join(icd9_secondary_causes_wide, by="patid") %>%
  left_join(icd10_secondary_causes_wide, by="patid") %>%
  left_join(icd9_underlying_causes_wide, by="patid") %>%
  left_join(icd10_underlying_causes_wide, by="patid") %>%
  analysis$cached("final", unique_indexes="patid")

final  %>% count()
#3,627,584 as above

# manually copied into cprd_jun24nondm_data via MySQL (see death_data_processing SQL script), and all columns indexed


