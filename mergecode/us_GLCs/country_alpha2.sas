************************************************************************************;
*Import Country Tax Rate;
* input file:      C:\Users\lihon\OneDrive - Kent State University\Patent_assignment\taxratet\country_tax_rate.dta;
* Date: April, 1st, 2024
************************************************************************************;

/**************************************************************************************
* Country Code
* Date: April, 1st, 2024
*
* https://blogs.sas.com/content/sgf/2016/08/19/maps-mapsgfk-and-mapssas-oh-my/
*
* https://www.iban.com/country-codes/
* Note: use upcase(IDNAME) to match 
************************************************************************************/
proc print data= mapsgfk.world_attr (obs=10);
* world_attr.isoalpha3;
* isoalpha2=b.country; 
run;
%contents( mapsgfk.world_attr)
data _testtt_;
set mapsgfk.world_attr;
*if ID NE ISOALPHA2;
if upcase(IDNAME) NE ISONAME;
run;
proc sql;
select * from mapsgfk.world_attr
/*where ID in ("SK" "SV");*/
where upcase(IDNAME)
quit;

%unique_values( mapsgfk.world_attr,var_name1 = ISOALPHA2, var_name2 =ISOALPHA3)

************************************************************************************;
*C:\Users\lihon\OneDrive - Kent State University\Patent_assignment\taxratet\country_tax_rate.dta;


%importstat(infile="C:\Users\lihon\OneDrive - Kent State University\Patent_assignment\taxratet\country_tax_rate.dta"
,outfile=country_tax)
data country_taxrate;
    set country_tax;
    if      Tax_country_name = "Bolivia"       then Tax_country_name= "Bolivia, Plurinational State of";
    else if Tax_country_name = "DEM REP CONGO" then Tax_country_name="Democratic Republic of Congo";
    else if Tax_country_name = "Guernsey"      then Tax_country_name="Bailiwick of Guernsey";
    else if Tax_country_name = "Hong Kong"     then Tax_country_name="Hong Kong";
    else if Tax_country_name = "Jersey"        then Tax_country_name="Bailiwick of Jersey";
    else if Tax_country_name = "KOREA (REP.)"  then Tax_country_name="North Korea";
    else if Tax_country_name = "Macau"         then Tax_country_name="Macao";
    else if Tax_country_name = "Russia"        then Tax_country_name="Russian Federation";
    else if Tax_country_name = "Taiwan"        then Tax_country_name="Taiwan, Province of China";
    else if Tax_country_name = "Tanzania"      then Tax_country_name="Tanzania, United Republic of";
    else if Tax_country_name = "Venezuela"     then Tax_country_name="Venezuela, Bolivarian Republic of";
    else if Tax_country_name = "Vietnam"       then Tax_country_name="Viet Nam";
run;
 /* Hong Kong is not in the table of "mapsgfk.world_attr"

https://www.iban.com/country-codes
*/ 

 proc sort data=mapsgfk.world_attr out= _temp3_;
 by IDNAME;
 run;
 proc sql;
   insert into _temp3_
      set ID='HK',
          IDNAME='Hong Kong',
          ISOALPHA2='HK',	
          ISOALPHA3='HKG',
          ISONAME='Hong Kong'
      set ID='MO',
          IDNAME='Macao',
          ISOALPHA2='MO',	
          ISOALPHA3='MAC',
          ISONAME='Macao';
          quit;       
run;

proc sql;
create table country_taxrate_all as 
select a.fyendyr
       ,a.TR
       ,a.TR_US
       ,a.tax_country_name
       ,b.*
    from country_taxrate as a
       left join
         _temp3_ b
     on  upcase(strip(tax_country_name)) =  upcase(strip(b.IDNAME));
    quit;
run;

  
    
 

 proc freq data= Or_ee_trans_tax;
 table ee_country;
 run;
  proc freq data= Or_ee_trans_tax;
 table or_fic;
 run;

/********************Merge countries with or and ee */

************************************************************************************;
*Merge Sate tax;
* April 1st, 2024
* Merge:
*      or_ee_trans_tax 
*      country_taxrate_all 
 merge Keys:
 *       b.state as or_state ;
*       ,b.fic as or_fic;
************************************************************************************; 
 proc freq data=or_ee_trans_tax;
 table ee_country;
 run;

proc sql;
create table _ee_country as
select distinct ee_country from or_ee_trans_tax;
quit;

proc sql;
create table __ee_country_merge as
select a.*,
       b.*
       from _ee_country a
       left join country_taxrate_all b
       on upcase(a.ee_country) = upcase(b.IDNAME);
       quit;
       run;

proc sql;
select distinct ee_country
from     __ee_country_merge 
where tax_country_name is missing;
quit;
/************************************************************************************; 
EE_names NOT matched :
NEED to fix the following ee_countries On weekend;


ALBERTA 
ANTARCTICA 
BRITISH COLUMBIA 
BRITISH INDIAN OCEAN TERRITORY 
CHAD 
CHANNEL ISLANDS 
COCOS (KEELING) ISLANDS 
CURACAO 
ENGLAND 
ENGLAND AND WALES 
EUROPEAN UNION 
GERMAN DEMOCRATIC REPUBLIC 
GREAT BRITAIN 
GUERNSEY 
IRAN, ISLAMIC REPUBLIC OF 
JERSEY 
KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF 
KOREA, REPUBLIC OF 
MACAU 
MANITOBA 
MARSHALL ISLANDS 
NETHERLANDS ANTILLES 
NEWFOUNDLAND AND LABRADOR 
NORTHERN IRELAND 
NOT PROVIDED 
NOTHERN MARIANA ISLANDS 
NOVA SCOTIA 
ONTARIO 
PUERTO RICO 
QUEBEC 
SAMOA 
SAN MARINO 
SASKATCHEWAN 
SCOTLAND 
SEYCHELLES 
STATELESS 
TAIWAN 
VENEZUELA 
VIRGIN ISLANDS, BRITISH 
VIRGIN ISLANDS, U.S. 
WALES 
************************************************************************************/ 


* Merge:
*      or_ee_trans_tax 
*      country_taxrate_all 
 merge Keys:
 *       b.state as or_state ;
*       ,b.fic as or_fic;


proc sql; 
  create table or_ee_trans_tax_ee as 
    select  a.* , b.TR as ee_country_tax, b.TR_US  as US_tax
        from or_ee_trans_tax   a
      left join
         country_taxrate_all b
      on  upcase(a.ee_country) = upcase(b.IDNAME)  and year(a.exec_dt) = b.fyendyr;
 quit;   
/* Convert keep both OR_fic  and  or_country names*/
 proc sql;
    create table or_ee_trans_tax_state_country as 
    select  a.* , b.TR as  or_country_tax, b.IDNAME as or_country  
        from or_ee_trans_tax_ee   a
      left join
          country_taxrate_all     b
      on  upcase(a.or_fic) = upcase(b.ISOALPHA3)  and year(a.exec_dt) = b.fyendyr;
quit; 



 


PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select or_ee_trans_tax_state_country;
RUN;
