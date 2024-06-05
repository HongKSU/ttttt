



/*
Proc options option=cpucount;
Run;
*/
options cpuCount = actual;
options msglevel=i fullstimer;
options threads;

/************************************************************************
* Load the COMP_CRSP merged dataset---downloaded from WRDS CRSP
* Date: Mar 21,2024
* Location: C:\Users\lihon\Downloads\merge_back\crsp_comp_ccm.sas7bdat
* "Crsp_comp_ccm","12.8MB","Table","","20Mar2024:20:56:29"
* Variables: GVKEY DATADATE FYEAR 
             LPERMCO LPERMNO CONSOL INDFMT DATAFMT POPSRC CURCD COSTAT
*/

data Crsp_comp_ccm;
set "C:\Users\lihon\Downloads\merge_back\crsp_comp_ccm_v1.sas7bdat";
run;

/*
* Load the data to work directory, keep variables needed for event study merge;
* Load assignment.dta *
* April 1, 2024
*/
PROC IMPORT OUT= WORK.assignment 
            DATAFILE= "D:\Research\patent\data\uspto\2022\assignment.dta" 
            DBMS=STATA REPLACE;

RUN;

/************************************************************************
* Load the Or_ee_trans_tax
*/


/*
Title "ee_or matched with GVKEY";
proc print data = "C:\Users\lihon\Downloads\merge_back\ee_or_mached_final.sas7bdat" (obs=10);
run;

Title "ee_or Gvkey matched with tax";
proc print data = "C:\Users\lihon\Downloads\merge_back\or_ee_trans_tax.sas7bdat" (obs=10);
run;
*/
/* need to figure out  why the following can not remove the DUPLICATES:
* proc sort data="C:\Users\lihon\Downloads\merge_back\or_ee_trans_tax.sas7bdat" 
*            out = or_ee_trans_sort;
*      by rf_id ee_name or_name exec_dt;
*      run;
* WORK.OR_EE_TRANS_SORT has 345993 observations and 15 variables.

*/

*
%importStata(infile="C:\Users\lihon\Downloads\merge_back\or_ee_trans_tax_state_country.dta", 
            outfile=or_ee_trans_tax_full) 
;

%importStata(infile="C:\Users\lihon\Downloads\merge_back\or_ee_trans_tax_state_country.dta", 
            outfile=or_ee_trans_tax) 

 *C:\Users\lihon\Downloads\merge_back\or_ee_trans_tax_state_country.dta;
data or_ee_trans_tax;
   /*set "C:\Users\lihon\Downloads\merge_back\or_ee_trans_tax.sas7bdat"(keep
       =rf_id ee_name or_name exec_dt or_gvkey relation);*/
    set or_ee_trans_tax(
                      keep=rf_id ee_name or_name exec_dt or_gvkey relation deciles_for foreign_tran);
                      exec_year = year(exec_dt);
run;

* The or_ee_trans_tax data has 
  one or_name matched more gvkey in CRSP names 
 >>>*
;
proc sort data= or_ee_trans_tax
          out = or_ee_trans_sort NODUPKEY;
    by rf_id  or_name exec_dt;
run;
* %unique_values(or_ee_trans_sort, rf_id,ee_name)
The rf_id is unique
;

*V2: The data set WORK.OR_EE_TRANS_SORT has 138396 observations and 7 variables;

*The data set WORK.OR_EE_TRANS_SORT has 127424 observations and 15 variables.;


/*
%varlist(or_ee_trans_sort) 
*/

/*
Merge or_ee_trans_sort and CRSP_comp_ccm to get Assignor's permno, permco
May, 24, 2024
out dataset: or_ee_trans_permno1
WORK.OR_EE_TRANS_PERMNO1 created, with 139413 rows and 13 columns.

*/
sasfile Crsp_comp_ccm load;
proc sql; * with 327470 rows and 11 columns.;
create table or_ee_trans_permno1 as 
select rf_id
       ,or_name
       ,exec_dt
       ,exec_year 
       ,or_gvkey
       ,relation
       ,lpermno as permno
       ,lpermco as permco
       ,fyear
       ,datadate
       ,costat
       ,deciles_for
       ,foreign_tran
       from or_ee_trans_sort as a
           left join
           Crsp_comp_ccm as b
           on a.or_gvkey=b.gvkey
              /* AND fyear-2 LE exec_year LE fyear+1 ;*/
              AND fyear= exec_year  ;
 quit;
 run;
sasfile Crsp_comp_ccm close;
/* Why the permno record_dt is not UNIQUE *
%unique_values(or_ee_trans_permno1, rf_id,or_gvkey)
The count of total values and unique variable rf_id and or_gvkey values from table or_ee_trans_permno1 


gvkey_N total 
16909 or_gvkey 
138396 rf_id 
361576 total 

%unique_values(Crsp_comp_ccm, rf_id,or_gvkey)
gvkey_N total 
16909 or_gvkey 
138396 rf_id 
361576 total 

*/
/*
Table WORK.OR_EE_TRANS_PERMNO1 created, with 361576 rows and 11 columns.

* 
proc contents data = or_ee_trans_permno1 ; *347900;
Title "Structure of Mar. 20, 2024 or_ee_trans_permno";
run;
 *
proc contents data = or_ee_trans_permno ; *347900;
Title "Structure of Mar. 20, 2024 or_ee_trans_permno";
run;
*/
proc sort data = or_ee_trans_permno1 NODUPKEY 
          out  = or_ee_trans_permno2 ;
    * by rf_id or_name exec_dt permno;
          by rf_id or_name;
run;




/* merge with the assignment data to get recorded_date*/
/* 197294 observations read from the data set WORK.OR_EE_TRANS_TAX.*/

proc sql;
  create table for_event_study1 as 
  select a.rf_id as rf_id
        ,permno
        ,relation
        ,deciles_for
        ,foreign_tran
        ,exec_dt
        ,record_dt
        ,or_name
        ,a.or_gvkey as or_gvkey
        from or_ee_trans_permno2 as a
            inner join assignment as b
            on a.rf_id =b.rf_id
            where NOT missing(permno) and relation=1
            ;
  quit;
run;
/* Why the permno record_dt is not UNIQUE *
%unique_values(or_ee_trans_permno1, rf_id,or_gvkey)
gvkey_N total 
16909 or_gvkey 
138396 rf_id 
361576 total 

*/
/*
proc sql;
  create table for_event_study_regression as 
    select *
    from or_ee_trans_tax_full as a
           inner join
         for_event_study1 as b
       on a.rf_id = b.rf_id;
 quit;
run;
*/
/*Extract event by Recorded Date

            */
%unique_values(for_event_study1, rf_id,permno)
proc sort data = for_event_study1 
          out  = for_event_study_v2  NODUPKEYS;
          by permno record_dt;
run;
%unique_values(for_event_study_v2, rf_id,permno)
%unique_values(car_evtdate, permno,evtdate)
/*
%print30(for_event_study1)
%print30(for_event_study_foreign)

data for_event_study_foreign;
  set for_event_study_v2(where=(foreign_tran=1));
run;
 
*/

/*
* Recorded date
*/
data for_event_study_relation; 
      format permno record_dt;
      set for_event_study_v2 ( where= (NOT missing(permno) )
                               keep=permno record_dt
                             );
run;
/*
%print30(for_event_study_relation)

data for_event_study_foreign; 
      format permno record_dt;
      set for_event_study_foreign(where= (NOT  missing(permno) )
                              keep=permno record_dt );
run;
%print30(for_event_study_foreign)
*/
/*
PROC EXPORT DATA= WORK.for_event_study_relation 
            OUTFILE= "C:\Users\lihon\OneDrive - Kent State University\aa
aa\event_Study\permno_record_dt_relation.txt" 
            DBMS=TAB REPLACE;
     PUTNAMES=YES;
RUN;
PROC EXPORT DATA= WORK.for_event_study_foreign 
            OUTFILE= "C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\permno_record_dt_foreign.txt" 
            DBMS=TAB REPLACE;
     PUTNAMES=YES;
RUN;
PROC EXPORT DATA= WORK.for_event_study_regression 
            OUTFILE= "C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\for_event_study_regression.txt" 
            DBMS=TAB REPLACE;
     PUTNAMES=YES;
RUN;
*/
