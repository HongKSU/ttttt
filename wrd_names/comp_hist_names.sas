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
/*
%let table=wrds_dow.compustat_names;


%unique_values(&table, gvkey, conm) 
*Gvkey:53523 , names: 53528 ;
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
  label  ipo_y  = "IPO year";
  label  global = "global_company";
  format global lbl_global.;
run;

%let table=Comp_all;
%unique_values(&table, gvkey, conm)    *Gvkey:110512=53523 , names: 125643=53528 ;
%contents(&table) 

 */
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
/*
%varList(&table)
proc sql;
  create index gvkey_conm on Comp_all(gvkey, conm);
quit;
run;
*/
/* conm
         ,conmL
gvkey fic loc costat idbflag city naics sic year1 year2 county state ipodate global start_year end_year ipo_y
*/


/*
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
       , loc as country
       from &table
       group by gvkey, conm;
 quit;
 proc sql;
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
       , loc as country
       from  _com_all_names
       group by gvkey, conmL
;
quit;

proc sql;
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
*/
*Stata do standardization and cleasing;

*D:\Research\patent\data\wrds_names\unique_crspHist_remove_fund_v2.do;

* load standardized com_all_names*;
* problems with com_all_names_unique_std:          
* There are unique gvkey: 102,546
* Total records is:       114,427, it implies one gvkey (11,881)might have many different names. For example
*             conm                    conmL                              gvkey   dup
* AMERICAN AIRLINES GROUP INC        AMERICAN AIRLINES GROUP INC         001045  1
* AMR CORP/DE                        AMR CORP.                           001045  2
* ASA LTD                            ASA BERMUDA LTD                     001062  1
* ASA GOLD AND PRECIOUS METALS       ASA GOLD AND PRECIOUS METALS LTD    001062  2
 COGNAEDUCACAO S.A                   COGNAEDUCACAO S.A                   286431  1
 COGNA EDUCACAO S A                  COGNA EDUCACAO S A                  286431  2
 KROTON EDUCACIONAL SA               KROTON EDUCACIONAL SA               286431  3

* Number of unique values of std_conmL gvkey is  112,534
* Number of records is  114,427
* There are many names( the same name have different gvkeys), for example
gvkey   std_conmL    
155340  360NETWORKS  
134453  360NETWORKS 
028554  3DICON   
152888  3DICON  
035995  4FRONT VENTURES  
033237  4FRONT VENTURES  
186661  A CLEAN SLATE     
063912  A CLEAN SLATE    


* missing of loc (headquarter location)  :631
* missing of fic (incorporated location) :1,483



PROC IMPORT OUT= WORK.com_all_names_unique_std 
            DATAFILE= "D:\Research\patent\data\wrds_names\com_all_names_unique_std.dta" 
            DBMS=STATA REPLACE;

RUN; *115112 observations and 21 variables;

/* 114427 observations and 22*/

%contents(com_all_names_unique_std)

 
         /*
%let stateAbb =AB   AK   AL   AR   AZ   BC   CA   CO   CT   DC   DE  FL   GA   GU   HI 
IA   ID   IL   IN   KS   KY   LA MA   MB   MD   ME   MI   MN   MO   MS   MT   NB   NC 
ND   NE   NF   NH   NJ   NM   NS   NV   NY   OH   OK   ON   OR   PA   PE   PR   QC  
RI   SC   SD   SK   TN  TX   UT   VA   VI   VT   WA   WI   WV   WY 



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

 
*/
/**/

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
/*June 24,2024
NOTE: There were 114427 observations read from the data set
      WORK.COM_ALL_NAMES_UNIQUE_STD.
NOTE: The data set WORK.COMP_AC has 27044 observations and 24 variables.
NOTE: The data set WORK.COMP_DG has 18112 observations and 24 variables.
NOTE: The data set WORK.COMP_HL has 17511 observations and 24 variables.
NOTE: The data set WORK.COMP_MR has 25215 observations and 24 variables.
NOTE: The data set WORK.COMP_SZ has 26545 observations and 24 variables.
NOTE: The data set WORK.COMP_OTHERS has 0 observations and 24 variables.
*/
