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
options nolabel;
libname mergback "C:\Users\lihon\Downloads\merge_back";
/*
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
*where ID in ("SK" "SV");*
where upcase(IDNAME)
quit;

%unique_values( mapsgfk.world_attr,var_name1 = ISOALPHA2, var_name2 =ISOALPHA3)

************************************************************************************;
*C:\Users\lihon\OneDrive - Kent State University\Patent_assignment\taxratet\country_tax_rate.dta;
*/


%importstata(infile="C:\Users\lihon\OneDrive - Kent State University\Patent_assignment\taxratet\country_tax_rate0416.dta"
,outfile=country_tax)
/*;
Recode the country name in international country tax data 
to IDNAME in SAS built-in data  mapsgfk.world_attr
*/

data country_taxrate;
    set country_tax; 
    IF      upcase(TAX_COUNTRY_NAME) = "BOLIVIA"       THEN TAX_COUNTRY_NAME= "BOLIVIA, PLURINATIONAL STATE OF";
    ELSE IF upcase(TAX_COUNTRY_NAME) = "DEM REP CONGO" THEN TAX_COUNTRY_NAME= "DEMOCRATIC REPUBLIC OF CONGO";
    ELSE IF upcase(TAX_COUNTRY_NAME) = "GUERNSEY"      THEN TAX_COUNTRY_NAME= "BAILIWICK OF GUERNSEY";
    ELSE IF upcase(TAX_COUNTRY_NAME) = "HONG KONG"     THEN TAX_COUNTRY_NAME= "HONG KONG";
    ELSE IF upcase(TAX_COUNTRY_NAME) = "JERSEY"        THEN TAX_COUNTRY_NAME= "BAILIWICK OF JERSEY";
    ELSE IF upcase(TAX_COUNTRY_NAME) = "KOREA (REP.)"  THEN TAX_COUNTRY_NAME= "SOUTH KOREA";
                                        
    ELSE IF upcase(TAX_COUNTRY_NAME) = "MACAU"         THEN TAX_COUNTRY_NAME= "MACAO";
    ELSE IF upcase(TAX_COUNTRY_NAME) = "RUSSIA"        THEN TAX_COUNTRY_NAME= "RUSSIAN FEDERATION";
    ELSE IF upcase(TAX_COUNTRY_NAME) = "TAIWAN"        THEN TAX_COUNTRY_NAME= "TAIWAN, PROVINCE OF CHINA";
    ELSE IF upcase(TAX_COUNTRY_NAME) = "TANZANIA"      THEN TAX_COUNTRY_NAME= "TANZANIA, UNITED REPUBLIC OF";
    ELSE IF upcase(TAX_COUNTRY_NAME) = "VENEZUELA"     THEN TAX_COUNTRY_NAME= "VENEZUELA, BOLIVARIAN REPUBLIC OF";
    ELSE IF upcase(TAX_COUNTRY_NAME) = "VIETNAM"       THEN TAX_COUNTRY_NAME= "VIET NAM";
run;
 /* Hong Kong is not in the table of "mapsgfk.world_attr"
  Here I  add Hong Kong to the dataset
https://stackoverflow.com/questions/32771303/sas-format-to-convert-country-codes-to-country-names
SAS 9.4 has a new set of maps, the GFK maps, which has a dataset that contains information similar to 
Sashelp.demographics which contains the Country Code but not the country alphanumeric code.
MAPSGFK.WORLD_ATTR has the country name, 
        upcased country name, 
        2 letter alpha, ISO 2 letter alpha, 
         ISO 3 letter alpha, and ISO country code for each country in its list (250 in total).
https://www.iban.com/country-codes

sas help:
https://documentation.sas.com/doc/en/pgmmvacdc/9.4/grmapref/p03gwkwlwxhv5dn1drl3z922qzxd.htm
mapsgfk.world_attr
*/ 

 proc sort data = mapsgfk.world_attr 
           out  = _SAS_country_names_;
    by IDNAME;
 run;

proc sql;
   insert into _SAS_country_names_
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

/* Get more country name representaions (IDNAME, ISO ALPHA3) 
in order to have more matching method

_SAS_country_names_ name:  
  
ID IDNAME      ISO ISOALPHA2 ISOALPHA3   CONT         ISONAME 
KP North Korea 408 KP         PRK         95 KOREA    (DEMOCRATIC PEOPLE'S REPUBLIC OF) 
KR South Korea 410 KR          KOR        95 KOREA    (THE REPUBLIC OF) 

*/
proc sql;
create table country_taxrate_all as 
select a.fyendyr
       ,a.TR
       ,a.TR_US
       ,a.tax_country_name
       ,b.*
    from country_taxrate as a
       left join
         _SAS_country_names_ b
     on  upcase(strip(tax_country_name)) =  upcase(strip(b.IDNAME));
    quit;
run;
/*
Title "Country Tax rate";
proc print data = country_taxrate (obs=5);
run;
proc freq data = country_taxrate;
table fyendyr;
run;

proc print data = country_taxrate_all(obs=20);
run; 
*/
 /*Virgin Islands, British;*/
data _temp_4;
    DO fyendyr=1982 to 2021;
       Ctry_Code = "BV";
       ISOALPHA3 = 'BVI';
       tax_country_name="VIRGIN ISLANDS, BRITISH";
       IDNAME="VIRGIN ISLANDS, BRITISH";
       TR = 0;
       output;
       ISOALPHA3 = "UVI";
       Ctry_Code = "UV";
       tax_country_name = "VIRGIN ISLANDS, U.S.";
       IDNAME = "VIRGIN ISLANDS, U.S.";
       TR = 2.31;
       output;
    end;
run;

proc sql;
    create table _temp_historical_us_Fed_tax as
       select distinct fyendyr, TR_US
       from country_taxrate_all;
run;

proc sql; 
 create table  UVI_BVI as
  select a.Ctry_Code as Ctry_Code
         ,a.fyendyr
         ,a.TR
         ,b.TR_US
         ,a.tax_country_name
         ,IDNAME
         from _temp_4 as a
                 inner join
              _temp_historical_us_Fed_tax as b
         on a.fyendyr = b.fyendyr;
  quit;
run;
 
data country_taxrate_all_my;
  set country_taxrate_all
      UVI_BVI
      ;
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
/*
 proc freq data=or_ee_trans_tax;
 table ee_country;
 run;
*/
proc sql;
create table _ee_country as
select distinct ee_country from or_ee_trans_tax;
quit;

proc sql;
create table __ee_country_merge as
select a.*,
       b.*
       from     _ee_country           a
          left join 
                country_taxrate_all_my b
       on upcase(a.ee_country) = upcase(b.IDNAME);
       quit;
       run;
/*
proc sql;
   select distinct ee_country
    from     __ee_country_merge 
      where tax_country_name is missing;
quit;


proc sql;
Title "All distinct country names in table `country_taxrate_all' ";
select distinct tax_country_name from country_taxrate_all_my
order by tax_country_name;
quit;

*/

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
************************************************************************************;
* Some country names are not correct, or did not show in coutry_taxrate file
* We first standidize them
************************************************************************************;
data or_ee_trans_tax;
  set mergback.or_ee_trans_tax;
run;
proc sql;
    update or_ee_trans_tax
       set ee_country = "CANADA"
         where ee_country in ('ALBERTA','BRITISH COLUMBIA', 'ONTARIO', 'QUEBEC', 'MANITOBA', "NOVA SCOTIA", "NEWFOUNDLAND AND LABRADOR");
    update or_ee_trans_tax
       set ee_country = "BERMUDA"
         where ee_country in ('ANTARCTICA');
    update or_ee_trans_tax
       set ee_country = "United Kingdom"
         where ee_country in ("BRITISH INDIAN OCEAN TERRITORY", "SCOTLAND", "WALES", "NORTHERN IRELAND", "ENGLAND", "GREAT BRITAIN", "ENGLAND AND WALES");
    update or_ee_trans_tax
       set ee_country = "Republic of Chad"
         where ee_country in ("CHAD");
    update or_ee_trans_tax
       set ee_country = "Bailiwick of Jersey"
         where ee_country in ("CHANNEL ISLANDS", "JERSEY");
    update or_ee_trans_tax
       set ee_country = "Australia"
         where ee_country in ("COCOS (KEELING) ISLANDS");
    update or_ee_trans_tax
       set ee_country = "Netherlands"
         where ee_country in ("CURACAO", "NETHERLANDS ANTILLES" );
    update or_ee_trans_tax
       set ee_country = "Bailiwick of Guernsey"
         where ee_country in ("GUERNSEY" );
    update or_ee_trans_tax
       set ee_country = "Germany"
         where ee_country in ("GERMAN DEMOCRATIC REPUBLIC");
    update or_ee_trans_tax
       set ee_country = "Iran"  
         where ee_country in ("IRAN, ISLAMIC REPUBLIC OF");
    update or_ee_trans_tax
       set ee_country = "North Korea"
         where ee_country in ("KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF");
    update or_ee_trans_tax
       set ee_country = "South Korea"
         where ee_country in ("KOREA, REPUBLIC OF");
    update or_ee_trans_tax
       set ee_country = "Venezuela, Bolivarian Republic of"
         where ee_country in ("VENEZUELA");
    update or_ee_trans_tax
       set ee_country = "Iran"
         where ee_country in ("IRAN, ISLAMIC REPUBLIC OF");
    update or_ee_trans_tax
       set ee_country = "TAIWAN, PROVINCE OF CHINA"
         where ee_country in ("TAIWAN");
         
quit;

proc sql;
   update or_ee_trans_tax
       set ee_country = ''
         where ee_country in ("NOT PROVIDED" , "STATELESS");

  update or_ee_trans_tax
       set ee_country = "Luxembourg"    
         where prxmatch("/AAM INTERNATIONAL/", upcase(ee_name));
  update or_ee_trans_tax
      set ee_country = "United Kingdom" 
        where prxmatch("/ARAYNER SURGICAL IN/",upcase(ee_name));
quit;

run;

/*   
data or_ee_trans_tax_ee;
    set or_ee_trans_tax_ee;
set update might be more efficient*/       

/************************************************************************************/ 
* Merge:
*      or_ee_trans_tax 
*      country_taxrate_all 
 merge Keys:
 *       b.state as or_state ;
*       ,b.fic as or_fic;
* April 13, 2024
* Country Tax information: 
* country_taxrate_all_my;

proc sql; 
  create table or_ee_trans_tax_ee as 
    select  a.* 
            ,b.TR     as ee_country_tax
            ,b.TR_US  as US_tax
        from or_ee_trans_tax   a
             left join
            country_taxrate_all_my b
       on upcase(a.ee_country) = upcase(b.IDNAME)  and year(a.exec_dt) = b.fyendyr;
quit;   
/* Convert keep both OR_fic  and  or_country names*/
 proc sql;
    create table or_ee_trans_tax_state_country as 
    select  a.* 
            ,b.TR as or_country_tax
            ,b.IDNAME as or_country  
          from or_ee_trans_tax_ee   a
                  left join
                country_taxrate_all_my b
          on upcase(a.or_fic) = upcase(b.ISOALPHA3)  and year(a.exec_dt) = b.fyendyr;
quit; 
/*
proc freq data = country_taxrate_all_my;
  table IDNAME;
run;
proc freq data = or_ee_trans_tax;
  table ee_country;
run;
*/
/* Deal with missed ee_country and or country

*/
/*
proc sql;
select * from country_taxrate_all_my
where isoalpha3 in ("AUS", 'AUT', 'BEL','AFG', 'LUX');
quit;
run;
proc sql;
select fyendyr from country_taxrate_all_my
where isoalpha3 in ('AFG')
order by  fyendyr desc ;
quit;

proc sql;
    create table _countries_missed_tax as
    select distinct year(exec_dt) as year
                   ,or_fic,IDNAME, ISONAME   
    from  mergback.or_ee_trans_tax_state_country or_ee
      inner join
       _SAS_country_names_     sas_country
    on upcase(or_ee.or_fic) = upcase(sas_country.ISOalpha3)
    where missing(or_country)
    order by or_fic, year;
 quit;

 proc sql;
 select * from _SAS_country_names_
 order by IDNAME ;
 run;

proc sql;
 select * from _SAS_country_names_
 where prxmatch("/^SL/", upcase(IDname));
 quit;

 ods trace on;
proc freq data =_countries_missed_tax  ; 
table year*IDNAME /nopercent nocum norow nocol  
  out=_acountries_missed_tax;
run;

ods trace off;
*/
/*
proc freq data = country_taxrate_all_my ;
table fyendyr;
run;

PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select country_taxrate_all_my;
RUN;

country_taxrate_all_my
*/
proc print data = or_ee_trans_tax_state_country;
     where ee_country_tax is missing and ee_country= "VIRGIN ISLANDS, BRITISH";
run;

Title "Check Country tax rarte";
proc sql;
select distinct   year(exec_dt)   
from or_ee_trans_tax_state_country
where upcase(ee_country)="VIRGIN ISLANDS, BRITISH" and missing(ee_country_tax);
run;
%contents(or_ee_trans_tax_state_country)

PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select or_ee_trans_tax_state_country;
RUN;    




PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  country_tax ;
RUN;
