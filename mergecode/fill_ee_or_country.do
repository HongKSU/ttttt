   *April, 17;
   log using fill_ee_or_country, append smcl name(fill_ee_or_country) 
   use C:\Users\lihon\Downloads\merge_back\or_ee_trans_tax_state_country.dta
   replace ee_country ="UNITED STATES" if !missing(ee_state) & missing(ee_country)
   replace relation = 0 if missing(relation)
   
   replace or_state ="" if or_fic=="CAN"
   replace or_state ="" if inlist(or_state, "BC","ON","QC", "AB", "SK","NS","MB","NF")
   * missing(or_country),  2,442
   rename or_fic ISOALPHA3 // for merge with _sas_country_names
save "C:\Users\lihon\Downloads\merge_back\or_ee_trans_tax_state_country.dta"


use C:\Users\lihon\Downloads\merge_back\_sas_country_names.dta
duplicates  drop ISOALPHA3,force
save, replace

merge m:1  ISOALPHA3 using C:\Users\lihon\Downloads\merge_back\_sas_country_names.dta, keepusing(IDNAME)
rename ISOALPHA3 or_fic
replace IDNAME ="" if missing(or_fic)
drop if _merge == 2
replace or_country = IDNAME if missing(or_country)
drop _merge IDNAME
notes: "cleaned or_country ee_country, 4/17/2024"

* afer fill ee_country, refill the missing tax for USA
gen fyendyr = year(exec_dt)
gen country = upper(ee_country)
merge m:1 country fyendyr using "C:\Users\lihon\OneDrive - Kent State University\Patent_assignment\taxratet\us_tax_rate0417.dta",keepusing(TR_US)
replace ee_country_tax = TR_US if missing(ee_country_tax) & country == "UNITED STATES"
/*
relation==1 & upper(ee_country)!=upper(or_country) &missing(country_tax_diff)&or_fic=="USA"
 upper(ee_country)!=upper(or_country) &missing(or_country_tax)
relation==1 & upper(ee_country)!=upper(or_country) &missing(or_country_tax)&or_fic=="USA"
*/
drop country 
drop _merge TR_US deciles
gen foreign_tran = 1 if upper(ee_country)!=upper(or_country) & relation==1
replace foreign_tran = 0 if missing(foreign_tran)
save, replace
**# Bookmark #1
