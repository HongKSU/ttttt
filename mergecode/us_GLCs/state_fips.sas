proc freq data = country_taxrate_all;
table tax_country_name;
run;

proc print data=country_taxrate_all(obs=10);
run;
%contents(country_taxrate_all)
proc sql obsout=10;
select *   
from or_ee_trans_tax_state_country
where prxmatch("/VIRGIN/", upcase(ee_country));
quit;
run;

proc format;
value Rx 1='Drug X' 0='Placebo';
run;
data exposed;
input Days Status Treatment Sex $ @@;
format Treatment Rx.;
datalines;
179 1 1 F 378 0 1 M
256 1 1 F 355 1 1 M
262 1 1 M 319 1 1 M
256 1 1 F 256 1 1 M
255 1 1 M 171 1 1 F
224 0 1 F 325 1 1 M
225 1 1 F 325 1 1 M
287 1 1 M 217 1 1 F
319 1 1 M 255 1 1 F
264 1 1 M 256 1 1 F
237 0 0 F 291 1 0 M
156 1 0 F 323 1 0 M
270 1 0 M 253 1 0 M
257 1 0 M 206 1 0 F
242 1 0 M 206 1 0 F
157 1 0 F 237 1 0 Mhttps://support.sas.com/edu/addtocart.html?eventId=US_2865540_2865546&ctry=US
249 1 0 M 211 1 0 F
180 1 0 F 229 1 0 F
226 1 0 F 234 1 0 F
268 0 0 M 209 1 0 F
;
run;
proc sort data = exposed ;
by treatment days;
run;
proc lifetest data=Exposed method=lt;
time Days*Status(0);
strata Treatment;
run;


data fips;
  fmtname='$FIPS';
  length fips 8 label $2 start $20 ;
  do fips=1 to 95;
    start=fipnamel(fips);
    if start ne 'Invalid Code' then do;
       label=fipstate(fips);
       output;
    end;
  end;
run;

proc format cntlin=fips ; run;

data test;
 set fips;
 statecode=put(start,$fips.);
run;
