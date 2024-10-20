libname mergback "C:\Users\lihon\Downloads\merge_back";
proc contents  data=mergback.or_ee_gvkey_patentid_record_dt;
run;

proc print data=mergback.or_ee_gvkey_patentid_record_dt 
 (obs=10);
var ee_country FYEAR 
 ee_ctry_ID: 
 FYEAR record_dt 
   or_country_code or_country_tax
;
run;
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
*/
proc print data = mergback.or_ee_gvkey_patentid_record_dt (obs=10);
where relation is missing;
run;

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
            group by permno
                ,FYEAR
                ,or_country_code
                ,ee_country
               ,relation
        having not missing(permno) AND  upper(or_country_code)="USA"
        order by permno, record_yr, relation, pcount
;
quit;

/* genrerate pseudo transaction 1980 to 2023*/
/*
 out=ee_ctry_freq(where=(count > 1 AND 
                                   NOT missing(ee_country)
                            ));
run;
*/
Title "Get list of ee countries";
proc freq data= relation_country_pair_count order=freq;
  where permno is not missing AND  upper(or_country_code)="USA";
   table   ee_country/missing 
           out=ee_ctry_freq(where=( NOT missing(ee_country)
                                  ));
run;

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

Title "firm country * recorded year:";
data ee_ctry_1980_2023;
   set pseudo_trans;
   do record_yr=1980 to 2023;
      output;
   end;
run;


proc sort data= relation_country_pair_count;
by  permno record_yr ee_country or_gvkey;
quit;
proc sort data = ee_ctry_1980_2023 ;
by permno record_yr ee_country;
quit;


data all_tran_with_counterfact;
  merge relation_country_pair_count ( in=in_rel )
      ee_ctry_1980_2023( in=in_psedo);
      length joinType $ 2;
      joinType = cats(in_rel, in_psedo);
  by permno record_yr;
run;
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

Title "check merge quality: from both sets";
proc sql outobs=100;
select count(*) from all_tran_with_counterfact1
where    joinType='11';
select * from all_tran_with_counterfact1
where    joinType='11';
quit;
Title "check merge quality: from trasaction sets only";
proc sql outobs=100;
select count(*) from all_tran_with_counterfact1
where    joinType='10';
select * from all_tran_with_counterfact1
where    joinType='10';
quit;

Title "check merge quality: from fake   sets only";
proc sql outobs=100;
select count(*) from all_tran_with_counterfact1
where    joinType='01';
select * from all_tran_with_counterfact1
where    joinType='01';
quit;



proc sql;
    create table all_tran_with_counterfact_com as
      select a.*, b.* from
                all_tran_with_counterfact as a
            right join 
                mergback.my_compustat b
            on a.or_gvkey = b.gvkey and
             a.record_yr = b.year
     order by or_gvkey, year;
quit;
 
proc freq data =all_tran_with_counterfact;
table jointype;where permno=81736;
run;
proc print data =all_tran_with_counterfact;
id record_yr;
where permno=81736;
run;
/** OK**/
proc freq data =mergback.my_compustat ;
table year;
where  gvkey='031887' ;
run;
/** OK**/
proc freq data =all_tran_with_counterfact;
table record_yr;
where permno=81736;
run;
proc sql;
    Title 'all_tran_with_counterfact_com';
    select * from all_tran_with_counterfact_com
            where permno=81736;
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
            where lpermno=81736; /*031887*/

quit;
proc sql;
 select   year from mergback.my_compustat
            where gvkey='031887';

quit;

