 /*%*%SYSMACDELETE split_non_matched  */
 %SYSMACDELETE fuzzy_sub_or_SPEDIS_v5  

%macro fuzzy_sub_or_SPEDIS_v5(or, comp 
                              ,or_name= std_firm1
                              ,len_std_or = len_std_or 
                              ,or_sub = or_sub_name
                              ,comp_original=HCONM
                              ,comp_name = std_sub_name 
                              ,sub_name = sub_name
                              ,len_name = len_name
                              ,merged_prefix=comp
                              ,up_spedis_score=10);
sasfile &or load;
sasfile &comp load;
proc sql _method ;
   create table m_&merged_prefix._&comp  as
   select a.rf_id,
          a.exec_dt, 
          a.id_or,
          a.id_ee, 
	  a.or_name,
	  a.entity_1 as entity_or_1,
          a.entity as entity_or,
          a.&or_name as or_std_name, 
          a.&or_sub,
          b.GVKEY,
          b.&comp_name as crsp_std_name, 
          b.&comp_original as comp_conm,
          SPEDIS(a.&or_name, b.&comp_name) as spedis_score, 
/****** compged(a.&or_name, b.&comp_name) as gl_score,*/
          a.&len_std_or as len_or,
          b.&len_name as len_comp,
          b.entity as entity_comp
   from  &or as a
   left join &comp as b
   on a.&or_sub = b.&sub_name  
   where (CALCULATED spedis_score <= &up_spedis_score   AND 
          a.&len_std_or>5 AND b.&len_name>5) OR
          (a.&or_name = b.&comp_name) ;

   quit;
 run;
sasfile &or close;
sasfile &comp close;
%mend fuzzy_sub_or_SPEDIS_v5;

/*************************************************************************************
joint tables:
    left OR
    right comp
 
    output:
    m_comp
**************************************************************************************/
%macro fuzzy_comp_or(or, comp);
  sasfile &or load;
  sasfile &comp load;
  proc sql _method ;
    create table m_&comp  as
    select a.rf_id, a.exec_dt, a.id_or, a.std_firm1 as or_std_name, a.or_name,
          b.GVKEY, b.std_nameL as crsp_std_name, b.HCONM, b.comnam,
          compged(a.std_firm1, b.std_nameL) as dist_score
      from  &or as a
        left join &comp as b
         on a.or_sub = b.sub_name
      where (CALCULATED dist_score<=120   AND  a.len_std_or>4 AND b.len_name>4) OR
           (a.std_firm1 = b.std_nameL) ;
  quit;
run;
sasfile &or close;
sasfile &comp close;
%mend fuzzy_comp_or;


%macro fuzzy_comp_or_SPEDIS(or, comp);
sasfile &or load;
sasfile &comp load;
proc sql _method ;
    create table m_&comp  as
    select a.rf_id, a.exec_dt, a.id_or, a.std_firm1 as or_std_name, a.or_name,
          b.GVKEY, b.std_nameL as crsp_std_name, b.HCONM, b.comnam,
          SPEDIS(a.std_firm1, b.std_nameL) as dist_score
    from  &or as a
    left join &comp as b
    on a.or_sub = b.sub_name
    where (CALCULATED dist_score<=5   
            AND  
	  a.len_std_or>4 
	    AND 
	  b.len_name>4) OR
        (a.std_firm1 = b.std_nameL) ;
    quit;
run;
sasfile &or close;
sasfile &comp close;
%mend fuzzy_comp_or_SPEDIS;

/***********************************************************
* March 2, 2024 Saturday
* V2: does not consider the length of names, 
*   will filter the length of names on the ouput merged files

* Try 1: only spedis:9
* Try 2: spedis <=15 compged <=200
********************************************************/

%macro fuzzy_comp_or_SPEDIS_v2(or, comp, 
	or_name= std_firm1, 
	comp_name = std_nameL, 
	up_spedis_score=15, 
	up_gl_score=230);
   sasfile &or load;
   sasfile &comp load;

   proc sql _method;
   create table m_&comp  as
   select a.rf_id
         ,a.exec_dt
	 ,a.id_or
	 ,a.&or_name as or_std_name
	 ,a.or_name
	 ,b.GVKEY
	 ,b.&comp_name as crsp_std_name
	 ,b.HCONM, b.comnam,
          SPEDIS(a.&or_name, b.&comp_name) as spedis_score, 
          compged(a.&or_name, b.&comp_name) as gl_score,
		  a.len_std_or as len_or,
          b.len_name as len_crsp
   from  &or as a
   left join &comp as b
   on a.or_sub = b.sub_name  
   where (CALCULATED spedis_score<=&up_spedis_score  AND 
          CALCULATED gl_score<=&up_gl_score  AND 
          a.len_std_or>4 AND b.len_name>4) OR
          (a.std_firm1 = b.std_nameL) ;
     quit;
 run;
sasfile &or close;
sasfile &comp close;
%mend fuzzy_comp_or_SPEDIS_v2;


%macro exact_comp_or(or, comp);
options msglevel=i fullstimer;

options cpuCount = actual;
sasfile doc.&or load;
sasfile &comp load;
proc sql _method ;
   create table m_&comp  as
   select a.rf_id, a.exec_dt, a.id_or,   a.std_firm1 as or_std_name, a.or_name,
          b.GVKEY, b.std_nameL as b_std_name, b.HCONM, b.comnam,
           
   from  doc.&or as a
   left join &comp as b
   on a.std_firm1 = b.std_nameL
  where a.   
    ;
  quit;
 run;
%mend exact_comp_or;


********************************************************************************;
*set nonmatched_comp
*
*
* Divid the COMP names into several small files *;
********************************************************************************;
%macro split_non_matched(all_data =or_name_orig 
                         ,std_firm = std_firmL
                         ,prefix = or
                        );
	data &prefix._name_A_C
         &prefix._name_D_G
         &prefix._name_H_L
         &prefix._name_M_R
         &prefix._name_S_Z
         &prefix._others;
    set &all_data;
    
     %* %if &first_letter Eq %then blocking = &first_letter;    
     %* %else  blocking = substr(&std_firm, 1,1);
     %* blocking= &first_letter;
     blocking = upcase(substr(&std_firm, 1,1));
	  &prefix._sub = substr(&std_firm,1,3);
      len_name = length(&std_firm);
   if blocking LE 'C' then output &prefix._name_A_C;
	 else if blocking GE 'D' AND blocking LE 'G' then output &prefix._name_D_G;
	 else if blocking GE 'H' AND blocking LE 'L' then output &prefix._name_H_L;
	 else if blocking GE 'M' AND blocking LE 'R' then output &prefix._name_M_R;
	 else if blocking GE 'S' AND blocking LE 'Z' then output &prefix._name_S_Z;
	 else output &prefix._others;
    drop blocking ;
    list;
run;
%mend split_non_matched;
 /*%*%SYSMACDELETE split_non_matched  */

%macro contents(table);
Title "Varibales in table &table";
proc contents data= &table;
run;
%mend contents;
%macro listVars(table);
Title "Varibale list in table &table";
proc contents data= &table short varnum;
run;
%mend listVars;
%macro unique_values(table, var_name1=GVKEY, var_name2=CONM);
Title "The count of unique variable values";
proc sql;
select count(distinct &var_name1) as gvkey_N from  &table
union
select count(distinct &var_name2) as conm_N from &table;
quit;
run;
%mend unique_values;
