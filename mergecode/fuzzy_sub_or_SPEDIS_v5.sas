/*
https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/mcrolref/n17rxjs5x93mghn1mdxesvg78drx.htm
https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/mcrolref/n17rxjs5x93mghn1mdxesvg78drx.htm
Because values in the macro processor are case sensitive

https://blogs.sas.com/content/sgf/2022/02/11/jedi-sas-tricks-resizing-renaming-and-reformatting-your-data/
https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/mcrolref/n0pfmkjlc3e719n1lks4go8ke61r.htm#:~:text=There%20are%20two%20types%20of,with%20a%20semicolon%20(%20%3B%20).
*/

/* BEFORE FUZZY match
Did you remove exact matches first?
*/
/*%*%SYSMACDELETE split_non_matched  */
%SYSMACDELETE fuzzy_sub_or_SPEDIS_v5  

libname cl_macro "C:\Users\lihon\Downloads\sas_code\cl_macro";
options mstored sasmstore=cl_macro;

%macro fuzzy_sub_or_SPEDIS_v5(or_table
                              ,comp 
                              ,original_name=or_name  /*need to set it up*/
                              ,or_name= std_firm1
                              ,len_std_or = len_std_or 
                              ,or_sub = or_sub_name
                              ,comp_original=HCONM
                              ,comp_name = std_sub_name 
                              ,country_code = country_code
                              ,sub_name = sub_name
                              ,len_name = len_name
                              ,merged_prefix=ee       /*must set a value*/
                              ,up_spedis_score=10);
sasfile &or_table load;
sasfile &comp     load;
proc sql _method ;
   create table m_&merged_prefix._&comp  as
   select a.rf_id
          ,a.exec_dt
          ,a.id_or
          ,a.id_ee 
	      ,a.&original_name as &merged_prefix._name
	     /* a.entity_1 as entity_or_1,*/
          ,a.entity   as &merged_prefix._entity
          ,a.&or_name as  &merged_prefix._std_name
          ,a.&or_sub
          ,b.GVKEY
          ,b.&comp_name     as crsp_std_name
          ,b.&comp_original as comp_conm
          ,SPEDIS(a.&or_name, b.&comp_name) as spedis_score
            /****** compged(a.&or_name, b.&comp_name) as gl_score,*/
          ,a.&len_std_or as len_&merged_prefix
          ,b.&len_name   as len_comp
          ,b.&country_code as country_code /*added on 06/12/2024*/
          /*b.entity as entity_comp*/
   from      &or_table as a
   left join &comp as b
   on a.&or_sub = b.&sub_name  
   where (CALCULATED spedis_score <= &up_spedis_score   AND 
          a.&len_std_or>5 AND b.&len_name>5) OR
          (a.&or_name = b.&comp_name) 
	  group by id_or
	  having spedis_score=min(spedis_score) 
	  order by id_or 
	  ;
   quit;
 run;
sasfile &or_table close;
sasfile &comp close;
%mend fuzzy_sub_or_SPEDIS_v5;

/*************************************************************************************
 macro deduplicate_merged:
    left OR
    right comp
 
    output:
    m_comp
**************************************************************************************/

%macro deduplicate_merged(merged_table 
                         ,out_merged_table
                         ,or_name=or_name
                         ,comp_name=comp_name
                         ,id_unique=id_unique);

%*can be done in the mathch macro;
proc sql;
create table _temp_ as
select * ,spedis(&or_name, &comp_name) as dist_name from &merged_table
group by &id_unique
having spedis_score = min(spedis_score)
order by &id_unique;
run;
proc sql;
create table _temp_2 as
select * from _temp_
group by &id_unique
having dist_name = min(dist_name)
order by &id_unique;
run;

proc sql;
Title "number record in origin";
select count(distinct &id_unique) as a from &merged_table;
 title "new rec";
 select count(distinct &id_unique) as d from _temp_2;
quit;
run; 

proc sort data =_temp_2 out= &out_merged_table  nodupkey;
by id_or  ;
run;
%mend deduplicate_merged;


/*************************************************************************************
joint tables:
    left OR
    right comp
 
    output:
    m_comp
**************************************************************************************/
%macro fuzzy_comp_or(or, comp);
  sasfile &or load;
  sasfile &comp load;
  proc sql _method ;
    create table m_&comp  as
    select a.rf_id, a.exec_dt, a.id_or, a.std_firm1 as or_std_name, a.or_name,
          b.GVKEY, b.std_nameL as crsp_std_name, b.HCONM, b.comnam,
          compged(a.std_firm1, b.std_nameL) as dist_score
      from  &or as a
        left join &comp as b
         on a.or_sub = b.sub_name
      where (CALCULATED dist_score<=120   AND  a.len_std_or>4 AND b.len_name>4) OR
           (a.std_firm1 = b.std_nameL) ;
  quit;
run;
sasfile &or close;
sasfile &comp close;
%mend fuzzy_comp_or;


%macro fuzzy_comp_or_SPEDIS(or, comp);
sasfile &or load;
sasfile &comp load;
proc sql _method ;
    create table m_&comp  as
    select a.rf_id, a.exec_dt, a.id_or, a.std_firm1 as or_std_name, a.or_name,
          b.GVKEY, b.std_nameL as crsp_std_name, b.HCONM, b.comnam,
          SPEDIS(a.std_firm1, b.std_nameL) as dist_score
    from  &or as a
    left join &comp as b
    on a.or_sub = b.sub_name
    where (CALCULATED dist_score<=5   
            AND  
	  a.len_std_or>4 
	    AND 
	  b.len_name>4) OR
        (a.std_firm1 = b.std_nameL) ;
    quit;
run;
sasfile &or close;
sasfile &comp close;
%mend fuzzy_comp_or_SPEDIS;

/***********************************************************
* March 2, 2024 Saturday
* V2: does not consider the length of names, 
*   will filter the length of names on the ouput merged files

* Try 1: only spedis:9
* Try 2: spedis <=15 compged <=200
********************************************************/

%macro fuzzy_comp_or_SPEDIS_v2(or, comp, 
	or_name= std_firm1, 
	comp_name = std_nameL, 
	up_spedis_score=15, 
	up_gl_score=230);
   sasfile &or load;
   sasfile &comp load;

   proc sql _method;
   create table m_&comp  as
   select a.rf_id
         ,a.exec_dt
	 ,a.id_or
	 ,a.&or_name as or_std_name
	 ,a.or_name
	 ,b.GVKEY
	 ,b.&comp_name as crsp_std_name
	 ,b.HCONM, b.comnam,
          SPEDIS(a.&or_name, b.&comp_name) as spedis_score, 
          compged(a.&or_name, b.&comp_name) as gl_score,
		  a.len_std_or as len_or,
          b.len_name as len_crsp
   from  &or as a
   left join &comp as b
   on a.or_sub = b.sub_name  
   where (CALCULATED spedis_score<=&up_spedis_score  AND 
          CALCULATED gl_score<=&up_gl_score  AND 
          a.len_std_or>4 AND b.len_name>4) OR
          (a.std_firm1 = b.std_nameL) ;
     quit;
 run;
sasfile &or close;
sasfile &comp close;
%mend fuzzy_comp_or_SPEDIS_v2;


%macro exact_comp_or(or, comp);
options msglevel=i fullstimer;

options cpuCount = actual;
sasfile doc.&or load;
sasfile &comp load;
proc sql _method ;
   create table m_&comp  as
   select a.rf_id, a.exec_dt, a.id_or,   a.std_firm1 as or_std_name, a.or_name,
          b.GVKEY, b.std_nameL as b_std_name, b.HCONM, b.comnam,
           
   from  doc.&or as a
   left join &comp as b
   on a.std_firm1 = b.std_nameL
  where a.   
    ;
  quit;
 run;
%mend exact_comp_or;


********************************************************************************;
*set nonmatched_comp
*
*
* Divid the COMP names into several small files *;
********************************************************************************;
%macro split_non_matched(all_data =or_name_orig 
                         ,std_firm = std_firmL
                         ,prefix = or
                        );
	data &prefix._AC
         &prefix._DG
         &prefix._HL
         &prefix._MR
         &prefix._SZ
         &prefix._others;
    set &all_data;
    
     %* %if &first_letter Eq %then blocking = &first_letter;    
     %* %else  blocking = substr(&std_firm, 1,1);
     %* blocking= &first_letter;
     blocking = upcase(substr(&std_firm, 1,1));
	  &prefix._sub = substr(&std_firm,1,3);
      len_name = length(&std_firm);
   if blocking LE 'C' then output &prefix._AC;
	 else if blocking GE 'D' AND blocking LE 'G' then output &prefix._DG;
	 else if blocking GE 'H' AND blocking LE 'L' then output &prefix._HL;
	 else if blocking GE 'M' AND blocking LE 'R' then output &prefix._MR;
	 else if blocking GE 'S' AND blocking LE 'Z' then output &prefix._SZ;
	 else output &prefix._others;
    drop blocking ;
    list;
run;
%mend split_non_matched;
 /*%*%SYSMACDELETE split_non_matched  */

%macro contents(table) /store des='table of variables';
Title "Varibales in table &table";
proc contents data= &table;
ods select Variables;
run;
%mend contents;
%macro contents_short(table)/store des='short list of variables';
Title "Varibales in table &table";
proc contents data= &table varnum short ;
ods select Variables;
run;
%mend contents_short;
%macro varList(table)/store des='list of variables';
Title "Varibale list in table &table";
proc contents data= &table short varnum;
run;
%mend varList;


/* Count number of observations in a dataset tb*/
%macro obs_count(tb)/store des='Count total observations in tb';
proc sql;
Title "Total number of observatoins in dataset &tb";
select count(*) format = comma10. from &tb;
quit;
run;
%mend obs_count;

%macro uniquevalue(table, var_name1)/store des='List unique values of var in par2 from par1: table';
Title "The count of total values and  unique variable &var_name1 from table &table";
proc sql;
select count(*)  as count format = comma10., 'total obs' as total from &table
union
select count(distinct &var_name1) as count format = comma10., "&var_name1" as uniq1 from  &table;
quit;
%put WARNING: End of macro;
run;
%mend uniquevalue;

***%uniquecombin();
%macro uniquecombin(table, var_name1, var_name2, title=)/store;
Title font="Arial" color="red" "&title";
Title2 "The count of total combination of variable %str(&var_name1) and %str(&var_name2) values from table &table";
    proc sql;
    select count(*) as count format = comma10. from(
            select &var_name1, &var_name2 from &table group by &var_name1, &var_name2
            having count(*) =1
    );
    quit;
%mend uniquecombin;
%macro unique_values(table, var_name1, var_name2, title=)/store;
Title font="Arial" color="red" "&title";
Title2 "The count of total values and unique variable %str(&var_name1) and %str(&var_name2) values from table &table";
proc sql;
select count(*) as count ,'total obs' as total from &table
union
select count(distinct &var_name1) as count format = comma10., "&var_name1" as uniqe_1 from &table
union
select count(distinct &var_name2) as count format = comma10., "&var_name2" as unique_2 from &table;
quit;
run;
%mend unique_values;
********************************************************************************;
* importStaat *;
* Load stata file to SAS WORK lib *;
*
* ;
********************************************************************************;
%macro importStata(infile=, outfile=);
PROC IMPORT OUT= WORK.&outfile 
            DATAFILE= &infile 
            DBMS=STATA REPLACE;
RUN;
%mend importStata;

%macro print30(infile, obs=30)/store des='Print first 30records' ;
proc print data=&infile (obs=&obs);
run;
%mend print30;

options mlogic mprint symbolgen;
%macro print100(infile,varlist, obs=100)/store des='Print first 100records of given varlist' ;
proc print data=&infile (obs=&obs);
%*var &varlist;
run;
%mend print100;
* copy table;
%macro copytb(table,outlib=mergback) /store des='Copy a dataset from work lib to outlib';
proc datasets NOLIST;
    copy in=work out=&outlib;
    select &table;
    run;
%mend copytb;
*); */; /*’*/ /*”*/; %mend;
*); */; /*’*/ /*”*/; %mend;
*';*";*/;run;
https://stackoverflow.com/questions/107414/whats-your-best-trick-to-break-out-of-an-unbalanced-quote-condition-in-base-sas
 ;*';*";*/;quit;run;
 ODS _ALL_ CLOSE;

 ; *'; *"; */;
ODS _ALL_ CLOSE;
quit; run; %MEND;
rename work dataset :
proc datasets library=usclim;
   change hightemp=ushigh lowtemp=uslow;
run;
data _NULL_; putlog "DONE"; run;

%* --This is the macro comment ;
OR 
/* This is the macro comment*/

 QUIT; RUN;

 NO! * will most often NOT work to comment out code in a macro, only %*  and the /* */ combination.

One always can run into a problem is trying to comment out code that already has code commented statements imbedded in it.
For that, as far as I know, there isn't a readily available method.

The method to comment out code that has commented statements embedded into it:

 

inside a macro, use:

 

%if 0 %then %do;

...

%end;

If not inside a macro, then you can comment out this section by making it a macro that is never called:

 

%macro dont_do_this;

...

%mend;

 

Naturally, you might want to add a comment statement just before you do this explaining that you are commenting out a whole block of code.



%macro test;
%put a;
*%put b;
%*put c;
/*%put d;*/
%put abcd;
%mend test;
%test 

%* Macro Comment Macro Statement;;
https://documentation.sas.com/doc/en/pgmsascdc/v_056/mcrolref/n17rxjs5x93mghn1mdxesvg78drx.htm
