/*data AJ_ee 
     KO_ee 
     PR_ee 
     ST_ee 
     UZ_ee 
     others_ee;
	 set unique_ee_name(keep=rf_id id_or 
                            id_ee std_ee_name
                            ee_country ee_state ee_name entity 
                            exec_y);
	 ee_sub = substr(std_ee_name,1,3);
	 len_name = length(std_ee_name);
	 blocking = substr(std_ee_name, 1, 1);

	   if blocking LE 'J' then output AJ_ee;
	   else if blocking GE 'K' AND blocking LE 'O' then output KO_ee;
	   else if blocking GE 'P' AND blocking LE 'R' then output PR_ee;
	   else if blocking GE 'S' AND blocking LE 'T' then output ST_ee;
	   else if blocking GE 'U' AND blocking LE 'Z' then output UZ_ee;
	   else output others_ee;
       keep rf_id id_or id_ee ee_country ee_state ee_name entity exec_y  std_ee_name ee_sub len_name;
run;
*/ 
PROC IMPORT OUT= unique_ee_name
     DATAFILE= "D:\Research\patent\data\uspto\unique_ee_name_dedup.dta" 
     DBMS=STATA REPLACE;
RUN;
/*NOTE: There were 180015 observations read from the data set WORK.UNIQUE_EE_NAME.
NOTE: The data set WORK.EE_AC has 40236 observations and 23 variables.
NOTE: The data set WORK.EE_DG has 28122 observations and 23 variables.
NOTE: The data set WORK.EE_HL has 29112 observations and 23 variables.
NOTE: The data set WORK.EE_MR has 40511 observations and 23 variables.
NOTE: The data set WORK.EE_SZ has 42028 observations and 23 variables.
NOTE: The data set WORK.EE_OTHERS has 6 observations and 23 variables.
*/
%split_non_matched(all_data =unique_ee_name  
                         ,std_firm = std_ee_name
                         ,prefix = ee
                         ) 
%varList(ee_ac)
;
%Variables in Creation Order 
rf_id ee_name ee_address_1 ee_address_2 ee_city ee_state ee_postcode ee_country  
exec_dt dup len_ee exec_y id_ee id_or std_ee_name dba fka entity attn ee_sub len_name 

*(or, comp, or_name= std_ee_name, comp_name = std_ee_name, or_sub=ee_sub, up_spedis_score=15, up_gl_score=200);
%fuzzy_sub_or_SPEDIS_v5(ee_ac, comp_ac, 
                            or_name = std_ee_name,len_std_or = len_name, or_sub= ee_sub,
							comp_original=HCONM, comp_name = std_nameL, sub_name = sub_name, len_name = len_name,
                             up_spedis_score=10)

%macro match_ee(ee_ac, comp_ac);
%fuzzy_sub_or_SPEDIS_v5( &ee_ac, &comp_ac
                              ,original_name=ee_name
                              ,or_name= std_ee_name
                              ,len_std_or = len_name 
                              ,or_sub = ee_sub
                              ,comp_original=conm
                              ,comp_name = std_conmL
                              ,sub_name = comp_sub
                              ,len_name = len_std
                              ,merged_prefix=ee
                              ,up_spedis_score=15)
%mend match_ee;


%*%%match_or(or_name_a_c, COMP_NAME_A_C);
%match_ee(ee_dg, COMP_dg)
%match_ee(ee_hl, COMP_hL)
%match_ee(ee_mr, COMP_mr)
%match_ee(ee_sz, COMP_sz)
%match_ee(ee_others, COMP_others)


                         
%macro comp_merge_ee;
  %put ERROR:***(or_name_K_O109896, KO_comp)***;
   	 %fuzzy_sub_or_SPEDIS_v5(KO_ee, KO_comp, 
                            or_name = std_ee_name,len_std_or = len_name, or_sub= ee_sub,
							comp_original=HCONM, comp_name = std_nameL, sub_name = sub_name, len_name = len_name,
                             up_spedis_score=10, up_gl_score=200);
  %put ERROR: ***(or_name_P_R130938, PR_comp***;
     %fuzzy_sub_or_SPEDIS_v5(PR_ee, PR_comp, 
                            or_name = std_ee_name,len_std_or = len_name, or_sub= ee_sub,
							comp_original=HCONM, comp_name = std_nameL, sub_name = sub_name, len_name = len_name,
                             up_spedis_score=10, up_gl_score=200);
    
  %put ERROR:***(or_name_S_T157024, ST_comp)***;
	 %fuzzy_sub_or_SPEDIS_v5(ST_ee, ST_comp, 
                            or_name = std_ee_name,len_std_or = len_name, or_sub= ee_sub,
							comp_original=HCONM, comp_name = std_nameL, sub_name = sub_name, len_name = len_name,
                             up_spedis_score=10, up_gl_score=200);
  
    %fuzzy_sub_or_SPEDIS_v5(or_name_S_T157024, ST_comp)
  %put "ERROR:(or_name_U_Z170073, UZ_comp)";
    	%fuzzy_sub_or_SPEDIS_v5(UZ_ee, UZ_comp, 
                            or_name = std_ee_name,len_std_or = len_name, or_sub= ee_sub,
							comp_original=HCONM, comp_name = std_nameL, sub_name = sub_name, len_name = len_name,
                             up_spedis_score=10, up_gl_score=200);
  

%mend comp_merge_ee;

%comp_merge_ee
*?8888888888888888888888888888888888888888888888888888888888888888888888;

*WORK.COMP_EE_MAR29_V3 has 25123 observations and 14 variables.;
DATA comp_ee_mar29_v3;  /*60,595*/
  set m_ee_comp_:;
RUN;

%deduplicate_merged(comp_ee_mar29_v3, comp_ee_mar29_v2
                    ,or_name=ee_name
                    ,comp_name=comp_conm
                    ,id_unique=id_ee
                   )


PROC DATASETS NOLIST;
  COPY IN = work OUT = comp_or ;
  *select  m_comp_comp_name_:;
  select comp_or_mar29_v3    ;
RUN;

/* removed the duplicated records */



***************;
PROC DATASETS NOLIST;
  COPY IN = work OUT = comp_ee ;
  select    m_ee: ;
RUN;

/***************************************************************************
*Combin all ee_merged*/
*
* comp_ee_merged
* sub_ee_merged;
**************************************************************************/

 
Title "comp_ee_merged";
title2 ;
proc contents data = comp_ee_merged varnum short;
ods select PositionShort;
run;
Title "sub_ee_merged";
proc contents data = subs_ee_merged varnum short;
ods select PositionShort;
run;
data ee_matched_all;
set subs_ee_merged	
    comp_ee_merged;
run;
PROC DATASETS NOLIST;
COPY IN = work OUT = comp_ee ;
select  ee_matched_all    ;
RUN;

proc sort data = unique_ee_name;
    by id_ee;
run;

proc sort data = comp_ee_merged;
   by id_ee;
run;

data nonmatched_ee_comp;
    merge unique_ee_name (in =in_ee)
          comp_ee_merged   (in=in_comp);
	   by id_ee;
    ee_in = in_ee;
    comp_in = in_comp;
   if NOT comp_in;
run;




proc datasets library=work nolist;
   change comp_ee=comp_ee_merged;
run;


data comp_ee_merged;
    set comp_ee.m_ee_aj_comp
 	comp_ee.m_ee_ko_comp
	comp_ee.m_ee_pr_comp
	comp_ee.m_ee_st_comp
	comp_ee.m_ee_uz_comp;
run;

data subs_ee_merged;
  set m_ee_subs:;
run;

PROC DATASETS NOLIST;
  COPY IN = work OUT = comp_ee ;
    select  comp_ee    ;
RUN;

PROC DATASETS NOLIST;
  COPY IN = work OUT = comp_ee ;
    select  m_ee_subs:;
    select subs_ee_merged    ;
RUN;
