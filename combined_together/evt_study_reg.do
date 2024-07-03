/*file:C:\Users\lihon\Downloads\sas_code\combined_together
*/

/*(esttab m* using "C:\Users\lihon\report\car1.tex", replace ///
nobaselevels longtable  eform label booktabs star(* 0.10 ** 0.05 *** 0.01) ///  
title("Main results of CAR from CAPM model around record date ") mtitle("model 1" "model 2" "model 3" "model 4")  
*/
// When you have title,
// stata will give the \begin{table} environment
/*
import sas using "C:\Users\lihon\Downloads\merge_back\car1_day2_comp.sas7bdat", clear

* All foreign transactions
import sas using "C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_all\evt_foreign_all_car1_day2_comp.sas7bdat"
*
import sas using "C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_all\evt_foreign_all_car1_day2_comp2.sas7bdat", clear
*/

 import sas using "C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\allRelationTrans\all_relat_evt_car_day2_comp2.sas7bdat", clear
 global outputPath "C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\allRelationTrans"
est clear 
/*replace ee_country = 
  
gen taxdiff=or_country_tax - ee_country_tax
 replace taxdiff = 0 if abs(taxdiff ) < 0.0021
 egen rank = rank(taxdiff ), unique
egen tax_group=cut(rank), group(10)
 gen foreign = 1 if upper(or_country_name)!=upper(ee_country) & !missing(or_country_name) & !missing(ee_country)
 
 replace foreign = 0 if missing(foreign) & !missing(or_country_name) & !missing(ee_country)
  taxdiff if foreign==0  
 
 gen bvEqity = PRCC_F * CSHO
 label variable bvEqity "BookValue"
 
 gen capIntens = CAPX/AT
 gen cashFlow = (IBC+DP)/AT
 gen cashHoldings = CHE/AT
gen costcap = XINT/DLC

gen leverages = (DLTT + DLC)/SEQ
gen roa = ibcom/at
gen roa = NI/AT
gen TobinsQ = (AT +bvEqity - CEQ)/AT
*/
rename agg_pack_size pac_size
rename agg_total_cites total_cites
rename agg_vreal vreal
rename agg_vnominal vnominal

   
label variable BE           "Book Value of Equity year t-1"
label variable LT           "Total Liabilities"
label variable bvcEquity    "Market Value"
label variable be_me        "Book/Market"
label variable AT           "Total Assets"
label variable capIntens    "Capital Intensity"
label variable cashFlow     "Cash Flow"
label variable cashHoldings "Cash Holdings"
label variable costcap      "Cost of Capital"
label variable leverages      "Leverage"
label variable bleverage       "Book leverage" 
label variable market_leverage "Market leverage" 
label variable earnings       "Earnings"
label variable NetLeverage     "NET Leverage" 
label variable roa             "ROA"
label variable roe             "ROE"
label variable ni             "NetIncome"
label variable TobinsQ        "TobinsQ"
label variable netloss         "NetLoss"
*https://www.baeldung.com/cs/latex-tables-vertical-horizontal
* global outputPath "C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\result\agg_foreign_all"

estpost tabstat taxdiff car*  ,by(decile) columns(statistics) stat(mean sd ) nototal  
/* 
 esttab  , unstack   ///
 starlevels(* 0.05 ** 0.01 *** 0.001) ///
 cells(mean(star fmt(%6.3fc) label(Mean)) sd(par fmt(2) label(SD)))nonumber   nomtitle eqlabels("D1" "D2" "D3" "D4" "D5" "D6" "D7"  "D8" "D9" "D10") nonote  nonumber noobs   
*/ 
esttab  using "$outputPath\descriptive_stats_cars.tex", replace unstack ///
               booktabs alignment(D{.}{.}{-1})  /// align elements
         	   cells(mean(star fmt(%6.3fc) label(Mean)) sd(par fmt(2) label(SD))) /// two columns  stacked
	           eqlabels("D1" "D2" "D3" "D4" "D5" "D6" "D7"  "D8" "D9" "D10")   ///
	           nonote  nonumber   nomtitle
est clear
estpost tabstat  AT LT EBIT BE  bvcEquity ni earnings netloss be_me cashFlow cashHoldings costcap leverages bleverage market_leverage roa roe   TobinsQ,by(decile) columns(statistics) stat(mean sd ) nototal  

esttab using "$outputPath\descriptive_stats_compvars.tex" , booktabs alignment(D{.}{.}{-1}) replace  unstack  cells(mean( fmt( %7.0fc %7.0fc %7.0fc %7.0fc %7.0fc  %7.0fc 2 2 2 2 2 2 2 2 2 2 2 2)) sd(par fmt(%7.0fc %7.0fc %7.0fc %7.0fc %7.0fc %7.0fc 2 2 2 2 2 2 2 2 2 2 2 2))  )  nomtitle eqlabels("D1" "D2" "D3" "D4" "D5" "D6" "D7"  "D8" "D9" "D10") nonote  nonumber noobs 
 
/* 
  esttab using "$outputPath\descriptive_stats_compvars_means.tex" , unstack  cells(mean( fmt( %7.0fc %7.0fc %7.0fc %7.0fc %7.0fc  %7.0fc 2 2 2 2 2 2 2 2 2 2))   )  nomtitle eqlabels("D1" "D2" "D3" "D4" "D5" "D6" "D7"  "D8" "D9" "D10") nonote  nonumber noobs 
  
  */
 
 
/*label variable costcap ="Cost of Capital";
 
tabstat taxdiff roa roe AT LT BE costcap leverages bleverage market_leverage, by(decile) stat(  mean  )  format(%9.2fc)   long
https://www.statalist.org/forums/forum/general-stata-discussion/general/1734105-exporting-a-table-to-latex-using-tabstat
 https://www.statalist.org/forums/forum/general-stata-discussion/general/1499038-is-it-possible-to-produce-tables-with-rounded-numbers-in-the-results-window
 
 
table (region var) (result), ///
    stat(mean `vlist') ///
    stat(sd `vlist') ///
    stat(min `vlist') ///
    stat(max `vlist')
	


* shorten some result labels
collect label levels result sd "SD" min "Min" max "Max", modify

* use a fixed numeric format for mean and sd
collect style cell result[mean sd], nformat(%9.2f)

* review style changes
collect preview
*/
winsor2 taxdiff car0 car1 car2 car3 sar0 sar1 sar2 sar3 abret0 abret1 abret2 abret3 bhar0 bhar1 bhar2 bhar3 ///
       AT LT CEQ cashHoldings bvcEquity be_me BE costcap ni EBIT EBITDA ///
       vreal  leverages roai vnominal bleverage  cash_assets         ///
       capIntens market_leverage TobinsQ  cashFlow   roa  roe      ///
       , cut(1, 99)  by(year) label


 
 /*
estpost 
estout m0 m1 m2 m3 m4 m5 m6  using "C:\Users\lihon\report\car_0_reg.tex", replace cell(b(star fmt(3)) se(par fmt(2)))  legend label varlabels(_cons Constant)  stats( df_r r2, fmt(0 4 ) label(N R-sqr ))

estout m1 m2 m3, cells(b(star fmt(3)) se(par fmt(2)))  legend label varlabels(_cons Constant)  stats( df_r r2, fmt(0 4 ) label(N R-sqr ))


esttab   m1 m2 m3 m4 m5 m6,nobaselevels    scalars(r2  )   


  booktabs star(* 0.10 ** 0.05 *** 0.01) 
///  
title("Main results of CAR from Market-Adjusted model around record date ") mtitle("model 1" "model 2" "model 3" "model 4"  "model 5" "model 6" "model 7")  
 
 
 
 
 
esttab    m1 m2 m3 m4 m5 m6 using "C:\Users\lihon\report\car_`i'_reg.tex", replace ///
nobaselevels    scalars(r2  )     booktabs star(* 0.10 ** 0.05 *** 0.01)    
 }
 
 

  local car1 car0 

  regress  `car1' `covar_comp1' ,vce(robust)
 
 est store m1, title(model 1)
 
 reg  `car1'  `covar_comp2' ,    vce(robust)
est store m2, title(model 2)
reg `car1' `covar_comp3' ,    vce(robust)
est store m3, title(model 3) 

reg `car1' `covar_comp4' ,    vce(robust)
est store m4, title(model 4)   
 
reg `car1' `covar_comp5' ,    vce(robust)
est store m5, title(model 5)

reg `car1' foreign  taxdiff total_cites pac_size vreal ,   vce(robust)
est store m6, title(model 6)


 local car1 car0 
regress  `car1' foreign  car_50-car_20,vce(robust)
est store m7, title(model 7)
regress  `car1' foreign  car_30-car_20,vce(robust)
est store m8, title(model 8)

estout m*, cells(b(star fmt(3)) se(par fmt(2)))  legend label varlabels(_cons Constant)  stats( df_r r2, fmt(0 4 ) label(N R-sqr ))
*/
 /* local car1          car2 
  local covar         car_50-car_20
  local covar_comp1   AT   leverages bvEqity
  local covar_comp2   AT  roa   leverages bvEqity
  local covar_comp3   AT  roa   LCT leverages bvEqity
  local covar_comp4   AT  roa   LCT leverages bvEqity TobinsQ 
 local covar_comp5    AT  roa   LCT leverages bvEqity TobinsQ taxdiff
 */
 /*
   egen rank = rank(taxdiff ), unique
egen tax_group=cut(rank), group(10) 

*/
 forvalues i=0(1)3{
 local car1 car`i'

 * local car1 car0_w
 
*  local car1 car0
quietly {
	est clear 
   reghdfe  `car1' taxdiff   ,  absorb(PERMNO year) vce (robust) 
   estadd local fef Yes
   estadd local fet Yes
   est store m1, title(model 1)
/*
   reghdfe  `car1' taxdiff roa,  absorb(PERMNO year)   vce(robust)
   estadd local fef Yes
   estadd local fet Yes
   est store m2, title(model 2)
*/
   reghdfe `car1'  taxdiff vreal,   absorb(PERMNO year)  vce(robust)
   estadd local fef Yes
   estadd local fet Yes
   est store m2, title(model 2) 

   reghdfe `car1'   taxdiff  vreal pac_size,   absorb(PERMNO year)  vce(robust)
   estadd local fef Yes
   estadd local fet Yes
   est store m3, title(model 3)   
 
   reghdfe `car1'   taxdiff   vreal  pac_size total_cites     ,  absorb(PERMNO year)  vce(robust)
   estadd local fef Yes
   estadd local fet Yes
   est store m4, title(model 4)

   reghdfe `car1'  taxdiff total_cites pac_size vreal roa netloss ,  absorb(PERMNO year)  vce(robust)
   estadd local fef Yes
   estadd local fet Yes
   est store m5, title(model 5)

 
   reghdfe `car1'   taxdiff total_cites pac_size vreal roa netloss market_leverage ,  absorb(PERMNO year)  vce(robust)
   estadd local fef Yes
   estadd local fet Yes
   est store m6, title(model 6)
   
   reghdfe `car1'    taxdiff total_cites pac_size vreal roa netloss market_leverage cashFlow ,  absorb(PERMNO year)  vce(robust)
   estadd local fef Yes
   estadd local fet Yes
   est store m7, title(model 7)
   }
   
   /*
   
   esttab   m1 m2 m3 m4 m5 m6 m7 m8 ,  scalars(r2  ) eqlabel("\textbf{Variables}") ///
   stats(fef fet r2 N, labels("Firm FE" "Year FE" "Adj R-square") ) /// 
			star(* 0.10 ** 0.05 *** 0.01) ///  
			 mtitle("model 1" "model 2" "model 3" "model 4"  "model 5" "model 6" )   ///
			  label /**/
			  
 }*/		
   esttab   m1 m2 m3 m4 m5 m6 m7   using "$outputPath\f_all_car_`i'_reg_fe.tex", replace ///
            booktabs alignment(D{.}{.}{-1}) ///
			stats(fef fet r2 N, labels("Firm FE" "Year FE" "Adj R-square") ) /// 
			star(* 0.10 ** 0.05 *** 0.01) label ///  
			mtitle("model 1" "model 2" "model 3" "model 4"  "model 5" "model 6" )  
 
}
*reghdfe car0_w   taxdiff  total_cites pac_size vreal netloss ,  absorb(PERMNO year)  vce(robust)

*reghdfe car0_w   taxdiff  total_cites pac_size vreal netloss leverages,  absorb(PERMNO year)  vce(robust)
  
//esttab   m1 m2 m3 m4 m5 m6 m7  ,nobaselevels    scalars(r2  ) 
/* Book leverage not significant
 local car1 car0_w
 reghdfe `car1' roa  taxdiff netloss bleverage  total_cites pac_size vreal ,  absorb(PERMNO year)  vce(robust)
  estadd local fef Yes
 estadd local fet Yes
est store m9, title(model 9)
*/
/*
esttab   m1 m2 m3 m4 m5 m6  , replace ///
nobaselevels    stats(fef fet r2 N, labels("Firm FE" "Year FE" "Adj R-square")  )       star(* 0.10 ** 0.05 *** 0.01) ///  
 mtitle("model 1" "model 2" "model 3" "model 4"  "model 5" "model 6" )  
 */
 /*
estpost 
estout   m1 m2 m3 m4 m5 m6  using "C:\Users\lihon\report\car_0_reg.tex", replace cell(b(star fmt(3)) se(par fmt(2)))  legend label varlabels(_cons Constant)  stats( df_r r2, fmt(0 4 ) label(N R-sqr ))

estout m1 m2 m3  m4 m5 m6 , cells(b(star fmt(3)) se(par fmt(2)))  legend label varlabels(_cons Constant)  stats( df_r r2, fmt(0 4 ) label(N R-sqr ))
*/
/*
esttab   m1 m2 m3 m4 m5 m6 

using "C:\Users\lihon\report\June20\car_`i'_reg_fe.tex", replace ///
nobaselevels    stats(fef fet r2 N, labels("Firm FE" "Year FE" "Adj R-square")  )     booktabs star(* 0.10 ** 0.05 *** 0.01) ///  
 mtitle("model 1" "model 2" "model 3" "model 4"  "model 5" "model 6" )  
 }
 *
 *
 egen rank = rank(taxdiff ), unique
egen tax_group=cut(rank), group(10) 

 * Big tax difference group
 */
 /*
tab NAICS ,sort
   reghdfe `car1' foreign  taxdiff  total_cites pac_size vreal if NAICS=="334413" ,  absorb(PERMNO  year)  vce(robust)
   reghdfe car1 foreign  taxdiff  total_cites pac_size vreal if NAICS=="334413" ,  absorb(PERMNO  year)  vce(robust)
   reghdfe car1 foreign   total_cites pac_size vreal if NAICS=="334413" ,  absorb(PERMNO  year)  vce(robust)
   reghdfe car1   taxdiff  total_cites pac_size vreal if NAICS=="334413" ,  absorb(PERMNO  year)  vce(robust)
   reghdfe car1   taxdiff  total_cites pac_size vreal if NAICS=="513210" ,  absorb(PERMNO  year)  vce(robust)
   reghdfe car1   taxdiff  total_cites pac_size vreal if NAICS=="325412" ,  absorb(PERMNO  year)  vce(robust)
   reghdfe car1   taxdiff  total_cites pac_size vreal if NAICS=="325414" ,  absorb(PERMNO  year)  vce(robust)

 duplicates drop
egen rank = rank(taxdiff ), unique
egen tax_group=cut(rank), group(10)

 bysort tax_group:sum taxdiff
keep if tax_group ==  9
keep PERMNO evtdate  

keep PERMNO evtdate  evttime car* taxdiff tax_group
keep  if tax_group ==9
 
 
 



estpost tabstat  decile taxdiff, c(stat) stat(mean median sd min max n)  
esttab using "Finals.tex", replace cells("mean(fmt(%13.4fc)) median(fmt(%13.4fc)) sd(fmt(%13.4fc)) min max count(fmt(%13.0fc))") nonumber  nomtitle nonote noobs label booktabs f  collabels("Mean" "Median" "SD" "Min" "Max" "N")



keep PERMNO evtdate  evttime car* taxdiff tax_group
keep  if tax_group ==9
sort taxdiff
drop if taxdiff  >=0
count
sort PERMNO evtdate
reg car0 foreign  if tax_group ==9
reg car1 foreign if tax_group ==9
duplicates drop PERMNO evtdate,force
reg car0 taxdiff
duplicates drop PERMNO evtdate,force
keep PERMNO  evtdate

format %tdNN/DD/CCYY evtdate
export delimited using "C:\Users\lihon\OneDrive - Kent State University\aaaa\event_Study\Big_diff_permno_evtDate.csv", delimiter(tab) replace

gen car001=car0/pac_size

////////////////////////
  local car1 car0_w

 reghdfe  `car1' taxdiff ,  absorb(PERMNO year) vce(robust) 
  estadd local fef Yes
 estadd local fet Yes
est store m1, title(model 1)

 reghdfe  `car1'   roa,  absorb(PERMNO year)   vce(robust)
  estadd local fef Yes
 estadd local fet Yes
est store m2, title(model 2)

 reghdfe `car1'   pac_size,   absorb(PERMNO year)  vce(robust)
  estadd local fef Yes
 estadd local fet Yes
est store m3, title(model 3) 

 reghdfe `car1'    vreal,   absorb(PERMNO year)  vce(robust)
  estadd local fef Yes
 estadd local fet Yes
est store m4, title(model 4)   
 
 reghdfe `car1'    total_cites     ,  absorb(PERMNO year)  vce(robust)
  estadd local fef Yes
 estadd local fet Yes
est store m5, title(model 5)

 reghdfe `car1' roa  at taxdiff  total_cites pac_size vreal ,  absorb(PERMNO year)  vce(robust)
  estadd local fef Yes
 estadd local fet Yes
est store m6, title(model 6)
*/