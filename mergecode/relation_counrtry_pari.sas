libname mergback "C:\Users\lihon\Downloads\merge_back";
/*
proc contents  data=mergback.or_ee_gvkey_patentid_record_dt;
run;

proc print data=mergback.or_ee_gvkey_patentid_record_dt(obs=10);
var ee_country FYEAR ee_ctry_ID:  
    FYEAR record_dt 
    or_country_code or_country_tax;
run;
*/
/*
proc sql;
create table relation_country_pair_count as 
select permno
        ,year(record_dt) as record_yr
       ,or_country_name
       ,or_country_code
        ,ee_country
       ,round(or_country_tax, 0.01) as or_tax
       ,round(ee_country_tax, 0.01) as ee_tax
       ,count(*) as pcount
       ,sum(total_cites) as cite_total
       ,sum(vreal) as vreal_total
       ,relation
       from mergback.or_ee_gvkey_patentid_record_dt 
            group by permno
                ,year(record_dt)
                ,or_country_code
                ,ee_country
                ,round(or_country_tax, 0.01)
                ,round(ee_country_tax, 0.01)
                ,relation
        order by permno, pcount
;
quit;
proc sql outobs=10;
select * from relation_country_pair_count
where pcount=0;
quit;

proc freq data= mergback.or_ee_gvkey_patentid_record_dt ;
table relation/missing;
run;

proc print data = mergback.or_ee_gvkey_patentid_record_dt (obs=10);
where relation is missing;
run;
*/

/* The relation is missing is still in the dataset
the code set relation=0 if missing(realtion) NEED CHECK
*/
***************************
* Include US to US: 
* 9153 rows 11 columns, 130 row's ee_country no value ;
* valid pair: 9023 = 9153-130
**************************;
* 1206 firms*year*ee_country pair transfer from US to nonUS;
proc sql;
create table relation_country_pair_count as 
select distinct or_gvkey
               ,permno
        ,FYEAR as record_yr
        ,or_country_code
        ,ee_country
        ,relation
        ,count(*) as pcount
        ,sum(total_cites) as cite_total
        ,sum(vreal) as vreal_total
        ,max(or_country_tax) as or_tax
        ,min(ee_country_tax) as ee_tax
       from mergback.or_ee_gvkey_patentid_record_dt 
       where NOT missing(relation) &
              ee_country NE ""
            group by permno
                ,FYEAR
                ,or_country_code
                ,ee_country
               ,relation
        having not missing(permno) AND  upper(or_country_code)="USA"
        order by permno, record_yr, relation, pcount
;
quit;

/*proc freq data = relation_country_pair_count order = freq;
table  ee_country ;
run;
*/

%unique_values(relation_country_pair_count, ee_country, permno)


* if missing citation or vreak, set patents characteristics to zero;
* remove US to US;
*1206 rows;
data relation_country_pair_count;
    set relation_country_pair_count(  
        where=(ee_country NE "UNITED STATES")
        );
    if missing(vreal_total) then vreal_total = .p;
    if missing(cite_total) then cite_total = .p;
run;
%obs_count(relation_country_pair_count)
%uniquecombin(relation_country_pair_count, permno, record_yr)
*Some firms have more than two transfers to a different destination in the year; 
%unique_values(relation_country_pair_count, ee_country, permno, 
   title=Unique Values of non-Us ee_coutry)

Title color=red "Table---   relation_country_pair_count + compustat";
proc sql;
    create table relation_country_pair_count_com as
      select a.*, b.* from
                relation_country_pair_count as a
            inner join 
                mergback.my_compustat b
            on a.or_gvkey = b.gvkey and
             a.record_yr = b.year
     order by or_gvkey, year, ee_country, pcount;
quit;

proc sort data=relation_country_pair_count_com NODUPKEY
%copytb(relation_country_pair_count_com )
DUPOUT=_dupcom_rec;
by  permno  record_yr;
run;
%uniquecombin(relation_country_pair_count_com, permno, record_yr)
relation_country_pair_count_com
%unique_values(relation_country_pair_count_com, ee_country, permno, 
   title=Unique Values of non-Us ee_coutry)
/*
proc freq data= relation_country_pair_count order = freq;
table relation /missing;
run;

proc freq data= relation_country_pair_count order = freq;
    table ee_country;
run;

proc reg data=relation_country_pair_count plots=none;
*where relation=1;
model pcount = or_tax ee_tax  ;
run;

proc sql;
select count(*) from relation_country_pair_count 
where upper(ee_country) NE "UNITED STATES" and  relation=1;
quit;

*/
/*
proc freq data=relation_country_pair_count order =freq;
table relation/missing;
run;
%obs_count(relation_country_pair_count)
proc print data=relation_country_pair_count (obs=100);
where record_yr=2013;
var ee_country or_tax ee_tax;
run;
*/
/* genrerate pseudo transaction 1980 to 2023*/
/*
 out=ee_ctry_freq(where=(count > 1 AND 
                                   NOT missing(ee_country)
                            ));
run;
*/
***************************;
* 51 non US countries;
**************************;

Title "Get list of ee countries";
proc freq data= relation_country_pair_count order=freq NOPRINT;
     where permno is not missing AND 
           upper(or_country_code)="USA";
     table ee_country/missing 
           out=ee_ctry_freq(
                      where=( NOT missing(ee_country))
                );
run;
%obs_count(ee_ctry_freq)
* permno list:794;
* EE_country_list: 51;
* Year 1980 to 2023: 44
*794*51*44 = 1,781,736
;
proc sql;
  Title 'get list of firms';
    create table _permno_list as
        select distinct or_gvkey, permno from relation_country_pair_count
        where permno is not missing AND  upper(or_country_code)="USA"
        order by permno;

  Title 'get list of ee countries';
    create table _ee_ctry_list as 
         select ee_country 
         from ee_ctry_freq
         where  not missing(ee_country)/*count>1 and*/
         order by ee_country;

  Title "combination of firm*country";
    create table pseudo_trans as
         select *
         from _permno_list, 
              _ee_ctry_list;
quit;
*.EE_CTRY_1980_2023 has 1781736 observations and 4 variables;
Title "firm country * recorded year:";
data ee_ctry_1980_2023;
   set pseudo_trans;
   do record_yr=1980 to 2023;
      output;
   end;
run;

 

*****************************************************************;


**;

proc sort data= relation_country_pair_count;
by  permno record_yr ee_country or_gvkey;
quit;
proc sort data = ee_ctry_1980_2023 ;
by permno record_yr ee_country;
quit;

/*
* add counterfactual obs
*joinType 10: onlyin country_pair_count
01: only in fake data;
11: both;
*/
%copytb(relation_country_pair_count)
data all_tran_with_counterfact;
  merge relation_country_pair_count ( in=in_rel )
      ee_ctry_1980_2023( in=in_psedo);
      length joinType $ 2;
      joinType = cats(in_rel, in_psedo);
  by permno record_yr ee_country;
run;

%unique_values(all_tran_with_counterfact, ee_country, permno, 
   title=all_tran_with_counterfact)
/*
proc sql;
 select * from ee_ctry_1980_2023
where permno= 81736;
quit;
proc sql;
 select * from 
relation_country_pair_count
where permno= 81736;
quit;
proc sql;
 select * from 
all_tran_with_counterfact
where permno= 81736;
quit;
*/
/**all_tran_with_counterfact 18,556* 
*relation_country_pair_count 17,131* 
proc sql;
 create table all_tran_with_counterfact as 
 select a.*
     from relation_country_pair_count a  
     full join ee_ctry_1980_2023      b
     on a.record_yr = b.year and 
        a.ee_country = b.ee_country and
        a.permno=b.permno
        having not missing(permno)
     order by permno, a.record_yr
        ;
quit;
*/
/*
Title "check merge quality: from both sets";
proc sql outobs=100;
select count(*) from all_tran_with_counterfact
where    joinType='11';
select * from all_tran_with_counterfact
where    joinType='11';
quit;
Title "check merge quality: from trasaction sets only";
proc sql outobs=100;
select count(*) from all_tran_with_counterfact
where    joinType='10';
select * from all_tran_with_counterfact1
where    joinType='10';
quit;
*/
*************


**************;
/*
Title "check merge quality: from fake   sets only";
proc sql outobs=100;
select count(*) from all_tran_with_counterfact
where    joinType='01' and permno= 81736;
select * from all_tran_with_counterfact
where    joinType='01' and permno= 81736;
quit;

proc print data=relation_country_pair_count (obs=100);
id ee_country;
var ee_country ee_tax;
where record_yr=2013;
run;
Title "Table---   all_tran_with_counterfact";
proc print data=all_tran_with_counterfact (obs=200);
id ee_country;
var or_country_code  or_tax ee_tax ;
where record_yr=2013 and joinType='11';
run;
 
*/
/* Transaction data + mycompustat*/
/*all_tran_with_counterfact

%contents(all_tran_with_counterfact_com)

*/
* Before merge compustat:
        1781741 observations and 12
      variables.
* After merge compustat:
         1480718 rows and 38 columns.

;
Title "Table---   all_tran_with_counterfact + compustat";
proc sql;
    create table all_tran_with_counterfact_com as
      select a.*, b.* from
                all_tran_with_counterfact as a
            right join 
                mergback.my_compustat b
            on a.or_gvkey = b.gvkey and
             a.record_yr = b.year
     order by or_gvkey, year, ee_country, pcount;
quit;
%unique_values(all_tran_with_counterfact_com, ee_country, permno, 
   title=all_tran_with_counterfact_com)

/*
Title "Table---check:   all_tran_with_counterfact + compustat";
proc print data=all_tran_with_counterfact_com (obs=200);
id ee_country;
var or_country_code  or_tax ee_tax ;
where record_yr=2013 and joinType='11';
run;

%contents(mergback.country_taxrate_all_my)
 
%print30(mergback.country_taxrate_all_my)
%contents(mergback.all_tran_counterfact_com)
  */
*1,211,816;
*1,075,799;
data all_tran_counterfact_com;
     set all_tran_with_counterfact_com (
                     where = (NOT missing(or_gvkey) )
                       );
     if missing(or_country_code) 
        AND missing(relation) 
        AND missing(pcount) then do;
         relation=.r;
         pcount=0;
         cite_total = 0;
         vreal_total = 0;
      end;
run;
/*
proc print data=all_tran_counterfact_com (obs=200);
id ee_country;
var or_country_code   or_tax ee_tax ;
where record_yr=2013 and joinType='11';
run;
*/

/*

proc sql; 
  create table or_ee_trans_tax_ee as 
    select  a.* 
            ,b.TR     as ee_country_tax
            ,b.TR_US  as US_tax
            ,upcase(b.IDNAME) as ee_ctry_IDNAME
        from or_ee_trans_tax   a
             left join
            country_taxrate_all_my b
        on    a.ee_country  = upcase(b.IDNAME) 
            and year(a.exec_dt) = b.fyendyr;
quit;  

proc sql;
select distinct IDNAME,tax_country_name from mergback.country_taxrate_all_my;
quit;
%contents(all_tran_counterfact_com)
*/
*
1227486 rows and 41 columns
;
 proc sql;
 create table all_tran_com as
   select b.*
          ,a.tax_country_name
          ,a.TR_US
          ,a.TR 
        from mergback.country_taxrate_all_my as a
            right join  
              all_tran_counterfact_com as b 
            on upcase(a.tax_country_name) = upcase(b.ee_country) 
            and a.fyendyr = b.record_yr
        order by or_gvkey, permno, record_yr, ee_country;
 quit;

 /*
%varlist(all_tran_counterfact_com)
proc print data=all_tran_com (obs=123);
where jointype ='01' and record_yr=2013;
id record_yr;
var  jointype ee_country tax_country_name ee_tax   TR ;
run;
 */
data all_tran_com_tax;
set all_tran_com;
  if not missing(TR) AND 
         missing(ee_tax) AND
         jointype ='01' then do;
           ee_tax=TR;
  end;
  if not missing(TR_US) AND
         missing(or_tax) then do;
           or_tax = TR_US;
           or_country_name= "UNITED STATES";
  end;
run;
%unique_values(all_tran_com_tax, ee_country, permno, 
   title=all_tran_com_tax)
%contents(all_tran_com_tax)
data all_tran_com_tax; 
     set all_tran_com_tax;
          if relation =1
              & (upcase(or_country_name) NE upcase(ee_country))
              & not missing(or_country_name)
              & not missing(ee_country)
             then foreign = 1 ;
           else if relation =1   
                 & (upcase(or_country_name) = upcase(ee_country))
                 & not missing(or_country_name) 
                 & not missing(ee_country)
               then  foreign = 0;
           else  foreign = .;
           taxdiff=or_tax - ee_tax;
           label taxdiff="or_tax-ee_tax";
           if abs(taxdiff ) < 0.0021 & not missing(taxdiff) then taxdiff = 0;
run;
%unique_values(all_tran_com_tax, ee_country, permno, 
   title=all_tran_com_tax)

proc sql;
create table firms_in_sample as 
select 
%copytb(all_tran_com_tax)
/** ';*";*/;run;;;;;;;;;;;;;;;;;*/

%put "NOTE: ok--"
%let varlist=%str(or_country_name or_country_code ee_country)
proc print data=all_tran_com_tax (obs=100);
  var or_country_name or_country_code ee_country ;
run;
proc freq  data =all_tran_com_tax;
table or_country_code or_country_name/missing; *United States;
run;
proc print data=all_tran_com_tax (obs=100);
id record_yr;
  var or_country_name or_country_code tax_country_name TR TR_US;
  where not missing(or_country_name) or 
        not missing(or_country_code) or  
              not missing(tax_country_name)
              and jointype='11'
        ;
run;

 
proc means data=all_tran_com_tax;
var or_tax or_country_tax ee_tax ee_country_tax ;
class relation;
run;
%obs_count(all_tran_com_tax)
/*
proc sql;
select count(*) 
from all_tran_com_tax
where missing(taxdiff)
;
quit;


proc mixed data=all_tran_com_tax  plots=none;
class year;
model pcount = or_tax ee_tax/solution;
repeated year/subject = permno;
run; 
proc reg data=all_tran_com_tax plots=none;
where relation=1;
model pcount = or_tax ee_tax  ;
run;

proc reg data=all_tran_com_tax;
where relation=0;
model pcount = or_tax ee_tax;
run;
proc reg data=all_tran_com_tax  plots=none;
model pcount = or_tax ee_tax;
run;
PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  all_tran_com_tax   ;
RUN;
%contents(mergback.or_ee_gvkey_patentid_record_dt)

ods pdf file='D:\trasn\trash\check_tax.pdf';
 proc sql outobs=200;
select distinct ee_country,us_tax, ee_country_tax from mergback.or_ee_gvkey_patentid_record_dt  
where fyear=2013;
quit;
run;

ods pdf close   ;

proc sort data= out=all_tran_counterfact_com;
by ee_country record_yr;
run;
 
proc freq data =all_tran_with_counterfact;
table jointype;where permno=81736;
run;
proc print data =all_tran_with_counterfact;
id record_yr;
where permno=81736;
run;
*/
** OK**;
/*
proc freq data =mergback.my_compustat ;
table year;
where  gvkey='031887' ;
run;
** OK**;
proc freq data =all_tran_with_counterfact;
table record_yr;
where permno=81736;
run;
proc sql;
    Title 'all_tran_with_counterfact_com';
    select * from all_tran_with_counterfact_com
            where permno=81736 and jointype="01"
     order by permno, ee_country, record_yr;
run;
proc freq data = all_tran_with_counterfact_com;
table year;
where permno=81736;
run;

Title 'ee_ctry_1980_2023';
proc sql;
    select * from ee_ctry_1980_2023
            where permno=81736;
run;
proc sql;
 select gvkey from mergback.crsp_comp_ccm_v1
            where lpermno=81736; 
quit;*031887*;
proc sql;
 select   year from mergback.my_compustat
            where gvkey='031887';

quit;

proc contents data=all_tran_with_counterfact_com;
run;

 * Check ee_ctry_tax data;
ods pdf file='D:\trasn\trash\check_taxrate20132.pdf';
proc sql ;
Title "list ee_country tax rate in 2013 from oree_gvkey_patentid_record_dtv2";
    select distinct tax_country_name, TR_US, TR
    from mergback.country_taxrate_all_my  
    where fyendyr=2013
    order by tax_country_name;
  quit;
run;
ods pdf close;
proc sql;   select distinct tax_country_name 
    from mergback.country_taxrate_all_my  
       quit;
run; 
ods pdf file='D:\trasn\trash\check_original taxrate20132.pdf';
/*KOREA (REP.)== SOUTH KOREA"* 
proc sql;  
Title "Check original taxrate dataset ..taxratet\country_tax.sas7bdat";
select distinct    tax_country_name 
    from "C:\Users\lihon\OneDrive - Kent State University\Patent_assignment\taxratet\country_tax.sas7bdat"  
    order by tax_country_name;
       quit;
 run; 
ods pdf close;
ods pdf file='D:\trasn\trash\check_my taxrate20132.pdf';
 *KOREA (REP.)== SOUTH KOREA"*;
proc sql;  
Title "Check original taxrate dataset ..taxratet\country_tax.sas7bdat";
select distinct    tax_country_name 
    from   mergback.country_taxrate_all_my
    order by tax_country_name;
       quit;
 run; 
ods pdf close;
proc print data =mergback.country_taxrate_all_my;
var tax_country_name TR fyendy;
where upcase( tax_country_name) = "ANDORRA";
run;

  *KOREA (REP.)== SOUTH KOREA"*;
 proc sql;
Title "Check original taxrate dataset ..taxratet\country_taxrate_all_my";
select distinct fyendyr, tax_country_name , TR_US, TR
    from mergback.country_taxrate_all_my                  
    where tax_country_name like "PUERTO%"
    order by tax_country_name;
       quit;
 run; 
  *KOREA (REP.)== SOUTH KOREA"*;
 proc sql;
Title "Check original taxrate dataset ..taxratet\country_taxrate_all_my";
select distinct tax_country_name   
    from mergback.country_taxrate_all_my                  
 
    order by tax_country_name;
       quit;
 run;
Title "Old taxrate on mergback lib"; 
proc contents data=mergback.country_taxrate_all_my ; 
run;*3263) obs*;
%Uniquevalue( mergback.country_taxrate_all_my,tax_country_name)

%Unique_values( mergback.country_taxrate_all_my,tax_country_name,fyendyr)
%let tb=%str(C:\Users\lihon\OneDrive - Kent State University\Patent_assignment\taxratet\country_tax.sas7bdat);
%Uniquevalue( "&tb" ,tax_country_name)

%Unique_values("&tb" ,tax_country_name,fyendyr)
proc sql;
Title '---country in my_taxrate but not in origial';
select distinct tax_country_name from mergback.country_taxrate_all_my where tax_country_name NOT in (
          select distinct tax_country_name from"&tb");
   Title '---country in origial NOT in my_taxrate';

select distinct tax_country_name from"&tb" where tax_country_name NOT in (
         select distinct tax_country_name from mergback.country_taxrate_all_my where tax_country_name  
         );
          quit;

* Check ee_ctry_tax data;
ods pdf file='D:\trasn\trash\check_tax2.pdf';
proc sql outobs=200;
Title "list ee_country tax rate in 2013 from oree_gvkey_patentid_record_dtv2";
select distinct ee_country
                ,us_tax
                ,ee_country_tax 
           from mergback.oree_gvkey_patentid_record_dtv2 
      
where fyear=2013  order by ee_country ;
quit;
run;
* Check ee_ctry_tax data;
ods pdf file='D:\trasn\trash\check_tax2.pdf';
proc sql outobs=200;
Title "list ee_country tax rate in 2013 from oree_gvkey_patentid_record_dtv2";
select distinct ee_country
                ,us_tax
                ,ee_country_tax 
           from mergback.oree_gvkey_patentid_record_dtv2 
      
where fyear=2013  order by ee_country ;
quit;
run;
ods pdf close   ;

* Check ee_ctry_tax data;
ods pdf file='D:\trasn\trash\check_tax2_or_ee.pdf';
proc sql outobs=200;
Title "list ee_country tax rate in 2013 from oree_gvkey_patentid_record_dtv2";
select distinct ee_country
                ,us_tax
                ,ee_country_tax 
           from mergback.or_ee_gvkey_patentid_record_dt 
      
where fyear=2013  order by ee_country ;
quit;
run;
ods pdf close   ;

 proc sql outobs=200;
select distinct or_country_name, ee_country, us_tax,or_country_tax,ee_country_tax
from mergback.or_ee_trans_tax_state_country  
where   exec_year =2013;
quit;
run;
*/
