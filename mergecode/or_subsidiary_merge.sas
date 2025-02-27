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
     DATAFILE= "D:\Research\patent\data\wrds_names\parent_gvkey_name_only_v2.dta" 
     DBMS=STATA REPLACE;
RUN;

 /*
%listvars(parent_sub_gvkey_name_only)

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
*/
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

/*
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

   */
%macro merge_sub_or(OR_table, SUBS_table);
%fuzzy_sub_or_SPEDIS_v5(&OR_table
                        ,&SUBS_table
                        ,or_name= std_firm1
                        ,len_std_or = len_std_or 
                        ,or_sub = or_sub
                        ,comp_original=coname
                        ,comp_name = std_sub_name
                        ,sub_name = subs_sub
                        ,country_code = country_code
                        ,len_name = len_name
                        ,merged_prefix=subs
                        ,up_spedis_score=12) /* version 1 has score=15, June 12, change to 12*/
%mend merge_sub_or;

* WORK.M_SUBS_SUBS_AC created, with 7914 rows and 14 columns;
* Table WORK.M_SUBS_SUBS_DG created, with 5220 rows and 14 columns;
%merge_sub_or(OR_AC, SUBS_AC)
%merge_sub_or(or_dg, SUBS_dg)
%merge_sub_or(or_hl, SUBS_hL)
%merge_sub_or(or_mr, SUBS_mr)
%merge_sub_or(or_sz, SUBS_sz)
%merge_sub_or(or_others, SUBS_others)
 

/* combine the merged subsets together */
DATA sub_or_merged;
    set m_subs_subs_: ;

RUN;

proc sql;
create table sub_or_merged_v1 as 
select a.*
        ,b.IDNAME as or_country
        ,b.ISOALPHA3 as  or_ISOALPHA3
        from  sub_or_merged    as a
               left join
             mapsgfk.world_attr as b
       on a.country_code  = b.ISOALPHA2
       ;
quit;



%contents(mapsgfk.world_attr)
%print30(mapsgfk.world_attr)

proc datasets library=work nolist;
  change sub_or_merged_v1=sub_or_merged_v3;
run;


PROC DATASETS NOLIST;
  COPY IN = work OUT = comp_or ;
*  select  m_subs_subs_:;
 * select sub_or_merged    ;
 select sub_or_merged_v3;
RUN;


*********************************************************;
* Subs_name in the code is or_name;
proc sql;
create table _temp_ as
    select * ,spedis(subs_name, comp_conm) as dist_name 
    from sub_or_merged_v3
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
select count(distinct rf_id) as sub_or_merged_unique_rf_id from sub_or_merged_v3;
 title "new rec";
 select count(distinct rf_id) as d from _temp_2;
quit;
run; 
 



proc sort data =_temp_2 out= sub_or_merged_v4  nodupkey;
by id_or  ;
run;
data comp_or.sub_or_merged_v4;
 set comp_or.sub_or_merged_v4( rename = (ISOALPHA3=or_ISOALPHA3 country=or_country));
 run;

%varList(sub_or_merged_v4)
%varList( COMP_OR.comp_or_mar29_v3)

/*NOTE: There were 26559 observations read from the data set WORK._TEMP_2.
NOTE: SAS sort was used.
NOTE: 6295 observations with duplicate key values were deleted.
NOTE: The data set WORK.SUB_OR_MERGED_V4 has 20264 observations and 18 variables.
NOTE: PROCEDURE SORT used (Total process time):

*/
*************************************************;



***********************************************;
/*
rf_id exec_dt id_or id_ee or_name entity_or_1 entity_or or_std_name or_sub gvkey crsp_std_name comp_conm spedis_score len_or len_comp dist_name 
rf_id exec_dt id_or id_ee or_name entity_or             or_std_name or_sub gvkey crsp_std_name comp_conm spedis_score len_or len_comp entity_comp dist_name

;
*/
data or_matched_all_v2;
  set sub_or_merged_v4(keep=rf_id exec_dt id_or subs_std_name subs_name gvkey 
                        crsp_std_name comp_conm 
                         spedis_score     dist_name  ISOALPHA3
				   rename=(comp_conm=firm_name crsp_std_name=std_name  subs_name=or_name subs_std_name =or_std_name 
                ISOALPHA3 =country_code ))

     COMP_OR.comp_or_june12_v4(keep=rf_id exec_dt id_or or_std_name or_name GVKEY 
                        crsp_std_name comp_conm 
                        spedis_score        dist_name country_code
		 	rename=(comp_conm=firm_name crsp_std_name=std_name));
run;
/*
There were 20264 observations read from the data set WORK.SUB_OR_MERGED_V4.
NOTE: There were 17174 observations read from the data set COMP_OR.COMP_OR_JUNE12_V4.
NOTE: The data set WORK.OR_MATCHED_ALL_V2 has 37438 observations and 11 variables.
*/
PROC DATASETS NOLIST;
     COPY IN = work OUT = comp_or ;
     select sub_or_merged_v4 or_matched_all_v2    ;
RUN;
***********************************************;
 
 



%macro subs_merge_ee;

comp_original=CONAME, or_name= std_firm1,
comp_name = std_sub_name, 
up_spedis_score=10, up_gl_score=230);

%macro subs_merge_ee;
  %put "ERROR:(or_name_K_O109896, subs_aj)";
      %fuzzy_sub_or_SPEDIS_v5(ee_name_A_J82098Ex, subs_AJ,
                             or_name = std_ee_name,
			     len_std_or = len_name, 
			     or_sub= ee_sub,
  			     comp_original=CONAME, 
			     comp_name = std_sub_name, 
			     sub_name = sub_name, 
			     len_name = len_name,
                             up_spedis_score=10, 
			     up_gl_score=200)
  %put "ERROR:(or_name_K_O109896, KO_comp)";
     %fuzzy_sub_or_SPEDIS_v5(ee_name_K_O109896Ex, subs_KO,
                             or_name = std_ee_name,
			     len_std_or = len_name, 
			     or_sub= ee_sub,
			     comp_original=CONAME, 
			     comp_name = std_sub_name, 
			     sub_name = sub_name, len_name = len_name,
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

 
