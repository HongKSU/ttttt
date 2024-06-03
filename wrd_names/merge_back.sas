/*match back to the data*/
libname mergback "C:\Users\lihon\Downloads\merge_back";
 PROC IMPORT OUT= work.ee_or
            DATAFILE= "C:\Users\lihon\Downloads\merge_back\ee_or.dta" 
            DBMS=STATA REPLACE;

RUN;

ODS NOPROCTITLE;

 *ee_or: 568,987;
/**************************************************************************************/
* Merge with assignor matched;
* April 1, 2024;
/**************************************************************************************/
proc sql; 
  create table ee_or_mached as /*ee_or:568,987*/
     select trans.rf_id, trans.ee_name, ee_state,
         trans.ee_country, trans.or_name, trans.exec_dt,
         ee.gvkey as ee_gvkey, or.gvkey as or_gvkey 
      from   ee_or as trans
              left join 
             ee_matched_all as ee
          on trans.id_ee = ee.id_ee
             left join or_matched_all as or
      on trans.id_or = or.id_or;
  quit;
  run;
data ee_or_mached1; /*139,870*/
    set ee_or_mached ;
	 if or_gvkey= ee_gvkey then relation = 1;
	 if NOT missing(or_gvkey );
	 run;

%contents(ee_or_mached1)
/**************************************************************************************/
 /*
Title "ee_or" ;

proc contents data = f1 varnum short;
ods select PositionShort;
run;
rf_id ee_name ee_address_1 ee_address_2 ee_city ee_state ee_postcode ee_country or_name exec_dt dup len_ee len_or exec_y ee_name_clean id_ee id_or 




Title "ee_matched_all" ;
proc contents data = ee_matched_all varnum;
ods select PositionShort;
run;
Variables in Creation Order 
rf_id exec_y id_or id_ee or_std_name ee_sub GVKEY crsp_std_name b_originalName spedis_score len_or len_crsp 

Title "or_matched_all" ;
proc contents data = or_matched_all varnum
ods select PositionShort;
run;

PROC IMPORT OUT= WORK.parent_sub_gvkey_name_location
            DATAFILE= "D:\Research\patent\data\wrds_names\parent_sub_name_only_stacked.dta"
            DBMS=STATA REPLACE;

RUN;
*/
* WORK.com_all_names_unique_std ;
 *           DATAFILE= "D:\Research\patent\data\wrds_names\com_all_names_unique_std.dta" 
;
%varlist(com_all_names_unique_std)

/**************************************************************************************/
/* ee_or_mached_location: with 197294 rows and 12 columns
Get OR firm country and state from COMP dataset
April,1st, 2024

/**************************************************************************************/
proc sql;
 create table ee_or_mached_location as 
 select a.*
       ,b.state as or_state
       ,b.fic as or_fic
       ,b.naics as or_naics
 from ee_or_mached1 as a
        left join 
      com_all_names_unique_std as b
        on a.or_gvkey=b.gvkey 
   ;
   quit;
run;

%contents(ee_or_mached_location)
proc print data=ee_or_mached_location(obs=10);
run;
PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  or_ee_trans_tax    ;
RUN;
/*
PROC IMPORT OUT= WORK.Astate_names 
            DATAFILE= "C:\Users\lihon\Downloads\merge_back\stateNames.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

data aStateNames1;
set aState_names(rename = (V1=stateL V1_1=stateShort));
StateLong= strip(upcase(stateL));
run;

EE_OR_MACHED_LOCATION;
*/
proc sql;*826,115 v2:* 197294 rows*;
  create table ee_or_mached_final as
  select a.*
         ,b.stateShort as ee_state2 /*short state name*/
   from         EE_OR_MACHED_LOCATION as a
     left join aStateNames1 as b
   on upcase(a.ee_state) = upcase(b.StateLong);
  quit;
run;
 */
PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  ee_or_mached_final    ;
RUN;

%let path=C:\Users\lihon\OneDrive - Kent State University\Patent_assignment\taxratet;
libname taxRate "&path"; 
*"C:\Users\hli5\OneDrive - Kent State University\Patent_assignment\taxratet";
%include "C:\Users\hli5\OneDrive - Kent State University\Patent_assignment\taxratet\Import_stateRate.sas";
;

PROC IMPORT OUT= WORK.stateRate 
            DATAFILE= "C:\Users\lihon\OneDrive - Kent State University\P
atent_assignment\taxratet\StateTaxRate.dta" 
            DBMS=STATA REPLACE;

RUN;


/*Merge ee_or with state tax Rate*/
proc contents data = aStateNames1;
run;

data fips;
  fmtname='FIPS';
  type='I';
  length label 8 start $20 ;
  do label=1 to 95;
    start=fipnamel(label);
    if start ne 'Invalid Code' then output;
  end;
run;

proc format cntlin=fips ; run;
%contents(stateRate)

data state_rates;
  set stateRate (drop=state_long b_state_short)  ;
      state_short=fipstate(fips)  ;
run;
 /*
proc sql;*826,115;
  create table state_rates as
  select a.*, b.StateLong as state_long, b.stateShort as b_state_short
* NOT recognize the fun in SQL: , fipstate(a.fips) as stateShort*;
  from stateRate as a
   left join aStateNames1 as b
  on upcase(a.state) = upcase(b.StateLong);
  quit;
  run;
*/

%contents(ee_or_mached_final)
proc freq data = state_rates;
table stateShort state state_short;
run;
* stateShort and State_short are identical;
 

  %contents(ee_or_mached_final)
  proc freq data =state_rates;
  table state_short;
  run;
************************************************************************************;
*Merge Sate tax;
* April 1st, 2024
*
************************************************************************************; 
proc sql; 
  create table ee_trans_tax as 
    select a.* 
          ,b.t_f as ee_federal_tax
          ,b.t_s as ee_state_tax
    from ee_or_mached_final   a
         left join
        state_rates b
    on a.ee_state = upcase(b.state) and year(a.exec_dt) = b.year ;
 /*where NOT missing(a.ee_state);*
       
       */
       quit;
 proc sql; 
  create table or_ee_trans_tax as 
     select a.*, b.t_f as or_federal_tax, b.t_s as or_state_tax
     from         ee_trans_tax  a
       left join  state_rates b
  on upcase(a.or_state) = upcase(b.state_short) and year(a.exec_dt) = b.year;
  quit;
run;

/*Merge ee_or with country tax Rate*
*EE_TRANS_TAX created, with 197294 rows and 15 columns.;


proc sql; 
  create table ee_trans_tax as 
  a.* ,b.t_f as ee_federal_tax, b.t_s as ee_state_tax
  from taxRate.ee_or_mached_final  a
  left join
       taxRate.statRate b
	   on a.ee_state = b.state and a.exec_year = b.year;

  create table or_ee_trans_tax as 
      a.* ,b.t_f as or_federal_tax, b.t_s as or_state_tax
  from  ee_trans_tax  a
  left join  
	   taxRate.statRate b
       *taxRate.ee_trans_tax b*;
	   on a.state = b.state and a.exec_year = b.year;
	   quit;
run;
 */
PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  or_ee_trans_tax    ;
RUN;

**** Exploration the data****;
proc contents data = or_ee_trans_tax varnum short;
Title "Structure of or_ee_trans_tax";
run;

proc sql  outobs=15;
  select  distinct ee_name,  
                   ee_gvkey,
                   count(relation) as rela_count
  from or_ee_trans_tax
  where relation=1 
  group by ee_name
  order by    rela_count desc;
  quit;

  proc sql  outobs=15;
  Title "Top Assignors with relations. ";
  select  distinct or_name,  or_gvkey, count(relation) as rela_count
  from or_ee_trans_tax
  where relation=1 
  group by or_name
  order by    rela_count desc;
  quit;

/* Mereg Country TAX rate 
  * Merged file input: C:\Users\lihon\Downloads\merge_back
  * Country tax file:
  *             C:\Users\lihon\OneDrive - Kent State University\Patent_assignment\taxratet
  * Merged Output:
  *

