set role 'role_full_admin';

# CHESS
CREATE INDEX x_chess_patid ON cprd_data.chess (patid);
CREATE INDEX x_chess_pracid ON cprd_data.chess (pracid);
CREATE INDEX x_chess_n_chess_patid ON cprd_data.chess (n_chess_patid);
CREATE INDEX x_chess_trustid ON cprd_data.chess (trustid);
CREATE INDEX x_chess_dateofadmission ON cprd_data.chess (weekofadmission,yearofadmission);
CREATE INDEX x_chess_estimateddateonset ON cprd_data.chess (estimateddateonset);
CREATE INDEX x_chess_infectionswabdate ON cprd_data.chess (infectionswabdate);
CREATE INDEX x_chess_labtestdate ON cprd_data.chess (labtestdate);
CREATE INDEX x_chess_covid19 ON cprd_data.chess (covid19);
CREATE INDEX x_chess_admittedfrom ON cprd_data.chess (admittedfrom);
CREATE INDEX x_chess_dateadmittedicu ON cprd_data.chess (dateadmittedicu);
CREATE INDEX x_chess_dateleavingicu ON cprd_data.chess (dateleavingicu);
CREATE INDEX x_chess_admissionflu ON cprd_data.chess (admissionflu);
CREATE INDEX x_chess_admissioncovid19 ON cprd_data.chess (admissioncovid19);
CREATE INDEX x_chess_ventilatedwhilstadmitteddays ON cprd_data.chess (ventilatedwhilstadmitteddays);
CREATE INDEX x_chess_wasthepatientadmittedtoicu ON cprd_data.chess (wasthepatientadmittedtoicu);
CREATE INDEX x_chess_daysecmo ON cprd_data.chess (daysecmo);
CREATE INDEX x_chess_hospitaladmissiondate ON cprd_data.chess (hospitaladmissiondate);
CREATE INDEX x_chess_admissionrsv ON cprd_data.chess (admissionrsv);
CREATE INDEX x_chess_respiratorysupportnone ON cprd_data.chess (respiratorysupportnone);
CREATE INDEX x_chess_oxygenviacannulaeormask ON cprd_data.chess (oxygenviacannulaeormask);
CREATE INDEX x_chess_highflownasaloxygen ON cprd_data.chess (highflownasaloxygen);
CREATE INDEX x_chess_noninvasivemechanicalventilation ON cprd_data.chess (noninvasivemechanicalventilation);
CREATE INDEX x_chess_invasivemechanicalventilation ON cprd_data.chess (invasivemechanicalventilation);
CREATE INDEX x_chess_respiratorysupportecmo ON cprd_data.chess (respiratorysupportecmo);
CREATE INDEX x_chess_anticovid19treatment ON cprd_data.chess (anticovid19treatment);
CREATE INDEX x_chess_chronicrespiratory ON cprd_data.chess (chronicrespiratory);
CREATE INDEX x_chess_asthmarequiring ON cprd_data.chess (asthmarequiring);
CREATE INDEX x_chess_chronicheart ON cprd_data.chess (chronicheart);
CREATE INDEX x_chess_chronicrenal ON cprd_data.chess (chronicrenal);
CREATE INDEX x_chess_chronicliver ON cprd_data.chess (chronicliver);
CREATE INDEX x_chess_chronicneurological ON cprd_data.chess (chronicneurological);
CREATE INDEX x_chess_isdiabetes ON cprd_data.chess (isdiabetes);
CREATE INDEX x_chess_diabetestype ON cprd_data.chess (diabetestype);
CREATE INDEX x_chess_immunosuppressiontreatment ON cprd_data.chess (immunosuppressiontreatment);
CREATE INDEX x_chess_immunosuppressiondisease ON cprd_data.chess (immunosuppressiondisease);
CREATE INDEX x_chess_other ON cprd_data.chess (other);
CREATE INDEX x_chess_obesityclinical ON cprd_data.chess (obesityclinical);
CREATE INDEX x_chess_obesitybmi ON cprd_data.chess (obesitybmi);
CREATE INDEX x_chess_pregnancy ON cprd_data.chess (pregnancy);
CREATE INDEX x_chess_prematurity ON cprd_data.chess (prematurity);
CREATE INDEX x_chess_hypertension ON cprd_data.chess (hypertension);
CREATE INDEX x_chess_travelin14days ON cprd_data.chess (travelin14days);
CREATE INDEX x_chess_worksashealthcareworker ON cprd_data.chess (worksashealthcareworker);
CREATE INDEX x_chess_contactwithconfirmedcovid19case ON cprd_data.chess (contactwithconfirmedcovid19case);
CREATE INDEX x_chess_finaloutcome ON cprd_data.chess (finaloutcome);
CREATE INDEX x_chess_finaloutcomedate ON cprd_data.chess (finaloutcomedate);
CREATE INDEX x_chess_transferdestination ON cprd_data.chess (transferdestination);
CREATE INDEX x_chess_causeofdeath ON cprd_data.chess (causeofdeath);
CREATE INDEX x_chess_hospitaladmissionadmittedfrom ON cprd_data.chess (hospitaladmissionadmittedfrom);
CREATE INDEX x_chess_mechanicalinvasiveventilationdur ON cprd_data.chess (mechanicalinvasiveventilationdur);
CREATE INDEX x_chess_asymptomatictesting ON cprd_data.chess (asymptomatictesting);
CREATE INDEX x_chess_patientstillonicu ON cprd_data.chess (patientstillonicu);
CREATE INDEX x_chess_respiratorysupportunknown ON cprd_data.chess (respiratorysupportunknown);
CREATE INDEX x_chess_priorhospitalattendance ON cprd_data.chess (priorhospitalattendance);
CREATE INDEX x_chess_dateofpriorattendance ON cprd_data.chess (dateofpriorattendance);
CREATE INDEX x_chess_admissionnotrelatedtorespiratory ON cprd_data.chess (admissionnotrelatedtorespiratory);
CREATE INDEX x_chess_typeorplaceofwork ON cprd_data.chess (typeorplaceofwork);
CREATE INDEX x_chess_treatmenttocilizumab ON cprd_data.chess (treatmenttocilizumab);
CREATE INDEX x_chess_treatmentremdesivir ON cprd_data.chess (treatmentremdesivir);
CREATE INDEX x_chess_treatmentother ON cprd_data.chess (treatmentother);
CREATE INDEX x_chess_treatmentconvalescentplasma ON cprd_data.chess (treatmentconvalescentplasma);


# HES APC
## hes_patient
CREATE INDEX x_hes_patient_pracid ON cprd_data.hes_patient (pracid);
CREATE INDEX x_hes_patient_gen_hesid ON cprd_data.hes_patient (gen_hesid);
CREATE INDEX x_hes_patient_n_patid_hes ON cprd_data.hes_patient (n_patid_hes);
CREATE INDEX x_hes_patient_gen_ethnicity ON cprd_data.hes_patient (gen_ethnicity);
CREATE INDEX x_hes_patient_match_rank ON cprd_data.hes_patient (match_rank);

## hes_hospital
CREATE INDEX x_hes_hospital_patid ON cprd_data.hes_hospital (patid);
CREATE INDEX x_hes_hospital_spno ON cprd_data.hes_hospital (spno);
CREATE INDEX x_hes_hospital_admidate ON cprd_data.hes_hospital (admidate);
CREATE INDEX x_hes_hospital_discharged ON cprd_data.hes_hospital (discharged);
CREATE INDEX x_hes_hospital_admimeth ON cprd_data.hes_hospital (admimeth);
CREATE INDEX x_hes_hospital_admisorc ON cprd_data.hes_hospital (admisorc);
CREATE INDEX x_hes_hospital_disdest ON cprd_data.hes_hospital (disdest);
CREATE INDEX x_hes_hospital_dismeth ON cprd_data.hes_hospital (dismeth);
CREATE INDEX x_hes_hospital_duration ON cprd_data.hes_hospital (duration);
CREATE INDEX x_hes_hospital_elecdate ON cprd_data.hes_hospital (elecdate);
CREATE INDEX x_hes_hospital_elecdur ON cprd_data.hes_hospital (elecdur);

## hes_episodes
CREATE INDEX x_hes_episodes_patid ON cprd_data.hes_episodes (patid);
CREATE INDEX x_hes_episodes_spno ON cprd_data.hes_episodes (spno);
CREATE INDEX x_hes_episodes_epikey ON cprd_data.hes_episodes (epikey);
CREATE INDEX x_hes_episodes_admidate ON cprd_data.hes_episodes (admidate);
CREATE INDEX x_hes_episodes_epistart ON cprd_data.hes_episodes (epistart);
CREATE INDEX x_hes_episodes_epiend ON cprd_data.hes_episodes (epiend);
CREATE INDEX x_hes_episodes_discharged ON cprd_data.hes_episodes (discharged);
CREATE INDEX x_hes_episodes_eorder ON cprd_data.hes_episodes (eorder);
CREATE INDEX x_hes_episodes_epidur ON cprd_data.hes_episodes (epidur);
CREATE INDEX x_hes_episodes_epitype ON cprd_data.hes_episodes (epitype);
CREATE INDEX x_hes_episodes_admimeth ON cprd_data.hes_episodes (admimeth);
CREATE INDEX x_hes_episodes_admisorc ON cprd_data.hes_episodes (admisorc);
CREATE INDEX x_hes_episodes_disdest ON cprd_data.hes_episodes (disdest);
CREATE INDEX x_hes_episodes_dismeth ON cprd_data.hes_episodes (dismeth);
CREATE INDEX x_hes_episodes_mainspef ON cprd_data.hes_episodes (mainspef);
CREATE INDEX x_hes_episodes_tretspef ON cprd_data.hes_episodes (tretspef);
CREATE INDEX x_hes_episodes_pconsult ON cprd_data.hes_episodes (pconsult);
CREATE INDEX x_hes_episodes_intmanig ON cprd_data.hes_episodes (intmanig);
CREATE INDEX x_hes_episodes_classpat ON cprd_data.hes_episodes (classpat);
CREATE INDEX x_hes_episodes_firstreg ON cprd_data.hes_episodes (firstreg);
CREATE INDEX x_hes_episodes_ethnos ON cprd_data.hes_episodes (ethnos);

## hes_diagnosis_epi
CREATE INDEX x_hes_diagnosis_epi_patid ON cprd_data.hes_diagnosis_epi (patid);
CREATE INDEX x_hes_diagnosis_epi_spno ON cprd_data.hes_diagnosis_epi (spno);
CREATE INDEX x_hes_diagnosis_epi_epikey ON cprd_data.hes_diagnosis_epi (epikey);
CREATE INDEX x_hes_diagnosis_epi_epistart ON cprd_data.hes_diagnosis_epi (epistart);
CREATE INDEX x_hes_diagnosis_epi_epiend ON cprd_data.hes_diagnosis_epi (epiend);
CREATE INDEX x_hes_diagnosis_epi_ICD ON cprd_data.hes_diagnosis_epi (ICD);
CREATE INDEX x_hes_diagnosis_epi_ICDx ON cprd_data.hes_diagnosis_epi (ICDx);
CREATE INDEX x_hes_diagnosis_epi_d_order ON cprd_data.hes_diagnosis_epi (d_order);

## hes_diagnosis_hosp
CREATE INDEX x_hes_diagnosis_hosp_patid ON cprd_data.hes_diagnosis_hosp (patid);
CREATE INDEX x_hes_diagnosis_hosp_spno ON cprd_data.hes_diagnosis_hosp (spno);
CREATE INDEX x_hes_diagnosis_hosp_admidate ON cprd_data.hes_diagnosis_hosp (admidate);
CREATE INDEX x_hes_diagnosis_hosp_discharged ON cprd_data.hes_diagnosis_hosp (discharged);
CREATE INDEX x_hes_diagnosis_hosp_ICD ON cprd_data.hes_diagnosis_hosp (ICD);
CREATE INDEX x_hes_diagnosis_hosp_ICDx ON cprd_data.hes_diagnosis_hosp (ICDx);

## hes_primary_diag_hosp
CREATE INDEX x_hes_primary_diag_hosp_patid ON cprd_data.hes_primary_diag_hosp (patid);
CREATE INDEX x_hes_primary_diag_hosp_spno ON cprd_data.hes_primary_diag_hosp (spno);
CREATE INDEX x_hes_primary_diag_hosp_admidate ON cprd_data.hes_primary_diag_hosp (admidate);
CREATE INDEX x_hes_primary_diag_hosp_discharged ON cprd_data.hes_primary_diag_hosp (discharged);
CREATE INDEX x_hes_primary_diag_hosp_ICD_PRIMARY ON cprd_data.hes_primary_diag_hosp (ICD_PRIMARY);
CREATE INDEX x_hes_primary_diag_hosp_ICDx ON cprd_data.hes_primary_diag_hosp (ICDx);

## hes_procedures_epi
CREATE INDEX x_hes_procedures_epi_patid ON cprd_data.hes_procedures_epi (patid);
CREATE INDEX x_hes_procedures_epi_spno ON cprd_data.hes_procedures_epi (spno);
CREATE INDEX x_hes_procedures_epi_epikey ON cprd_data.hes_procedures_epi (epikey);
CREATE INDEX x_hes_procedures_epi_admidate ON cprd_data.hes_procedures_epi (admidate);
CREATE INDEX x_hes_procedures_epi_epistart ON cprd_data.hes_procedures_epi (epistart);
CREATE INDEX x_hes_procedures_epi_epiend ON cprd_data.hes_procedures_epi (epiend);
CREATE INDEX x_hes_procedures_epi_discharged ON cprd_data.hes_procedures_epi (discharged);
CREATE INDEX x_hes_procedures_epi_OPCS ON cprd_data.hes_procedures_epi (OPCS);
CREATE INDEX x_hes_procedures_epi_evdate ON cprd_data.hes_procedures_epi (evdate);
CREATE INDEX x_hes_procedures_epi_p_order ON cprd_data.hes_procedures_epi (p_order);

## hes_acp
CREATE INDEX x_hes_acp_patid ON cprd_data.hes_acp (patid);
CREATE INDEX x_hes_acp_spno ON cprd_data.hes_acp (spno);
CREATE INDEX x_hes_acp_epikey ON cprd_data.hes_acp (epikey);
CREATE INDEX x_hes_acp_epistart ON cprd_data.hes_acp (epistart);
CREATE INDEX x_hes_acp_epiend ON cprd_data.hes_acp (epiend);
CREATE INDEX x_hes_acp_eorder ON cprd_data.hes_acp (eorder);
CREATE INDEX x_hes_acp_epidur ON cprd_data.hes_acp (epidur);
CREATE INDEX x_hes_acp_numacp ON cprd_data.hes_acp (numacp);
CREATE INDEX x_hes_acp_acpn ON cprd_data.hes_acp (acpn);
CREATE INDEX x_hes_acp_acpstar ON cprd_data.hes_acp (acpstar);
CREATE INDEX x_hes_acp_acpend ON cprd_data.hes_acp (acpend);
CREATE INDEX x_hes_acp_acpdur ON cprd_data.hes_acp (acpdur);
CREATE INDEX x_hes_acp_intdays ON cprd_data.hes_acp (intdays);
CREATE INDEX x_hes_acp_depdays ON cprd_data.hes_acp (depdays);
CREATE INDEX x_hes_acp_acploc ON cprd_data.hes_acp (acploc);
CREATE INDEX x_hes_acp_acpsour ON cprd_data.hes_acp (acpsour);
CREATE INDEX x_hes_acp_acpdisp ON cprd_data.hes_acp (acpdisp);
CREATE INDEX x_hes_acp_acpout ON cprd_data.hes_acp (acpout);
CREATE INDEX x_hes_acp_acpplan ON cprd_data.hes_acp (acpplan);
CREATE INDEX x_hes_acp_acpspef ON cprd_data.hes_acp (acpspef);
CREATE INDEX x_hes_acp_orgsup ON cprd_data.hes_acp (orgsup);

## hes_ccare
CREATE INDEX x_hes_ccare_patid ON cprd_data.hes_ccare (patid);
CREATE INDEX x_hes_ccare_spno ON cprd_data.hes_ccare (spno);
CREATE INDEX x_hes_ccare_epikey ON cprd_data.hes_ccare (epikey);
CREATE INDEX x_hes_ccare_admidate ON cprd_data.hes_ccare (admidate);
CREATE INDEX x_hes_ccare_discharged ON cprd_data.hes_ccare (discharged);
CREATE INDEX x_hes_ccare_epistart ON cprd_data.hes_ccare (epistart);
CREATE INDEX x_hes_ccare_epiend ON cprd_data.hes_ccare (epiend);
CREATE INDEX x_hes_ccare_eorder ON cprd_data.hes_ccare (eorder);
CREATE INDEX x_hes_ccare_ccstartdate ON cprd_data.hes_ccare (ccstartdate);
CREATE INDEX x_hes_ccare_ccstarttime ON cprd_data.hes_ccare (ccstarttime);
CREATE INDEX x_hes_ccare_ccdisrdydate ON cprd_data.hes_ccare (ccdisrdydate);
CREATE INDEX x_hes_ccare_ccdisrdytime ON cprd_data.hes_ccare (ccdisrdytime);
CREATE INDEX x_hes_ccare_ccdisdate ON cprd_data.hes_ccare (ccdisdate);
CREATE INDEX x_hes_ccare_ccdistime ON cprd_data.hes_ccare (ccdistime);
CREATE INDEX x_hes_ccare_ccadmitype ON cprd_data.hes_ccare (ccadmitype);
CREATE INDEX x_hes_ccare_ccadmisorc ON cprd_data.hes_ccare (ccadmisorc);
CREATE INDEX x_hes_ccare_ccsorcloc ON cprd_data.hes_ccare (ccsorcloc);
CREATE INDEX x_hes_ccare_ccdisstat ON cprd_data.hes_ccare (ccdisstat);
CREATE INDEX x_hes_ccare_ccdisdest ON cprd_data.hes_ccare (ccdisdest);
CREATE INDEX x_hes_ccare_ccdisloc ON cprd_data.hes_ccare (ccdisloc);
CREATE INDEX x_hes_ccare_cclev2days ON cprd_data.hes_ccare (cclev2days);
CREATE INDEX x_hes_ccare_cclev3days ON cprd_data.hes_ccare (cclev3days);
CREATE INDEX x_hes_ccare_bcardsupdays ON cprd_data.hes_ccare (bcardsupdays);
CREATE INDEX x_hes_ccare_acardsupdays ON cprd_data.hes_ccare (acardsupdays);
CREATE INDEX x_hes_ccare_bressupdays ON cprd_data.hes_ccare (bressupdays);
CREATE INDEX x_hes_ccare_aressupdays ON cprd_data.hes_ccare (aressupdays);
CREATE INDEX x_hes_ccare_gisupdays ON cprd_data.hes_ccare (gisupdays);
CREATE INDEX x_hes_ccare_liversupdays ON cprd_data.hes_ccare (liversupdays);
CREATE INDEX x_hes_ccare_neurosupdays ON cprd_data.hes_ccare (neurosupdays);
CREATE INDEX x_hes_ccare_rensupdays ON cprd_data.hes_ccare (rensupdays);
CREATE INDEX x_hes_ccare_dermsupdays ON cprd_data.hes_ccare (dermsupdays);
CREATE INDEX x_hes_ccare_orgsupmax ON cprd_data.hes_ccare (orgsupmax);
CREATE INDEX x_hes_ccare_ccunitfun ON cprd_data.hes_ccare (ccunitfun);
CREATE INDEX x_hes_ccare_unitbedconfig ON cprd_data.hes_ccare (unitbedconfig);
CREATE INDEX x_hes_ccare_bestmatch ON cprd_data.hes_ccare (bestmatch);
CREATE INDEX x_hes_ccare_ccapcrel ON cprd_data.hes_ccare (ccapcrel);


# IMD
## patient_imd2015
CREATE INDEX x_patient_imd2015_pracid ON cprd_data.patient_imd2015 (pracid);
CREATE INDEX x_patient_imd2015_imd2015_10 ON cprd_data.patient_imd2015 (imd2015_10);

## practice_imd
CREATE INDEX x_practice_imd_country ON cprd_data.practice_imd (country);
CREATE INDEX x_practice_imd_e2015_imd_10 ON cprd_data.practice_imd (e2015_imd_10);
CREATE INDEX x_practice_imd_ni2017_imd_10 ON cprd_data.practice_imd (ni2017_imd_10);
CREATE INDEX x_practice_imd_s2016_imd_10 ON cprd_data.practice_imd (s2016_imd_10);
CREATE INDEX x_practice_imd_w2014_imd_10 ON cprd_data.practice_imd (w2014_imd_10);


# ONS death
CREATE INDEX x_ons_death_pracid ON cprd_data.ons_death (pracid);
CREATE INDEX x_ons_death_gen_death_id ON cprd_data.ons_death (gen_death_id);
CREATE INDEX x_ons_death_n_patid_death ON cprd_data.ons_death (n_patid_death);
CREATE INDEX x_ons_death_match_rank ON cprd_data.ons_death (match_rank);
CREATE INDEX x_ons_death_dor ON cprd_data.ons_death (dor);
CREATE INDEX x_ons_death_dod ON cprd_data.ons_death (dod);
CREATE INDEX x_ons_death_dod_partial ON cprd_data.ons_death (dod_partial);
CREATE INDEX x_ons_death_nhs_indicator ON cprd_data.ons_death (nhs_indicator);
CREATE INDEX x_ons_death_pod_category ON cprd_data.ons_death (pod_category);
CREATE INDEX x_ons_death_cause ON cprd_data.ons_death (cause);
CREATE INDEX x_ons_death_cause1 ON cprd_data.ons_death (cause1);
CREATE INDEX x_ons_death_cause2 ON cprd_data.ons_death (cause2);
CREATE INDEX x_ons_death_cause3 ON cprd_data.ons_death (cause3);
CREATE INDEX x_ons_death_cause4 ON cprd_data.ons_death (cause4);
CREATE INDEX x_ons_death_cause5 ON cprd_data.ons_death (cause5);
CREATE INDEX x_ons_death_cause6 ON cprd_data.ons_death (cause6);
CREATE INDEX x_ons_death_cause7 ON cprd_data.ons_death (cause7);
CREATE INDEX x_ons_death_cause8 ON cprd_data.ons_death (cause8);
CREATE INDEX x_ons_death_cause9 ON cprd_data.ons_death (cause9);
CREATE INDEX x_ons_death_cause10 ON cprd_data.ons_death (cause10);
CREATE INDEX x_ons_death_cause11 ON cprd_data.ons_death (cause11);
CREATE INDEX x_ons_death_cause12 ON cprd_data.ons_death (cause12);
CREATE INDEX x_ons_death_cause13 ON cprd_data.ons_death (cause13);
CREATE INDEX x_ons_death_cause14 ON cprd_data.ons_death (cause14);
CREATE INDEX x_ons_death_cause15 ON cprd_data.ons_death (cause15);


# SGSS
CREATE INDEX x_sgss_patid ON cprd_data.sgss (patid);
CREATE INDEX x_sgss_pracid ON cprd_data.sgss (pracid);
CREATE INDEX x_sgss_n_patid_spec ON cprd_data.sgss (n_patid_spec);
CREATE INDEX x_sgss_pseudo_specimen_id ON cprd_data.sgss (pseudo_specimen_id);
CREATE INDEX x_sgss_organism_species_name ON cprd_data.sgss (organism_species_name);
CREATE INDEX x_sgss_lab_report_date ON cprd_data.sgss (lab_report_date);
CREATE INDEX x_sgss_age_in_years ON cprd_data.sgss (age_in_years);
CREATE INDEX x_sgss_reporting_lab_id ON cprd_data.sgss (reporting_lab_id);
CREATE INDEX x_sgss_specimen_date ON cprd_data.sgss (specimen_date);
CREATE INDEX x_sgss_care_home ON cprd_data.sgss (care_home);






