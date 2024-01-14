*** use UKHLS(1-31) clean and merge with key variables ***
qui{
	// set the do folder
global dofld "P:\Research projects\grad_gwg\do_files"
	do "${dofld}/1. dataclean.do"
	}

// Set panel data
xtset pidp wave, yearly

// Set table results to directory
cd "P:\Research projects\grad_gwg\Results\table"
putexcel set table_results

********* SUMMARY STATISTICS PANEL DATA and KEY VARIABLES   *************
// Table 3.1 Sample size 
tab Year if sex == 1, su(pidp)
tab Year if sex == 2, su(pidp)
tab wave, su(pidp)

// Table 3.2 summary Age FT and PT experience
// Age 
tab Year if sex == 1, su(age)
tab Year if sex == 2, su(age)
tab Year, su(age)

// full-time and part-time variables
tab Year if sex == 1, su(ptexp)
tab Year if sex == 2, su(ptexp)
tab Year, su(ptexp)

// Table 3.3
// Industry stats
groups jbsic07_cc if wave==31 & sex == 1, order(h) select(7) 
groups jbsic07_cc if wave==31 & sex == 2, order(h) select(7) 

// Occupation stats
groups jbsoc00_cc if wave==31 & sex == 1 , order(h) select(7) 
groups jbsoc00_cc if wave==31 & sex == 2 , order(h) select(7) 

********* SUMMARY STATISTICS GWG   *************

// Get raw gwg at the mean and different quantiles
bys wave sex: egen mean_grswage = mean(grswage)
bys wave sex: egen p10_grswage = pctile(grswage), p(10)
bys wave sex: egen p25_grswage = pctile(grswage), p(25)
bys wave sex: egen p50_grswage = pctile(grswage), p(50)
bys wave sex: egen p75_grswage = pctile(grswage), p(75)
bys wave sex: egen p90_grswage = pctile(grswage), p(90)

// Get raw gwg ratio at the mean and different quantiles
by wave: gen mean_ratio = mean_grswage[_N]/mean_grswage[1]
by wave: gen p10_ratio = p10_grswage[_N]/p10_grswage[1]
by wave: gen p25_ratio = p25_grswage[_N]/p25_grswage[1]
by wave: gen p50_ratio = p50_grswage[_N]/p50_grswage[1]
by wave: gen p75_ratio = p75_grswage[_N]/p75_grswage[1]
by wave: gen p90_ratio = p90_grswage[_N]/p90_grswage[1]

gen mean_gap = 1-mean_ratio
gen p10_gap = 1-p10_ratio
gen p25_gap = 1-p25_ratio
gen p50_gap = 1-p50_ratio
gen p75_gap = 1-p75_ratio
gen p90_gap = 1-p90_ratio

// Table 3.4
tab Year, su(mean_gap)
tab Year, su(p10_gap)
tab Year, su(p25_gap)
tab Year, su(p50_gap)
tab Year, su(p75_gap)
tab Year, su(p90_gap)

// Figure 3.1 Gender wage gap and ratio at the mean

// Set results/graph directory
cd "P:\Research projects\grad_gwg\Results\graphs"

// Generate mean grswage & graph
twoway (line mean_grswage wave if sex == 1) (line mean_grswage wave if sex == 2)
graph save mean_grswage_birth1980-2021.gph, replace

// Graph mean ratio & graph
tsline mean_ratio
graph save mean_ratio_birth1980-2021.gph, replace

graph combine mean_grswage_birth1980-2021.gph mean_ratio_birth1980-2021.gph

// Generate wage ratio and gap for different waves group
*keep if wave <= 10
*keep if wave >=11 & wave <=20
*keep if wave >=21 & wave <=30

// Generate wage ratios and gap for diffrerent choorts 
*keep if birth >= 1990 & birth < 2000
keep if birth >= 1985
keep if birth >= 1960 & birth < 1980
keep if birth <= 1960
keep if birth >= 1990

// Gender wgae gap by age
bys age sex: egen mean_age_grswage = mean(grswage)
twoway (line mean_age_grswage age if sex == 1) (line mean_age_grswage age if sex == 2)
graph save byage_1970-1980.gph, replace

// Trend at different level of the wage distribution