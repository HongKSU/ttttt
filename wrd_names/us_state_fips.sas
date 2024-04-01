/*
SAS State and ZIP code functions:
TFIPS   returns a numeric U.S. Federal Information Processing Standards (FIPS) code. 
STNAME  returns an uppercase state name. 
STNAMEL returns a mixed case state name.
FIPNAME returns uppercase state names. 
FIPNAMEL returns mixed case state names. 
FIPSTATE returns a two-character state postal code (or worldwide GSA geographic code for U.S. territories) in uppercase.
1. FIPNAMEL(U.S. FIPS code, eg. 37) -> NORTH CAROLINA
2. FIPNAME (U.S. FIPS code  eg. 37) -> North Carolina
3. FIPstate(U.S. FIPS code  eg. 37) -> NC
4. STfips( two-character standard state postal code, eg. 'NC')-->  stfips('NC') --> 37; 
5. STname  -->                                                     stname('NC') --> NORTH CAROLINA
6. STnameL                                                         stnamel('NC')--> North Carolina

*AQ BQ CQ DQ GQ HQ JQ KQ MQ NQ PQ RQ VQ WQ;
*/
data stateAbb_;
length comp_stcode $2;
input comp_stcode    $   @@;
datALINES;
AK  AL  AR  AZ  CA  CO  CT  DC  DE  FL  
GA  GU  HI  IA  ID  IL  IN  KS  KY  LA  
MA  MD  ME  MI  MN  MO  MS  MT  NC  ND  
NE  NH  NJ  NM  NV  NY  OH  OK  OR  PA  
PR  RI  SC  SD  TN  TX  UT  VA  VI  VT  
WA  WI  WV  WY  MP  AS  UM  MH  FM  PW   
TT 
;
run;
data stateAbb;
set stateAbb_;
  state_name = stnamel(comp_stcode);
run;

/*USE GLCs for state and U.S. Territories
https://www.gsa.gov/reference/geographic-locator-codes/glcs-for-the-us-and-us-territories
https://en.wikipedia.org/wiki/List_of_U.S._state_and_territory_abbreviations
https://communities.sas.com/t5/SAS-Programming/Convert-Full-State-Name-to-Abbreviation/td-p/738723
*/
data stateAbb_1;
length comp_stcode $2;
input comp_stcode    $   @@;
datALINES;
 AQ 
 BQ CQ DQ GQ HQ JQ KQ MQ NQ PQ RQ VQ 
 WQ
;
run;
data stateAbb_1;
set stateAbb_1;
  state_name = stnamel(comp_stcode);
run;

/*
https://communities.sas.com/t5/SAS-Programming/convert-state-abbreviations-to-full-names/td-p/533742
https://stats.oarc.ucla.edu/sas/faq/how-can-i-access-and-use-sas-zip-code-data-files-for-the-united-states/
*/
data _ddddele_;
set sashelp.zipcode;
run;
/*
Fips:
The FIPS codes for counties already includes the FIPS codes for the state. https://transition.fcc.gov/oet/info/maps/census/fips/fips.txt
https://stackoverflow.com/questions/76740958/sas-data-filtering-question-im-trying-to-filter-and-narrow-down-a-large-datase
*/
