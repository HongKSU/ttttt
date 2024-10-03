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
libname mytrans "C:\Users\lihon\OneDrive - Kent State University\aaaa\merged_ana";
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
Purpose: get or_permno
----------------------------------------------------------------
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
    set mergback.or_ee_gvkey_patentid_record_dt(drop = us_grant);
        rec_exec_days =intck('day', record_dt, exec_dt ); * exec_dt - record_dt;
        if relation =1 
           & (upcase(or_country_name) NE upcase(ee_country)) 
           & not missing(or_country_name) 
           & not missing(ee_country)
           then foreign = 1 ;
        else if not missing(or_country_name) 
                & not missing(ee_country) 
            then  foreign = 0;
        else  foreign = .;
        if NOT missing(or_country_tax) 
           & NOT missing(ee_country_tax) 
           then taxdiff = or_country_tax - ee_country_tax;
           else taxdiff = .;
        label     taxdiff = "Assignor Tax-Assignee tax"
            rec_exec_days = "Exec_dt - Record_dt"
            ;
        if abs(taxdiff ) < 0.005 then taxdiff = 0;
run;

*-------------------------------------------------------------------------
Table WORK.AGGMY_ALL_TRANS created, with 90,750 rows and 9 columns.
permno: $5,148$ 
;
proc sql  NOREMERGE;
create table aggmy_all_trans as
select  distinct permno
        ,or_gvkey
        ,record_dt
        ,foreign
        ,relation
        ,sum(pac_size) as agg_pack_size
        ,sum(total_cites) as agg_total_cites
        ,sum(vreal) as agg_vreal
        ,sum(vnominal) as agg_vnominal
        ,max(taxdiff) as  taxdiff /*It was min(taxdiff) before*/
        ,min(rec_exec_days) as rec_exec_days
        from my_all_trans
  group by permno
           ,or_gvkey
           ,record_dt
           ,foreign
           ,relation
           ;
quit;


*
Table WORK.OREE_GVKEY_RECORD_DTV2_COMP created, with 94,036 rows and 62 columns.
why have more
;
proc sql;
    create table  oree_gvkey_record_dtv2_comp as
        select * from 
        aggmy_all_trans as a
          
         /*or_ee_gvkey_patentid_record_dt2 as a*/
              inner join 
           my_compustat as b
           on a.or_gvkey = b.gvkey
           and    year(a.record_dt) = b.YEAR;
        /*and    year(a.record_dt) - b.FYEAR=1;*/
quit;
run;

%contents(oree_gvkey_record_dtv2_comp)

libname onedrive "C:\Users\lihon\OneDrive - Kent State University\aaaa\merged_ana";
PROC DATASETS NOLIST;
    COPY IN = work OUT = onedrive ;
    select  /*my_all_trans
            aggmy_all_trans*/
           oree_gvkey_record_dtv2_comp
     ;
run;


proc sort data = relation_trans (keep= permno record_dt
                        rf_id ee_comp_stdname ee_gvkey
                        or_name or_comp_stdname or_gvkey  
                        exec_dt or_country_ISONAME or_country_name ee_country) 
                         
           out = _sort_relation_trans;
  by permno record_dt;
run;


%unique_values(oree_gvkey_record_dtv2_comp, rf_id, permno)

%unique_values(aggmy_all_trans, rf_id, permno)
* in my_all_tans, total unique: permno  51,48;
%unique_values(my_all_trans, rf_id, permno) 

proc sql;
select count(*) from (
  select distinct rf_id, or_gvkey,   count(*)
         from oree_gvkey_record_dtv2_comp
         group by rf_id, or_gvkey );
         quit;
run;
/***/

* Version 0

Relational trans;
*************************************************************;
data  relation_trans; * There were 25,513 observations;
     set mytrans.my_all_trans (where =( NOT missing(permno) 
                              and  relation=1));
run;


%uniqueValue(relation_trans,rf_id) *25,964;

*****************************************************
* 2072 permno 
* 6189  record_dt
*****************************************;
%unique_values(relation_trans, permno, record_dt)

Title "Unique combinatons in foreign transactions on recorded date from same OR";
proc sql; *17,501;
select count(*) from (
select distinct permno, record_dt, count(*) as ccc 
from  relation_trans   
group by permno, record_dt);
quit;
run;

proc sort data = relation_trans (keep= permno record_dt
                        rf_id ee_comp_stdname ee_gvkey
                        or_name or_comp_stdname or_gvkey  
                        exec_dt 
                         or_country_ISONAME or_country_name ee_country) 
                         
           out = _sort_relation_trans;
  by permno record_dt;
run;


***************************************************************************;
* 0. All relational trans;

proc sql  NOREMERGE;
create table aggrelation_trans as
select  distinct permno
        ,or_gvkey
        ,record_dt
        ,sum(pac_size) as agg_pack_size
        ,sum(total_cites) as agg_total_cites
        ,sum(vreal) as agg_vreal
        ,sum(vnominal) as agg_vnominal
        ,min(taxdiff) as  taxdiff
        ,min(rec_exec_days) as rec_exec_days
        ,foreign
        from relation_trans
  group by permno
           ,or_gvkey
           ,record_dt
           ,foreign;
  quit;
run;
%unique_comb_values(aggrelation_trans, permno, record_dt ) *17501;


libname allrel "C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\allRelationTrans";

proc rank  data=aggrelation_trans
           out = aggrelation_trans_decile groups=10;
     var taxdiff;
ranks decile;
run;

libname aggrel "C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\allRelationTrans";
PROC DATASETS NOLIST;
    COPY IN = work OUT = aggrel ;
    select  /*my_all_trans
            aggmy_all_trans*/
           aggrelation_trans_decile    ;
run;

%event_study(outputPath=C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\allRelationTrans
          ,permno_list = aggrelation_trans_decile)
%event_turnover(outputPath=outputPath, permno_list=aggrelation_trans_decile, output_prefix=allrel)

%car_comp(event_source=aggrelation_trans_decile
                       ,car_evtwin=car_evtwin
                       ,outlib=allrel
                       ,outdata_pref=all_relat)      

%uniqueValue(allrel.all_relat_evt_car_day2_comp2, permno)

proc contents data = all_relat_evt_car_day2_comp2;
run;
 
**********************************************;
* 1. Foreign trans
                       Select foreign transfer and deciles divided
* June 16, 2016
* There were 25513 observations read from the data set WORK.MY_ALL_TRANS
* ;



data  foreign_trans; * There were 25,513 observations;
     set mytrans.my_all_trans (where =( NOT missing(permno) 
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

libname aggf_all "C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_all";
PROC DATASETS NOLIST;
    COPY IN = work OUT = aggf_all ;
    select foreign_trans 
           foreign_trans_decile
 
;
run;
proc means data = foreign_trans_decile mean std;
    class decile;
    var roa roe;
run;

* Version 1: all foreign transactions;
proc rank  data=foreign_trans_exec_record10
           out = foreign_trans_execrec10_decile groups=10;
     var taxdiff;
ranks decile;
run;
libname allfor "C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_all";

%event_study(outputPath=C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_all
            ,permno_list = allfor.foreign_trans_decile)

%event_turnover(outputPath=C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_all
            ,permno_list=allfor.foreign_trans_decile, output_prefix=foreign_rel)
%let output_prefix=foreign_rel;
%let outputPath=%str(C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_all);
%contents(foreign_trans_decile)
%car_comp(event_source=foreign_trans_decile
                       ,car_evtwin=allfor.car_evtwin
                       ,outlib=allfor
                       ,outdata_pref=all_f) 



proc rank  data=foreign_trans_exec_record10
           out = foreign_trans_execrec10_decile groups=10;
     var taxdiff;
ranks decile;
run;

%car_comp(event_source=relation_trans
                       ,car_evtwin=car_evtwin
                       ,outlib=allrel
                       ,outdata_pref=all_relat) 

* WORK.FOREIGN_TRANS_EXECREC10_DECILE has 792 obse

June 28 463
;
data  foreign_trans_exec_record10; * There were 25513 observations;
     set aggforeign_trans (where =( NOT missing(permno) 
                                  and 0 le rec_exec_days<10));
      
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

%event_turnover(outputPath=%str(C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_rec_exe10)
            ,permno_list= foreign_trans_execrec10_decile, output_prefix=forrec_exe10)


* Version 3: all foreign transactions record-exec_dt <=10 days;
*;
* WORK.FOREIGN_TRANS_EXECREC10_DEC10 has 74 observations and 10 variables;
*;
data  foreign_trans_execrec10_dec10;
set foreign_trans_execrec10_decile (where = (decile=9));
run;
%event_study(outputPath=C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_rec_exe10
          ,permno_list = foreign_trans_execrec10_dec10)

%event_turnover(outputPath=%str(C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_rec_dec10)
            ,permno_list=foreign_trans_execrec10_dec10, output_prefix=for_execrec10)


* Version 4: all foreign transactions record-exec_dt <=10 days;
*;
* WORK.FOREIGN_TRANS_EXECREC10_DEC10 has 74 observations and 10 variables;
*;
data  foreign_trans_dec10;
set allfor.foreign_trans_decile (where = (decile=9));
run;
agg_foreign_rec_dec10;


proc means data = foreign_trans_execrec10_decile;
class decile;
var taxdiff;
run;

%event_study(outputPath=C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_rec_dec10
          ,permno_list = foreign_trans_dec10)
%event_turnover(outputPath=%str(C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_rec_dec10)
            ,permno_list=foreign_trans_dec10
, output_prefix=for_execrec10)
foreign_trans_dec10

libname frec_d10 "C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_rec_dec10";
agg_foreign_rec_exe10_dec10
 
%car_comp(event_source=foreign_trans_dec10
                       ,car_evtwin=frec_d10.car_evtwin
                       ,outlib=frec_d10
                       ,outdata_pref=f_re_d10) 
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


PROC DATASETS NOLIST;
COPY IN = work OUT = allrel ;
select  relation_trans  _sort_relation_trans;
RUN;
* Version 4

Relational trans NON foreign;
*************************************************************;
data  domestic_relation_trans; * There were 25,513 observations;
     set my_all_trans (where =( NOT missing(permno) 
                              and  relation=1 and foreign NE 1));
run;
proc sort data = domestic_relation_trans 
          out  = domestic_relation_trans_uniq  NODUPKEYS;
          by permno record_dt;
run;
%event_study(outputPath=C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\relation_Non_foreign
          ,permno_list = domestic_relation_trans_uniq)


*******Domestic trans without Blackberry;

data    domes_trans_noBlackBerry;  *9455;
 set domestic_relation_trans_uniq (where = (permno ne 86745) );
 run;
proc sort data = domes_trans_noBlackBerry  out=domes_trans_noBlackBerry_uniq
            NODUPKEYS;
          by permno record_dt;
 %event_study(outputPath=C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\rel_Non_f_noBlack
          ,permno_list = domes_trans_noBlackBerry_uniq)

 proc sql NOREMERGE;
  Title "without Black";
          select * from domes_trans_noBlackBerry
where  permno = 86745;

quit;

Title "witht Black";
select or_comp_name, permno, count(*) from domestic_relation_trans
where  permno = 86745
group by permno;

libname noBlac "C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\rel_Non_f_noBlack";
%car_comp(event_source=domes_trans_noBlackBerry_uniq
                       ,car_evtwin=car_evtwin
                       ,outlib=noBlac
                       ,outdata_pref=No_black) 

