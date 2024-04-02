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

 

%macro split_non_matched(nonmatched_or_comp=nonmatched_ee_comp,
                         id_or= id_ee, or_name = ee_name, std_firm=std_ee_name , 
                         len_std_or=len_ee,prefix=ee);
%split_non_matched(nonmatched_or_comp=nonmatched_ee_comp,
                          or_name = ee_name, std_firm=std_ee_name , 
                          len_std_or=len_ee,prefix=ee)
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
/*March 24, 2024
      WORK.PARENT_SUB_GVKEY_NAME_ONLY.
NOTE: The data set WORK.SUBS_NAME_A_C has 237975 observations and 5 variables.
NOTE: The data set WORK.SUBS_NAME_D_G has 145690 observations and 5 variables.
NOTE: The data set WORK.SUBS_NAME_H_L has 133860 observations and 5 variables.
NOTE: The data set WORK.SUBS_NAME_M_R has 197274 observations and 5 variables.
NOTE: The data set WORK.SUBS_NAME_S_Z has 199035 observations and 5 variables.
NOTE: The data set WORK.SUBS_OTHERS has 0 observations and 5 variables.
*/

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

    *Version 2:
    *Date :March 31, 2024.
*NOTE: The data set WORK.OR_NAME_A_C has 33165 observations and 16 variables.
*NOTE: The data set WORK.OR_NAME_D_G has 23846 observations and 16 variables.
*NOTE: The data set WORK.OR_NAME_H_L has 23932 observations and 16 variables.
*NOTE: The data set WORK.OR_NAME_M_R has 34061 observations and 16 variables.
*NOTE: The data set WORK.OR_NAME_S_Z has 34369 observations and 16 variables.
*NOTE: The data set WORK.OR_OTHERS has 9 observations and 16 variables.
    ;


********************************************************************************;
*set nonmatched_comp
*
*
* Divid the COMP names into several small files *;
********************************************************************************;

proc datasets library=work nolist;
change OR_NAME_A_C=orac;
run;