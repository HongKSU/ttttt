*can be done in the mathch macro;
proc sql;
create table _temp_ as
select * from comp_or_nonmatched
group by id_or
having spedis_score = min(spedis_score);
order by id_or
run;

proc sort data=  _temp_;
by id_or;
run;
data _temp2_;
set _temp_;
keep rf_id id_or   or_name comp_conm spedis_score dist dup_id_or;
dist = spedis(or_name, comp_conm);
run;

proc sql;
create table _temp_3 as
select * from _temp2_
group by id_or
having dist = min(dist)
order by id_or;
run;
