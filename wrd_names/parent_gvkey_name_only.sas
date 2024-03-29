PROC IMPORT OUT= WORK.parent_sub_gvkey_name_only 
            DATAFILE= "D:\Research\patent\data\wrds_names\parent_gvkey_n
ame_only.dta" 
            DBMS=STATA REPLACE;

RUN;
