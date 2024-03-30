/*
proc fedsql  MEMSIZE=90G;
  create table or_name_m as
  select a.rf_id, a.exec_dt, a.id_or as a_idor, b.id_or as b_idor,  a.std_firm1 as a_name, b.std_firm1 as b_name,
           compged(a.std_firm1, b.std_firm1) as dist_score		   
   from or_name10000 as a 
     inner join or_name10000 as b
   on a.or_sub = b.or_sub
*where  CALCULATED dist_score<20   AND   a.len_or>5;
 where  compged(a.std_firm1, b.std_firm1)<20   AND   a.len_or>5
order by a.id_or;
quit;
run;

proc fedsql  MEMSIZE=90G;
 create table or_name_m as
select a.rf_id, a.exec_dt, a.id_or as a_idor, b.id_or as b_idor,  a.std_firm1 as a_name, b.std_firm1 as b_name,
           compged(a.std_firm1, b.std_firm1) as dist_score		   
from  &subset as a 
 inner join &subset as b
on a.or_sub = b.or_sub
*where  CALCULATED dist_score<20   AND   a.len_or>5;
where  compged(a.std_firm1, b.std_firm1)<20   AND   a.len_or>5
order by a.id_or;
quit;
run;
*/
 