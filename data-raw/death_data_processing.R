
# Setup
library(tidyverse)
library(aurum)
rm(list=ls())

cprd = CPRDData$new(cprdEnv = "diabetes-jun2024", cprdConf = "~/.aurum.yaml")

# Get raw death data
analysis = cprd$analysis("temporary")
death <- death %>% analysis$cached("ons_death")

analysis = cprd$analysis("ons_death")


# Number of distinct patids
death %>% distinct(patid) %>% count()
#628,750

# Number with death date (will remove those without)
death %>% filter(!is.na(reg_date_of_death)) %>% distinct(patid) %>% count()
#628,745



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
#628745 as above



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
  ungroup() %>%
  pivot_wider(id_cols=patid, names_from=id, values_from=nhs_indicator) %>%
  analysis$cached("nhs_indicator", unique_indexes="patid")


# Secondary causes of death
## Only include unique values for each patient

## Convert ICD9 to ICD10: using UKBB lookup which is based on:
### TRUD files used from 'NHS ICD-10 5th Edition data files' file pack: ICD10_Edition5_CodesAndTitlesAndMetadataFileSpecification_GB_20160401, ICD10_Edition5_TablesOfCodingEquivalencesSpecification(analysis)_GB_20160401. [Date downloaded: 21/06/2019]
### Additional files: NHS Centre for Coding and Classification. Tables of Equivalence A Specification of the File Structure for Tables of Equivalence between ICD-9 and ICD-10 Version 1.1. Sep 1994.
### Not all had translation - mapped to nearest definition (all seemed to map well in terms of definition)
### Only 15 codes, 14 unique values

icd9_secondary_causes <- interim_1 %>%
  select(patid, starts_with("icd9_orig")) %>%
 pivot_longer(cols=c(starts_with("icd9_orig"))) %>%
  filter(!is.na(value)) %>%
  mutate(cause=case_when(value==1749 ~ "C509",
                         value==1990 ~ "C800",
                         value==1991 ~ "C809",
                         value==2387 ~ "D479",
                         value==2429 ~ "E059", 
                         value==2500 ~ "E119",
                         value==380 ~ "H60",
                         value==4019 ~ "I10",
                         value==410 ~ "I21",
                         value==485 ~ "J180",
                         value==4823 ~ "J13",
                         value==486 ~ "J188",
                         value==492 ~ "J43",
                         value==5329 ~ "K269")) %>%
  select(patid, cause) %>%
  analysis$cached("icd9_secondary_causes", indexes="patid")


# Make long table of all secondary cause then convert to wide
all_secondary_causes_long <- interim_1 %>%
  select(patid, starts_with("s_cod_code")) %>%
  pivot_longer(cols=c(starts_with("s_cod_code"))) %>%
  filter(!is.na(value)) %>%
  rename(cause=value) %>%
  select(patid, cause) %>%
  union_all(icd9_secondary_causes) %>%
  group_by(patid, cause) %>%
  summarise(id=n()) %>%
  ungroup() %>%
  select(-id) %>%
  analysis$cached("all_secondary_causes_long", indexes="patid")
  
all_secondary_causes_wide <- all_secondary_causes_long %>%
  group_by(patid) %>%
  dbplyr::window_order(cause) %>%
  mutate(id=paste0("cause_", row_number())) %>%
  ungroup() %>%
  pivot_wider(id_cols="patid", names_from="id", values_from="cause") %>%
  analysis$cached("all_secondary_causes_wide", unqiue_indexes="patid")
# max number of causes = 17



# Underlying cause of death
## Only include unique values for each patient

## Convert ICD9 to ICD10: using UKBB lookup which is based on:
### Only 5 codes

icd9_underlying_causes <- interim_1 %>%
  select(patid, s_underlying_cod_icd9) %>%
  filter(!is.na(s_underlying_cod_icd9)) %>%
  mutate(underlying_cause=case_when(s_underlying_cod_icd9==1749 ~ "C509",
                                    s_underlying_cod_icd9==1991 ~ "C809",
                                    s_underlying_cod_icd9==2429 ~ "E059", 
                                    s_underlying_cod_icd9==485 ~ "J180",
                                    s_underlying_cod_icd9==492 ~ "J43")) %>%
  select(patid, underlying_cause) %>%
  analysis$cached("icd9_underlying_causes", indexes="patid")


# Make long table of all secondary cause then convert to wide
all_underlying_causes_long <- interim_1 %>%
  select(patid, s_underlying_cod_icd10) %>%
  filter(!is.na(s_underlying_cod_icd10)) %>%
  rename(underlying_cause=s_underlying_cod_icd10) %>%
  select(patid, underlying_cause) %>%
  union_all(icd9_underlying_causes) %>%
  group_by(patid, underlying_cause) %>%
  summarise(id=n()) %>%
  ungroup() %>%
  select(-id) %>%
  analysis$cached("all_underlying_causes_long", indexes="patid")

all_underlying_causes_wide <- all_underlying_causes_long %>%
  group_by(patid) %>%
  dbplyr::window_order(underlying_cause) %>%
  mutate(id=paste0("underlying_cause_", row_number())) %>%
  ungroup() %>%
  pivot_wider(id_cols="patid", names_from="id", values_from="underlying_cause") %>%
  analysis$cached("all_underlying_causes_wide", unqiue_indexes="patid")
# max number of causes = 3



final <- interim_1 %>%
  group_by(patid, pracid, reg_date_of_death) %>%
  summarise(id=n()) %>%
  ungroup() %>%
  select(-id) %>%
  left_join(pod_cod, by="patid") %>%
  left_join(pod_establishment_site, by="patid") %>%
  left_join(nhs_indicator, by="patid") %>%
  left_join(all_secondary_causes_wide, by="patid") %>%
  left_join(all_underlying_causes_wide, by="patid") %>%
  analysis$cached("final", unique_indexes="patid")

#628745 as above

# manually copied into cprd_jun24dm_data via MySQL (see death_data_processing SQL script), and all columns indexed


