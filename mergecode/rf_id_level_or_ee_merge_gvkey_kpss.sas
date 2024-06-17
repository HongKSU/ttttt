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
proc freq data =_t1_or_ee_gvkey;
table dup_rf_id;
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
proc freq data =_t1_or_ee_gvkey_dup;
table total_dup  nonmis_ee;
run;
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
*  by rf_id
* only keep non employer assignment
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
* by patent number
* get patent value, citation, 
; 
proc sql;
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

* all nonmissing data are US granted;
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
           ,sum(us_grant)   as us_grant /*all shows US */
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
* NOTE:
* or_ee_gvkey_patentid.sas7 has UNIQUE rf_id                                   *;
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
create table or_ee_trans_permno_rf_id as 
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
              a.exec_year = fyear 
      ; 
  /*where not missing(a.exec_dt)*/
 quit;
run;
sasfile Crsp_comp_ccm close;

proc sort data = or_ee_trans_permno_rf_id NODUPKEY 
          out  = or_ee_trans_permno_rf_id_unique; 
by rf_id ee_name or_name exec_dt ee_gvkey or_gvkey ee_country or_fic or_country_name vreal;
run;
/*
 
%unique_values(or_ee_trans_permno_rf_id_unique,or_gvkey, ee_gvkey)
proc sql;
create table all_gvkey as
   select distinct or_gvkey as gvkey from or_ee_trans_permno_rf_id_unique where NOT missing(or_gvkey)
   union 
   select distinct ee_gvkey as gvkey  from or_ee_trans_permno_rf_id_unique  where not missing(ee_gvkey);
   quit;
 run;
*/
PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select   or_ee_trans_permno_rf_id_unique;
RUN;
PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select all_gvkey ;
RUN;

proc sql;
  
  drop table documentid_assign
             ,kpss2022
              ,documentid
              , assignment_conveyance
             ;
quit;
proc sql;
drop table _t0_or_ee_gvkey
          ,_t1_or_ee_gvkey
          ,_t1_or_ee_gvkey_dup
         ;
    quit;
run; 
  
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
        from or_ee_trans_permno_rf_id_unique as a
            inner join assignment as b
         on a.rf_id =b.rf_id;
      quit;
run;
gen taxdiff=or_country_tax - ee_country_tax
 replace 
 
;;
data  my_all_trans;
    set or_ee_gvkey_patentid_record_dt(drop = us_grant);
        rec_exec_days =intck('day', record_dt, exec_dt );
        if upcase(or_country_name) NE upcase(ee_country) & not missing (or_country_name) & not missing(ee_country)
            then foreign = 1 ;
        else if not missing(or_country_name) & not missing(ee_country) then  foreign = 0;
        else   foreign = .;
        taxdiff=or_country_tax - ee_country_tax;

        if abs(taxdiff ) < 0.0021 then taxdiff = 0;
      run;

       
**********************************************;
*Select foreign transfer and deciles divided
* June 16, 2016
 ;

data  foreign_trans; * There were 25513 observations;
     set my_all_trans (where =( NOT missing(permno) 
                              and  foreign=1));
      
run;
proc rank  data=foreign_trans
           out = foreign_trans_decile groups=10;
     var taxdiff;
ranks decile;
run;
%unique_values(foreign_trans_decile, permno, rf_id)

proc freq data = foreign_trans_decile order=freq;
table decile;
run;

ods latex path='C:\Users\lihon\Downloads\sas_code\sas_temp\' file='taxdiff_summary_report.tex' style=Journal2;
Title 'Show in RTF and LaTeX';
options nolabel;

proc means data = foreign_trans_decile;
var taxdiff;
class decile;
run;
ods latex close;
 
title;

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
proc sort data = foreign_trans_decile NODUPKEY 
          out  = or_ee_gvkey_patentid_record_dt2 ;
    * by rf_id or_name exec_dt permno;
          by rf_id or_name;
run;
proc sort data = or_ee_gvkey_patentid_record_dt2 
          out  = oree_gvkey_patentid_record_dtv2  NODUPKEYS;
          by permno record_dt;
run;
