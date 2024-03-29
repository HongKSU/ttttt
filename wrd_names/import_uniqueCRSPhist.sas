PROC IMPORT OUT= WORK.UNIQUE_CRSPHist 
            DATAFILE= "D:\Research\patent\data\wrds_names\unique_crspHis
t.dta" 
            DBMS=STATA REPLACE;

RUN;
