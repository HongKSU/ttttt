/* Input SMALL_CRSP_HIST.dta
output:  "unique_crspHist_remove_fund.dta"
*/
use "D:\Research\patent\data\wrds_names\SMALL_CRSP_HIST.dta" 
count
unique HCONM
unique HCONML
unique GVKEY
sort HCONM
gen leng_com = length(HCONM)
gsort -leng_com
compress
unique GVKEY
unique HCONM
unique HCONML
unique comnam
stnd_compname comnam, gen(std_nameL)
help label
/* label the generated var*/
label variable std_nameL "standarize HCONML-legal company name"
stnd_compname comnam, gen(std_conmL)
label variable std_conmL "standarize HCONM- company name"
unique GVKEY HCONM
unique GVKEY std_nameL std_conmL
duplicates drop GVKEY std_conmL std_nameL, force
save unique_crspHist.dta
pwd
compress
gen len_name= length(std_conmL)
gen len_nameL = length(std_nameL)
sum len_name len_nameL
gsort -len_name
drop if len_name >76
drop if len_name >69
drop if len_name >59
count
drop if ustrregexm(std_conmL, "(ETF|ETN)$")
count
drop if ustrregexm(std_conmL, "FUND$")
count
drop if ustrregexm(std_conmL,"\bDUE[ ][0-9]+\b")
drop if ustrregexm(std_conmL,"\bSHARES\b$")
drop if len_name > 20 &ustrregexm(std_conmL,"\bPORTFOLIO\b$")

//tab HNAICS
// HNAICS might NOT be useful
drop if HNAICS == "525910"
count
drop if HNAICS == "522320"
drop if len_name > 50
save, replace
count
drop if ustrregexm(std_conmL, "\bSECURITIES\b")
drop if ustrregexm(std_conmL, "\bTRUST$\b")
drop if ustrregexm(std_conmL, "\bINDEX$\b")
drop if ustrregexm(std_conmL, "\bFUND[S]?\b")
unique GVKEY std_conmL
count
gen sub_std_name = substr(std_conmL, 1,2)
list HCONM std_conmL if  missing(sub_std_name)
save unique_crspHist_remove_fund
replace sub_std_name = substr( HCONM , 1,2)
save "unique_crspHist_remove_fund.dta", replace
compress
save, replace
