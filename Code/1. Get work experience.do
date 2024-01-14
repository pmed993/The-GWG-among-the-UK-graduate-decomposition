****************************************************************************
*****************            BUILDING ACCUMULATED          *****************
*****************     yearly WORK EXPERIENCE VARIABLES     *****************     
*****************  FOR PART-TIME AND FULL-TIME JOBS SINCE  ***************** 
*****************         BEGINNING OF WORKING LIFe        *****************
****************************************************************************

use "P:\Research projects\grad_gwg\DATA\UKHLS Work-Life Histories\Data\Merged Dataset.dta", clear
merge m:m pidp using "P:\Research projects\grad_gwg\DATA\UKHLS Work-Life Histories\Data\Interview Grid.dta"
drop if _merge == 2
by pidp, sort: gen count = _n
*pidp 12,115 missing infomration on initial and end of a spell, no possible to calculate experience
*Drop any spells that occur after a given interview
br pidp Wave Spell IntDate_MY Status Start_MY End_MY Job_Hours count

isid pidp Wave Spell, sort
gen wave_year = 1990 + Wave
by pidp (Wave): gen byte first_wave = (_n == 1)

*generating between wave and years experience
//  SEPARATE THE DATA INTO INTERVIEWS AND SPELLS OF EMPLOYMENT
keep pidp Wave Spell wave_year
cd "P:\Research projects\grad_gwg\DATA\work experience"
save interviews.dta, replace

use "P:\Research projects\grad_gwg\DATA\UKHLS Work-Life Histories\Data\Merged Dataset.dta", clear
merge m:m pidp using "P:\Research projects\grad_gwg\DATA\UKHLS Work-Life Histories\Data\Interview Grid.dta"
drop if _merge == 2
drop _merge
*pidp 12,115 missing information on initial and end of a spell, no possible to calculate experience
*Drop any spells that occur after a given interview
br pidp Wave Spell IntDate_MY Status Start_MY End_MY Job_Hours
isid pidp Wave Spell, sort

//  ALLOCATE THE EMPLOYMENT SPELLS OVER CALENDAR YEARS
keep if inlist(Status, 1, 2) // ELIMINATE SPELLS NOT SELF EMPLOYED OR PAID EMPLOYMENT
gen Start_Y = year(dofm(Start_MY))
gen End_Y = year(dofm(End_MY))
expand End_Y - Start_Y + 1
by pidp Spell, sort: gen year = Start_Y + _n - 1
drop Start_Y End_Y
gen January = ym(year, 1)
gen December = ym(year, 12)
format January December %tm
gen FTmonths_worked = max(min(End_MY, December) - max(Start_MY, January) + 1, 0) if Job_Hours == 1
gen PTmonths_worked = max(min(End_MY, December) - max(Start_MY, January) + 1, 0) if Job_Hours == 2 
rename year wave_year
// //  LINK TO THE INTERVIEW DATA
merge 1:1 pidp Spell wave_year using "P:\Research projects\grad_gwg\DATA\work experience\interviews.dta"

//  COMBINE ALL WORK PRIOR AND UP TO EACH WAVE
by pidp (wave_year), sort: gen n_interviews = sum(!missing(Wave[_n-1]))
save combined_int_hist.dta, replace
use "P:\Research projects\grad_gwg\DATA\work experience\combined_int_hist.dta", clear
br pidp Spell Start_MY End_MY Status IntDate_MY Job_Hours Wave jbstat FTmonths_worked wave_year n_interviews
collapse (sum) FTmonths_worked (max) wave_year (lastnm) Wave, by(pidp n_interviews)

*generate fulltime experience var
sort pidp wave_year
by pidp: gen ftexp = sum(FTmonths_worked)
bysort pidp Wave: egen ftexp2 = max(ftexp)
drop ftexp
bysort pidp Wave: keep if _n ==1
rename ftexp2 ftexp

save ftexp.dta, replace

*gen parttime experience var
use "P:\Research projects\grad_gwg\DATA\work experience\combined_int_hist.dta", clear
br pidp Spell Start_MY End_MY Status IntDate_MY Job_Hours Wave jbstat PTmonths_worked wave_year n_interviews
collapse (sum) PTmonths_worked (max) wave_year (lastnm) Wave, by(pidp n_interviews)
sort pidp wave_year
by pidp: gen ptexp = sum(PTmonths_worked)
bysort pidp Wave: egen ptexp2 = max(ptexp)
drop ptexp
bysort pidp Wave: keep if _n ==1
rename ptexp2 ptexp

save ptexp.dta, replace

*merge ftexp with ptexp
isid pidp Wave
merge 1:1 pidp Wave using "P:\Research projects\grad_gwg\DATA\work experience\ftexp.dta"
keep pidp Wave ptexp ftexp
rename Wave wave
* Get years of full and part time experience
replace ptexp = ptexp/12
replace ftexp = ftexp/12
save workexperience.dta, replace

by pidp, sort: gen count = _n


* Check 22445, 9527(10 175, 11 174, 12 174)
