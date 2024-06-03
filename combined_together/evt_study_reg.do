esttab m* using "C:\Users\lihon\report\car1.tex", replace ///
nobaselevels longtable  eform label booktabs star(* 0.10 ** 0.05 *** 0.01) ///  
title("Main results of CAR from CAPM model around record date ") mtitle("model 1" "model 2" "model 3" "model 4")  


 gen taxdiff=or_country_tax - ee_country_tax
 gen foreign = 1 if upper(or_country)!=upper(ee_country)
 replace foreign = 0 if missing(foreign)
 
 gen bvEqity = PRCC_F * CSHO
 label variable bvEqity "BookValue"
 
 gen capIntens = CAPX/AT
 gen cashFlow = (IBC+DP)/AT
 gen cashHoldings = CHE/AT
*gen costcap = XINT/DLC

gen leverages = (DLTT + DLC)/SEQ

gen roa = NI/AT
gen TobinsQ = (AT +bvEqity - CEQ)/AT

label variable LT "Total Liabilities"
label variable AT "Total Assets"
label variable capIntens "Capital Intensity"
label variable cashFlow "Cash Flow"
label variable cashHoldings "Cash Holdings"
*label variable costcap "Cost of Capital"
label variable leverages "Leverage"
label variable roa "ROA"
label variable  TobinsQ "TobinsQ"

 local car1 car 
regress  `car1' foreign ,vce(robust)
est store m1, title(model 1)
reg  `car1' foreign us_grant,    vce(robust)
est store m2, title(model 2)
reg `car1' foreign pac_size,    vce(robust)
est store m3, title(model 3) 
reg `car1' foreign  vreal,    vce(robust)
est store m4, title(model 4)   
 
reg `car1' foreign  total_cites pac_size   ,   vce(robust)
est store m5, title(model 5)

reg `car1' foreign  taxdiff total_cites pac_size vreal ,   vce(robust)
est store m6, title(model 6)

local car1 car 
  reg `car1'    taxdiff,   vce(robust)
est store m7, title(model 7)

estout m*, cells(b(star fmt(3)) se(par fmt(2)))  legend label varlabels(_cons Constant)  stats( df_r r2, fmt(0 4 ) label(N R-sqr ))
estout m1 m2 m3, cells(b(star fmt(3)) se(par fmt(2)))  legend label varlabels(_cons Constant)  stats( df_r r2, fmt(0 4 ) label(N R-sqr ))
  local car1 car20 
  local covar foreign car_50-car_20
  local covar_comp1 foreign  AT   leverages bvEqity
  local covar_comp2   foreign  AT  roa   leverages bvEqity
    local covar_comp3 foreign  AT  roa   LCT leverages bvEqity
	    local covar_comp4 foreign  AT  roa   LCT leverages bvEqity TobinsQ 
		local covar_comp5 foreign  AT  roa   LCT leverages bvEqity TobinsQ taxdiff
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

estout m7 m8, cells(b(star fmt(3)) se(par fmt(2)))  legend label varlabels(_cons Constant)  stats( df_r r2, fmt(0 4 ) label(N R-sqr ))
