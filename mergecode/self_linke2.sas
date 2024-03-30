/*
Feb 05,
"C:\Users\lihon\OneDrive\Documents\stn_unique_or_dedupe.dta" 
C:\Users\lihon\Downloads\stn_unique_or_dedupe_co.dta

This file did self_join
*/
options nolabel;
options msglevel=i FULLSTIMER;
Options THREADS;
options cpuCount = actual;

Proc options option=cpucount;
Run;

option MEMSIZE=85899345920;
options insert=( MEMSIZE="85899345920");

proc options option=memsize;
run;

proc options group = memory;
run;

proc setinit noalias; run;
proc product_status; run;

libname doc "C:\Users\lihon\Downloads";

PROC IMPORT OUT= WORK.OR_NAME_orig 
     DATAFILE= "C:\Users\lihon\Downloads\stn_unique_or_dedupe_co.dta" 
     DBMS=STATA REPLACE;
RUN;

PROC DATASETS;
  COPY IN = work 
       OUT = doc;
  select OR_NAME_orig ;
RUN;

proc contents data = doc.OR_NAME_orig;
run;


proc contents data = or_name;
run;
*************************************************************************************;
/*sasfile doc.OR_NAME_orig load; */
*170,073 obs                                   *;
*************************************************************************************;
data or_name;
  set  OR_NAME_orig(
                  keep = rf_id id_ee id_or 
                         or_name std_firm std_firm1 dba fka entity entity_1 exec_dt
                );
    or_sub=substr(std_firm1, 1, 3);  
    len_std_or = length(std_firm);
    len_std_or1 = length(std_firm);
    exec_y= year(exec_dt);
run;
proc sort data=or_name out=or_name;
by or_sub;
run; 
/******************************************************************
* Divide the input unique_or data into subsets 
*****************************************************************/

/*********************************************;
* Sub1: A_J last record *;
*; 
data or_name_A_J82098;
    set or_name(obs=82098);
run;

*Sub2: K_O *;
data or_name_K_O109896;
    set or_name(FirstObs=82099 obs=109895);
run;

*Sub3: R_P *;
data or_name_P_R130938;
   set or_name(FirstObs=109896 obs=130938);
run;

*Sub4: R_P *;
data or_name_S_T157024;
    set or_name(FirstObs=130939 obs=157024);
run;
*Sub5: U_Z *;
data or_name_U_Z170073;
    set or_name(FirstObs=157025 obs=170073);
run;
**************************************************/
data or_name_A_J82098Ex
     or_name_K_O109896Ex
     or_name_P_R130938Ex
     or_name_S_T157024Ex
     or_name_U_Z170073Ex others;
     set or_name;
	  blocking = substr(std_firm, 1,1);
	  exec_year = year(exec_dt);
   if blocking LE 'J' then output or_name_A_J82098Ex;
	else if blocking GE 'K' AND blocking LE 'O' then output or_name_K_O109896Ex;
	else if blocking GE 'P' AND blocking LE 'R' then output or_name_P_R130938Ex;
	else if blocking GE 'S' AND blocking LE 'T' then output or_name_S_T157024Ex;
	else if blocking GE 'U' AND blocking LE 'Z' then output or_name_U_Z170073Ex;
	else output others;
    drop blocking sub_std_name;
	run;

proc sql;
  create index or_sub 
          on or_name_A_J82098(or_sub)      ;
quit;

proc contents data =or_name_A_J82098;
run;

proc contents data = or_name_U_Z170073;
run;

proc sql;
  delete from or_name_K_O109896
         where  id_or =127273;
run;

/*
a macro to subset SAS name data
*/
%sort_d(or_name_A_J82098)
%merge_sub(or_name_A_J82098)
%merge_sub_sql(or_name_A_J82098);


proc sql;
  drop table or_sub1, or_sub2, or_sub3, or_sub1111, or_sub1112;
  quit;
run;

proc datasets lib=work nolist nowarn;
  delete or_sub:;
run;


%macro sort_d(subset);
   proc sort data= &subset;
        by or_sub;
%mend sort_d;
 
%macro create_index(subset);
     proc sql;
      create index or_sub 
              on &subset(or_sub);
      quit;
%mend create_index;


/*SELF Merge:
subset self join */
%macro merge_sub_sql(subset);
  sasfile &subset load;
  proc sql _method ;
     create table m_&subset  as
     select a.rf_id, a.exec_dt, a.id_or as a_idor, b.id_or as b_idor,  a.std_firm1 as
     a_name, b.std_firm1 as b_name,
             compged(a.std_firm1, b.std_firm1) as dist_score
   from  &subset as a
             inner join 
	 &subset as b
   on a.or_sub = b.or_sub
   where  CALCULATED dist_score<20 AND a.len_or>5
   order by a.id_or;
  quit;
 run;
sasfile &subset close;
%mend merge_sub_sql;

%macro run_it(subset);
 %sort_d(&subset)
 %create_index(&subset)
 %merge_sub_sql(&subset)
%mend run_it;


%macro clustered(merged);
  proc sql;
	create table clus_&merged as
	select a_idor, b_idor, a_name, b_name, dist_score
	 from  &merged
	where a_idor ^= b_idor AND a_idor < b_idor;
  quit;
%mend clustered;


%do v= or_name_K_O109896 or_name_P_R130938
       or_name_S_T157024  or_name_U_Z170073

%put WARNING: "or_name_K_O109896 1";

Title "or_name_K_O109896 1";
%run_it(or_name_K_O109896)

%put ERROR: "or_name_P_R130938 2";
Title "or_name_P_R130938 2";
%run_it(or_name_P_R130938)

%put WARNING: "or_name_S_T157024 3";
Title "or_name_S_T157024 3";
%run_it(or_name_S_T157024)

%put WARNING: "or_name_U_Z170073 4";
Title "or_name_U_Z170073 4";
%run_it(or_name_U_Z170073)

%do v= or_name_a_j82098
       or_name_K_O109896 
       or_name_P_R130938
       or_name_S_T157024  
       or_name_U_Z170073

%clustered(M_or_name_a_j82098)
%clustered(m_or_name_K_O109896)
%clustered(m_or_name_P_R130938)
%clustered(m_or_name_S_T157024)
%clustered(m_or_name_U_Z170073)


data repeated_or;
set Clus_m_or_name: ;
run;

PROC DATASETS;
  COPY IN = work OUT = doc;
  select repeated_or ;
RUN;
* 
libname doc "C:\Users\lihon\Downloads";
libname or_crsp_merged "C:\Users\lihon\Downloads\or_crsp_merged";
or_crsp_merged
PROC DATASETS;
COPY IN = work OUT = or_crsp_merged NOLIST;
select or_name_a_j82098
       or_name_K_O109896 
       or_name_P_R130938
       or_name_S_T157024  
       or_name_U_Z170073 ;
RUN;
