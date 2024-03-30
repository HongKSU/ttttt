/*HITACHI TOUBU SEMICONDUCTOR, LTD., (CHANGED NAME TO HIGASHI NIHON SEMICONDUCTOR TECHNOLOGIES (SAME AS EASTERN JAPAN SEMICONDUCTOR TECHNOLOGIES (TRANSLATED INTO ENGLISH), CHANGED NAME TO RENESAS EASTERN JAPAN SEMICONDUCTOR, INC.)
*/
replace or_name = "RENESAS EASTERN JAPAN SEMICONDUCTOR, INC." if ustrregexm(or_name, "HITACHI TOUBU SEMICONDUCTOR, LTD., \(CHANGED NAME TO HIGASHI NIHON SEMICONDUCTOR TECHNOLOGIES")

/*
VSESOJUZNY NAUCHNO-ISSLEDOVATELSKY I PROEKTNOKONSTRUKTORSKY INSTITUT PO AVTOMATIZIROVANNOMU ELEKTROPRIVOKU V PROMYSHLENNOSTI SELSKOM KHOZYAISTVE I NA TRANSPORTE - RUSSIA, MOSCOW, SADOVO-SPASSKAYA, 1/2, KORPUS 2
*/
replace or_name ="VSESOJUZNY NAUCHNO-ISSLEDOVATELSKY I PROEKTNOKONSTRUKTORSKY INSTITUT"  if regexm(or_name, "VSESOJUZNY NAUCHNO-ISSLEDOVATELSKY I PROEKTNOKONSTRUKTORSKY INSTITUT PO AVTOMATIZIROVANNOMU ELEKTROPRIVOKU V PROMYSHLENNOSTI SELSKOM")




/*

WIS HOLDING COMPANY, INC., WIS HOLDINGS CORP., WESTERN INVENTORY SERVICE, INC., WASHINGTON INVENTORY SERVICE, WIS INTERNATIONAL, INC., LABOR SUPPORT INTERNATIONAL, INC. AND SERVICE SUPPORT INTERNATIONAL, INC.
*/

replace or_name ="WIS HOLDING COMPANY, INC." if regexm(or_name, "WIS HOLDING COMPANY, INC., WIS HOLDINGS CORP., WESTERN INVENTORY SERVICE, INC.")


/*
PURESENSE (ASSIGNMENT FOR THE BENEFIT OF CREDITORS), LLC, A CALIFORNIA LIMITED LIABILITY COMPANY, IN ITS SOLE AND LIMITED CAPACITY AS ASSIGNEE FOR THE BENEFIT OF CREDITORS OF PURESENSE ENVIRONMENTAL, INC.

BLUESMART (ASSIGNMENT FOR THE BENEFIT OF CREDITORS), LLC, A CALIFORNIA LIMITED LIABILITY COMPANY (THE "SELLER"), IN ITS SOLE AND LIMITED CAPACITY AS ASSIGNEE FOR THE BENEFIT OF CREDITORS OF BLUESMART INC.

*/
drop if ustrregexm(or_name, " \bCREDITORS\b")

/*
LEENA HANNONEN - CAPITALIZED MEANING NOT DEFINED HEREIN HAS THE MEANING AS DEFINED WITHIN THE TERMS AND CONDITIONS OF THE AGREEMENT TO AND INTO WHICH THE CAPITALIZED NAME IS INCORPORATED BY REFERENCE
*/
replace or_name ="LEENA HANNONEN" if regexm(or_name, "LEENA HANNONEN")

/*
V TECHNOLOGY USA, INC., (FORMERLY KNOWN AS AOI SYSTEMS, INC. AND FOCUS AOI, INC., AND SUCCESSOR IN INTEREST TO ITEK CORPORATION THROUGH THE PURCHASE AND SALE OF CERTAIN ASSETS FROM ITEK CORPORATION)
*/

 replace or_name = "AOI SYSTEMS" if ustrregexm(or_name, "V TECHNOLOGY USA, INC., \(FORM")

/*

PHYSIO-CONTROL INTERNATIONAL, INC /K/A MEDTRONIC EMERGENCY RESPONSE SYSTEMS INTERNATIONAL, INC., F/K/A MEDTRONIC PHYSIO-CONTROL INTERNATIONAL, INC., F/K/A MEDTRONIC PHYSIO-CONTROL, INC.
*/
replace or_name = "MEDTRONIC PHYSIO-CONTROL MANUFACTURING CORP." if ustrregexm(or_name, "\bPHYSIO-CONTROL INTERNATIONAL\b")


/*
EASTFIELD CORPORATION AND SHAREHOLDERS AS FOLLOWS MARTIN J. COHEN, ANN SAWYER KREMER, CARL P. KREMER, JR. WILLIAM J. NIGHTINGALE, MARK O. POWERS, JOSEPH E. SILVERMAN AND FRANCIS F. SCHLEY
*/

replace or_name = "EASTFIELD CORPORATION AND SHAREHOLDERS" if regexm(or_name, "EASTFIELD CORPORATION AND SHAREHOLDERS AS FOLLOWS MARTIN J. COHEN, ANN SAWYER")

/*
DE STAAT DER NEDERLANDEN, VERT. DOOR DE MINISTER VAN VOLKSGEZONDHEID, WELZIJN EN SPORT, NAMENS DE MINISTER, PROJECTDIRECTIE ALT, HET INSTITUUT VOOR TRANSLATIONELE VACCINOLOGIE (INTRAVACC)

*/

replace or_name = "DE STAAT DER NEDERLANDEN, VERT."  if regexm(or_name, "DOOR DE MINISTER VAN VOLKSGEZONDHEID, WELZIJN EN SPORT")

/*CHEMTURA CORPORATION, F/K/A CROMPTON CORPORATION, SUCCESSOR BY MERGER TO CHEMTURA USA CORPORATION, INC., F/K/A CROMPTON MANUFACTURING COMPANY, INC., F/K/A UNIROYAL CHEMICAL COMPANY, INC.
*/
replace or_name = "CHEMTURA CORPORATION" if  regexm(or_name, "CROMPTON CORPORATION, SUCCESSOR BY MERGER TO CHEMTURA USA CORPORATION, INC")



AUSTRALIAN INSTITUTE OF MARINE SCIENCE (A STATUTORY CORPORATION ESTABLISHED BY SECTION 7 OF THE AUSTRALIAN INSTITUTE OF MARINE SCIENCE ACT 1972) (AUSTRALIAN BUSINESS NO. 78 961 616 230)

replace or_name = "AUSTRALIAN INSTITUTE OF MARINE SCIENCE" if regexm(or_name, "AUSTRALIAN INSTITUTE OF MARINE SCIEN")


ROCHESTER PHOTONICS CORPORATION (REFERRED TO IN ATTACHED AS CORNING ROCHESTER PHOTONICS CORPORATION TO SHOW THAT THE CORPORATION WAS A PART OF CORNING, INC. AT THE TIME OF EXECUTION).

replace or_name = "ROCHESTER PHOTONICS CORPORATION"  if ustrregexm(or_name, "ROCHESTER PHOTONICS CORPORATION \(REFERRED")

/*
WOLRIDGE MAHON LIMITED IN ITS CAPACITY AS AN INSTRUMENT APPOINTED RECEIVER OF THE UNDERTAKING, PROPERTY AND ASSETS OF SHARP PLASTICS MANUFACTURING LTD. AND ROCK CLIFFE COATINGS LTD.
*/
replace or_name ="WOLRIDGE MAHON LIMITED" if regexm(or_name, "WOLRIDGE MAHON LIMITED IN ITS")

/*
MACKEY, WILLIAM GAWEN AND WILLIAM MORYS ROBERT JOINT RECEIVERS AND MAN AGERS AS ATTORNEYS FOR AND ON BEHALF OF STONE-PLATT FLUID FIE LIMITED WILLIAM G. MACKEY AND WILLIAM M. ROBERTS
*/

drop if regexm(or_name, "MACKEY, WILLIAM GAWEN AND WILLIAM MORYS ROBERT JOINT")



replace or_name ="MARCOR RESORTS L.P." if regexm(or_name, "MARCOR RESORTS L.P. V")
MARCOR RESORTS L.P. V, A LIMITED PARTNERSHIP ORGANIZED UNDER THE LASW OF THE STATE OF NEVADA AND HAVING AS ITS GENERAL PARTNER MARCOR RESORT PROPERTIES, INC., A NAVADA CORPORATION

SIEMENS NIXDORF INFORMATIONSSYSTEME GMBH (FORMERLY SIEMENS NIXDORF INFORMATIONSSYSTEME AG WITH CHANGE OF NAME AS REGISTERED IN MUNICH, GERMANY ON JUNE 11, 2003, REISTRY ATTACHED)

replace or_name ="SIEMENS NIXDORF INFORMATIONSSYSTEME GMBH" if ustrregexm(or_name, "SIEMENS NIXDORF INFORMATIONSSYSTEME GMBH \(")

SALTON/MAXIM HOUSEWARES GROUP, AN ILLINOIS GENERAL PARTNERSHIP CONSISTING OF SALTON HOUSEWARES, INC. (AN ILLINOIS CORPORATION) AND FINANCO/MAXIM, INC. (A NEW JERSEY CORPORATION)

replace or_name ="SALTON/MAXIM HOUSEWARES GROUP"  if regexm(or_name, "SALTON/MAXIM HOUSEWARES GROUP")

replace or_name ="COLORADO FUND I, L.P."  if regexm(or_name, "COLORADO FUND I, L.P.")


COLORADO FUND I, L.P. ON ITS OWN BEHALF AND AS BOTH AGENT FOR, AND COLLATERAL AGENT FOR SURGINETICS, INC. SERIES A-1 AND SERIES A-2 STOCKHOLDERS AND AWEIDA VENTURE PARTNERS


replace or_name ="POLARIS INDUSTRIES L.P."  if regexm(or_name, "POLARIS INDUSTRIES L.P.")
POLARIS INDUSTRIES L.P., BY ITS OPERATING GENERAL PARTNERS, POLARIS INDUSTRIES ASSOCIATES L.P., BY ITS MANAGING GENERAL PARTNER, POLARIS INDUSTRIES CAPITAL CORPORATION

replace or_name = "CEASE FIRE L.P." if regexm(or_name, "CEASE FIRE L.P.")
CEASE FIRE L.P., A DE LIMITED PARTNERSHIP CONSISTING OF CEASE FIRE CORPORATION, A DE CORP. A GENERAL PARTNER, AND C.F. VENTURE CORP., A CORP. OF DE, A LIMITED PARTNER
197481-194427

/*
Spelling Error
*/
replace or_name = `OBSHESTVO S OGRANICHENNOY OTVETSTVENNOSTYU "SINEZIS"' if or_name ==`OBSHESTVO S OGRANICHENNOY OTVETSTVENNOSTYU "SINEZIS"'