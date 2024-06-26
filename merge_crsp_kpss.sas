
/*
The Name ending date in CRSP does not work
need to regenerage a ending date
*/
libname crsp "D:\Research\patent\data";
libname data "D:\Download";


* %let Tmp1 = data; 

%INCLUDE "C:\Users\lihon\Downloads\loadKPSS_Stata_data.sas";



/*
proc sql;
select permno, permco, COMNAM, year from Data.Crsp_hist where permno =10001;
quit;
run;
proc sql;
select permno, permco, COMNAM, year from Data.Crsp_hist where permno =14592
order by year;
quit;
run;
*/


/*
patent_num  
5154697
5401072
5737189
6115680

permno
77487
79420
84631
86902
*/

/*
* Check 3COM, which has merger and name chagne
*
proc sql;
select permno, permco, COMNAM, year from Data.Crsp_hist where permno =22592;
quit;
run;

proc sql;
select permno, permco, COMNAM, year from Data.Crsp_hist where permno =10216;
quit;
run;
proc sql;
select permno, permco, COMNAM from Data.Crsp_hist where permno =24942;
quit;
run;
proc sql;
select * from Data.Crsp_hist where missing(COMNAM);
quit;
run;
proc sql;
select permno, permco, COMNAM, year,  date from Data.Crsp_hist where permno =23579;
quit;
run;


proc sql;
select  permno, issue_date from kpss2022 where patent_num  ="6649529";
quit;
run;

proc sql;
select permno, permco, COMNAM, year,  date from Data.Crsp_hist where permno =59328;
quit;
run;

*
Reset Ending date:
 start_year = by name start year and 
 end_year = the year which names last apear
*

 
 
*
proc sql;
create table  temp_crsp_hisp as
    select *, min(year) as  start_year, max(year) as end_year
    from  Data.Crsp_hist
    group by permno, permco, COMNAM;
quit;
run;
*
/*--
How about match by year?

Here We keep original date rather than year to keep the match at a finer degree
*/
proc sql;
create table  temp_crsp_hisp as
    select *
           , min(date) as  start_year format= MMDDYY10. 
           ,max(date)  as end_year format= MMDDYY10.
    from  Data.Crsp_hist
    group by permno, permco, COMNAM;
quit;
run;

/*
proc sql;
select permno, permco, COMNAM, year ,start_year, from Data.Crsp_hist where permno =14592
order by year;
quit;
run;

proc sort data= temp_crsp_hisp;
by permno year;
run;
proc sql;
select permno, permco, COMNAM, end_year,start_year,NAMEENDT from temp_crsp_hisp where permno =24942;
quit;
run;
proc sql;
select permno, permco, COMNAM, start_year, end_year from temp_crsp_hisp where permno =10216;
quit;
run;
*/
/* Total CRSP
4927531*
proc sql;
select count (*) from temp_crsp_hisp ;
quit;
*/
/*Total Name missing 
35001
*/
/*
proc sql;
select count (*) from temp_crsp_hisp  where missing(COMNAM);
quit;
run;
*/

/* Delete the missing records in CRSP_HIST */
/* Otherwise the data after remove duplicates in unique sort will have empty COMNAM
which brought confusing info in the match with KPSS
*/

data temp_crsp_hisp; 
/* read in: 4927531
* out: 4892530 */
set temp_crsp_hisp ;*(where= (!missing(COMNAM));
 *if !missing(COMNAM);
 *if COMNAM NE missing(COMNAM);
where not missing(COMNAM);
run;

/*
proc sql;
select count (*) from temp_crsp_hisp_unique;
run;
*/
/* The following data has empty COMNAM */

proc sort data = temp_crsp_hisp 
	  out = temp_crsp_hisp_unique nodupkey;
  by permno permco COMNAM;
run;

/*
proc sql;
select permno, permco, COMNAM, end_year,start_year from temp_crsp_hisp_unique where permno =24942;
quit;
run;

proc sql;
select permno, permco, COMNAM,start_year, end_year  from temp_crsp_hisp_unique where permno =10216;
quit;
run;
 
 */
/* Copy the non duplicate crsp to crsp lib
and rename the one as crsp1925_2022 
*/
PROC DATASETS;
   COPY IN = work OUT = crsp;
   select temp_crsp_hisp_unique ;
RUN;
/*
bysort  PERMNO PERMCO: gen year_end = year[_n+1]

*/
/* Rename temp_crsp_hisp_unique as  crsp1925_2022

delete  crsp1925_2022 if it exist in CRSP LIB
*/
proc datasets nolist ;
 delete crsp1925_2022 ;
quit;
/*
proc datasets library=work;
    change temp_crsp_hisp_unique=crsp1925_2022;
run;
*/
data crsp1925_2022;
  set crsp.temp_crsp_hisp_unique;
run;
/*
proc sql;
select * from crsp1925_2022 where missing(COMNAM);
quit;
run;
*/

/*
proc sql;
 create table kpss_crsp as
 select Kpss2022.*, crsp1925_2022.COMNAM, crsp1925_2022.permco, crsp1925_2022.year, crsp1925_2022.end_year,crsp1925_2022.start_year  from crsp1925_2022, Kpss2022
 where crsp1925_2022.permno = Kpss2022.permno  AND year(Kpss2022.issue_y) GE start_year&  year(Kpss2022.issue_y) <=crsp1925_2022.end_year;
 quit;
 run;
*/
/*
proc sql;
select count(distinct permno) from kpss2022;
quit;
run;

proc sql;
select count(distinct permno) from crsp1925_2022;
quit;
run;

*/
/*
Strict date compare might miss some records, so we allow issue days 30 days before first observation
and 30 days after the date of last observation*
 proc sql;
 create table kpss_crsp as
 select Kpss2022.*, crsp1925_2022.COMNAM, crsp1925_2022.permco, crsp1925_2022.year, crsp1925_2022.end_year,crsp1925_2022.start_year  from crsp1925_2022, Kpss2022
 where crsp1925_2022.permno = Kpss2022.permno  AND Kpss2022.issue_y >= crsp1925_2022.start_year AND  Kpss2022.issue_y <=crsp1925_2022.end_year;
 quit;
 run;
*/


proc sql;
  create table kpss_crsp2 as
    select Kpss2022.*
           , crsp1925_2022.COMNAM
	   , crsp1925_2022.permco
	   , crsp1925_2022.year
	   , crsp1925_2022.end_year
	   , crsp1925_2022.start_year
    from crsp1925_2022, Kpss2022
     where crsp1925_2022.permno = Kpss2022.permno  
       AND Kpss2022.issue_y +30 >= crsp1925_2022.start_year 
       AND  Kpss2022.issue_y-30 <=crsp1925_2022.end_year;
quit;
run;


/* 
proc sql; *8,547;
select  count( distinct permno) from kpss_crsp2;
quit;
run;
proc sql; *8,547;
select  count( distinct permno) from Tmp2.kpss_crspv2;
quit;
run;
proc sql; *3,159,359;
select  count( *) from Tmp2.kpss_crspv2;
quit;
run;
 proc sql; *3,221,591;
 select count(*) from kpss_crsp;
 quit;
 run;
  proc sql;
 select count(*) from KPSS2022;
 run;
  proc sql;
 select count(distinct permno) from KPSS2022;
 run;
 proc sql;
 select count(*) from Data.Crsp_hist;
 quit;
 run;

 proc sql;
select permno, permco, COMNAM, NAMEENDT from Data.Crsp_hist where permno =10275;
quit;

PROC DATASETS;
COPY IN = work OUT = crsp;
select crsp1925_2022 Kpss_crsp2;
RUN;
proc sql; *8,547;
select  * from kpss_crsp where
patent_num = "2665705" AND	permno = 10006;
quit;
run;


 proc sql; *3,221,591; 3,212,278
 select count(*) from kpss_crsp where missing(COMNAM);
 quit;
 run;
*/
 /*
patent_num permno issue_date filing_date xi_nominal xi_real cites issue_y Company Name PERMCO year end_year start_year 
2665705 10006 19540112 19501229 0.059525 0.217588 0 01/12/1954 A C F INDUSTRIES INC 22156 1956 1984 1954 
2665705 10006 19540112 19501229 0.059525 0.217588 0 01/12/1954 AMERICAN CAR & FDRY CO 22156 1934 1954 1925 
 */
/*
proc sql;
select *, year(start_year) as s_year, year(end_year) as e_year from crsp1925_2022 where permno in (77487,
79420,
84631,
86902);
quit;
run;

proc sql;
select *, year(start_year) as s_year, year(end_year) as e_year from crsp1925_2022 where permno in (21338,
23579, 25419);
quit;
run;
proc sql; *8,547;
select  * from kpss_crsp2 where
patent_num = "1736001" AND	permno = 14592;
quit;
run;
 */
proc sql;
 create table kpss_crsp_dup as
  select * from  kpss_crsp2
   group by patent_num, permno, issue_date
having count(*) gt 1;


 proc sql;
 create table kpss_crsp_NO_dup as
  select * from  kpss_crsp2
  group by patent_num, permno, issue_date
  having count(*) EQ 1;
quit;
run;

/*
proc sql; 603
 select count(distinct permno) from kpss_crsp_dup;
quit;
run;

proc sql;  
 select count(distinct permno) from kpss_crsp_No_dup;
run;

Title "Permno which are duplicated ";
   proc sql;  
select  * from kpss_crsp_dup where permno = 14592; 
run;

proc sql;  
 select  * from kpss_crsp_No_dup where permno = 14592; 
run;
*/
/*
PROC DATASETS;
COPY IN = work OUT = crsp;
select crsp1925_2022 Kpss_crsp;
RUN;
*/
PROC DATASETS;
COPY IN = work OUT = crsp;
  select crsp1925_2022 
         Kpss_crsp2 
	 kpss_crsp_No_dup 
	 kpss_crsp_dup;
RUN;

data kpss_dup_names;
set crsp.kpss_crsp_dup (keep = patent_num 
                               permno 
			       issue_y);
run;

proc sort data = kpss_dup_names 
	  out = crsp_dup_unique nodupkey;
by permno ;
run;
proc sort data = kpss_dup_names 
          out= kpss_dup_unique nodupkey;
by   patent_num permno issue_y ;
run;

/* select the CRSP source */

proc sql;
 create table crsp_overlap_time_names as
 select a.* 
   from data.crsp_hist a
        inner join 
       crsp_dup_unique b
   on a.permno = b.permno
   order by a.permno, date;
quit;
run;

/*select the KPSS 2022 data source */



/* Merge the duplicates one by time
crsp: date--NAME date
kpss: issue time
*/

proc sql;
 create table kpss_crsp_part2 as
 select kpss_dup_unique.*
        , a.COMNAM
        , a.permco
	, a.date
	, intck('day', kpss_dup_unique.issue_y, a.date) as diff_days
  from crsp_overlap_time_names a, kpss_dup_unique
    where a.permno = kpss_dup_unique.permno  
having abs(diff_days) <15.5;
quit;
run;

/* The difference in days can be negative
the diff is numeric second
the diff can be 14,-14
proc sql;
 create table kpss_crsp_part2 as
 select kpss_dup_unique.*, a.COMNAM, a.permco, a.year
  from crsp_overlap_time_names a, kpss_dup_unique
 on a.permno = kpss_dup_unique.permno  
having kpss_dup_unique.issue_y -a.date<183;
quit;
run;
patent_num	permno	    issue_y	    COMNAM	                  PERMCO	DATE	diff_days	dup
8116297	    33452	       14feb2012	ERICSSON	                1577	29feb2012	15	1
8116297	    33452	       14feb2012	ERICSSON L M TELEPHONE CO	1577	31jan2012	-14	1
I will do the detection in Stata.
*
 duplicates tag patent_num permno issue_y, gen(dup)
 
. sort patent permno issue COM

. drop if dup!=0 & diff_days <0
(84 observations deleted)

. count
  7,482

*/
proc sql;
  create table kpss_crsp2_dup as
   select * 
   from  kpss_crsp_part2
   group by patent_num, permno, issue_y
having count(*) gt 1;
proc sql;
  create table kpss_crsp2_NO_dup as
  select * from  kpss_crsp_part2
  group by patent_num, permno, issue_y
  having count(*) EQ 1;
quit;
run;

/*
proc sort data=kpss_crsp_part2 out= part2_Nodup_unique nodupkey;
by permno ;
run;
proc sort data=kpss_crsp_part2 out= part2_dup_unique nodupkey;
by   patent_num permno issue_y ;
run;
*/
proc sql;
 create table kpss_crsp2_dup_remove as
  select * from  kpss_crsp2_dup
   where diff_days GE 0;
  quit;
run;

/* merge the no dupe and dup removed dataset*/

data kpss_crsp_NO_dup_part2;
 set kpss_crsp2_dup_remove 
     kpss_crsp2_NO_dup;
run; 

/* merge with part one no dup */
data kpss_crsp_full;
    set crsp.kpss_crsp_no_dup(keep = patent_num 
                                     permno issue_y 
				     COMNAM permco)
        kpss_crsp_NO_dup_part2(drop = diff_days); 
run;

proc sql;
  select count( distinct patent_num) from  kpss_crsp_full;
quit;
run;

PROC DATASETS;
  COPY IN = work OUT = crsp;
  select kpss_crsp_full;
RUN;

/* *ee_or_document_kpss.dta" ;  has some problem*/
PROC IMPORT OUT= WORK.or_ee_kpss 
            DATAFILE= "D:\Research\patent\data\merged_all_v2.dta"
            DBMS=STATA REPLACE;

RUN;

data kpss;
  set Or_ee_kpss;
  issue_y = input(put(issue_date,8.), yymmdd8.) ;
 *format issue_y weekdate9.    Tuesday;
  format issue_y date9.;
run;

/* merge transaction with KPSS recognized */

proc sql;
  create table   kpss22 as
  select patent_assigne.*, crsp.COMNAM 
    from  kpss as patent_assigne
      left join 
       kpss_crsp_full as crsp
  on patent_assigne.patent_num = crsp.patent_num
  AND  patent_assigne.issue_y = crsp.issue_y;
  quit;
run;

PROC EXPORT DATA= WORK.Kpss22 
            OUTFILE= "C:\Users\lihon\Downloads\KPSS_CRSP_OR_EE.dta" 
            DBMS=STATA REPLACE;
RUN;


data kpss_crsp_full;
 set TMP1.kpss_crsp_full;
 run;

Title "Total records in KPSS_CRSP";
proc sql;
select count(*) from kpss_crsp_full;
quit;
run;

Title "Total distinct patent records in KPSS_CRSP";
proc sql;
select count (distinct patent_num ) from kpss_crsp_full;
quit;
run;

Title "Total distinct permno records in KPSS_CRSP";
proc sql;
select count (distinct permno ) from kpss_crsp_full;
quit;
run;
