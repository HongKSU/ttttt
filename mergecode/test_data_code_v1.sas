proc sort data=TMP3.evt_foreign_all_car1_day2_comp out=tmpsd NODUPKEYS;
by PERMNO evtdate car0 car1 car2;
run;
libname evt_allf "C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_all";
PROC DATASETS NOLIST;
COPY IN = work OUT = evt_allf ;
select   tmpsd;
run;

proc sql;
select count (*) from
(select distinct permno, record_dt from  mergback.foreign_trans_decile
  group by permno, record_dt);
quit;
run;

  proc sql;
   select count (*) from
    (select distinct permno, evtdate from aggf_all.car_evtwin
     where evttime=2 group by permno, evtdate);



proc univariate data = aggf_all.car_evtwin CIBASIC ;
  var car0 car1 car2;
    where evttime=2 ;
run;

%contents(oree_compustatAllMy_gvkey)
 %contents(mergback.gvkey_in_comp_global)
 proc means data = mergback.my_all_trans  ;
var foreign permno permco ;
run;
sasfile mergback.my_all_trans load;
proc sql;
select count(distinct rf_id) as relation, "relationOnly" as count from my_all_trans where relation=1
union
select count(distinct rf_id) as relation, "foreign" as count from my_all_trans where relation=1 &  foreign=1
union
select count(distinct rf_id) as relation, "none foreign" as count from my_all_trans where relation ne 1 &  foreign=1

 union
select count(distinct permno) as permno, "permno" as count from  mergback.my_all_trans where relation=1;
quit;
sasfile mergback.my_all_trans close;
proc sql;

select count(distinct rf_id) as relation, "relationOnly" as count from relation_trans where relation=1
  union
select count(distinct rf_id) as relation, "foreign" as count from relation_trans where relation=1 &  foreign=1
  union
select count(distinct rf_id) as relation, "none foreign" as count from relation_trans where relation ne 1 &  foreign=1
  union
select count(distinct rf_id) as permno, "permno" as count from  relation_trans where relation=1 and foreign ne 1;
quit;

Title "total rf_id foreign trans";
proc sql;

select count(distinct rf_id) as relation, "relationOnly" as count from relation_trans where foreign =1
;
quit;
run;


proc sql;
select count (*) from foreign_trans;
quit;
run;

 proc sql;
  select count (*) from
    (select distinct permno, evtdate from aggf_all.car_evtwin
 where evttime=2 group by permno, evtdate);
quit;
run;


%contents(mergback.my_all_trans)
sasfile mergback.my_all_trans close;

%print30(sashelp.class)
proc gplot data =sashelp.class;
 
 Title "Market adjusted model:  CARs and BHARs around the event date";
 plot Height*Weight;
   refline 60 /axis=y lineattrs=(color=DarkRed);
 run;
       
run;


data myline;
   input xline yline;
datalines;
-2 0
2 0
;

data toplot;
   set sashelp.class
       myline
   ;
run;

proc sgplot data= sashelp.class;
   scatter x=height y=weight;
   refline 80 /axis=y lineattrs=(color=DarkRed);
run;
*******************************************;
* Frequncey exp;
proc freq data = relation_trans order =freq;
table or_comp_name;
run;
*******************************************;
* Frequncey exp;
proc freq data = relation_trans order =freq;
table permno;
run;
proc freq data = relation_trans order =freq;
table permno;
run;

proc freq data=relation_trans order =freq;
    tables permno / maxlevels=10;
proc freq data = my_all_trans order =freq;
table permno/ maxlevels=50; 
run;


proc freq data = my_all_trans order =freq;
table permno/ maxlevels=50;
where foreign=1 & permno=77178 ;
run;


*** Domestic trasn;


proc freq data = my_all_trans order =freq;
table permno/ maxlevels=50;* MISSPRINT   tables age/missing out=work.count;
where foreign NE 1 & relation=1 ;
run;

proc sql NOREMERGE ;
create table demestic_rel as
select  permno , or_comp_name, count(*) as count_f
 from   my_all_trans  where foreign NE 1 & relation=1 
group by   permno , or_comp_name
order by  count_f desc
;
 quit;
run; 
proc freq data = demestic_rel order =freq;
table permno / maxlevels=50;
run;

proc sql; *QUALCOMM  or_gvkey = 024800;
select distinct or_gvkey from mergback.or_ee_trans_permno_rf_id
where permno=77178 ;
quit;

proc sql; *QUALCOMM  or_gvkey = ;
select  count(*) from mergback.ee_or
where or_gvkey ="024800" ;
quit;
**************************************************************;
*extract eventdates car and merge with comp data;

%macro car_comp(event_source=foreign_trans_decile
                       ,car_evtwin=car_evtwin
                       ,outlib=outlib
                       ,outdata_pref=all_relat);
%*Merge event_sorce with comp data;
proc sql;
    create table  aggforeign_trans_record_dt_comp as
        select * from 
         /*        ??aggforeign_trans as a*/
           &event_source as a
         /*or_ee_gvkey_patentid_record_dt2 as a*/
              inner join 
           my_compustat as b
              on         a.or_gvkey = b.gvkey
              and year(a.record_dt) = b.YEAR;
        /*and    year(a.record_dt) - b.FYEAR=1;*/
quit;
run;   

 
%* merge with car data;
%** 1. First  subsample;
PROC SQL;
  create table &outdata_pref._Evt_car_day2_comp as 
   select * from  &car_evtwin as a
      inner join aggforeign_trans_record_dt_comp as b
   on a.permno = b.permno and a.evtdate = b.record_dt
where evttime=2;
 quit;
 run;

 %* remove duplicates;
 proc sort data =  &outdata_pref._Evt_car_day2_comp 
            out =  &outdata_pref._Evt_car_day2_comp2 nodupkeys;
           by permno evtdate;
           run;
 %* save to corresponding subdirecory; 
 PROC DATASETS NOLIST;
     COPY IN = work OUT = &outlib ;
     select &outdata_pref._Evt_car_day2_comp2;
run;
%mend car_comp;

;*';*";*/;quit;run;
*);*/;/*'*/ /*"*/; %MEND;run;quit;;;;;

proc freq data=aggrelation_trans_decile ;
table decile;
run;

data atestreg;
input id values1;
datalines;
1 1
2 2 
3 3
4 4
5 5
;
run;

proc reg data=atestreg edf outest=params;
        model values1=;
        run;
%print30(sashelp.class)
proc means data = atestreg;
var values1;
  output out=a_atestreg
  mean = 
     n = 
     t = 
   sum =/autoname;
run;
