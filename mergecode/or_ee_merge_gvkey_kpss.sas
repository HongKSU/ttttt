/****************
 * check:
The merged data has many duplicated 
rf_id, or_,ee_, or_gvkey, ee_gvkey

After drop the duplicated, one or_name has two or more assignee,
we drop the ee_name
1. If there is ee_gvkey, we keep the ee which does have a gv_key,
2. if none of them has a gvkey, keep one on the top after sort by 

input data: or_ee_trans_tax_state_country.dta
            or_ee_trans_tax_state_country.sas7bdat
*/
proc sort data = mergback.or_ee_trans_tax_state_country out=_t0_or_ee_gvkey nodupkey;
    by rf_id  descending ee_gvkey ee_name or_name  or_gvkey des;
run;

data _t1_or_ee_gvkey;
    set _t0_or_ee_gvkey;
    by rf_id;
   if first.rf_id then dup_rf_id=0;
     dup_rf_id +1;
run;
    
proc sql;
   create table _t1_or_ee_gvkey_dup as
        select *
               ,count(*) as total_dup
               ,count(ee_gvkey) as nonmis_ee /*non-missing ee_gvkey*/
from _t1_or_ee_gvkey
        group by rf_id;
quit;

data t2_or_ee_gvkey;
    set _t1_or_ee_gvkey_dup;
    if total_dup = 1 then output;
     else if (total_dup > 1 and nonmis_ee =0 and dup_rf_id =1) then output;
     else if (total_dup > 1 and nonmis_ee =1 and not missing(ee_gvkey)) then output;
      else if (total_dup > 1 and nonmis_ee >1 and not missing(ee_gvkey) and dup_rf_id =2) then output;
 run;

 proc sql;
 drop table _t0_or_ee_gvkey
            ,_t1_or_ee_gvkey
            ,_t1_or_ee_gvkey_dup
         ;
         quit;
run;
%contents(documentid)

/* merge with the documentid to grab the patent number
* Each rf_id can have multiple patentno
*/
%let usptoData=D:\Research\patent\data\uspto\2022;
%loadStata(infile="&usptoData\documentid.dta", outfile=documentid)
%loadStata(infile="D:\Research\patent\data\kpss.dta", outfile=kpss2022)
proc sql;
  create table or_ee_gvkey_patentid as
    select a.*
        ,b.appno_country as appno_country
        ,b.appno_date as appno_date
        ,b.grant_country as grant_country
        ,b.grant_date as grant_date
        ,b.grant_doc_num as patent_no
        from t2_or_ee_gvkey as a
                inner join 
            documentid as b
    on a.rf_id =b.rf_id;
    quit;
run;

proc sql;
  create table or_ee_gvkey_patentid_kpss as
    select a.*
          ,b.permno as orig_permno
          ,b.issue_y
          ,b.xi_nominal
          ,b.xi_real
          ,b.cites
        from or_ee_gvkey_patentid as a
                left join 
            kpss2022 as b
    on a.patent_no =b.patent_num;
    quit;
run;
 proc sql;
 drop table documentid
            ,kpss2022
            ,or_ee_gvkey_patentid
         ;
         quit;
run;


/* Merge with kpss 2022*/

PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  t2_or_ee_gvkey ;
RUN;




