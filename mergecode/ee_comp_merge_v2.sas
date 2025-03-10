﻿%let path=%str(C:\Users\lihon\OneDrive - Kent State University\2023Spring\crsp_or);
*OR_name 
libname or_crsp "C:\Users\lihon\Downloads\or_crsp_merged";
libname comp_or "C:\Users\lihon\Downloads\data_or_crsp_merged";
libname comp_ "C:\Users\lihon\Downloads\ee_crsp_merged";
libname oneDrive "&path";

options mlogic MPRINT;
options cpuCount = actual;
options msglevel=i fullstimer;
options cpuCount = actual;

/*************************************************************************************;
* Import COMPSTAT firm names 
* 53,958 obs 
* 18 Variables                                                                     *;
*************************************************************************************;
proc import datafile = "D:\Research\patent\data\wrds_names\unique_crspHist_remove_fund.dta"
      out = work.unique_crspHist_remove_fund   
      dbms=DTA 
      replace;
run;

*** Divid the COMPUSTAT names into several small files *;
************************************************************************;
* UNIQUE_CRSPHIST_REMOVE_FUND: 53,958
* AJ_COMP: 27,132
* KO_COMP:  9,393
* PR_COMP:  5,598
* ST_COMP:  7,298
* UZ_COMP:  4,537
****************************;
data AJ_comp KO_comp 
     PR_comp ST_comp 
     UZ_comp 
     others;
     set unique_crspHist_remove_fund(KEEP=GVKEY HCONM std_nameL);
         or_sub = substr(std_nameL, 1,3);
         blocking = substr(std_nameL, 1,1);
         len_name = length(std_nameL);
     if blocking LE 'J' then output AJ_comp;
     else if blocking GE 'K' AND blocking LE 'O' then output KO_comp;
     else if blocking GE 'P' AND blocking LE 'R' then output PR_comp;
     else if blocking GE 'S' AND blocking LE 'T' then output ST_comp;
     else if blocking GE 'U' AND blocking LE 'Z' then output UZ_comp;
     else output others;
     drop blocking;
run;


*************************************************************************************;
* The assignor names are divided into several files and match them with COMPUSTAT   *;
* corresponding files                                                               *;
* March 2nd, 2024                                                                   *;
* Directory: "C:\Users\lihon\Downloads\or_crsp_merged"                              *;
*************************************************************************************;
* subset of or_names
%do v= or_name_a_j82098
       or_name_K_O109896 
       or_name_P_R130938
       or_name_S_T157024  
       or_name_U_Z170073 
       ;
* 
************************************************************************************;
*Import Unique  name ;
*                  ;
************************************************************************************;
proc import datafile = "D:\Research\patent\data\uspto\unique__name_dedup.dta"
     out = work.unique__name   
     dbms=DTA 
     replace;
run;

************************************;
proc contents data = unique__name;
ods select Variables;
run;
*;

proc contents data = unique_crspHist_remove_fund;
run;
************************************
proc sort data=unique_crspHist_remove_fund;
by sub_std_name;
run;

proc sort data = unique__name;
  blocking = substr(std__name, 1, 1);
by std__name;
run;
/*****************************************************
* 1       State	        Char	8	 
* 2	coname	        Char	300	 
* 4	country_code	Char	8	 
* 1	gvkey	        Char	6	 
* 3	location	Char	300	 
* 7	y_report	Num	8	 
* 6	year_report	Num	8	DATE
******************************************************

%macro merge_comp_or(or, comp);
  data or_comp;
set;
%mend ;
/*********** SPLIT OR

; *'; *"; *); *;

quit; run;

%mEnd;

proc sort data=or_name_orig out = or_name1;
by std_firm1;
run;
*/
%split_non_matched(all_data =or_name  
                         ,std_firm = std_firm1
                         ,prefix = or
                         ) 


*/
%macro split_non_matched(all_data = 
                         ,std_firm = std_firm
                         ,prefix = comp
                         ,first_letter = first_lette






/**********************/

libname or_name "C:\Users\lihon\Downloads\data_or_crsp_merged";
%let lab_or=or_name;
%let comp_ac=COMP_NAME_A_C;

%fuzzy_comp_or(          &lab_or..or_name_a_j82098, AJ_comp)
%fuzzy_comp_or_SPEDIS(   &lab_or..or_name_a_j82098, AJ_comp)
%fuzzy_comp_or_SPEDIS_v5(&lab_or..or_name_a_j82098, AJ_comp)

%fuzzy_comp_or(or_name_U_Z170073, UZ_comp)
%fuzzy_sub_or_SPEDIS_v5( or_name_a_c, COMP_NAME_A_C
                               ,or_name= std_firm1
                              ,len_std_or = len_std_or 
                              ,or_sub = or_sub
                              ,comp_original=conm
                              ,comp_name = std_conmL
                              ,sub_name = comp_sub
                              ,len_name = len_std
                              ,merged_prefix=comp
                              ,up_spedis_score=10)

%macro match_or(or_name_a_c, COMP_NAME_A_C);
%fuzzy_sub_or_SPEDIS_v5( &or_name_a_c, &COMP_NAME_A_C
                              ,or_name       = std_firm1
                              ,len_std_or    = len_std_or 
                              ,or_sub        = or_sub
                              ,comp_original = conm
                              ,comp_name     = std_conmL
                              ,sub_name      = comp_sub
                              ,len_name      = len_std
                              ,merged_prefix =comp
                              ,up_spedis_score=15)
%mend match_or;

%match_or(or_name_a_c, COMP_NAME_A_C)
%match_or(or_name_d_g, COMP_NAME_d_g)
%match_or(or_name_h_l, COMP_NAME_h_L)
%match_or(or_name_m_r, COMP_NAME_m_r)
%match_or(or_name_s_z, COMP_NAME_s_z)
%match_or(or_others, COMP_others)

** or_name_d_g or_name_h_L or_name_m_R or_name_S_Z;

DATA comp_or_mar29_v3;  /*60,595*/
  set m_comp_comp_name_:;
RUN;
*can be done in the mathch macro;
proc sql;
create table _temp_ as
select * ,spedis(or_name, comp_conm) as dist_name from comp_or_mar29_v3
group by id_or
having spedis_score = min(spedis_score)
order by id_or;
run;
proc sql;
create table _temp_2 as
select * from _temp_
group by id_or
having dist_name = min(dist_name)
order by id_or;
run;

proc sql;
Title "number record in origin";
select count(distinct rf_id) as a from comp_or_mar29_v3;
 title "new rec";
 select count(distinct rf_id) as d from _temp_2;
quit;
run; 
 



proc sort data =_temp_2 
	out= comp_or_mar29_v3  nodupkey;
    by id_or  ;
run;

PROC DATASETS NOLIST;
  COPY IN = work OUT = comp_or ;
  *select  m_comp_comp_name_:;
  select comp_or_mar29_v3    ;
RUN;

/* removed the duplicated records */



/*****************************************************
*       or_name_a_j82098
*       or_name_K_O109896 
*       or_name_P_R130938
*       or_name_S_T157024  
*       or_name_U_Z170073
*
*	    AJ_comp 
*       KO_comp
*	    PR_comp 
*       ST_comp 
*       UZ_comp ;
**************************************************/
%macro comp_merge_or;
  %put "NOTE:(or_name_A_J, AJ_comp)";
     %fuzzy_comp_or_SPEDIS_v2(or_name_a_j82098, AJ_comp)
  %put "NOTE:(or_name_K_O109896, KO_comp)";
     %fuzzy_comp_or_SPEDIS_v2(or_name_K_O109896, KO_comp)
  %put "NOTE:(or_name_P_R130938, PR_comp)";
     %fuzzy_comp_or_SPEDIS_v2(or_name_P_R130938, PR_comp)
  %put "ERROR:(or_name_S_T157024, ST_comp)";
     %fuzzy_comp_or_SPEDIS_v2(or_name_S_T157024, ST_comp)
  %put "ERROR:(or_name_U_Z170073, UZ_comp)";
    %fuzzy_comp_or_SPEDIS_v2(or_name_U_Z170073, UZ_comp)
%mend comp_merge_or;

proc sql;
drop table m_aj_comp;
quit;

DATA comp_or;  /*60,595*/
  set comp_or.m_aj_comp /*42,158*/
      comp_or.m_ko_comp /*1,688*/
	  comp_or.m_pr_comp /*7,872*/
	  comp_or.m_st_comp /*2,100*/
	  comp_or.m_uz_comp; /*6,777*/
RUN;

proc sort data = comp_or out=comp_or_unique;
by id_or gl_score;
run;

data comp_or_merged;
  set comp_or_unique;
     by id_or;
  if first.id_or;
run;

* Too FEW records NOT used here;
* OBS from comp_or: 16,054  variables: 8;
* comp_or_simple: 16,054;
data comp_or_simple;
   set comp_or(kp = rf_id gvkey id_or or_name 
                     crsp_std_name HCONM 
                     spedis_score gl_score 
              where = (spedis_score <=20 and gl_score <= 200)
             );
run;



*************************************************************************************;
* subsidiaries                                                                      *;
*
*************************************************************************************;
DATA sub_or_merged;
    set m_subs: ;
RUN;

PROC DATASETS NOLIST;
  COPY IN = work OUT = comp_or ;
  select  m_subs:;
  select sub_or_merged    ;
RUN;



Title "sub_or_merged";
title2 ;
proc contents data = sub_or_merged varnum short;
   ods select PositionShort;
run;

Title "comp_or";
proc contents data = comp_or varnum short;
ods select PositionShort;
run;

data or_matched_all;
  set sub_or_merged(kp=rf_id exec_dt id_or or_std_name or_name gvkey 
                        crsp_std_name b_originalName 
                         spedis_score gl_score len_or len_crsp
				   rename=(b_originalName=firm_name crsp_std_name=std_name))

     comp_or(kp=rf_id exec_dt id_or or_std_name or_name GVKEY 
                        crsp_std_name HCONM 
                        spedis_score gl_score len_or len_crsp  
		 	rename=(HCONM=firm_name crsp_std_name=std_name));
run;

PROC DATASETS NOLIST;
     COPY IN = work OUT = comp_or ;
     select or_matched_all    ;
RUN;



PROC DATASETS NOLIST;
COPY IN = work OUT = comp_or ;
select or_matched_all    ;
RUN;
Title "";
ods select default;

%comp_merge_or

proc sort data = or_name ;
by id_or ;
run;

 ods trace off; 

*************************************************************************************;
* Nonmatched_comp                                                                   *;
* comp_or:60,595                                                                    *;
* or_name: 170,073                                                                  *;
* only keep the records which does not hav a GVKEY matched ;
*************************************************************************************;
data nonmatched_or_comp;
    merge or_name (rf_id=or_rfid 
                   or_name=orig_or_name 
		   exec_dt=orig_exec_dt 
		   in =inor)
          comp_or_merged (in=incomp);
    by id_or;
    
    or_in = inor;
    comp_in = incomp;
    if NOT comp_in;
RUN;
/*
NOTE: There were 170073 observations read from the data set WORK.OR_NAME.
NOTE: There were 23102 observations read from the data set WORK.COMP_OR_MERGED.
NOTE: The data set WORK.NONMATCHED_COMP has 146971 observations and 26 variables.
NOTE: DATA statement used (Total process time):
      real time           0.35 seconds
      user cpu time       0.14 seconds
      system cpu time     0.20 seconds
      memory              1174.71k

*/
PROC DATASETS NOLIST;
    COPY IN = work 
         OUT = or_crsp;
    select comp_or_merged nonmatched_or_comp;
RUN;

%merge_comp_or(or_name_a_j82098, AJ_comp)
fuzzy_comp_or_SPEDIS

PROC EXPORT DATA= WORK.M_aj_comp 
            OUTFILE= "C:\Users\lihon\Downloads\or_crsp_merged\aj.dta" 
            DBMS=STATA REPLACE;
RUN;


 
PROC DATASETS NOLIST;
COPY IN = work OUT = or_crsp ;
select M_AJ_COMP ;
RUN;

PROC DATASETS NOLIST;
COPY IN = work OUT = onedrive ;
select M_AJ_COMP ;
RUN;

* Make a sound *;
data _null_;
 call sound(523,500);
run;

PROC DATASETS NOLIST;
	COPY IN = work OUT = or_crsp ;
	select AJ_comp KO_comp
	       PR_comp ST_comp 
	       UZ_comp
	       ;
RUN;

PROC DATASETS NOLIST;
	COPY IN = work OUT = or_crsp ;
	select  
	  M_aj_comp;
	  M_PR_COMP;
	  M_UZ_comp;
RUN;
