/*12345678901234567890123456789012345678901234567890123456789012345678901234567890;


libname wrds_db "D:\Research\patent\data\wrds_names";
%let wrds = wrds-cloud.wharton.upenn.edu 4016;
signon wrds username = hli5 password =_PROMPT_;
Lihong123654;
*/
/*Log out of WRDS.*/
* signoff;

/********************************************************************************;
Downlaod data from WRDS
subsidiary data:
CRSP:


rsubmit;

proc download data= SUBS.parent_sub_name_only_stacked out=wrds_db.parent_sub_name_only_stacked;
run;
endrsubmit;


rsubmit;
proc download data= SUBS.CRSP_NAMES out=wrds_db.crsp_names;
run;
endrsubmit;
*/
/* Download data */
/*
rsubmit;

proc download data= SUBS.CRSP_NAMES out=wrds_db.crsp_names;
run;
endrsubmit;

*/
/*crsp.comhist*/
rsubmit;

proc download data= Crsp.COMPHIST out=wrds_db.crspHist;
run;
endrsubmit;


proc contents data = wrds_db.crsp_names varnum;
run;

proc sort data = wrds_db.crsp_names;
by permco comnam;
run;
proc freq data = wrds_db.crsp_names;
table shr
data In_Use_crsp_names;
set wrds_db.crsp_names(keep=permco comnam);
comnam1 = strip(comnam);
run;


/*44,723 without trim leading/tail spaces*/
PROC SORT DATA=In_Use_crsp_names
 OUT=unique_crsp_names_nodupe
 NODUPRECS;
 BY  comnam1 permco;  
RUN ;

proc sort data = unique_crsp_names_nodupe;
by comnam1;
run;

proc sort data = unique_crsp_names_nodupe;
by comnam1;
run;



data crsp_hist;
 set wrds_db.crspHist(keep =GVKEY shrcd HADD: HCITY HCOSTAT HCOUNTY HINCORP HNAICS HCONM HCONML);
 comnam = strip(HCONM);
run; 

proc contents data = crsp_hist;
run;

PROC SORT DATA=crsp_hist
 OUT=uniq_crsp_hist
 NODUPRECS ;
 BY   comnam gvkey;  
RUN ;

proc sql;
  Title "Unique records";
  select count(*) from uniq_crsp_hist;
  Title "Unique company names";
  select count(distinct comnam) from uniq_crsp_hist;
  Title "Unique GVKEYs";
  select count(distinct gvkey) from uniq_crsp_hist;
quit;



proc sql; *69,209; 
  Title "Unique GVKEYs * CONNAM";
  select count(distinct gvkey|| Comnam) from uniq_crsp_hist;
  quit;
proc sql;
 create table _trashit_ as  
 select comnam from uniq_crsp_hist
 where HNAICS = "522320";
quit;

proc sql;
 create table _atrashit_ as  
 select distinct comnam from _trashit_;
quit;
 
proc sql;
 create index permco_comnam ();
 quit;


/*Close the connection */
*signoff;

proc contents data = Unique_crsphist;
run;

data UniqueCRSPHist;
set  doc.OR_NAME_orig(keep=rf_id id_ee id_or std_firm std_firm1 dba fka entity entity_1 exec_dt);
or_sub=substr(std_firm1, 1, 3);  
len_or = length(std_firm1);
run;
/* Subsidiaries data*/
