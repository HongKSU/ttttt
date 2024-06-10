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
proc sort data = or_ee_trans_tax_state_country 
      out=_t0_or_ee_gvkey nodupkey;
    by rf_id  descending ee_gvkey ee_name or_name descending or_gvkey  ;
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
    drop dup_rf_id total_dup nonmis_ee;
run;

proc sql;
drop table _t0_or_ee_gvkey
          ,_t1_or_ee_gvkey
          ,_t1_or_ee_gvkey_dup
         ;
    quit;
run;

/*
%contents(documentid)
*/
/* merge with the documentid to grab the patent number
* Each rf_id can have multiple patentno
*/
%let usptoData=D:\Research\patent\data\uspto\2022;
%importStata(infile="&usptoData\documentid.dta", outfile=documentid)
%importStata(infile="D:\Research\patent\data\kpss.dta", outfile=kpss2022)
%importStata(infile="D:\Research\patent\data\assignment_conveyance.dta", outfile=assignment_conveyance)

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

Note: missing exec_dt: Invalid (or missing) arguments to 
the YEAR function have caused the function to return a missing value.
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
               year(a.exec_dt) = fyear  
  /*where not missing(a.exec_dt)*/
 ;
 quit;
 run;
sasfile Crsp_comp_ccm close;

%unique_values(or_ee_trans_permno1,or_gvkey, ee_gvkey)
proc sql;
create table all_gvkey as
   select distinct or_gvkey as gvkey from or_ee_trans_permno1 where NOT missing(or_gvkey)
   union 
   select distinct ee_gvkey as gvkey  from or_ee_trans_permno1  where not missing(ee_gvkey);
   quit;
 run;

PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select all_gvkey ;
RUN;


 
  
********************************************************************************;
* Merge with assignment to get the record_dt;
*output dataset:                               ;
*            or_ee_gvkey_patentid_record_dt     ;
*Table WORK.OR_EE_GVKEY_PATENTID_RECORD_DT created, with 78855 rows and 33 columns.;

********************************************************************************;
proc sql;
 create table or_ee_gvkey_patentid_record_dt as 
 select  a.*
        ,record_dt
        from or_ee_trans_permno1 as a
            inner join assignment as b
         on a.rf_id =b.rf_id
           where NOT missing(permno) and 
                relation=1              
            ;
         quit;
run;
/* fill the empty ee_country to USA;

data or_ee_gvkey_patentid_record_dt;
set or_ee_gvkey_patentid_record_dt;
diff_rec_exe = intck('day' ,exec_dt, record_dt );
if not missing(ee_state) then ee_country = "USA";

run;

*/
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
proc sort data = or_ee_gvkey_patentid_record_dt NODUPKEY 
          out  = or_ee_gvkey_patentid_record_dt2 ;
    * by rf_id or_name exec_dt permno;
          by rf_id or_name;
run;
proc sort data = or_ee_gvkey_patentid_record_dt2 
          out  = oree_gvkey_patentid_record_dtv2  NODUPKEYS;
          by permno record_dt;
run;











/* Merge with compustat
*/
proc sql;
    create table  oree_gvkey_record_dtv2_comp as
        select * from 
        /*oree_gvkey_patentid_record_dtv2 as a*/
        or_ee_gvkey_patentid_record_dt2 as a
              inner join 
           mergback.oree_compustat_gvkey as b
           on a.or_gvkey = b.gvkey
       and    year(a.record_dt) - b.FYEAR=1;
quit;
run;

%contents(oree_gvkey_record_dtv2_comp)
/*
proc sql;
    create table  oree_gvkey_record_comp2 as
        select * from 
          oree_gvkey_patentid_record_dtv2 as a
              inner join 
        mergback.compustat_evt_gvkey as b
              on a.or_gvkey = b.gvkey
  and    year(a.record_dt) - b.FYEAR=1;
quit;
run;
*/
/* Extract permno and gvkey in 

 %importStata(infile="C:\Users\lihon\Downloads\wrd_evt_res\dnltqx87bslc9xnb_edate.dta",
              outfile=wrds_ff)

PROC SQL;
create table wrd_car_evtdate_comp as
select * from wrds_ff as a
 inner join oree_gvkey_record_dtv2_comp as b
 on a.permno = b.permno and a.evtdate = b.record_dt;
 quit;
 run;

oree_gvkey_patentid_record_dtv2
/*
proc sort data = for_event_study1 
          out  = for_event_study_v2  NODUPKEYS;
          by permno record_dt;
run;
*/

/* Merge  evt-CARs with COMPUSTAT
oree_gvkey_record_dtv2_comp
car1_day2: day2 cars
*/

proc sql;
create table aad_tmp as 
select rf_id
        ,or_name
        ,ee_name
        ,PERMno
        ,record_dt
        ,exec_dt
from  oree_gvkey_record_dtv2_comp
order by rf_id, record_dt;

quit;
run;

proc sort data=aad_tmp;
 by permno record_dt;
 run;


/*oree_gvkey_record_dtv2_comp:
 the combination of permno and date is not unique;
 */
PROC SQL;
  create table car1_day2_comp as 
   select * from  car_evtdate as a
      inner join  as b
   on a.permno = b.permno and a.evtdate = b.record_dt;
 quit;
 run;

%contents(car1_day2_comp)
PROC SQL;
create table car_evtdate_comp as
select * from car_evtdate as a
 inner join oree_gvkey_record_dtv2_comp as b
 on a.permno = b.permno and a.evtdate = b.record_dt;
 quit;
 run;

/*second merge of CARs and comp
 */
 PROC SQL;
create table car1_day2_comp_2 as
select * from car1_day2 as a
 inner join oree_gvkey_record_comp2 as b
 on a.permno = b.permno and a.evtdate = b.record_dt;
 quit;
 run;

/* merge the CARs with compustat data;
* C:\Users\lihon\Downloads\merge_back\compustat1979_2023.sas7bdat;
*/
proc sql;
  create table wrds_or_ee_event_res_car0_comp as
    select * from 
    /* car_evtwin a*/
    /*wrds_evt_Neg20_p10 a*/
    wrds_or_ee_event_res_car0 as a
    left join
     /* mergback.compustat1979_2023 as b*/
         mergback.compustat_evt_gvkey as b
   on a.or_gvkey = b.GVKEY 
   and year(a.record_dt) - b.FYEAR=1;
quit;



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
     or_ee_gvkey_patentid_record_dt as b
   on a.PERMNO = b.permno 
   and b.record_dt=a.evtdate;
quit;



74,153 obs)???
PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  wrds_or_ee_event_res_car0_comp ;
RUN;

PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  wrd_car_evtdate_comp ;
RUN;


PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  car1_day2_comp  car_evtdate_comp;
RUN;
PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select car1_day2_comp;
RUN;
***********************************************;



PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  or_ee_gvkey_patentid_record_dt2  oree_gvkey_patentid_record_dtv2 ;
RUN;

%unique_values(oree_gvkey_patentid_record_dtv2, or_gvkey, permno)
%unique_values(or_ee_trans_permno1, or_gvkey, permno)
