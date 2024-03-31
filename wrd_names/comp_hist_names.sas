
options mlogic MPRINT;
options cpuCount = actual;
options msglevel=i fullstimer;
 
options nolabel;

libname wrds_dow "D:\Research\patent\data\wrds_names";
/*
proc contents data="C:\Users\lihon\OneDrive - Kent State University\aaaa\COMP\comp_names_all.sas7bdat" varnum;
 
run;

proc print data="C:\Users\lihon\OneDrive - Kent State University\aaaa\COMP\comp_names_all.sas7bdat";
where gvkey in ('178855' '145512');
run;
****
%let path=D:\Research\patent\data\wrds_names;

proc contents data= wrds_dow.crsphist;
run;
proc sql;
select count(distinct GVKEY) as gvkey_N from wrds_names.crsphist 
union
select count(distinct hconm) as conm_N from wrds_names.crsphist;
quit;
run;
*/
/********************************


proc contents data= wrds_dow.compustat_names;
run;
*/
%let table=wrds_dow.compustat_names;


%unique_values(&table) *Gvkey:53523 , names: 53528 ;
%let table = wrds_dow.NoDate_compustat_or_names;
%contents(&table) *Gvkey:53523 , names: 53528 ;

proc format library=work;
value lbl_global
    0 = 'COMP_HIST'
    1 = 'global_comp'
;
run;
data Comp_all;
  set "C:\Users\lihon\OneDrive - Kent State University\aaaa\COMP\comp_names_all.sas7bdat";
  ipo_y = year(ipodate);
  label ipo_y = "IPO year";
  label global = "global_company";
  format global lbl_global.;
run;

%let table=Comp_all;

%contents(&table) 
%unique_values(&table) *Gvkey:110512=53523 , names: 125643=53528 ;
 
/***

145512*
PROC SQL;
select * from &table where gvkey='145512' and conm="ABRAXIS BIOSCIENCE INC";
quit;
*

proc sql;
DELETE FROM &table
 WHERE gvkey='145512' and conm="ABRAXIS BIOSCIENCE INC";
QUIT;
RUN;
*/

%listVars(&table)
proc sql;
  create index gvkey_conm on Comp_all(gvkey, conm);
quit;
run;

/* conm
         ,conmL
gvkey fic loc costat idbflag city naics sic year1 year2 county state ipodate global start_year end_year ipo_y
*/

proc sql   ;
  create table _com_all_names as
  select conm 
       ,conmL 
       ,gvkey        
       ,fic 
       ,loc 
       ,costat 
       ,idbflag 
       ,city 
       ,naics 
       ,sic   
       ,county 
       ,state 
       ,IPO_y 
       ,start_year
       ,end_year
       ,min(start_year) as start_y
       ,max(end_year) as end_y
       ,global
       from &table
       group by gvkey, conm;
 
  create table com_all_names as
   select conm 
       ,conmL 
       ,gvkey        
       ,fic 
       ,loc 
       ,costat 
       ,idbflag 
       ,city 
       ,naics 
       ,sic   
       ,county 
       ,state 
       ,IPO_y 
       ,start_year
       ,end_year
       ,min(start_year) as start_y
       ,max(end_year) as end_y
       ,global
       from  _com_all_names
       group by gvkey, conmL
;
drop table _com_all_names;
     quit;
run;

proc sort data = com_all_names out= com_all_names_unique NODUPKEY;
by gvkey conm start_y end_y;
run;
proc sort data = com_all_names_unique out= com_all_names_unique NODUPKEY;
  by gvkey conmL start_y end_y;
run;
proc datasets library=work;
   copy in=work out=wrds_dow ;
          select com_all_names_unique/memtype=data;
run;

*Stata do standardization and cleasing;

*D:\Research\patent\data\wrds_names\unique_crspHist_remove_fund_v2.do;
/* load standardized com_all_names*/
          
PROC IMPORT OUT= WORK.com_all_names_unique_std 
            DATAFILE= "D:\Research\patent\data\wrds_names\com_all_names_unique_std.dta" 
            DBMS=STATA REPLACE;

RUN; *115112 observations and 21 variables;

%contents(com_all_names_unique_std)

 
         /*
%let stateAbb =AB   AK   AL   AR   AZ   BC   CA   CO   CT   DC   DE  FL   GA   GU   HI   IA   ID   IL   IN   KS   KY   LA MA   MB   MD   ME   MI   MN   MO   MS   MT   NB   NC ND   NE   NF   NH   NJ   NM   NS   NV   NY   OH   OK   ON   OR   PA   PE   PR   QC   RI   SC   SD   SK   TN  TX   UT   VA   VI   VT   WA   WI   WV   WY 
data stateAbb_;

         AB |      1,559       18.05       18.05
         BC |      3,124       36.17       54.22
         MB |         64        0.74       55.03
         NB |         17        0.20       55.23
         NF |         23        0.27       55.49
         NS |         99        1.15       56.64
         ON |      2,957       34.24       90.92
         PE |          2        0.02       90.96
         QC |        716        8.29       99.25
         SK |         62        0.72       99.97
         
*AB  BC MB NB NF NS ON PE QC  SK;

WRONG Code
  CA CO MA NY PA  TX WA

 



length comp_stcode $2;
input comp_stcode    $   @@;
datALINES;
AK  AL  AR  AZ  CA  CO  CT  DC  DE  FL  
GA  GU  HI  IA  ID  IL  IN  KS  KY  LA  
MA  MD  ME  MI  MN  MO  MS  MT  NC  ND  
NE  NH  NJ  NM  NV  NY  OH  OK  OR  PA  
PR  RI  SC  SD  TN  TX  UT  VA  VI  VT  
WA  WI  WV  WY  MP  AS  UM  MH  FM  PW   
TT
;
run;
data stateAbb;
set stateAbb_;
  state_name = stnamel(comp_stcode);
run;
*/                           * com_all_names_unique_std;
%split_non_matched(all_data = com_all_names_unique_std 
                         ,std_firm = std_conmL
                         ,prefix = comp
                         )

                         /*
NOTE: There were 115112 observations read from the data set
WORK.COM_ALL_NAMES_UNIQUE_STD.
NOTE: The data set WORK.COMP_NAME_A_C has 27390 observations and 23 variables.
NOTE: The data set WORK.COMP_NAME_D_G has 18257 observations and 23 variables.
NOTE: The data set WORK.COMP_NAME_H_L has 17577 observations and 23 variables.
NOTE: The data set WORK.COMP_NAME_M_R has 25033 observations and 23 variables.
NOTE: The data set WORK.COMP_NAME_S_Z has 26855 observations and 23 variables.
NOTE: The data set WORK.COMP_OTHERS has 0 observations and 23 variables.
*/
