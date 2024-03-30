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
