PROC IMPORT OUT= WORK.kpss2022 
            DATAFILE= "D:\Research\patent\data\kpss.dta" 
            DBMS=STATA REPLACE;

RUN;
