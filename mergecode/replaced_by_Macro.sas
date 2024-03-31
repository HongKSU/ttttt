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