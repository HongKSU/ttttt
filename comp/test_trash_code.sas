proc sql;
* Contains KOREA (REP.);
select distinct tax_country_name from country_tax 
where prxmatch("/^KOR/", upcase(tax_country_name));
 quit;
proc sql;
* Contains KOREA (REP.);
select distinct tax_country_name from country_taxrate 
where prxmatch("/KOR/", upcase(tax_country_name));
 quit;
 
 * CONTAINS "NORTH KOREA", SOUTH KOREA;
 proc sql;
 Title "_SAS_country_names_";
select   * from _SAS_country_names_
where prxmatch("/KOREA/", upcase(IDNAME));
 quit;
/*
 ID IDNAME ISO ISOALPHA2 ISOALPHA3 CONT ISONAME 
KP    North Korea 408 KP PRK 95 KOREA (DEMOCRATIC PEOPLE'S REPUBLIC OF) 
KR    South Korea 410 KR KOR 95 KOREA (THE REPUBLIC OF) 
*/


*KOREA (REP.) changed to NORTH KOREAR
 proc sql;
 Title "country_taxrate";
select distinct tax_country_name from country_taxrate
where prxmatch("/KOR/", upcase(tax_country_name));
 quit;


 *NOT Contains KOREA (REP.);
 proc sql;
select distinct tax_country_name from country_taxrate_all
where prxmatch("/KOR/", upcase(tax_country_name));
 quit;
 *NOT Contains KOREA (REP.);
 proc sql;
select distinct tax_country_name from country_taxrate_all_my 
where prxmatch("/KOR/", upcase(tax_country_name));
 quit;

 proc sql;
select  *   from  _SAS_country_names_ 
where prxmatch("/UN/", upcase(IDNAME));
 quit;
/* format 
 state abbreviation to long state names
 */
 
data makeFormat;

  /* Make column with format name repeated in each row */
  fmtname='$FIPS';

  /* Following best practice, declare lengths of character columns*/
  length label $ 2 start $20 ;

  /* Create an output row for each FIPS code */
  do fips = 1 to 95;
    start = fipnamel(fips);
    if start ne 'Invalid Code' then do;
       label = fipstate(fips);
       output;
    end;
  end;

  drop fips;
run;
proc sort data=makeFormat;
by label;
run;

data _state;
input long_state $30;
datalines;
         CALIFORNIA 
               TEXAS 
            NEW YORK 
       MASSACHUSETTS 
            MICHIGAN 
            DELAWARE 
          NEW JERSEY 
            ILLINOIS 
          WASHINGTON 
        PENNSYLVANIA 
           MINNESOTA 
                OHIO 
             FLORIDA 
            COLORADO 
      NORTH CAROLINA 
         CONNECTICUT 
             GEORGIA 
            VIRGINIA 
           WISCONSIN 
              NEVADA 
             INDIANA 
        RHODE ISLAND 
            MARYLAND 
            MISSOURI 
              OREGON 
                UTAH 
             ARIZONA 
           TENNESSEE 
       NEW HAMPSHIRE 
      SOUTH CAROLINA 
            OKLAHOMA 
            NEBRASKA 
            KENTUCKY 
                IOWA 
               IDAHO 
              KANSAS 
DISTRICT OF COLUMBIA 
             ALABAMA 
           LOUISIANA 
               MAINE 
          NEW MEXICO 
             VERMONT 
            ARKANSAS 
             WYOMING 
         MISSISSIPPI 
        SOUTH DAKOTA 
       WEST VIRGINIA 
             MONTANA 
              ALASKA 
        NORTH DAKOTA 
              HAWAII 
;
run;


/* creates $fips based off of work.makeFormat */
proc format cntlin=makeFormat; 
run;

data example;
	set  _state;
	  format long_state $fips.;    /* changes display only, not storage */
run;

data test;
 	set _state;

	length stateCode $ 2;
    statecode = put(long_state, $fips.); /* put function returns the display text for X when $fips is applied to it
								   That returned text is then saved into stateCode */

	 /* remove existing format from X, so we see its raw value */
run;



/*

 put uses format
     stored value --> displayed value

 put(column, format)
      the column can be numeric or character
      the format is being applied to the column, then the resulting display text is returned
           * put always outputs a character value

 input uses informat

 input(charColumn, informat)
        the character column is being interpreted into a number
        the informat tells the computer how to do that interpretation
           * input always outputs a numeric value, length 8

 input: character --> numeric


 */


/*

Temporary Array

 */

data example_array;
	array a[*] A1-A5;
	array b[5] _temporary_ (10, 53, 35, 52, 43); 
		/* temporary array is available to the PDV during processing, it is not output.
		   the values in parentheses are the initial values of this array, we could overwrite them during
				the data step execution, if we want to */

	do i = 1 to 5;
		a[i] = b[i] / 3;
	end;
run;

BC, "ON", ,'QC', 'AB', 'SK','NS','MB','NF', 


PROC DATASETS NOLIST;
COPY IN = work OUT = mergback ;
select  _sas_country_names_ ;
RUN;







