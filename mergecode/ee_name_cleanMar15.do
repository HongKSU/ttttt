replace ee_name = "3D SYSTEMS, INC." if regexm(ee_name,"3D SYSTEEMS, INC.")

use kpss.dta
unique patent_num
Number of unique values of patent_num is  3160453
Number of records is  3160453

unique permno
Number of unique values of permno is  8547
Number of records is  3160453

list permno if patent_num == "6140009"

if list ee_name if ustrregexm(ee_name, "^\W+")
replace ee_name = regexr(ee_name, "[,@!*]","") if  ustrregexm(ee_name, "^[,@!*]")

replace  ee_name = "KT CORPORATION"  if ee_name == "50% INTEREST TO KT CORPORATION"

replace  ee_name = regexr(ee_name, "^[\(]?50% INTEREST[\)]?","") if ustrregexm(ee_name, "^[\(]?50% INTEREST[\)]?")

replace ee_name = regexr(ee_name, "^[.]","")  if ustrregexm(ee_name, "^[.]")strtrim
replace ee_name = strtrim(ee_name) if ustrregexm(ee_name, "^\s")
replace ee_name_clean  ustrregexs(0) if ustrregexm(ee_name, "^\W+")
