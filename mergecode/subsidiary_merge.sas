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

* The import data set has 913834 observations and 5 variables.;

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

*************************************************************************************;
* Nonmatched_comp                                                                   *;
* comp_or:60,595                                                                    *;
* or_name: 170,073                                                                  *;
* only keeop the records which does not hav a GVKEY matched ;
*************************************************************************************;
%split_non_matched(all_data =Parent_sub_gvkey_name_only  
                         ,std_firm = std_sub_name
                         ,prefix = subs
                         ) 




*************************************************************************************;
* Nonmatched_comp                                                                   *;
* comp_or:60,595                                                                    *;
* or_name: 170,073                                                                  *;
* only keeop the records which does not hav a GVKEY matched ;
*************************************************************************************;
/*
NOTE: There were 149382 observations read from the data set WORK.NOMMATCHED_OR.
NOTE: The data set WORK.OR_NAME_A_C has 33165 observations and 16 variables.
NOTE: The data set WORK.OR_NAME_D_G has 23846 observations and 16 variables.
NOTE: The data set WORK.OR_NAME_H_L has 23932 observations and 16 variables.
NOTE: The data set WORK.OR_NAME_M_R has 34061 observations and 16 variables.
NOTE: The data set WORK.OR_NAME_S_Z has 34369 observations and 16 variables.
NOTE: The data set WORK.OR_OTHERS has 9 observations and 16 variables.
NOTE: DATA statement used (Total process time):
------------------------------------------------------------------------------------
NOTE: There were 913834 observations read from the data set
      WORK.PARENT_SUB_GVKEY_NAME_ONLY.
NOTE: The data set WORK.SUBS_NAME_A_C has 913834 observations and 6 variables.
NOTE: The data set WORK.SUBS_NAME_D_G has 0 observations and 6 variables.
NOTE: The data set WORK.SUBS_NAME_H_L has 0 observations and 6 variables.
NOTE: The data set WORK.SUBS_NAME_M_R has 0 observations and 6 variables.
NOTE: The data set WORK.SUBS_NAME_S_Z has 0 observations and 6 variables.
NOTE: The data set WORK.SUBS_OTHERS has 0 observations and 6 variables.

*/

proc datasets library=work nolist;
change OR_NAME_A_C=orac;
run;
%macro merge_sub_or(or_name_a_c, SUBS_NAME_A_C);

%fuzzy_sub_or_SPEDIS_v5(&OR_NAME_A_C, &SUBS_NAME_A_C
                               ,or_name= std_firm1
                              ,len_std_or = len_std_or 
                              ,or_sub = or_sub
                              ,comp_original=coname
                              ,comp_name = std_sub_name
                              ,sub_name = subs_sub
                              ,len_name = len_name
                              ,merged_prefix=subs
                              ,up_spedis_score=15)


%mend merge_sub_or;

%merge_sub_or(orac, SUBS_NAME_A_C)
%match_or(or_name_d_g, COMP_NAME_d_g)
%match_or(or_name_h_l, COMP_NAME_h_L)
%match_or(or_name_m_r, COMP_NAME_m_r)
%match_or(or_name_s_z, COMP_NAME_s_z)
%match_or(or_others, COMP_others)

%macro subs_merge_or;
  %put ERROR- "****merge non comp or_names with subsidiaries********";
  %put "ERROR:(or_name_K_O109896, KO_comp)";
    %fuzzy_sub_or_SPEDIS_v5(or_name_K_O109896Ex, subs_KO )
  %put "ERROR:(or_name_P_R130938, PR_comp)";
    %fuzzy_sub_or_SPEDIS_v5(or_name_P_R130938Ex, subs_PR )
  %put "ERROR:(or_name_S_T157024, ST_comp)";
    %fuzzy_sub_or_SPEDIS_v5(or_name_S_T157024Ex, subs_ST )
  %put "ERROR:(or_name_U_Z170073, UZ_comp)";
    %fuzzy_sub_or_SPEDIS_v5(or_name_U_Z170073Ex, subs_UZ )
%mend subs_merge_or;

%subs_merge_or




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

 
