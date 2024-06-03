/********************************************************************************;
* check:
The merged data has many duplicated 
                 rf_id, or_,ee_, or_gvkey, ee_gvkey

After drop the duplicated, one or_name has two or more assignee,
we drop the ee_name
1. If there is ee_gvkey, we keep the ee which does have a gv_key,
2. if none of them has a gvkey, keep one on the top after sort by 

input data: or_ee_trans_tax_state_country.dta
            or_ee_trans_tax_state_country.sas7bdat
*******************************************************************************/
proc sort data = mergback.or_ee_trans_tax_state_country 
      out=_t0_or_ee_gvkey nodupkey;
    by rf_id  descending ee_gvkey ee_name or_name  or_gvkey des;
run;

/***********************
* count number of patents in the rf_id  *;
* and number the patents in the same rf_id;
*/
data _t1_or_ee_gvkey;
    set _t0_or_ee_gvkey;
      by rf_id;
    if first.rf_id then dup_rf_id=0;
      dup_rf_id +1;
run;
    
proc sql;
    create table _t1_or_ee_gvkey_dup as
        select *
               ,count(*)        as total_dup
               ,count(ee_gvkey) as nonmis_ee /*non-missing ee_gvkey*/
        from _t1_or_ee_gvkey
        group by rf_id
    ;
quit;
********************************************************************************;
* remove the duplicated ee_ from the same rf_id *;

********************************************************************************;
data t2_or_ee_gvkey;
    set _t1_or_ee_gvkey_dup;
      if total_dup = 1 then output;
    else if (total_dup > 1 and nonmis_ee =0 and dup_rf_id =1) then output;
    else if (total_dup > 1 and nonmis_ee =1 and not missing(ee_gvkey)) then output;
    else if (total_dup > 1 and nonmis_ee >1 and not missing(ee_gvkey) and dup_rf_id =2) then output;
    drop dup_rf_id total_dup nonmiss_ee;
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
%loadStata(infile="D:\Research\patent\data\assignment_conveyance.dta", outfile=assignment_conveyance)

/********************************************************************************;
*
* Merge document id with assignment type
  by rf_id
only keep non employer assignment
*
*
********************************************************************************/

proc sql;
  create table documentid_assign  as
    select a.rf_id
          ,appno_date
          ,appno_country
          ,grant_country
          ,grant_date
          ,grant_doc_num as patent_num
    from documentid as a
                inner join 
         assignment_conveyance as b
    on   a.rf_id = b.rf_id 
       and convey_ty = "assignment" 
       and employer_assign=0;
   quit;
run;

* merge doc_nonemployer assignment with KPSS 
by patent number
; 
proc sql;
  drop table documentid, assignment_conveyance;
  create table documentid_kpss as
    select a.rf_id
          ,appno_date
          ,appno_country
          ,grant_country
          ,grant_date
          ,a.patent_num
          ,b.permno as orig_permno
          ,b.issue_y
          ,b.xi_nominal
          ,b.xi_real
          ,b.cites
    from documentid_assign as a
            inner join 
         kpss2022         as b
    on a.patent_num =b.patent_num;
  quit;
run;
proc sql;
  drop table documentid_assign
             ,kpss2022
             ;
quit;


/*
1. Get the total of the assignment package by rf_id in the t2_or_ee_gvkey dataset; 
   us_granted
   package size
   total citation
   real_value of the package
   nominal value of the package

  merge with the patent transaction data;
                t2_or_ee_gvkey +  documentid_kpss
output dataset: 
         rf_id_total
*/
proc sql;
    create table _docid_kpss as
      select
           a.rf_id
           ,b.*
           ,case
              when grant_country = "US" then 1
              else 0 
           end as US_grant
      from t2_or_ee_gvkey as a
                   left join
            documentid_kpss as b
      on a.rf_id =b.rf_id;

    create table rf_id_total as
      select rf_id
           ,count(*)        as pac_size
           ,sum(us_grant)   as us_grant
           ,sum(cites)      as total_cites
           ,sum(xi_real)    as vreal
           ,sum(xi_nominal) as vnominal
           from _docid_kpss
       group by rf_id;
   quit;
run;
*********************************************************************************;
* merge:                                                                        *;
*          t2_or_ee_gvkey + rf_id_total                                         *;
* Output dataset:                                                               *;
*          or_ee_gvkey_patentid                                                 *;
*********************************************************************************;
proc sql;
   create table or_ee_gvkey_patentid as 
     select a.*
            ,b.*
    from t2_or_ee_gvkey as a
          left join
         rf_id_total    as b
    on a.rf_id =b.rf_id;
  quit;
run;

/*
%varlist(or_ee_trans_sort) 

merge or_ee_gvkey_patentid to get or_permno
*/
sasfile Crsp_comp_ccm load;
proc sql; * with 327470 rows and 11 columns.;
create table or_ee_trans_permno1 as 
select a.*
       ,or_gvkey
       ,lpermno as permno
       ,lpermco as permco
       ,fyear
       ,year(a.exec_dt)as exec_year
       ,datadate
       ,costat
        from or_ee_gvkey_patentid as a
           left join
           Crsp_comp_ccm as b
           on a.or_gvkey=b.gvkey
                AND 
              fyear-2 LE year(a.exec_dt) LE fyear+1 ;
 quit;
 run;
sasfile Crsp_comp_ccm close;

********************************************************************************;
* Merge with assignment to get the record_dt;
*output dataset:                               ;
*            or_ee_gvkey_patentid_record_dt     ;
*;
********************************************************************************;
proc sql;
 create table or_ee_gvkey_patentid_record_dt as 
 select  a.*
        ,record_dt
        from or_ee_trans_permno1 as a
            inner join assignment as b
         on a.rf_id =b.rf_id
          where NOT missing(permno) and relation=1
            ;
         quit;
run;
/*

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
*/
 
/*
Merge with the compustat data

*/

proc sql;
 drop table documentid
            ,kpss2022
            ,or_ee_gvkey_patentid
         ;
         quit;
run;

********************************************************************************;
* importStaat *;
* Load stata file to SAS WORK lib *;
*
* ;
********************************************************************************;
/*
proc sql;
  create table or_ee_event_res as
    select * from 
    /* car_evtwin a*/
   /*    car_evtdate a
    left join
       or_ee_gvkey_patentid_record_dt b
   on a.permno = b.permno 
   and b.record_dt=a.evtdate;
quit;
*/
proc transpose data= car_evtwin 
      prefix = car out= car0_evtwin_wide(drop = _NAME_);
    by  permno evtdate;
    id evttime;
    var car0;
format evtdate MMDDYY10.;
run;
proc sql;
  create table wrds_or_ee_event_res_car0 as
    select * from 
    /* car_evtwin a*/
    /*wrds_evt_Neg20_p10 a*/
    car0_evtwin_wide as a
    left join
     or_ee_gvkey_patentid_record_dt b
   on a.PERMNO = b.permno 
   and b.record_dt=a.evtdate;
quit;

/* merge compustat data;
* C:\Users\lihon\Downloads\merge_back\compustat1979_2023.sas7bdat;
*/
proc sql;
  create table wrds_or_ee_event_res_car0_comp as
    select * from 
    /* car_evtwin a*/
    /*wrds_evt_Neg20_p10 a*/
    wrds_or_ee_event_res_car0 as a
    left join
     mergback.compustat1979_2023 b
   on a.or_gvkey = b.GVKEY 
   and year(a.record_dt) - b.FYEAR=1;
quit;

74,153 obs)???
PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  wrds_or_ee_event_res_car0_comp ;
RUN;

PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  car0_evtwin_wide ;
RUN;

