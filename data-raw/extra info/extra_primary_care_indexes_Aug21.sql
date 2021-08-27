set role 'role_full_admin';

SET GLOBAL key_buffer_size = 200*1024*1024*1024;
SET sort_buffer_size = 200*1024*1024*1024;
SET myisam_sort_buffer_size = 200*1024*1024*1024;

#done
CREATE INDEX x_consultation_staffid ON cprd_data.consultation (staffid);
CREATE INDEX x_consultation_conssourceid ON cprd_data.consultation (conssourceid);

#running
CREATE INDEX x_drug_issue_staffid ON cprd_data.drug_issue (staffid);

#to do
CREATE INDEX x_drug_issue_quantunitid ON cprd_data.drug_issue (quantunitid);

#running
CREATE INDEX x_observation_consid ON cprd_data.observation (consid);

# to do
CREATE INDEX x_observation_staffid ON cprd_data.observation (staffid);
CREATE INDEX x_observation_obstypeid ON cprd_data.observation (obstypeid);

# Done
CREATE INDEX x_patient_usualgpstaffid ON cprd_data.patient (usualgpstaffid);
CREATE INDEX x_patient_gender ON cprd_data.patient (gender);
CREATE INDEX x_patient_emis_ddate ON cprd_data.patient (emis_ddate);
CREATE INDEX x_patient_acceptable ON cprd_data.patient (acceptable);
CREATE INDEX x_practice_lcd ON cprd_data.practice (lcd);
CREATE INDEX x_practice_region ON cprd_data.practice (region);
CREATE INDEX x_problem_lastrevstaffid ON cprd_data.problem (lastrevstaffid);
CREATE INDEX x_problem_parentprobrelid ON cprd_data.problem (parentprobrelid);
CREATE INDEX x_problem_signid ON cprd_data.problem (signid);
CREATE INDEX x_referral_refsourceorgid ON cprd_data.referral (refsourceorgid);
CREATE INDEX x_referral_reftargetorgid ON cprd_data.referral (reftargetorgid);
CREATE INDEX x_referral_refurgencyid ON cprd_data.referral (refurgencyid);
CREATE INDEX x_referral_refmodeid ON cprd_data.referral (refmodeid);
CREATE INDEX x_staff_jobcatid ON cprd_data.staff (jobcatid);
