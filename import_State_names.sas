PROC IMPORT OUT= WORK.Astate_names 
            DATAFILE= "C:\Users\lihon\Downloads\merge_back\stateNames.cs
v" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
