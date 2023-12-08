//Srinidhi Narayanan
//14.33 Final Project Regression Results Do-File

log:  /Users/srinidhi/Desktop/Python Scripts/Policing Project Scripts/paper_results_log.smcl

//loading in data

use "/Users/srinidhi/Desktop/Python Scripts/Policing Project Scripts/event_study.dta", clear

//Setting up panel structure, where 'ori' represents municipality and 'month_code' is time
egen muni_id = group(ori)
egen month_id = group(month_code)
xtset muni_id month_id

//can see outputs in log file
summarize

//summary of relevant columns
//For every result I generate, I also generate latex code to display the corresponding table
summarize index population_x total_employees_officers officers_killed_total total_assaults total_arrests
esttab, label booktabs replace

//First stage regression; post_0 represents killed indicator
gen shoot_kill_int = assault_indicator * post_0
xtreg log_total_arrests assault_indicator shoot_kill_int, fe
esttab, label booktabs replace

//Second stage regression and generation of necessary interaction terms
gen pre3 = post_0 * pre_3
gen pre2 = post_0 * pre_2
gen pre1 = post_0 * pre_1
gen post1 = post_0 * post_1
gen post2 = post_0 * post_2
gen post3 = post_0 * post_3
gen post4 = post_0 * post_4
gen post5 = post_0 * post_5
gen post6 = post_0 * post_6

xtreg log_total_arrests pre_3 pre_2 pre_1 post_0 post_1 post_2 post_3 post_4 post_5 post_6 pre3 pre2 pre1 post1 post2 post3 post4 post5 post6, fe
esttab, label booktabs replace

//Reading in new data for final stage DDD regression -- this data has many observations not in the timespan thrown out, a new post_overall column with 0/1 treatment
//indication, etc

save "/Users/srinidhi/Desktop/Python Scripts/Policing Project Scripts/event_study.dta", replace
file /Users/srinidhi/Desktop/Python Scripts/Policing Project Scripts/event_study.dta saved
use "/Users/srinidhi/Desktop/Python Scripts/Policing Project Scripts/DDD.dta"

gen killed_post_int = post_0 * post_overall

//Generating ForceSize x post interaction terms for both notions of size that I study
gen abs_employment_size_int = post_overall * employment_median_indicator
gen prop_size_int = post_overall * employment_pop_prop_indicator

//Generating 2 corresponding triple interaction terms
gen triple_int_abs_employment = post_0 * post_overall * employment_median_indicator
gen triple_int_prop_employment = post_0 * post_overall * employment_pop_prop_indicator

//Setting up panel structure for new dataset
egen muni_id = group(ori)
egen month_id = group(month_code)
xtset muni_id month_id

//Two versions of same estimating equation using two different size mechanisms
xtreg log_total_arrests post_overall killed_post_int abs_employment_size_int triple_int_abs_employment, fe
esttab, label booktabs replace

xtreg log_total_arrests post_overall killed_post_int prop_size_int triple_int_prop_employment, fe
esttab, label booktabs replace

log close
