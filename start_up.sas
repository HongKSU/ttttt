%let path=%str(C:\Users\lihon\OneDrive - Kent State University\2023Spring\crsp_or);
*OR_name  ;
ODS NOPROCTITLE;
options nolabel;
options mlogic MPRINT;
options cpuCount = actual;
options msglevel=i FULLSTIMER;
Options THREADS; 

libname oneDrive "&path";
/*match back to the data*/
*OR_name 
libname or_crsp "C:\Users\lihon\Downloads\or_crsp_merged";
 
libname mergback "C:\Users\lihon\Downloads\merge_back";


 

