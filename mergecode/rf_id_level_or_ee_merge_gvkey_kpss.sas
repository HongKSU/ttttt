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
  /*
   27  * Load the data to work directory, keep variables needed for event study merge;
   28: * Load assignment.dta *
   29  * April 1, 2024
   30  */
PROC IMPORT OUT= WORK.assignment 
             DATAFILE= "D:\Research\patent\data\uspto\2022\assignment.dta" 
             DBMS=STATA REPLACE;
run;
  
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
select  a.*
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

proc sort data = mergback.or_ee_trans_permno_rf_id NODUPKEY 
          out  = or_ee_trans_permno_rf_id_unique; 
      by rf_id 
         ee_name or_name 
         exec_dt ee_gvkey 
         or_gvkey ee_country 
         or_fic or_country_name 
         vreal;
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
             ,assignment_conveyance
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
*Table WORK.OR_EE_GVKEY_PATENTID_RECORD_DT created, with 78,855 rows and 33 columns.;

****************************************************************************************;
* June 19, 2024:                                                                       *;
* Table WORK.OR_EE_GVKEY_PATENTID_RECORD_DT created, with 124,849 rows and 42 columns. *;
*      
********************************************************************************;
proc sql;
 create table or_ee_gvkey_patentid_record_dt as 
 select  a.*
        ,record_dt
        from or_ee_trans_permno_rf_id_unique as a
               inner join
             assignment                      as b
         on a.rf_id =b.rf_id;
      quit;
run;


* June 19, 2024;
* The data set WORK.MY_ALL_TRANS has 124,849 observations and 44 variable;
 
data  my_all_trans;
    set or_ee_gvkey_patentid_record_dt(drop = us_grant);
        rec_exec_days =intck('day', record_dt, exec_dt );
        if upcase(or_country_name) NE upcase(ee_country) & not missing (or_country_name) & not missing(ee_country)
            then foreign = 1 ;
        else if not missing(or_country_name) & not missing(ee_country) then  foreign = 0;
        else   foreign = .;
        taxdiff=or_country_tax - ee_country_tax;
        label taxdiff="Assignor Tax-Assignee tax";
        if abs(taxdiff ) < 0.0021 then taxdiff = 0;
run;

       
**********************************************;
* Select foreign transfer and deciles divided
* June 16, 2016
* There were 25513 observations read from the data set WORK.MY_ALL_TRANS
* ;

data  foreign_trans; * There were 25,513 observations;
     set my_all_trans (where =( NOT missing(permno) 
                              and  foreign=1));
      
run;

Title "Unique combinatons in foreign transactions on recorded date from same OR";
proc sql; *18,130;
select count(*) from (
select distinct permno, record_dt, count(*) as ccc 
from  foreign_trans   
group by permno, record_dt);
quit;
run;

Title "Unique combinatons in foreign transactions on recoreded date between OR and EE";
proc sql; *18,986;
select count(*) from (
select distinct permno, record_dt, ee_comp_stdname,count(*) as ccc 
from  foreign_trans   
group by permno, record_dt, ee_comp_stdname);
quit;
run;

***************************************************************************;
*There are many rf_id between same assignor and assignee
* on the same recorded date;
* We aggreagate them together now;

/*
 * with 21227 rows and 23 variables; 
select  distinct permno
proc sql;
create view v_foreign_perm_record_all as  
                 ,ee_name
                 ,or_name
                 ,or_gvkey
                 ,or_country_code
                 ,or_country_name
                 ,or_fic
                 ,ee_gvkey
                 ,or_naics   
                 ,ee_country
                 ,ee_country_tax     
                 ,or_country_tax
                 ,taxdiff 
                 ,decile
                 ,exec_year
                 ,FYEAR
                 ,exec_dt 
                 ,rec_exec_days 
                 ,agg_total_cites
                 ,agg_pack_size
                 ,agg_vreal
                 ,agg_vnominal
      from aggforeign_trans_decile
      order by permno, record_dt;

    *  create view foreign_perm_record_all as   with 21227 rows and 23 variables; 
select  distinct permno
                 ,ee_name
                 ,or_name
                 ,or_gvkey
                 ,or_country_code
                 ,or_country_name
                 ,or_fic
                 ,ee_gvkey
                 ,or_naics   
                 ,ee_country
                 ,ee_country_tax     
                 ,or_country_tax
                 ,taxdiff 
                 ,decile
                 ,exec_year
                 ,FYEAR
                 ,record_dt
                 ,exec_dt 
                 ,rec_exec_days 
                 ,agg_total_cites
                 ,agg_pack_size
                 ,agg_vreal
                 ,agg_vnominal
      from aggforeign_trans_decile
      order by permno, record_dt;
      quit;
run;
*/
proc sql  NOREMERGE;
create table aggforeign_trans as
select  distinct permno
        ,or_gvkey
        ,record_dt
        ,sum(pac_size) as agg_pack_size
        ,sum(total_cites) as agg_total_cites
        ,sum(vreal) as agg_vreal
        ,sum(vnominal) as agg_vnominal
        ,min(taxdiff) as  taxdiff
        ,min(rec_exec_days) as rec_exec_days
        from foreign_trans
  group by permno, or_gvkey,record_dt;
  quit;
run;
proc rank  data=aggforeign_trans
           out = foreign_trans_decile groups=10;
     var taxdiff;
ranks decile;
run;

proc sort data = foreign_trans_decile NODUPKEY;
  by permno  record_dt;
run;
proc sql;
  create table input_agg_foreign_all
  as select distinct permno, record_dt as edate format MMDDYY10.
  from foreign_trans_decile where not missing(-2) and year(record_dt);
quit;


proc sql NOREMERGE;
    select count(*) from(
                    select distinct permno, record_dt from aggforeign_trans group by permno, record_dt)
;
quit;

PROC DATASETS NOLIST;
    COPY IN = work OUT = mergback ;
    select foreign_trans 
           foreign_trans_decile
foreign_trans_exec_record10
foreign_trans_execrec10_decile
foreign_trans_execrec10_dec10
;
run;

proc means data = foreign_trans_decile mean std;
    class decile;
    var roa roe;
run;

* Version 1: all foreign transactions;
%event_study(outputPath=C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_all
            ,permno_list = foreign_trans_decile)

%contents(foreign_trans_decile)

* WORK.FOREIGN_TRANS_EXECREC10_DECILE has 792 obse
;
data  foreign_trans_exec_record10; * There were 25513 observations;
     set aggforeign_trans (where =( NOT missing(permno) 
                                  and 0 le rec_exec_days<5));
      
run;


proc rank  data=foreign_trans_exec_record10
           out = foreign_trans_execrec10_decile groups=10;
     var taxdiff;
ranks decile;
run;
proc sort data = foreign_trans_execrec10_decile NODUPKEY;
by permno  record_dt;
run;

* Version 2: all foreign transactions record-exec_dt <=10 days;
%event_study(outputPath=C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_rec_exe10
            ,permno_list = foreign_trans_execrec10_decile)


* Version 3: all foreign transactions record-exec_dt <=10 days;
*;
* WORK.FOREIGN_TRANS_EXECREC10_DEC10 has 74 observations and 10 variables;
*;
data  foreign_trans_execrec10_dec10;
set foreign_trans_execrec10_decile (where = (decile=9));
run;

proc means data = foreign_trans_execrec10_decile;
class decile;
var taxdiff;
run;

%event_study(outputPath=C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_rec_exe10_dec10
          ,permno_list = foreign_trans_execrec10_dec10)

proc sort data = foreign_trans_decile NODUPKEY;
by permno  record_dt;
run;

proc sort data = foreign_trans_decile NODUPKEY;
by permno  record_dt;
run;
PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  foreign_trans_decile;
RUN;


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

** First version of event study;
** All foreign countries;
** Record date:
    oree_gvkey_patentid_record_dtv2
**;
proc sort data = or_ee_gvkey_patentid_record_dt2 
          out  = oree_gvkey_patentid_record_dtv2  NODUPKEYS;
          by permno record_dt;
run;
PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  oree_gvkey_patentid_record_dtv2 ;
RUN;
