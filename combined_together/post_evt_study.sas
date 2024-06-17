
* North american data;

 data oree_compustatAllMy_gvkey;
      set  mergback.oree_compustat_gvkey
           mergback.oree_compustat_gvkey_extraJune16;
run;

*extract needed variables;
 

data northamerica_comp(keep=gvkey BE year bvcEquity capIntens cashFlow 
                      cashHoldings costcap 
                       leverages bleverage market_leverage
                      roa roe  TobinsQ at lt  ni ebit );
set oree_compustatAllMy_gvkey;
* 1. Book Value Per Share (bkvlps)
BKVLPS
Market Value - Total - Fiscal (mkvalt)
* Price Close - Annual - Fiscal (prcc_f) * Common Shares Outstanding (csho);
* bvEquity = PRCC_F *CSHO;
   /* Two years of accounting data before 1990 */
	/* PS: prefered stock value*/
  PS=coalesce(PSTKRV, PSTKL, PSTK, 0);
  if missing(TXDITC) then 
        TXDITC=0;
  BE=SEQ + TXDITC - PS;
  if BE<0 then
	BE=.;
  year=year(datadate);
  * BE of common equity;
  bvcEquity = PRCC_F *CSHO;
  capIntens = CAPX/AT;
  cashFlow = (IBC+DP)/AT;
  cashHoldings = CHE/AT;
  costcap = XINT/DLC;
  * Debt in Current Liabilities - Total (dlc)  +  Long-Term Debt - Total (dltt) / tockholders Equity - Parent (seq);
  leverages = (DLTT + DLC)/SEQ;

  * book leverage;
  bleverage = (dltt + dlc )/at;
  market_leverage = (dltt + dlc )/(at-ceq + bvcEquity);
  * ib, ibcom, ni;
  roa = ib/at;
  roe = ni/bvcEquity;
  cash_assets = che/AT;

 * roai = NI/AT;
 TobinsQ = (AT +bvEqity - CEQ)/AT;
 label BE='Book Value of Equity FYear t-1';
 label   LT= "Total Liabilities";
 label   AT= "Total Assets";
 label   capIntens= "Capital Intensity";
 label   cashFlow ="Cash Flow";
 label     cashHoldings= "Cash Holdings";
 *label variable costcap ="Cost of Capital";
 label   leverages= "Leverage";
 label   roa= "ROA";
 label   roe= "ROE";
 label    TobinsQ= "TobinsQ";
 run;


data global_comp(keep=gvkey BE year bvcEquity capIntens cashFlow 
                      cashHoldings costcap 
                       leverages bleverage market_leverage
                      roa roe  TobinsQ at lt  ni ebit );
set mergback.gvkey_in_comp_global;
* 1. Book Value Per Share (bkvlps)
BKVLPS
Market Value - Total - Fiscal (mkvalt)
** Price Close - Annual - Fiscal (prcc_f) * Common Shares Outstanding (csho);
** bvEquity = PRCC_F *CSHO;
   /* Two years of accounting data before 1990 */
	/* PS: prefered stock value*/
  PS=coalesce(PSTKRV, PSTKL, PSTK, 0);
  if missing(TXDITC) then 
        TXDITC=0;
  BE=SEQ + TXDITC - PS;
  if BE<0 then
	BE=.;
  year=year(datadate);
  * BE of common equity;
  bvcEquity = PRCC_F *CSHO;
  capIntens = CAPX/AT;
  cashFlow = (IBC+DP)/AT;
  cashHoldings = CHE/AT;
  costcap = XINT/DLC;
  * Debt in Current Liabilities - Total (dlc)  +  Long-Term Debt - Total (dltt) / tockholders Equity - Parent (seq);
  leverages = (DLTT + DLC)/SEQ;

  * book leverage;
  bleverage = (dltt + dlc )/at;
  market_leverage = (dltt + dlc )/(at-ceq + bvcEquity);
  * ib, ibcom, ni;
  roa = ib/at;
  roe = ni/bvcEquity;
  cash_assets = che/AT;

 * roai = NI/AT;
 TobinsQ = (AT +bvEqity - CEQ)/AT;
 label BE='Book Value of Equity FYear t-1';
 label   LT= "Total Liabilities";
 label   AT= "Total Assets";
 label   capIntens= "Capital Intensity";
 label   cashFlow ="Cash Flow";
 label     cashHoldings= "Cash Holdings";
 *label variable costcap ="Cost of Capital";
 label   leverages= "Leverage";
 label   roa= "ROA";
 label   roe= "ROE";
 label    TobinsQ= "TobinsQ";
 run;
 * short debt/ total debt;

 *Debt/Asset Ratio = Total Debt/total Assets;

 *Debt-to-Equity Ratio = totaldebt/;
*short debt 
 short
run;
data my_compusta;
    set global_comp 
        northamerica_comp;
    run;

proc contents data= mergback.oree_compustat_gvkey VARNUM;
run;
proc contents data= mergback.oree_compustat_gvkey_extraJune16 VARNUM;
run;



/* Merge with compustat
*/
proc sql;
    create table  oree_gvkey_record_dtv2_comp as
        select * from 
        oree_gvkey_patentid_record_dtv2 as a
          
         /*or_ee_gvkey_patentid_record_dt2 as a*/
              inner join 
           my_compusta as b
           on a.or_gvkey = b.gvkey
           and    year(a.record_dt) = b.YEAR;
        /*and    year(a.record_dt) - b.FYEAR=1;*/
quit;
run;

%contents(oree_gvkey_record_dtv2_comp)
/*
proc sql;
    create table  oree_gvkey_record_comp2 as
        select * from 
          oree_gvkey_patentid_record_dtv2 as a
              inner join 
        mergback.compustat_evt_gvkey as b
              on a.or_gvkey = b.gvkey
  and    year(a.record_dt) - b.FYEAR=1;
quit;
run;
*/
/* Extract permno and gvkey in 

 %importStata(infile="C:\Users\lihon\Downloads\wrd_evt_res\dnltqx87bslc9xnb_edate.dta",
              outfile=wrds_ff)

PROC SQL;
create table wrd_car_evtdate_comp as
select * from wrds_ff as a
 inner join oree_gvkey_record_dtv2_comp as b
 on a.permno = b.permno and a.evtdate = b.record_dt;
 quit;
 run;

oree_gvkey_patentid_record_dtv2
/*
proc sort data = for_event_study1 
          out  = for_event_study_v2  NODUPKEYS;
          by permno record_dt;
run;
*/

/* Merge  evt-CARs with COMPUSTAT
oree_gvkey_record_dtv2_comp
car1_day2: day2 cars
*/

proc sql;
create table aad_tmp as 
select rf_id
        ,or_name
        ,ee_name
        ,PERMno
        ,record_dt
        ,exec_dt
from  oree_gvkey_record_dtv2_comp
order by rf_id, record_dt;

quit;
run;

proc sort data=aad_tmp;
 by permno record_dt;
 run;


/*oree_gvkey_record_dtv2_comp:
 the combination of permno and date is not unique;
 */
PROC SQL;
  create table car1_day2_comp as 
   select * from  car_evtdate as a
      inner join oree_gvkey_record_dtv2_comp as b
   on a.permno = b.permno and a.evtdate = b.record_dt;
 quit;
 run;

%contents(car1_day2_comp)
PROC SQL;
create table car_evtdate_comp as
select * from car_evtdate as a
 inner join oree_gvkey_record_dtv2_comp as b
 on a.permno = b.permno and a.evtdate = b.record_dt;
 quit;
 run;

/*second merge of CARs and comp
 */
 PROC SQL;
create table car1_day2_comp_2 as
select * from car1_day2 as a
 inner join oree_gvkey_record_comp2 as b
 on a.permno = b.permno and a.evtdate = b.record_dt;
 quit;
 run;

/* merge the CARs with compustat data;
* C:\Users\lihon\Downloads\merge_back\compustat1979_2023.sas7bdat;
*/
proc sql;
  create table wrds_or_ee_event_res_car0_comp as
    select * from 
    /* car_evtwin a*/
    /*wrds_evt_Neg20_p10 a*/
    wrds_or_ee_event_res_car0 as a
    left join
     /* mergback.compustat1979_2023 as b*/
         mergback.compustat_evt_gvkey as b
   on a.or_gvkey = b.GVKEY 
   and year(a.record_dt) - b.FYEAR=1;
quit;



proc transpose data= car_evtwin 
      prefix = car out= car0_evtwin_wide(drop = _NAME_);
    by  permno evtdate;
    id evttime;
    var car0;
format evtdate MMDDYY10.;
run;
proc sql;
  create table wrds_or_ee_event_res_car0 as
    select * from 
    /* car_evtwin a*/
    /*wrds_evt_Neg20_p10 a*/
    car0_evtwin_wide as a
    left join
     or_ee_gvkey_patentid_record_dt as b
   on a.PERMNO = b.permno 
   and b.record_dt=a.evtdate;
quit;



74,153 obs)???
PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  wrds_or_ee_event_res_car0_comp ;
RUN;

PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  wrd_car_evtdate_comp ;
RUN;


PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  car1_day2_comp  car_evtdate_comp;
RUN;
PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select car1_day2_comp;
RUN;
***********************************************;



PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  or_ee_gvkey_patentid_record_dt2  oree_gvkey_patentid_record_dtv2 ;
RUN;

%unique_values(oree_gvkey_patentid_record_dtv2, or_gvkey, permno)
%unique_values(or_ee_trans_permno1, or_gvkey, permno)
