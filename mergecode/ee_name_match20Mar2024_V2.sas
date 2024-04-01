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
* removed the duplicated records *;
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
  select comp_ee_mar29_v2    ;
RUN;



*?8888888888888888888888888888888888888888888888888888888888888888888888;
proc sql;
create table nommatched_ee1 as
select * from unique_ee_name  
where id_ee not in
            (select id_ee from comp_ee_mar29_v3);
 
quit;
run;

%split_non_matched(all_data =nommatched_ee1  
                         ,std_firm = std_ee_name
                         ,prefix = ee
) 
 
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

proc sort data = comp_ee_mar29_v3;
   by id_ee;
run;

data nonmatched_ee_comp1;
    merge unique_ee_name (in =in_ee)
          comp_ee_mar29_v3   (in=in_comp);
	   by id_ee;
    ee_in = in_ee;
    comp_in = in_comp;
   if NOT comp_in;
run;




proc datasets library=work nolist;
   change comp_ee=comp_ee_merged;
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
