%contents(mergback.ee_or_mached_final_v1)
proc contents data = mergback.ee_or_mached_final_v1;
run;
%unique_values(mergback.ee_or_mached_final_v1, or_gvkey, ee_gvkey)
mergback.ee_or_mached_final_v1
%unique_values(mergback.or_ee_trans_tax, or_gvkey, ee_gvkey)
mergback.ee_or_mached_final_v1


%unique_values(mergback.or_ee_trans_tax_v2, or_gvkey, ee_gvkey)


%unique_values(mergback.or_ee_trans_tax_state_country_v0, or_gvkey, ee_gvkey)
%unique_values(mergback.or_ee_trans_tax_state_country_v0, or_gvkey, ee_gvkey)

proc contents data = mergback.or_ee_trans_tax_state_country_v0;
run;

proc contents data = mergback.or_ee_trans_tax_state_country_v0;
run;
proc print data = mergback.or_ee_trans_tax_state_country_v0 (obs = 150);
var ee_country  or_country;
run;


%unique_values(mergback.or_ee_trans_permno_rf_id, or_gvkey, ee_gvkey)
%unique_values(mergback.or_ee_trans_permno_rf_id, or_gvkey,rf_id)
%unique_values(mergback.or_ee_trans_permno_rf_id, permno,rf_id)

%unique_values(or_ee_trans_permno_rf_id_unique, permno,rf_id)

%unique_values(mergback.or_ee_gvkey_patentid_record_dt, permno,or_gvkey)



proc contents data=my_all_trans;
run;

proc means data=mergback.or_ee_trans_permno_rf_id n sum mean;
variable 

C:\Users\lihon\Downloads\sas_code\combined_together
