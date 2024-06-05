*===========================================================================================;

/*Extract event by   exec_dt Date
April 2nd, 2024
For exec date*/
/* or_ee_trans_permno1*/
/*Extract event by Recorded Date

            */
%print30(for_event_study1)
%contents(for_event_study1)
proc sort data = for_event_study1 
          out=for_exec_dt_study  NODUPKEYS;
          by permno exec_dt;
run;
%print30(for_exec_dt_study)
%print30(for_event_study_foreign)

 
proc sort data = for_exec_dt_study 
          out= for_event_study_exec_dt_temp  NODUPKEYS;
          by permno exec_dt;
run;
data exec_dt_study_relation;  *12838;
      format permno exec_dt;
      set for_event_study_exec_dt_temp (where= (NOT  missing(permno))
                              keep=permno exec_dt );
run;
%print30(for_event_study_exec_dt_temp)

data exec_dt_study_foreign; *4285;
      format permno record_dt;
      set for_event_study_exec_dt_temp( where=(foreign_tran=1)
                                        keep=permno exec_dt foreign_tran);
                                        drop foreign_tran;
run;
%print30(exec_dt_study_foreign)

PROC EXPORT DATA= WORK.exec_dt_study_relation 
            OUTFILE= "C:\Users\lihon\OneDrive - Kent State University\aa
aa\event_Study\exec_dt_study_relation.txt" 
            DBMS=TAB REPLACE;
     PUTNAMES=YES;
RUN;
PROC EXPORT DATA= WORK.exec_dt_study_foreign 
            OUTFILE= "C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\exec_dt_study_foreign.txt" 
            DBMS=TAB REPLACE;
     PUTNAMES=YES;
RUN;


*8888888888888;
*delete the following//////////////////////////////;

data for_event_study_exec_dt_v1; 
       format permno exec_dt;
      set for_event_study_exec_dt_temp(where= (NOT  missing(permno) and relation=1)
                              keep=permno exec_dt relation);
                              drop  relation;
   run;
proc sort data =for_event_study_exec_dt_v1 NODUPKEY;
 by permno exec_dt;
 run;
PROC EXPORT DATA= WORK.for_event_study_exec_dt_v1 
            OUTFILE= "C:\Users\lihon\OneDrive - Kent State University\aa
aa\event_Study\for_event_study_exec_dt_v1.txt" 
            DBMS=TAB REPLACE;
     PUTNAMES=YES;
RUN;

/*
data for_event_study;
       format permno exec_dt;
      set or_ee_trans_permno(where= (NOT  missing(permno) and relation=1)
                              keep=permno exec_dt);
   run;
 
 */

%put _user_;
data _null;
%put _automatic_;
run;
