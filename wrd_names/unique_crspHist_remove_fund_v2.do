/*
Read in the SAS processed comp_all firms, then here we do:
1. delete non_firm entries
2. standardize both names
3. leave the entity type
input:
  "D:\Research\patent\data\wrds_names";
  "D:\Research\patent\data\wrds_names\com_all_names_unique.sas7bdat"
output:
      "D:\Research\patent\data\wrds_names\com_all_names_unique_std.dta" 
. count
  113,981 v1
  114,427 v2

*/
*local  compall "D:\Research\patent\data\wrds_names\com_all_names_unique.sas7bdat"
	           
*use "D:\Research\patent\data\wrds_names\SMALL_CRSP_HIST.dta" 
 

clear
import sas conm conmL gvkey fic loc costat idbflag city naics sic county state ipo_y start_y end_y global using  "D:\Research\patent\data\wrds_names\com_all_names_unique.sas7bdat"
/*"`comp_all'"*/

/*format ipodate year1 year2 year2 %tdCCYYNNDD
*format rf_id %10.0f
format rf_id %10.0f
 
list comnam if GVKEY =="178855" | GVKEY== "145512"
list GVKEY comnam if GVKEY =="178855" | GVKEY== "145512"

list gvkey conm if inlist(gvkey, "178855", "145512")
list gvkey conm year1 year2 if inlist(gvkey, "178855", "145512")
list gvkey conm  start_year end_year if inlist(gvkey, "178855", "145512")
list gvkey conm  start_year end_year ipodate ipodate if inlist(gvkey, "178855", "145512")
list gvkey conm  start_year end_year ipodate ipodate if inlist(gvkey, "178855", "145512")
list gvkey conm  start_year end_year ipodate   if inlist(gvkey, "178855", "145512"), sepby(gvkey)

*keep if inlist(gvkey, "178855", "145512")
*save  test_comp_all2Gvkey



list gvkey conm  start_year end_year  ipo_y if inlist(gvkey, "178855", "145512")
bysort gvkey: gen dup=cond(_N==1,0, _n)
list conm conmL ipo_y if gvkey=="013888"
list conm conmL if missing(conm) |missing(conmL) | missing(gvkey)

*/
gen conmL_c = upper(conmL)
*clonevar conmL=conmL_c
replace conmL = conmL_c
gen first_letter = substr(conm, 1,1)
*tab first_letter
*list conm conmL ipo_y  *_y if gvkey=="013888"
*drop if missing(conm)
replace conm=upper(conmL) if missing(conm) & !missing(conmL)
*list conm conmL if missing(conmL)
replace conmL = conm if missing(conmL) & !missing(conm)
label variable conmL "Upper conmL"

stnd_compname conmL, gen(std_conmL dba fka entity attn)
stnd_compname conm, gen(std_conm dba1 fka1 entity1 attn1)
gen len_std =length(std_conmL)
 
*drop if len_std>59
drop attn* dba* fka1 

replace entity = fka   if missing(entity) &!missing(fka)
replace entity =entity1 if missing(entity) &!missing(entity1)
drop fka entity1
/* label the generated var*/
label variable std_conmL "standarize CONML-legal company name"

label variable std_conm "standarize HCONM- company name"
label variable first_letter "First letter of firm for blocking"

*count if ustrregexm(upper(conmL),"\bSHARES\b$")
*list conmL  if !ustrregexm(upper(conmL),"\bSHARES\b$") &  ustrregexm(std_conmL,"\bSHARES\b$")

*count if ustrregexm(std_conmL, "(ETF|ETN)$")
drop if ustrregexm(std_conmL, "(ETF|ETN)$")
*count if ustrregexm(upper(conmL), "FUND$")
*count if ustrregexm(std_conmL, "FUND$")
drop if ustrregexm(upper(conmL), "FUND$")

*count if ustrregexm(std_conmL,"\bSHARES\b$")


 
//Delete note due
drop if ustrregexm(std_conmL,"\bDUE[ ][0-9]+\b")
drop if ustrregexm(upper(conmL),"\bSHARES\b$")
drop if len_std > 20 &ustrregexm(std_conmL,"\bPORTFOLIO\b$")
drop if ustrregexm(conmL,"\bDUE[ ][0-9]+\b")
drop if ustrregexm(upper(conmL),"\bDUE[ ][A-Z]*[0-9]*\b")
//tab HNAICS
// HNAICS might NOT be useful
*drop if naics == "525910"
*count
*drop if naics == "522320"


*drop if len_std > 50

//drop if ustrregexm(upper(conmL), "\bSECURITIES\b")
//drop if ustrregexm(upper(conmL), "\bTRUST$\b")
drop if ustrregexm(upper(conmL), "\bINDEX$\b")
*drop if ustrregexm(upper(conmL), "\bFUND[S]?\b")
drop if ustrregexm(upper(conm), "\bETF[ -][A-Z]*$\b")
drop if ustrregexm(upper(conmL), "\bETF[ -][A-Z]*$\b")
/* country location
and state */

 
replace fic=loc if missing(fic) &!missing(loc)
replace loc=fic if !missing(fic) &missing(loc)

levelsof state if fic!="USA" & loc!="USA"
*count if inlist(state, "CA", "CO", "MA",  "NY", "PA",  "TX", "WA") & fic!="USA" & loc!="USA"
replace state="" if  inlist(state, "CA", "CO", "MA",  "NY", "PA",  "TX", "WA") & fic!="USA" & loc!="USA"


*Duplicates in terms of conm conmL
duplicates drop  conm conmL, force
     
save com_all_names_unique_std, replace
