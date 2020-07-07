/*  Time-to-Event Analysis
	RN to BS Online Nursing Program
	created by Valerie Ryan
	last updated July 7, 2020 */

/* Data Manipulation */
*import the .csv data file;
proc import out=work.RNBS datafile="C:\Users\Your Path\Name of File.csv"
	dbms=csv;
	getnames=yes;
run;
*use proc print to view the data set;
proc print data=RNBS;
run;
*use proc contents to get summary information (e.g. number of variables, number of observations, variable types);
proc contents data=RNBS;
run;
*demographic information: how many people in each race/ethnicity group?;
proc freq data=rnbs;
tables ethnic_grp_desc;
run;
*prep data for analysis: change from wide to long and rename variables;
data long;
	set RNBS;
	mini_semester_pass=_2158_OL1;
	semester=ms_1_end;
	semester_count=1;
	id=id;
	output;
	mini_semester_pass=_2158_OL2;
	semester=ms_2_end;
	semester_count=2;
	id=id;
	output;
	mini_semester_pass=_2162_OL1;
	semester=ms_3_end;
	semester_count=3;
	id=id;
	output;
	mini_semester_pass=_2162_OL2;
	semester=ms_4_end;
	semester_count=4;
	id=id;
	output;
	mini_semester_pass=_2165_OL1;
	semester=ms_5_end;
	semester_count=5;
	id=id;
	output;
	mini_semester_pass=_2165_OL2;
	semester=ms_6_end;
	semester_count=6;
	id=id;
	output;
	mini_semester_pass=_2168_OL1;
	semester=ms_7_end;
	semester_count=7;
	id=id;
	output;
	mini_semester_pass=_2168_OL2;
	semester=ms_8_end;
	semester_count=8;
	id=id;
	output;
	mini_semester_pass=_2172_OL1;
	semester=ms_9_end;
	semester_count=9;
	id=id;
	output;
	mini_semester_pass=_2172_OL2;
	semester=ms_10_end;
	semester_count=10;
	id=id;
	output;
	keep mini_semester_pass semester semester_count id age_at_admission ethnic_grp_desc sex readmit admit_term_start complete_date;
run;
*calculate new variable for time;
data long1;
	set long;
	semester_time = semester - admit_term_start;
	if mini_semester_pass=. then semester_time=.;
run;
*check the new data set;
proc print data=long1;
run;

/* Preliminary Analysis */

proc glimmix data=long1 empirical plots=all oddsratio;
	class id semester;
	model mini_semester_pass(event='1')=semester /dist=binary;
	random intercept /sub=id type=vc;
	lsmeans semester /ilink plot=meanplot(ilink cl join);
run;

*create a new variable for zero time;
data marginal;
	set long1;
	zero_time=0;
run;
*check the new data set;
proc print data=marginal;
run;

/* Marginal Models */

*models from time = 0 to current semester;
*event variable is semester count;
*censor variable is mini_semester_pass;

/* Full Marginal Model - Modeling Success */
proc phreg data=marginal covs(aggregate) covm plots(cl overlay=byrow)=(survival cumhaz);
	class Ethnic_Grp_Desc(ref='White');
	model (zero_time semester_time)*mini_semester_pass(1) = Age_at_Admission | Ethnic_Grp_Desc /risklimits ties=efron;
	strata semester_count;
	hazardratio 'interaction' Age_at_Admission /at(Ethnic_Grp_Desc ='White');
	id id;
run;

/* Marginal Model - Modeling Failure */
proc phreg data=marginal covs(aggregate) covm plots(cl overlay=byrow)=(survival cumhaz);
	class Ethnic_Grp_Desc(ref='White');
	model (zero_time semester_time)*mini_semester_pass(0) = Age_at_Admission Ethnic_Grp_Desc /risklimits ties=efron;
	strata semester_count;
	id id;
run;

/* Results */

*only age was statistically significant: 2% less risk of dropping out with each 1 unit increase in age (HR = 0.98);
*race/ethnicity was only statistically significant before grouping race/ethnicity together, unstable estimates;
*race/etnicity not significant after groups combined into one category;


/* Conditional B Model */

*models from semester to semester;
*modeling failure;
*need to create new variable, interval_time, as offset of semester_time;

proc phreg data=marginal covs(aggregate) covm plots(cl overlay=byrow)=(survival cumhaz);
	class Ethnic_Grp_Desc(ref='White');
	model (zero_time interval_time)*mini_semester_pass(0) = Age_at_Admission Ethnic_Grp_Desc /risklimits ties=efron;
	strata semester_count;
	id id;
run;
