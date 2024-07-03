proc options option=autosaveloc;
run;

Winsorization;

*Calculate IQR and first/third quartiles;
proc means data=sashelp.class stackods n qrange p25 p75;
var weight height;
ods output summary=ranges;
run;

*create data with outliers to check;
data capped; 
	set sashelp.class;
	if name='Alfred' then weight=220;
	if name='Jane' then height=-30;
run;

*macro to cap outliers;

%macro cap(dset=,var=, lower=, upper=);

data &dset;
	set &dset;
	if &var>&upper then &var=&upper;
	if &var<&lower then &var=&lower;
run;

%mend;


*create cutoffs and execute macro for each variable;
data cutoffs;
set ranges;
lower=p25-3*qrange;
upper=p75+3*qrange;
string = catt('%cap(dset=capped, var=', variable, ", lower=", lower, ", upper=", upper ,");");
call execute(string);
run;


Modify the macro slightly - I'm adding the win to the beginning of the variable because that will allow you to use naming shortcuts in SAS later on if required.

%macro cap(dset=,var=, lower=, upper=);

data &dset;

set &dset;

win_&var = &var;

if &var>&upper then win_&var=&upper;

if &var<&lower then win_&var=&lower;

run;

%mend;
