PROC IMPORT OUT= WORK.com_all_names_unique_std 
            DATAFILE= "D:\Research\patent\data\wrds_names\com_all_names_unique_std.dta" 
            DBMS=STATA REPLACE;

%split_non_matched(all_data = com_all_names_unique_std 
                         ,std_firm = std_conmL
                         ,prefix = comp
                         )

                         proc sql;
select count(distinct id_or) from comp_or.sub_or_merged
union
select count(distinct id_or) from sub_or_merged_v2;
quit;
