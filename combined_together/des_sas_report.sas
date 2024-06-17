*Running this creates a new template;
 
 
ods tagsets.minimal file='C:\Users\lihon\Downloads\sas_code\sas_temp\betChannel_data.tex' (notop nobot) newfile=table;
proc means data = have N MEAN MEDIAN STDDEV MIN MAX MAXDEC=2;
        VAR stake;
        label bet_channel = "Channel";
        CLASS bet_channel;
run;
ods tagsets.minimal close;    
x 'notepad C:\Users\lihon\Downloads\sas_code\sas_temp\betChannel_data.tex';


***********************************;
*;

 


 
ods latex path='C:\Users\lihon\Downloads\sas_code\sas_temp\' file='evt_model_sum.tex' style=journal;
 
options nolabel;
proc report data=allevtdate;
  column  model Cret_mean   car_mean  bhar_mean    car_t  scar_t  pat_car n ;
  define  model / display;
  define  Cret_mean / display;
  define  car_mean / display;
  define  bhar_mean / display;
  define  car_t / display;
  define  scar_t / display;
 define  pat_car / display;
 define n / display "total Obs";

run;
ods latex close;
 
title;

 


/*
Variables in Creation Order 
evttime nobs _TYPE_ _FREQ_ ret_Mean cret_Mean
car0_Mean car1_Mean car2_Mean car3_Mean
bhar0_Mean bhar1_Mean bhar2_Mean bhar3_Mean 
bhar0win_Mean bhar1win_Mean bhar2win_Mean bhar3win_Mean 
cretwin_Mean car0win_Mean car1win_Mean car2win_Mean car3win_Mean 
scar0_Mean scar1_Mean scar2_Mean scar3_Mean 

abret0_Mean abret1_Mean abret2_Mean abret3_Mean 
sar0_Mean sar1_Mean sar2_Mean sar3_Mean 
pat_scale_Mean 
ret_N cret_N car0_N car1_N car2_N car3_N 
bhar0_N bhar1_N bhar2_N bhar3_N 
bhar0win_N bhar1win_N bhar2win_N bhar3win_N 
cretwin_N car0win_N car1win_N car2win_N car3win_N 
scar0_N scar1_N scar2_N scar3_N 

abret0_N abret1_N abret2_N abret3_N 
sar0_N sar1_N sar2_N sar3_N 
pat_scale_N 
ret_t cret_t 
car0_t car1_t car2_t car3_t 
bhar0_t bhar1_t bhar2_t bhar3_t 
bhar0win_t bhar1win_t bhar2win_t bhar3win_t 
cretwin_t car0win_t car1win_t car2win_t car3win_t 
scar0_t scar1_t scar2_t scar3_t 

abret0_t abret1_t abret2_t abret3_t 

sar0_t sar1_t sar2_t sar3_t

pat_scale_t 

ret_Sum cret_Sum car0_Sum car1_Sum car2_Sum car3_Sum 
bhar0_Sum bhar1_Sum bhar2_Sum bhar3_Sum 
bhar0win_Sum bhar1win_Sum bhar2win_Sum bhar3win_Sum 
cretwin_Sum car0win_Sum car1win_Sum car2win_Sum car3win_Sum scar0_Sum scar1_Sum scar2_Sum scar3_Sum 
abret0_Sum abret1_Sum abret2_Sum abret3_Sum sar0_Sum sar1_Sum sar2_Sum sar3_Sum pat_scale_Sum 

*/
ods latex path='C:\Users\lihon\Downloads\sas_code\sas_temp\' file='aret_summary_report.tex' style=Journal2;
Title 'Show in RTF and LaTeX';
options nolabel;
proc report data=allstats;
  column  evttime abret0_Mean abret1_Mean abret2_Mean abret3_Mean  abret0_t abret1_t abret2_t abret3_t sar0_t sar1_t sar2_t sar3_t;
  define  evttime / display;
  define  abret0_Mean / display format=7.5;
  define  abret1_Mean / display format=7.5;
  define  abret2_Mean / display format=7.5;
  define  abret3_Mean / display format=7.5;
  define  abret0_t / display format=5.3;
  define  abret1_t / display format=5.3;
  define   abret2_t / display format=5.3;
  define   abret3_t / display format=5.3;
  define  sar0_t / display format=5.3;
  define  sar1_t / display format=5.3;
 define  sar2_t / display format=5.3;
 define  sar3_t / display format=5.3;
 
where  NOT missing(evttime);

run;
ods latex close;
 
title;

ods latex path='C:\Users\lihon\Downloads\sas_code\sas_temp\' file='car_summary_report.tex' style=Journal2;
Title 'Show in RTF and LaTeX';
options nolabel;
proc report data=allstats;
  column  evttime  car0_Mean car1_Mean car2_Mean car3_Mean car0_t car1_t car2_t car3_t scar0_t scar1_t scar2_t scar3_t ;
  define  evttime / display;
  define  car0_Mean / display format=7.5;
  define car1_Mean / display format=7.5;
  define  car2_Mean / display format=7.5;
 define  car3_Mean / display format=7.5;
 define  car0_t / display format=5.3;
 define  car1_t / display format=5.3;
 define  car2_t / display format=5.3;
 define  car3_t / display format=5.3;
  define  scar0_t / display format=5.3;
 define  scar1_t / display format=5.3;
 define  scar2_t / display format=5.3;
 define  scar3_t / display format=5.3;
 
where  NOT missing(evttime);

run;
ods latex close;
 
title;
