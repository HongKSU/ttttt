********************************************************************************;
* Data:                                                                        *;
* set wrds_db.parent_sub_name_only_stacked                                     *;   
********************************************************************************;
/********************************************************************************
* %let wrds = wrds-cloud.wharton.upenn.edu 4016;
* signon wrds username = hli5 password =_PROMPT_;
* Lihong123654;
*
*                "D:\Research\patent\data\wrds_names\parent_sub_name_only_stacked.dat"
*******************************************************************************/
options msglevel=i fullstimer;
options cpuCount = actual;
options mlogic MPRINT;
libname wrds_db "D:\Research\patent\data\wrds_names";

*Log out of WRDS.*;
*signoff;
*rsubmit;

*proc download data= SUBS.parent_sub_stacked out=wrds_db.parent_sub_name_only_stacked;
*run;
*endrsubmit;
*01234567890123456789012345678901234567890123456789012345678901234567890123456789;
********************************************************************************;
* Import the Standardized SUBSIDIARY firm names from Stata                     *;
* Parent_sub_gvkey_name_only                                                   *;
********************************************************************************;
****************************************************************;
*%include "D:\Research\patent\data\wrds_names\parent_sub_gvkey_name_only.sas"; 

PROC IMPORT OUT= WORK.parent_sub_gvkey_name_only 
     DATAFILE= "D:\Research\patent\data\wrds_names\parent_gvkey_name_only.dta" 
     DBMS=STATA REPLACE;
RUN;

Title "Subsidiary data";
PROC sql;
    create table subs_gvkey as 
      select distinct gvkey    
    from SUBS.parent_sub_stacked;
quit;

Title "Contents of Subsidiary data";
proc contents data= SUBS.parent_sub_stacked;  varnum;
*ods select PositionShort;
run;

********************************************************************************;
*** Divid the Subsidiary COMP names into several small files *;
* There were 913834 observations read from the data set "Parent_sub_gvkey_name_only";
* NOTE: There were 913834 observations read from the data set *;
*      WORK.PARENT_SUB_GVKEY_NAME_ONLY.*;
* NOTE: The data set WORK.SUBS_AJ has 467586 observations and 5 variables.*;
* NOTE: The data set WORK.SUBS_KO has 158702 observations and 5 variables.*;
* NOTE: The data set WORK.SUBS_PR has 88511 observations and 5 variables.*;
* NOTE: The data set WORK.SUBS_ST has 127905 observations and 5 variables.*;
* NOTE: The data set WORK.SUBS_UZ has 71130 observations and 5 variables.*;
* NOTE: The data set WORK.SUBS_OTHERS has 0 observations and 5 variables.*;
* NOTE: DATA statement used (Total process time):  *;

********************************************************************************;
data   subs_AJ  /*467586*/
       subs_KO  /*15870*/
       subs_PR  /* 88511 */
       subs_ST  /*127,905*/
       subs_UZ  /*71,130*/
       subs_others; /*0*/
	   set Parent_sub_gvkey_name_only(KEEP=GVKEY CONAME std_sub_name blocking);
 	   blocking = substr(std_sub_name, 1,1);
	   sub_name = substr(std_sub_name, 1,3);
	   len_name = length(std_sub_name);
	   if blocking LE 'J' then output subs_AJ;
	   else if blocking GE 'K' AND blocking LE 'O' then output subs_KO;
	   else if blocking GE 'P' AND blocking LE 'R' then output subs_PR;
	   else if blocking GE 'S' AND blocking LE 'T' then output subs_ST;
	   else if blocking GE 'U' AND blocking LE 'Z' then output subs_UZ;
	   else output subs_others;
       drop blocking;
	   KEEP GVKEY CONAME std_sub_name blocking;
	   keep sub_name len_name;
	run;

********************************************************************************;
*set nonmatched_comp
*
*
* Divid the COMP names into several small files *;
* AJ82:
NOTE: There were 146971 observations read from the data set WORK.NONMATCHED_COMP.
NOTE: The data set WORK.OR_NAME_A_J82098EX has 67806 observations and 7 variables.
NOTE: The data set WORK.OR_NAME_K_O109896EX has 30103 observations and 7 variables.
NOTE: The data set WORK.OR_NAME_P_R130938EX has 14039 observations and 7 variables.
NOTE: The data set WORK.OR_NAME_S_T157024EX has 24227 observations and 7 variables.
NOTE: The data set WORK.OR_NAME_U_Z170073EX has 10787 observations and 7 variables.
NOTE: The data set WORK.OTHERS has 9 observations and 7 variables

********************************************************************************;
DATA or_name_A_J82098Ex
     or_name_K_O109896Ex
     or_name_P_R130938Ex
     or_name_S_T157024Ex
     or_name_U_Z170073Ex others;
   set nonmatched_or_comp(keep = rf_id or_name id_or std_firm1 std_firm exec_dt len_std_or);
	 blocking = substr(std_firm, 1,1);
	 or_year = year(exec_dt);
	 or_sub = substr(std_firm1,1,3);
	 len_nameL = length(std_firmL);
   if blocking LE 'J'                 then            output or_name_A_J82098Ex;
	else if blocking GE 'K' AND blocking LE 'O' then output or_name_K_O109896Ex;
	else if blocking GE 'P' AND blocking LE 'R' then output or_name_P_R130938Ex;
	else if blocking GE 'S' AND blocking LE 'T' then output or_name_S_T157024Ex;
	else if blocking GE 'U' AND blocking LE 'Z' then output or_name_U_Z170073Ex;
	else output others;
    drop blocking ;
	keep rf_id or_name id_or std_firm1 std_firm exec_dt len_std_or;
	keep or_sub len_nameL;
	run;
********************************************************************************;
*set nonmatched_comp
*
*
* Divid the COMP names into several small files *;
********************************************************************************;
%macro split_non_matched(nonmatched_or_comp=nonmatched_or_comp,
                             or_name = or_name, std_firm=std_firm1, 
                             len_std_or=len_std_or,prefix=or);
	data &prefix._name_A_J82098Ex
     &prefix._name_K_O109896Ex
     &prefix._name_P_R130938Ex
     &prefix._name_S_T157024Ex
     &prefix._name_U_Z170073Ex &prefix._others;
   set &nonmatched_or_comp(keep = rf_id &or_name id_or id_ee &std_firm exec_dt &len_std_or);
	 blocking = substr(&std_firm, 1,1);
	 or_year = year(exec_dt);
	 &prefix._sub = substr(&std_firm,1,3);
	 len_name = length(&std_firm);
   if blocking LE 'J' then output &prefix._name_A_J82098Ex;
	else if blocking GE 'K' AND blocking LE 'O' then output &prefix._name_K_O109896Ex;
	else if blocking GE 'P' AND blocking LE 'R' then output &prefix._name_P_R130938Ex;
	else if blocking GE 'S' AND blocking LE 'T' then output &prefix._name_S_T157024Ex;
	else if blocking GE 'U' AND blocking LE 'Z' then output &prefix._name_U_Z170073Ex;
	else output &prefix._others;
    drop blocking ;
	keep rf_id &or_name id_or id_ee &std_firm  exec_dt &len_std_or;
	keep &prefix._sub len_name;
	run;
%mend split_non_matched;

%macro split_non_matched(nonmatched_or_comp=nonmatched_ee_comp,
                         id_or= id_ee, or_name = ee_name, std_firm=std_ee_name , 
                         len_std_or=len_ee,prefix=ee);
%split_non_matched(nonmatched_or_comp=nonmatched_ee_comp,
                          or_name = ee_name, std_firm=std_ee_name , 
                          len_std_or=len_ee,prefix=ee)



proc contents data = ee_name_A_J82098Ex;
ods select variables;
run;

ods select position;
proc contents data =nonmatched_or_comp varnum ;
run;
ods select default;

subs_AJ
       subs_KO
       subs_PR
       subs_ST
       subs_UZ 


%macro fuzzy_sub_or_SPEDIS_v3(or, comp, 
comp_original=CONAME, or_name= std_firm1, 
comp_name = std_sub_name, up_spedis_score=10, up_gl_score=230);
sasfile &or load;
sasfile &comp load;
PROC sql _method ;
    create table m_&comp  as
    select a.rf_id, a.exec_dt, a.id_or, a.&or_name as or_std_name, a.or_name,
          b.GVKEY, b.&comp_name as crsp_std_name, b.&comp_original as b_originalName,
          SPEDIS(a.&or_name, b.&comp_name) as spedis_score, 
/*          compged(a.&or_name, b.&comp_name) as gl_score,*/
		  a.len_std_or as len_or,
          b.len_name as len_crsp
   from  &or as a
   left join &comp as b
   on a.or_sub = b.sub_name  
   where (CALCULATED spedis_score<=&up_spedis_score  AND 
          CALCULATED gl_score<=&up_gl_score  AND 
          a.len_std_or>5 AND b.len_name>5) OR
          (a.&or_name = b.&comp_name) ;

     quit;
RUN;
sasfile &or close;
sasfile &comp close;
%mend fuzzy_sub_or_SPEDIS_v3;

%macro fuzzy_sub_or_SPEDIS_v4(or, comp, 
                              comp_original=CONAME, or_name= std_firm1,
                              comp_name = std_sub_name, 
                              up_spedis_score=10, up_gl_score=230);
    sasfile &or load;
    sasfile &comp load;
    proc sql _method ;
    create table m_&comp  as
    select a.rf_id, a.exec_dt, a.id_or, a.&or_name as or_std_name, a.or_name,
          b.GVKEY, b.&comp_name as crsp_std_name, b.&comp_original as b_originalName,
          SPEDIS(a.&or_name, b.&comp_name) as spedis_score, 
/*          compged(a.&or_name, b.&comp_name) as gl_score,*/
		  a.len_std_or as len_or,
          b.len_name as len_crsp
   from  &or as a
   left join &comp as b
   on a.or_sub = b.sub_name  
   where (CALCULATED spedis_score<=&up_spedis_score   AND 
          a.len_std_or>5 AND b.len_name>5) OR
          (a.&or_name = b.&comp_name) ;

     quit;
 run;
sasfile &or close;
sasfile &comp close;
%mend fuzzy_sub_or_SPEDIS_v4;

%fuzzy_sub_or_SPEDIS_v3(or_name_a_j82098Ex, subs_AJ,
                         or_name= std_firm1, 
                         comp_name = std_sub_name, up_spedis_score=15, up_gl_score=200)

%macro subs_merge_or;
  %put "ERROR:(or_name_K_O109896, subs_aj)";
  %put "ERROR:(or_name_K_O109896, KO_comp)";
    %fuzzy_sub_or_SPEDIS_v4(or_name_K_O109896Ex, subs_KO )
  %put "ERROR:(or_name_P_R130938, PR_comp)";
    %fuzzy_sub_or_SPEDIS_v4(or_name_P_R130938Ex, subs_PR )
  %put "ERROR:(or_name_S_T157024, ST_comp)";
    %fuzzy_sub_or_SPEDIS_v4(or_name_S_T157024Ex, subs_ST )
  %put "ERROR:(or_name_U_Z170073, UZ_comp)";
    %fuzzy_sub_or_SPEDIS_v4(or_name_U_Z170073Ex, subs_UZ )
%mend subs_merge_or;

%subs_merge_or

/************************************** SUB ee***************/
%macro fuzzy_sub_or_SPEDIS_v5(or, comp, 
                             or_name= std_firm1, len_std_or = len_std_or, or_sub = or_sub_name,
                             comp_original=HCONM, comp_name = std_sub_name, sub_name = sub_name, len_name = len_name,
							 merged_prefix=EE, exec_y=exec_dt,
                             up_spedis_score=10, up_gl_score=200);
options msglevel=i fullstimer;

options cpuCount = actual;
sasfile &or load;
sasfile &comp load;
proc sql _method ;
   create table m_&merged_prefix._&comp  as
   select a.rf_id,
          a.&exec_y, 
          a.id_or,
          a.id_ee, 
          a.&or_name as or_std_name, 
		  a.&or_sub,
          b.GVKEY,
          b.&comp_name as crsp_std_name, 
          b.&comp_original as b_originalName,
          SPEDIS(a.&or_name, b.&comp_name) as spedis_score, 
/*          compged(a.&or_name, b.&comp_name) as gl_score,*/
		  a.&len_std_or as len_or,
          b.&len_name as len_crsp
   from  &or as a
   left join &comp as b
   on a.&or_sub = b.&sub_name  
   where (CALCULATED spedis_score<= &up_spedis_score   AND 
          a.&len_std_or>5 AND b.&len_name>5) OR
          (a.&or_name = b.&comp_name) ;

     quit;
 run;
sasfile &or close;
sasfile &comp close;
%mend fuzzy_sub_or_SPEDIS_v5;
      fuzzy_sub_or_SPEDIS_v5
%macro subs_merge_ee;

comp_original=CONAME, or_name= std_firm1,
comp_name = std_sub_name, 
up_spedis_score=10, up_gl_score=230);
%macro subs_merge_ee;
%put "ERROR:(or_name_K_O109896, subs_aj)";
    %fuzzy_sub_or_SPEDIS_v5(ee_name_A_J82098Ex, subs_AJ,
                           or_name = std_ee_name,len_std_or = len_name, or_sub= ee_sub,
							comp_original=CONAME, comp_name = std_sub_name, sub_name = sub_name, len_name = len_name,
                             up_spedis_score=10, up_gl_score=200)
  %put "ERROR:(or_name_K_O109896, KO_comp)";
  %fuzzy_sub_or_SPEDIS_v5(ee_name_K_O109896Ex, subs_KO,
                           or_name = std_ee_name,len_std_or = len_name, or_sub= ee_sub,
							comp_original=CONAME, comp_name = std_sub_name, sub_name = sub_name, len_name = len_name,
                             up_spedis_score=10, up_gl_score=200)
     
  %put "ERROR:(or_name_P_R130938, PR_comp)";
 
	%fuzzy_sub_or_SPEDIS_v5(ee_name_P_R130938Ex, subs_PR,
                           or_name = std_ee_name,len_std_or = len_name, or_sub= ee_sub,
							comp_original=CONAME, comp_name = std_sub_name, sub_name = sub_name, len_name = len_name,
                             up_spedis_score=10, up_gl_score=200)
  %put "ERROR:(ee_name_S_T157024, ST_comp)";
 
	%fuzzy_sub_or_SPEDIS_v5(ee_name_S_T157024Ex, subs_ST,
                           or_name = std_ee_name,len_std_or = len_name, or_sub= ee_sub,
							comp_original=CONAME, comp_name = std_sub_name, sub_name = sub_name, len_name = len_name,
                             up_spedis_score=10, up_gl_score=200)
  %put "ERROR:(or_name_U_Z170073, UZ_comp)";
    
	%fuzzy_sub_or_SPEDIS_v5(ee_name_U_Z170073Ex, subs_UZ ,
                           or_name = std_ee_name,len_std_or = len_name, or_sub= ee_sub,
							comp_original=CONAME, comp_name = std_sub_name, sub_name = sub_name, len_name = len_name,
                             up_spedis_score=10, up_gl_score=200)
	
%mend subs_merge_ee;
%subs_merge_ee

 
