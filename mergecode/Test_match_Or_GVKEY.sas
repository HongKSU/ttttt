proc setinit;
run;
178  
/*NOTE: The file WORK.OR_NAME.DATA has been loaded into memory by the SASFILE statement.
WARNING: Only 10000 records were read from WORK.OR_NAME (alias=A) due to INOBS= option.
WARNING: Only 10000 records were read from WORK.OR_NAME (alias=B) due to INOBS= option.
NOTE: Table WORK.OR_NAME_M created, with 2893 rows and 7 columns.

*/
  *proc sql inobs=10000;
  *create index nameindex on ;
options cpuCount = actual;
options  FULLSTIMER; 
options msglevel=i fullstimer;

options msglevel=i fullstimer;
options cpuCount = actual;


sasfile or_name load;


proc sql;
	create index or_sub1 on or_name10000(or_sub, std_firm1)      ;
	quit;
run;
proc sql;
	drop index or_sub from or_name10000      ;
	quit;
run;
/*
PROC SQL;
	CREATE <UNIQUE > INDEX index-name
	ON table-name(column-name-1<...,column-name-n>);
	DROP INDEX index-name FROM table-name;
QUIT;
*/

proc sort data=or_name (index=(or_sub std_firm1));
	by or_sub;
run;

proc sort data=or_name10000 (index=(or_sub));
	by or_sub;
run;

sasfile or_name10000 load;
proc sql _method ;
   create table or_name_m  as
   select a.rf_id, a.exec_dt, a.id_or as a_idor, b.id_or as b_idor,  a.std_firm1 as
  a_name, b.std_firm1 as b_name,
             compged(a.std_firm1, b.std_firm1) as dist_score
   from  or_name10000 as a
   inner join or_name10000 as b
   on a.or_sub = b.or_sub
  where  CALCULATED dist_score<20   AND   a.len_or>5
   order by a.id_or;

  quit;
 run;
sasfile or_name10000 close;
/*
NOTE: PROCEDURE SQL used (Total process time):
      real time           48.30 seconds
      cpu time            48.68 seconds

CPU:
NOTEE: PROCEDURE SQL used (Total process time):
      real time           13.00 seconds
      user cpu time       12.89 seconds
      system cpu time     0.14 seconds
      memory              12597.73k
      OS Memory           149100.00k
      Timestamp           02/22/2024 06:37:54 PM
      Step Count                        69  Switch Count  0

WITHOUT CPU:
NOTE: PROCEDURE SQL used (Total process time):
      real time           15.26 seconds
      user cpu time       15.01 seconds
      system cpu time     0.03 seconds
      memory              11918.48k
      OS Memory           46424.00k
      Timestamp           02/23/2024 08:53:15 PM
      Step Count                        79  Switch Count  0
** Sort without an Index:
NOTE: PROCEDURE SQL used (Total process time):
      real time           14.35 seconds
      user cpu time       13.23 seconds
      system cpu time     1.76 seconds
      memory              11761.28k
      OS Memory           44016.00k
      Timestamp           02/23/2024 09:23:49 PM
      Step Count                        115  Switch Count  0

 PROCEDURE SQL used (Total process time):
      real time           14.03 seconds
      user cpu time       12.75 seconds
      system cpu time     1.34 seconds
      memory              20443.93k
      OS Memory           53316.00k
      Timestamp           02/23/2024 09:15:09 PM
 
Sort with index:
NOTE: PROCEDURE SQL used (Total process time):
      real time           12.98 seconds
      user cpu time       13.06 seconds
      system cpu time     0.37 seconds
      memory              20475.21k
      OS Memory           53316.00k
      Timestamp           02/23/2024 09:25:10 PM
      Step Count                        117  Switch Count

 
*/

proc print data = M_or_name_a_j82098;
	var a_idor b_idor a_name b_name dist_score;
	where a_idor ^= b_idor AND a_idor < b_idor;
run;
proc sql;
	select count(*) from M_or_name_a_j82098
	where a_idor ^= b_idor;
quit; 

proc sql;
	select count(*) from M_or_name_a_j82098
	where a_idor ^= b_idor AND a_idor < b_idor;
quit;

options mlogic ;
options MPRINT;
options SYMBOLGEN;
/* SLOWER than with WHERE clause
options msglevel=i fullstimer;

options cpuCount = actual;
sasfile or_name10000 load;
proc sql _method ;
   create table or_name_m  as
   select a.rf_id, a.exec_dt, a.id_or as a_idor, b.id_or as b_idor,  a.std_firm1 as
  a_name, b.std_firm1 as b_name,
             compged(a.std_firm1, b.std_firm1) as dist_score
   from  or_name10000 as a
   inner join or_name10000 as b
   on a.or_sub = b.or_sub and a.len_or>5;
 
  quit;
 run;
sasfile or_name10000 close;

*/

 
