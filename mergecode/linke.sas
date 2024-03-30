proc sql;
create table merged_or_or as
select a.rf_id, a.exec_dt, a.id_or as a_idor, b.id_or as b_idor,  a.or_name as a_name, b.or_name_clean as b_clean_name, compged(a.or_name_clean, b.or_name_clean) as dist_score 
from  UNIQUE_OR_NAME as a
, UNIQUE_OR_NAME as b
where CALCULATED dist_score<1000 AND (a.id_or NE b.id_or);
quit;
run;



proc sort data = merged_or_or;
by dist_score;
run; 
