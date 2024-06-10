PROC EXPORT DATA= WORK.ALL_GVKEY 
            OUTFILE= "C:\Users\lihon\Downloads\merge_back\all_gvkey.txt" 
            DBMS=TAB REPLACE;
     PUTNAMES=YES;
RUN;
