/*Nov 19, 2024*/
/*
%contents(mergback.or_ee_gvkey_patentid_record_dt)
 proc freq data=mergback.or_ee_gvkey_patentid_record_dt order=freq;
 table ee_country;
 where relation=1;
 run;

*/
  *Nov 19, 2024* ;
/*
 proc freq data=mergback.or_ee_gvkey_patentid_record_dt order=freq;
 table or_code;
 where relation=1;
 run;
*/
 **check dataset mergback.or_ee_gvkey_patentid**;
 ** 64, 605 non missing ee_gvkey, of which 7,871 are unique**;

/*
proc sql; 
 title "How many nonmissing ee_gvkey";
 select count(distinct ee_gvkey) from mergback.or_ee_gvkey_patentid
 where not missing(ee_gvkey);
 quit;

title ;
*/
 **check dataset mergback.or_ee_gvkey_patentid**;

/*
proc sql;
 title "How many nonmissing or_gvkey";
 select count(*) from mergback.or_ee_gvkey_patentid
 where not missing(or_gvkey);
 quit;

title ;

 **check dataset mergback.or_ee_gvkey_patentid**;
proc sql;
 title "How many nonmissing distinct or_gvkey";
 select count(distinct or_gvkey) from mergback.or_ee_gvkey_patentid_record_dt
 where not missing(or_gvkey);
 quit;
proc sql;
 title "How many nonmissing distinct or_gvkey";
 select count(distinct or_gvkey) from mergback.or_ee_gvkey_patentid_record_dt
 where   missing(permno);
 quit;

 %contents(mergback.or_ee_trans_permno_rf_id)
 proc sql outobs=25;
 title "How many nonmissing distinct or_gvkey";
 select distinct or_gvkey,  exec_year,fyear from mergback.or_ee_trans_permno_rf_id
 where   missing(permno);
 quit;

 proc sql ;
 title "How many nonmissing distinct or_gvkey";
 select count(*) from  MERGBACK.AGGMY_ALL_TRANS_EXEC_YEAR
 where   missing(permno);
 quit;


 proc sql;
 title "How many nonmissing distinct or_gvkey";
 select count(distinct or_gvkey) from  or_ee_gvkey_patentid_record_dt
 where   missing(permno);
 quit; 
 proc sql outobs=25;
 title "How many nonmissing distinct or_gvkey";
 select distinct or_gvkey,  exec_year,fyear from mergback.or_ee_trans_permno_rf_id
 where   missing(permno);
 quit;

 
proc sql;
 select lpermno, gvkey, fyear from mergback.Crsp_comp_ccm
 where gvkey in ('001000', '001002',  '001006'  '001010');
quit;
title ;

Title "relationship count";
proc freq data = mergback.or_ee_gvkey_patentid  ;
table relation/missing;
run;

 **check relational transactions :  mergback.or_ee_gvkey_patentid**;
proc sql;
 title "How many nonmissing relaiton=1";
 select count(*) from mergback.or_ee_gvkey_patentid
 where relation=1;
 quit;

title ;

proc catalog catalog=cl_macro.sasmacr;
  where 
  contents;


quit;
COPYTB
proc sql;
 describle table dictionary.catalogs;
quit;

options nolabel;
proc sql;
  select * 
    from dictionary.catalogs
    where objtype='MACRO' and libname ne "SASHELP";
quit;
*/
/*
proc sql;
 Title "missing relation but NOT missing or_gvkey";
 select count(or_gvkey) from my_all_trans
 where missing(relation) and not missing(or_gvkey);
 quit;
proc sql;
Title "Total or_gvkey with missing relation but NOT missing ee_gvkey";
 select count(or_gvkey) from my_all_trans
 where missing(relation) and  missing(ee_gvkey);

Title "Total distinct or_gvkey with missing relation but NOT missing ee_gvkey";
 select count(distinct or_gvkey) from my_all_trans
 where missing(relation) and  missing(ee_gvkey);
 quit;

 proc sql;
Title "Total or_gvkey with   relation =1";
 select count(distinct  or_gvkey) from my_all_trans
 where  relation =1;

Title "Total or_gvkey with   relation =0";
 select count(distinct or_gvkey) from my_all_trans
 where relation=0;
 quit;
*/
 proc sql;
 Title "Except all: Total or_gvkey which only has nonrelational transactions";
 select count(distinct or_gvkey) from 
 (
 select or_gvkey from my_all_trans
 where relation=0
 except all 

 select or_gvkey from my_all_trans
 where  relation =1
);
 Title "Except  : Total or_gvkey which only has nonrelational transactions";
 select count(distinct or_gvkey) from 
 (
 select or_gvkey from my_all_trans
 where relation=0
 except  

 select or_gvkey from my_all_trans
 where  relation =1
);
quit;
/* Second version of aggregation all trans by exec_year, not fyear (which has many missings)

Result: with 48159 rows and 11 columns

*/

/*
%obs_count(oree_gvkey_record_dtv2_comp)
%contents( mergback.my_compustat)
*/
/** aggmy_all_trans;
 proc sql;
 Title "Except all: Total or_gvkey which only has nonrelational transactions";
 select count(distinct or_gvkey) from 
     (
         select or_gvkey from aggmy_all_trans
         where relation=0
                except all 
         select or_gvkey from aggmy_all_trans
         where  relation =1
    );
 Title "Except  : Total or_gvkey which only has relational transactions";
     select count(distinct or_gvkey) from 
     (
         select or_gvkey from aggmy_all_trans
         where relation=1
               except  
         select or_gvkey from aggmy_all_trans
         where  relation =0
    );
quit;

proc sql;
 Title "Except  : relation=0 only: Total or_gvkey which only has nonrelational transactions";
 select count(distinct or_gvkey) from 
     (
         select or_gvkey from aggmy_all_trans_exec_year
         where relation=0
                except  
         select or_gvkey from aggmy_all_trans_exec_year
         where  relation =1
    );
 Title "Except  :relation=1 only:Total or_gvkey which only has  relational=1 transactions";
     select count(distinct or_gvkey) from 
     (
         select or_gvkey from aggmy_all_trans_exec_year
         where relation=1
               except  
         select or_gvkey from aggmy_all_trans_exec_year
         where  relation =0
    );
     Title "intersect  : Total or_gvkey which only has nonrelational transactions";
     select count(distinct or_gvkey) from 
     (
         select or_gvkey from aggmy_all_trans_exec_year
         where relation=0
               intersect  
         select or_gvkey from aggmy_all_trans_exec_year
         where  relation =1
    );
quit;

proc sql;
 Title "Total distinct or_gvkey in agg_my_tran transactions";
 select count(distinct permno) from aggmy_all_trans_exec_year;
 quit;

proc sql;
 Title "Total nonmissing relation or_gvkey in agg_my_tran transactions";
 select count(distinct permno) from aggmy_all_trans_exec_year where not missing(relation);

 quit;
*/


 /*oree_gvkey_record_dtv2_comp;
proc sql;
 Title "Total distinct or_gvkey in agg_my_tran transactions";
 select count(distinct or_gvkey) from oree_gvkey_record_dtv2_comp;
 quit;

proc sql;
 Title "Total nonmissing relation or_gvkey in agg_my_tran transactions";
 select count(distinct or_gvkey) from oree_gvkey_record_dtv2_comp where not missing(relation);

 quit;
 */
/* construct three types of assignors relation=0, relation=1, relation=0 and =1     
 */
 proc sql;
 Title "---count---";
  create table azzz as;
  select * from aggmy_all_trans_exec_year 
   where missing(permno);
   quit;

/*
   Feb 12, 2025


;
%let agg_trans_frim_exec_year = aggmy_all_trans_exec_year;
PROC SQL;
ALTER TABLE oree_gvkey_record_dtv2_comp ADD firm_type   NUM (8);
 
QUIT;

proc sql;
 Title "firms which only have nonrelational transactions";
 update oree_gvkey_record_dtv2_comp
 set firm_type=0 where or_gvkey in 
     (
         select or_gvkey from aggmy_all_trans
         where relation=0
                except  
         select or_gvkey from aggmy_all_trans
         where  relation =1
    );
 
 Title "firms which only have relational transactions";
 update oree_gvkey_record_dtv2_comp
 set firm_type=1 where or_gvkey in 
     (
         select or_gvkey from aggmy_all_trans
         where relation=1
               except  
         select or_gvkey from aggmy_all_trans
         where  relation =0
    );
     
 Title "firms which have both relation+nonrelational transactions";
 update oree_gvkey_record_dtv2_comp
 set firm_type=2 where or_gvkey in 
     (
         select or_gvkey from aggmy_all_trans
         where relation=0
               intersect  
         select or_gvkey from aggmy_all_trans
         where  relation =1
    );
quit;

proc sql;
Title "firm type = 0";
select count(distinct or_gvkey) from oree_gvkey_record_dtv2_comp where firm_type= 0;
Title "firm type = 1";
select count(distinct or_gvkey) from oree_gvkey_record_dtv2_comp where firm_type= 1;
Title "firm type = 2";
select count(distinct or_gvkey) from oree_gvkey_record_dtv2_comp where firm_type= 2;
quit;

proc sql;
Title "firm type  missing";
select count(distinct or_gvkey) from oree_gvkey_record_dtv2_comp where firm_type not in (0,1,2);
quit;

proc sort data=my_all_trans;
by firm_type or_gvkey ;
run; 

proc sql;
create table examine1 as 
select distinct or_comp_name, ee_name, or_gvkey, firm_type
from my_all_trans ;
quit;
proc sql; 
create table examine1_type2 as 
select distinct or_comp_name, ee_name   
from my_all_trans where firm_type=2 ;
 
create table examine1_type1 as 
select distinct or_comp_name, ee_name   
from my_all_trans where firm_type=1 ;
quit;

proc sql; 
 
select  count(*)   
from my_all_trans where firm_type=2 ;quit;

proc sql;
select count(*) from 
     (
         select or_gvkey from unique_orgvkey
         where relation=0
               intersect  
         select or_gvkey from unique_orgvkey
         where  relation =1
    );
quit;

proc sql; 
create table aexamine1_type0 as 
select distinct or_gvkey, or_comp_name ,firm_type   , relation   
from my_all_trans where firm_type=0
order by or_comp_name;

create table aexamine1_type2 as 
select distinct or_gvkey, or_comp_name,firm_type , relation    
from my_all_trans where firm_type=2 
order by or_comp_name;
 
create table aexamine1_type1 as 
select distinct or_gvkey, or_comp_name  ,firm_type  , relation   
from my_all_trans where firm_type=1 
order by or_comp_name;
quit;

proc sql; 
create table aexamine1_type0 as 
select distinct or_comp_name    
from my_all_trans where firm_type=1 ;
quit;



%contents(oree_gvkey_record_dtv2_comp)
proc means data = oree_gvkey_record_dtv2_comp;
var    be_me bvcEquity capIntens cashFlow cash_assets 
    costcap earnings  leverages market_leverage ni  
        Altman_Z roa roe   agg_vnominal agg_vreal agg_total_cites agg_pack_size; *total_cites vreal vnominal;
class firm_type;
run;
Title "------------------------------------------------------------------------------------*";
Title "-------------------Regression-------------------------------------------------------";
proc reg data=oree_gvkey_record_dtv2_comp (where= (firm_type =0)) plots=none;
   eq0: model agg_pack_size =  Altman_Z;
   *eq1: model agg_vnominal =  Altman_Z;
   *eq2: model agg_vreal =  Altman_Z;
run;
 ** 
data have;
input a b c;
datalines;
1 2 3
4 . 6
1 . .
;

data want;
set have;
sum=sum(a,b,c);
plus = a+b+c;
run;

proc sql;
select count(distinct or_gvkey) as  firm_0   from oree_gvkey_record_dtv2_comp where firm_type =0
union
select count(distinct or_gvkey) as firm_1 from oree_gvkey_record_dtv2_comp where firm_type =1
union
select count(distinct or_gvkey) as firm_2 from oree_gvkey_record_dtv2_comp where firm_type =2;
quit;


proc sql;
select (distinct or_gvkey) as  firm_0   from oree_gvkey_record_dtv2_comp where firm_type =0

;
proc sql; 
 
select distinct or_comp_name  ,firm_type , relation 
from aexamine1_type0 where prxmatch("\Kodak\", or_comp_name);
select distinct or_comp_name     ,firm_type, relation
from aexamine1_type1 where prxmatch("\Kodak\", or_comp_name);
select distinct or_comp_name     ,firm_type, relation
from aexamine1_type2 where prxmatch("/Kodak/", or_comp_name);
quit;


Nokia ;

proc sql; 
 
select distinct or_comp_name  ,firm_type , relation 
from aexamine1_type0 where prxmatch("\okia\", or_comp_name);
select distinct or_comp_name     ,firm_type, relation
from aexamine1_type1 where prxmatch("\okia\", or_comp_name);
select distinct or_comp_name     ,firm_type, relation
from aexamine1_type2 where prxmatch("\okia\", or_comp_name);
quit;

proc sql; 
 
select distinct or_comp_name  ,   ee_name , relation 
from my_all_trans where prxmatch("\blackberry\",lowcase( or_comp_name));
 quit;
proc sql; 
 
select distinct or_comp_name  ,   ee_name , relation 
from my_all_trans where prxmatch("\okia\",lowcase( ee_name));
 quit;

 proc sql; 
 
select distinct or_comp_name   , relation 
from my_all_trans where prxmatch("\BlackBerry\", or_name);
 quit;

 proc sql; 
 Title "Nokia";
select rf_id,   or_comp_name,  or_name, ee_name , relation 
from my_all_trans where prxmatch("\^nokia\", lowcase(or_name));
select rf_id,  or_comp_name ,or_name,  ee_name ,     relation 
from my_all_trans where prxmatch("\alikie\", lowcase(ee_name));
  
quit;
proc sql;
select *, min(altman_z)
from oree_gvkey_record_dtv2_comp
group by firm_type
having Altman_Z = min(Altman_Z)
;
quit;

proc sql;
select min(year) from oree_gvkey_record_dtv2_comp;
quit;

%contents(oree_gvkey_record_dtv2_comp)

data  part2;
set oree_gvkey_record_dtv2_comp;
if not missing(Altman_Z) then do;
if Altman_Z <1.8 then distress = 1;
else if  Altman_Z >3 then distress = 1;




proc means data = oree_gvkey_record_dtv2_comp mean median p5 q1 q3 p95 std min max;
var   AT LT
 be_me bvcEquity     cash_assets 
    costcap earnings      ni   Altman_Z roa roe  agg_total_cites agg_vreal agg_vnominal agg_pack_size;
;
class firm_type;
run;

PROC CORR DATA=oree_gvkey_record_dtv2_comp (where= (firm_type =0)) plots=none ;
    VAR  Altman_Z;
    WITH ROA ROE;
RUN;
*/




/*
*
*
proc sql;
    create table  oree_gvkey_record_dtv2_comp as
        select * from 
        aggmy_all_trans as a
          
         /*or_ee_gvkey_patentid_record_dt2 as a*/
         /*     inner join 
           mergback.my_compustat as b
           on a.or_gvkey = b.gvkey
           and    year(a.record_dt) = b.YEAR;*/
        /*and    year(a.record_dt) - b.FYEAR=1;*/
 

/*
Aggregate by -firm- and -year-
*/
libname mergback "C:\Users\lihon\Downloads\merge_back";



proc sql  NOREMERGE;
create table aggmy_all_trans_exec_year as
select  distinct permno
        ,or_gvkey
        ,exec_year
        ,foreign
        ,relation
        ,sum(pac_size) as agg_pack_size
        ,sum(total_cites) as agg_total_cites
        ,sum(vreal) as agg_vreal
        ,sum(vnominal) as agg_vnominal
        from my_all_trans
  group by permno
           ,or_gvkey
           ,exec_year
           ,foreign
           ,relation
    order by permno
             ,or_gvkey
             ,exec_year
           ;
quit;
%contents(mergback.aggmy_all_trans_exec_year)
%obs_count(mergback.aggmy_all_trans_exec_year)
%print30(mergback.aggmy_all_trans_exec_year)
/* fyear missing more than exec_year,
 so we don't aggregate by fyear;

proc sql  NOREMERGE;
  create table agg2_all_trans as
     select   permno
        ,or_gvkey
        ,foreign
        ,FYEAR as year 
        ,relation
        ,sum(pac_size) as agg_pack_size
        ,sum(total_cites) as agg_total_cites
        ,sum(vreal) as agg_vreal
        ,sum(vnominal) as agg_vnominal
        from my_all_trans
     group by permno
           ,or_gvkey
           ,foreign
           ,FYEAR 
           ,relation
           ;
quit;
*/
proc freq data = aggmy_all_trans_exec_year;
table relation/missing  nopercent nocum;
table foreign/missing  nopercent nocum;
table exec_year/missing  nopercent nocum;
table relation*foreign/missing  nopercent nocum;
run;
%print30(aggmy_all_trans_exec_year)
*

%importStata(infile="D:\Research\patent\data\kpss2023.dta", outfile=kpss2022)
;

data kpss2023clean;
set kpss2023;
filing_year = floor(filing_date/10000);
run;
/* Exam data:
see the distinct permno in each year in KPSS
*/
proc sql;
  select filing_year, count(distinct permno ) from kpss2023clean
  where
  group by filing_year
  order by filing_year;
  quit;



%uniquevalue(kpss2023clean, permno)
data kpss2022; 
 set kpss2023clean ;
 filing_dt=input(put(filing_date,8.),yymmdd8.);
    format filing_dt date9.;
   
run;

proc freq data = kpss2022;
table filing_year;
run;
proc sql;
select count( distinct permno) from kpss2022;
quit;



/* Both issue_daet and filing_dates are characters
convert date;
year: extract the year of filing_date, if filing_date is missing, use the year of issue_date
* 
data kpss2022;
  set kpss2022( rename = (filing_date=fdate1));
     drop   fdate1 issue_date1;
       filing_date = input(put(fdate1, 8.), yymmdd8.);
       issue_date1 = input(put(issue_date, 8.), yymmdd8.);
       filing_y = year(filing_date);
 if missing(filing_date) then 
       filing_y=year(issue_date1);
 format   filing_date mmddyy10.;
 format   filing_date mmddyy10.;
 run;
 */



/*
proc sql;
create table permno_patent_year as
select distinct permno, filing_year as year, count(*) as patent_filing 
    from kpss2022
    group by permno, year;
quit;
*/
%copytb(aggmy_all_trans_exec_year)
*keep trans after 1980;
data aggmy_all_trans_exec_year;
    set mergback.aggmy_all_trans_exec_year (where = (not missing(permno))
                                            drop= foreign taxdiff 
                                            rename= (agg_pack_size   = pack_size 
                                                     agg_total_cites = cites
                                                     agg_vreal       = vreal
                                                     agg_vnominal    = vnominal
                                                     )
                                              );
run;
proc freq data = aggmy_all_trans_exec_year;
table exec_year;
run;
%copytb(permno_patent_year)
*


;
proc sql;
   create table permno_patent_year as
       select distinct permno
                   ,min(filing_year) as begin_year
                   ,max(filing_year) as end_year
      from kpss2022 (where=(2023 > filing_year >= 1970))
      group by permno
      order by permno;
quit;

*get the gvkey by merging ccm;
proc sql;
   create table permno_gvkey_patent_year as
    select a.*, b.gvkey as gvkey from permno_patent_year as a
    inner join gvkey_permno_table as b
    on a.permno = b.LPERMNO;
    quit;



/*permno in kpss not in mine :3728 
  permno in mine not in KPSS :3307 
  permno in BOTH kpss + mine: 6284 
*/

proc sql;
  Title "permno in kpss not in mine";
   select count(distinct permno) from(
       select permno from permno_patent_year
                     except  
       select permno from aggmy_all_trans_exec_year
      );
quit;
proc sql;
  Title "permno in mine not in KPSS";
    select count(distinct permno) from(
          select permno from aggmy_all_trans_exec_year
                except  
        select permno from permno_patent_year
       );
quit;

proc sql;
 Title "permno in  BOTH kpss + mine";
   select count(distinct permno) from(
          select permno from aggmy_all_trans_exec_year
                intersect  
         select permno from permno_patent_year
    );
quit;
/* 
Only keep the transactions that I can only find patent values 
so only keep the transactions that I can find in KPSS
*/
proc sql;
  create table aggmy_all_trans_withKPSS as
  select * from aggmy_all_trans_exec_year 
        where permno in (
                     select distinct permno from permno_patent_year
                        )
  order by permno, exec_year;
quit;

data All_kpss_permno_year(keep= permno gvkey year);
    set permno_gvkey_patent_year;
       do year = begin_year to min(end_year+10, 2022);
         output;
       end;
run;
/* Potential problem that the relation is missing;
*/

proc sql;
  create table valAll_kpss_permno_year as 
   select /*repKPSS.permno
           ,repKPSS.year*/
          repKPSS.*
           ,aggtrans.* 
        from All_kpss_permno_year as repKPSS
              left join 
            aggmy_all_trans_withKPSS  as aggtrans 
           
         on repKPSS.permno = aggtrans.permno
            and repKPSS.year = aggtrans.exec_year
            and  2023 > exec_year >=  1980
            /*and repKPSS.year>*/
   ;
quit;

proc freq data= aggmy_all_trans_withKPSS;
table exec_year;
run;

data  part2trans_with_counter_fact;
set valAll_kpss_permno_year(drop = rec_exec_days  
                            where=( year > 1979));
   if missing(pack_size) then pack_size = 0;
   if missing(vreal) then vreal = 0;
   if missing(vnominal) then  vnominal = 0;
   format vreal vnominal comma12.2;
  
run;


%uniquevalue(aggmy_all_trans_withKPSS,permno)
/*
proc sql;
select count(*) from permno_patent_year
  where permno not in (
        select unique permno

Title ":---------------------;";
proc sql;
  select count(*) from permno_patent_year 
    where missing(permno) or missing(year)  ;
  quit;

%uniquevalue(permno_patent_year, permno)
%uniquevalue(part2_permno_year_comp, permno)
*/

/*

proc sql;
select count(distinct or_gvkey) as  firm_0   from part2_permno_year_comp where firm_type =0
union
select count(distinct or_gvkey) as firm_1 from part2_permno_year_comp where firm_type =1
union
select count(distinct or_gvkey) as firm_2 from part2_permno_year_comp where firm_type =2;
quit;
*/

/* Full join;
106,926;
left join: 96474 rows and 37 columns

* 
proc sql;
create table counter_fact as 
select b.*, a.patent_filing as patent_applied 
   from  permno_patent_year a
          left join 
         part2_permno_year_comp b
    on a.permno = b.permno and a.year=b.year
   order by permno, year;
quit;

proc sort  data=counter_fact;
by permno or_gvkey;
run;

%obs_count(counter_fact)
%obs_count(part2_permno_year_comp)
data counter_fact0;
set counter_fact (where =
                    (not (missing(permno) and missing(or_gvkey)) )
                  );
run;


proc sql;
create table miss_perm_gvkey as 
select distinct permno, or_gvkey from agg2_all_trans
where missing(permno);
quit;

proc sql;
Title "missing permno";
select count(*) from agg2_all_trans where missing(permno);
Title "missing or_gvkey";
select count(*) from agg2_all_trans where missing(or_gvkey);
quit;

*/


*-----------------------------------------------;
*
*TBD;
*
*
*
*
*
*;

proc freq data = agg2_all_trans;
table relation*year/missing;
run;



%obs_count(agg2_all_trans)
%contents(agg2_all_trans)
proc sql;
select count( *) from (
  select distinct permno , or_gvkey, foreign, year,relation from agg2_all_trans
);
quit;
proc sql;
    create table  part2_permno_year_comp as
        select * from 
        part2trans_with_counter_fact as a
          
         /*or_ee_gvkey_patentid_record_dt2 as a*/
              inner join 
           mergback.my_compustat as b
           on a.gvkey = b.gvkey
           and    a.year = b.YEAR;
        /*and    year(a.record_dt) - b.FYEAR=1;*/
quit;
run;
%contents(part2_permno_year_comp)
proc sql;

select count(*) from agg2_all_trans where missing(permno);
quit;


PROC SQL;
  ALTER TABLE part2_permno_year_comp ADD firm_type   NUM (8);
QUIT;

 proc sql;
 Title "firms which only have nonrelational transactions";
 update part2_permno_year_comp
 set firm_type=0 where gvkey in 
     (
         select gvkey from part2trans_with_counter_fact
         where relation=0
                except  
         select gvkey from part2trans_with_counter_fact
         where  relation =1
    );
 
 Title "firms which only have relational transactions";
 update part2_permno_year_comp
 set firm_type=1 where gvkey in 
     (
         select gvkey from part2trans_with_counter_fact
         where relation=1
               except  
         select gvkey from part2trans_with_counter_fact
         where  relation =0
    );
     
 Title "firms which have both relation+nonrelational transactions";
 update part2_permno_year_comp
 set firm_type=2 where gvkey in 
     (
         select gvkey from part2trans_with_counter_fact
         where relation=0
               intersect  
         select gvkey from part2trans_with_counter_fact
         where  relation =1
    );
quit;

data  part2_permno_year_comp0;
      set part2_permno_year_comp (where=(firm_type NE 1));
      if relation EQ 1 then do; 
         cites =0;
         pack_size = 0;
         vnominal =0;
         vreal = 0;
       end;

run;


proc freq data = part2_permno_year_comp0;
table firm_type/missing;
run;

proc sql;
select count(*) from part2_permno_year_comp
where not missing(AT);
quit;


proc means data = part2_permno_year_comp mean median p5 q1 q3 p95 std min max;
class firm_type;
   var   AT LT
      be_me bvcEquity     cash_assets 
      costcap earnings     
      ni   Altman_Z edf roa roe  cites vreal vnominal pack_size;
   class firm_type;
run;



proc reg data=part2_permno_year_comp0;* (where =(firm_type = 0 and -5<Altman_Z <18))  plots=none;
Title "Firm : external transfer only";
   eq0: model pack_size =  Altman_Z  ;
   
   eq1: model vnominal =  Altman_Z  ;
   eq2: model vreal =  Altman_Z  ;
   ods select ParameterEstimates;
run;

proc reg data=part2_permno_year_comp0 (where =(firm_type = 0 and -5<Altman_Z <18))  plots=none;
Title "Firm : internal transfer only";
   eq0: model pack_size =  Altman_Z  ;
   
   eq1: model vnominal =  Altman_Z  ;
   eq2: model vreal =  Altman_Z  ;
   ods select ParameterEstimates;
run;

 
proc reg data=part2_permno_year_comp (where =(firm_type = 1 and -5<Altman_Z <18))  plots=none;
Title "Firm : external transfer only";
   eq0: model agg_pack_size =  Altman_Z  ;
   
   eq1: model agg_vnominal =  Altman_Z  ;
   eq2: model agg_vreal =  Altman_Z  ;
   ods select ParameterEstimates;
run;
ods select all;
*---------------------------------------------------



**;
%contents(part2_permno_year_comp)

Title "-----------------------------------------------------------------------------------";
proc reg data=part2_permno_year_comp0 (where =(firm_type = 0 and -5<Altman_Z <18))  plots=none;
Title "Firm : external transfer only";
  eq0: model pack_size =  Altman_Z  AT BE EBIT  LT TobinsQ Be_me capintens cashFlow ni ROA / selection = forward slentry = 0.99;;
   
  * eq1: model vnominal =  Altman_Z  ;
   *eq2: model agg_vreal =  Altman_Z  ;
 *  ods select ParameterEstimates;
run;

proc reg data=part2_permno_year_comp0 (where =(firm_type = 0 and -5<Altman_Z <18))  plots=none;
Title "Firm : external transfer only";
  eq0: model pack_size =  Altman_Z   capintens cashFlow ni  year  ;
   
   eq1: model vnominal =   Altman_Z   capintens cashFlow ni   year ;
   eq2: model vreal =   Altman_Z   capintens cashFlow ni    year;
    ods select ParameterEstimates;
run;

proc reg data=part2_permno_year_comp (where =(firm_type = 1 and -5<Altman_Z <18))  plots=none;
Title "Firm : internal transfer only-----";
     eq0: model agg_pack_size =  Altman_Z   capintens cashFlow ni  year  ;
   
     eq1: model agg_vnominal =   Altman_Z   capintens cashFlow ni    year;
    eq2:model agg_vnominal =   Altman_Z   capintens cashFlow ni  year;
    ods select ParameterEstimates;
run;

/*
proc reg data=part2_permno_year_comp (where =(firm_type = 2 and -5<Altman_Z <18))  plots=none;
Title "Firm: both internal and external transfers";
  model agg_pack_size =  Altman_Z   capintens cashFlow ni    ;
   
   *eq1: model agg_vnominal =  Altman_Z  ;
   *eq2: model agg_vreal =  Altman_Z  ;
    ods select ParameterEstimates;
run;
*/
%copytb(part2_permno_year_comp0)
/* for Mortan DD*/

proc sql;
create table mertonDD as
select distinct gvkey, permno, year from part2_permno_year_comp where firm_type = 0;
quit;
proc sql;
create table mertonDD_type2 as
select distinct gvkey, permno, year from part2_permno_year_comp where firm_type = 2;
quit;

%copytb(mertonDD)
%copytb(mertonDD_type2)
proc freq data = mertonDD;
table year;
run;
%uniquevalue(mertonDD, permno)
%uniquevalue(mergback.kmv, permno)

proc sort data = part2_permno_year_comp0  out =atman_z_type0_2(where = (not missing(firm_type) AND  -100<Altman_z<100));
by firm_type;
run;


 proc sql;
create table mertonDD as
select distinct gvkey , year from part2_permno_year_comp where firm_type = 0;
quit;
/*
proc transpose data = part2_permno_year_comp0 out=wide_atmanzscore prefix = type;
by gvkey year;
id firm_type;
var Altman_z;
run;

*/
proc sql;
  create table zscore_0 as
  select  year, mean(altman_z) as zscore1 
                , median(altman_z) as mzscore1 from part2_permno_year_comp where firm_type = 0
             group by year; 
  create table zscore_2 as
  select  year, mean(altman_z) as zscore2
                , median(altman_z) as mzscore2 from part2_permno_year_comp where firm_type = 2
                group by year; 
  create table zscore0_2 as
  select a.*, b.* from zscore_0 as a
    inner join zscore_2 AS b
    on a.year = b.year;
    quit;

proc sgplot data=zscore0_2;
 
 density mzscore1/ type=kernel legendlabel="Zscore of Firms Transfering Patents Externally Only";
 density mzscore2/ type=kernel legendlabel="Zscore of Firms Transfering Patents Internally and Externally";
 keylegend /  
 across=1
 
 titleattrs=(weight=bold
 size=12pt)
 valueattrs=(style=italic
 size=10pt);

 run;
part2_permno_year_comp0
 proc sql;
 create table part2_zscore_dd as
 select * from part2_permno_year_comp as a
  left join mergback.kmv0_2 as b
  on a.gvkey = b.gvkey and a.year = year(b.date);
  quit;

  proc means data = part2_zscore_dd mean median p5 q1 q3 p95 std min max;
class firm_type;
   var   
         Altman_Z edf       vreal   pack_size;
  
run;


 proc sql;
 create table part2_zscore_dd as
 select * from part2_permno_year_comp0 as a
  left join mergback.kmv0_2 as b
  on a.gvkey = b.gvkey and a.year = year(b.date);
  quit;
%copytb(part2_zscore_dd)
