use "D:\Research\patent\data\wrds_names\parent_sub_name_only_stacked.dta" 
duplicates drop gvkey coname location country_code, force
count
duplicates drop gvkey coname, force
count
gen len_name = length(coname )
gsort len_name
list if gvkey=="063417"
list coname if gvkey=="063417"
list coname if gvkey=="028314"
list coname if gvkey=="063417"
list coname if gvkey=="028314"
list coname if gvkey=="063417"
count if gvkey=="063417"
duplicates drop gvkey coname, force
list coname if regexm( coname ,"^TeleTe") & gvkey=="063417"

stnd_compname  coname , gen(std_sub_name stn_dbaname stn_fkaname entitytype attn_name)
count if !missing(attn_name)
count if !missing(stn_dbaname)
count if !missing(stn_fkaname)
save "D:\Research\patent\data\wrds_names\std06122024_parent_sub_name_only_stacked.dta" ,replace
duplicates drop gvkey std_sub_name, force

drop if missing(std_sub_name )
count
sort gvkey coname

insobs 1
replace gvkey = " 163120     Herbalife International Finland OY c/o Hanes " in 913848
replace gvkey = " 163120" in 913848
replace coname = " Hanes " in 913848
replace country_code = "FI" in 913848
drop attn_name

keep gvkey stn_dbaname stn_fkaname
duplicates drop gvkey stn_dbaname stn_fkaname, force

rename stn_dbaname  coname
clonevar  std_sub_name =coname
count
use D:\Research\patent\data\wrds_names\std06122024_parent_sub_name_only_stacked.dta,clear
duplicates drop gvkey stn_dbaname stn_fkaname, force
keep gvkey stn_dbaname stn_fkaname
count
drop if missing( stn_dbaname) & missing( stn_fkaname)
count

use D:\Research\patent\data\wrds_names\std06122024_parent_sub_name_only_stacked.dta,clear
count if !missing(stn_dbaname)
count if !missing(stn_fkaname)
count
drop if missing(gvkey)
save, replace
count
count if !missing(stn_dbaname)
!missing(stn_fkaname)
keep if !missing(stn_fkaname) | !missing(stn_dbaname)
count

keep gvkey location country_code State y_report   std_sub_name stn_dbaname stn_fkaname
replace      stn_dbaname  =stn_fkaname  if  missing(stn_dbaname)  &  !missing(stn_fkaname)
replace std_sub_name = stn_dbaname if !missing(stn_dbaname)
drop stn_dbaname stn_fkaname
clonevar  coname=std_sub_name

save std06122024_parent_sub_name_only_stacked_dba_fka
use  D:\Research\patent\data\wrds_names\std06122024_parent_sub_name_only_stacked.dta

drop stn_dbaname stn_fkaname
save parent_sub_name_stackedV2
count
use  std06122024_parent_sub_name_only_stacked_dba_fka
use  parent_sub_name_stackedV2
count
use  std06122024_parent_sub_name_only_stacked_dba_fka
use  parent_sub_name_stackedV2
use  std06122024_parent_sub_name_only_stacked_dba_fka
gen len_name = length(coname)
save, replace

use  parent_sub_name_stackedV2
append using std06122024_parent_sub_name_only_stacked_dba_fka
count
sort len_name
drop if len_name ==1
pwd
unique gvkey
duplicates drop gvkey std_sub_name,force
count
save parent_gvkey_name_only_v2
list gvkey if coname=="owned subsidiaries:"
drop if  coname=="owned subsidiaries:"
save "parent_gvkey_name_only_v2.dta", replace
unique gvkey
count
disp 149382- 20691
