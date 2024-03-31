%let path=%str(C:\Users\lihon\OneDrive - Kent State University\2023Spring\crsp_or);
*OR_name 
libname or_crsp "C:\Users\lihon\Downloads\or_crsp_merged";
libname comp_or "C:\Users\lihon\Downloads\data_or_crsp_merged";
libname comp_ee "C:\Users\lihon\Downloads\ee_crsp_merged";
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
* The assignor names are divided into several files and mathc them with COMPUSTAT   *;
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
*Import Unique ee name ;
*                  ;
************************************************************************************;
proc import datafile = "D:\Research\patent\data\uspto\unique_ee_name_dedup.dta"
     out = work.unique_ee_name   
     dbms=DTA 
     replace;
run;

************************************;
proc contents data = unique_ee_name;
ods select Variables;
run;
*;

proc contents data = unique_crspHist_remove_fund;
run;
************************************
proc sort data=unique_crspHist_remove_fund;
by sub_std_name;
run;

proc sort data = unique_ee_name;
  blocking = substr(std_ee_name, 1, 1);
by std_ee_name;
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
                               ,or_name= std_firm1
                              ,len_std_or = len_std_or 
                              ,or_sub = or_sub
                              ,comp_original=conm
                              ,comp_name = std_conmL
                              ,sub_name = comp_sub
                              ,len_name = len_std
                              ,merged_prefix=comp
                              ,up_spedis_score=15)
%mend match_or;

%match_or(or_name_a_c, COMP_NAME_A_C)
%match_or(or_name_d_g, COMP_NAME_d_g)
%match_or(or_name_h_l, COMP_NAME_h_L)
%match_or(or_name_m_r, COMP_NAME_m_r)
%match_or(or_name_s_z, COMP_NAME_s_z)
%match_or(or_others, COMP_others)

or_name_d_g or_name_h_L or_name_m_R or_name_S_Z

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
 



proc sort data =_temp_2 out= comp_or_mar29_v3  nodupkey;
by id_or  ;
run;

PROC DATASETS NOLIST;
  COPY IN = work OUT = comp_or ;
  *select  m_comp_comp_name_:;
  select comp_or_mar29_v3    ;
RUN;

/* removed the duplicated records */



/*****************************************************
*        or_name_a_j82098
*        or_name_K_O109896 
*       or_name_P_R130938
*       or_name_S_T157024  
*       or_name_U_Z170073
*
*	    AJ_comp 
*       KO_comp
*	    PR_comp 
*       ST_comp 
*       UZ_comp ;
**************************************************
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

DATA comp_or;  *60,595*;
  set comp_or.m_aj_comp ;*42,158*;
      comp_or.m_ko_comp ;*1,688*;
	  comp_or.m_pr_comp ;*7,872*;
	  comp_or.m_st_comp ;*2,100*;
	  comp_or.m_uz_comp; *6,777*;
RUN;

proc sort data = comp_or out=comp_or_unique;
by id_or gl_score;
run;

data comp_or_merged;
  set comp_or_unique;
     by id_or;
  if first.id_or;
run;
*
* Too FEW records NOT used here;
* OBS from comp_or: 16,054  variables: 8;
* comp_or_simple: 16,054;
*/



*************************************************************************************;
*************************************************************************************;
* subsidiaries                                                                      *;
*
*************************************************************************************;


*comp_or_mar29_v3c;
* need to change the name make them consistent;
*There were 20691 observations read from the data set WORK.COMP_OR;



proc datasets library=work nolist;
change comp_or_mar29_v3=comp_or;
run;
data comp_or_merged;
  set comp_or;
     by id_or;
  if first.id_or;
run;

%listVars(comp_or)
/*
rf_id exec_dt id_or id_ee or_name entity_or or_std_name or_sub
gvkey crsp_std_name comp_conm 
spedis_score len_or len_comp entity_comp dist_name



Title "sub_or_merged";

data comp_or_simple;
   set comp_or(keep = rf_id gvkey id_or or_name 
                     crsp_std_name comp_conm  
                     spedis_score  
              where = (spedis_score <=20 )
             );
run;
*/

*************************************************************************************;
* Nonmatched_comp                                                                   *;
* comp_or:60,595                                                                    *;
* or_name: 170,073                                                                  *;
* only keeop the records which does not hav a GVKEY matched ;
*************************************************************************************;
/*data nonmatched_or_comp;
    merge or_name(rename=(rf_id=or_rfid 
                          or_name=orig_or_name 
		                  exec_dt=orig_exec_dt) 
		   in =inor)
          comp_or_merged (in=incomp);
    by id_or;
    
    or_in = inor;
    comp_in = incomp;
    if NOT comp_in;
RUN;
*/
proc sql;
create table nommatched_or as
select * from or_name  
where rf_id not in
            (select rf_id from comp_or_merged);
 
quit;
run;

%split_non_matched(all_data =nommatched_or  
                         ,std_firm = std_firm1
                         ,prefix = or
                         ) 

 *NOTE: There were 149382 observations read from the data set WORK.NOMMATCHED_OR.
NOTE: The data set WORK.OR_NAME_A_C has 33165 observations and 16 variables.
NOTE: The data set WORK.OR_NAME_D_G has 23846 observations and 16 variables.
NOTE: The data set WORK.OR_NAME_H_L has 23932 observations and 16 variables.
NOTE: The data set WORK.OR_NAME_M_R has 34061 observations and 16 variables.
NOTE: The data set WORK.OR_NAME_S_Z has 34369 observations and 16 variables.
NOTE: The data set WORK.OR_OTHERS has 9 observations and 16 variables.

*WORK.NOMMATCHED_OR created, with 149382 rows and 1 columns.;


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
