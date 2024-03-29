PROC IMPORT OUT= WORK.or_ee_kpss 
            DATAFILE= "D:\Research\patent\data\ee_or_document_kpss.dta" 
            DBMS=STATA REPLACE;

RUN;
