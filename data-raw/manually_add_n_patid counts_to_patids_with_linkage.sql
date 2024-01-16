set role 'role_full_admin';

alter table cprd_data.patids_with_linkage add column n_chess_patid smallint, add column n_patid_hes smallint, add column n_patid_death smallint, add column n_patid_spec smallint;

update cprd_data.patids_with_linkage a left join cprd_data.chess b on a.patid=b.patid left join cprd_data.hes_patient c on a.patid=c.patid left join cprd_data.ons_death d on a.patid=d.patid left join cprd_data.sgss e on a.patid=e.patid set a.n_chess_patid=if(b.n_chess_patid is null,0,b.n_chess_patid), a.n_patid_hes=if(c.n_patid_hes is null,0,c.n_patid_hes), a.n_patid_death=if(d.n_patid_death is null,0,d.n_patid_death), a.n_patid_spec=if(e.n_patid_spec is null,0,e.n_patid_spec);
