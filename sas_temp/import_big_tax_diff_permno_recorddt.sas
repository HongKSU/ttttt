PROC IMPORT OUT= WORK.Big_diff_permno_evtDate 
            DATAFILE= "C:\Users\lihon\OneDrive - Kent State University\a
aaa\event_Study\Big_diff_permno_evtDate.txt" 
            DBMS=TAB REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
