// set the do folder
global dofld "P:\Research projects\grad_gwg\do_files"

// import the appended dataset
use "P:\Research projects\grad_gwg\DATA\UKHLS_extr\extrapp.dta", clear

// tidy
sort wave
tab wave
sort pidp wave

// cleaning vairables 
drop sex_dv
drop jliindb_dv

// replace missing values
replace aidhrs=. if aidhrs<0
replace jbhas=. if jbhas <0
replace jbhrs=. if jbhrs <0
replace jbot=. if jbot<0
replace jbotpd =. if jbotpd<0
replace basrate =. if basrate<0
replace jbsat =. if jbsat <0
replace ch1by4=. if ch1by4<0
replace gor_dv=. if gor_dv<0
replace jbiindb_dv=. if jbiindb_dv<=0
replace paygu_dv=. if paygu_dv <0
replace payg_dv=. if payg_dv<0
recode hiqual_dv(-9/-1=.)

// replace birth date missing, refusal, don't know, with derived birth
replace birthy = doby if birthy == . | birthy == -1 | birthy == -2 | birthy == -9
drop doby
drop doby_dv

// dopping vairables 
// unify age in one variable
replace age = age_dv if age == .
drop age_dv

// create gender squared
gen age2 = age^2

// cleaning racel_bh 
egen wanted = min(cond(inrange(racel_bh, 1, .), racel_bh, .)), by(pidp)
egen check = max(cond(inrange(racel_bh, 1, .), racel_bh, .)), by(pidp)
by pidp: replace racel_bh = wanted if racel_bh <=0
drop wanted check

// cleaning race variable 
egen wanted = min(cond(inrange(race, 1, .), race, .)), by(pidp)
egen check = max(cond(inrange(race, 1, .), race, .)), by(pidp)
by pidp: replace race = wanted if race <=0
drop wanted check

***************        ADJUSTING FOR INFLATION      ************
* CPIH (2015==100) downloaded from ONS * https://www.ons.gov.uk/economy/inflationandpriceindices/timeseries/l522/mm23
merge m:1 wave using "P:\Research projects\grad_gwg\DATA\CPIH_num.dta"
drop if _merge ==2
drop _merge
gen inflator = 100/CPIH2015100
replace fimnlabgrs_dv = fimnlabgrs_dv*inflator

**************     WAGE HOURLY RATE    *****************
*RATIO OF GROSS WEEKLY HOURS BY THE HOURS WEEKLY WORKED
generate wklabgrs = fimnlabgrs_dv/4
label variable wklabgrs "total weekly labour income gross"
generate jbhrs_ota = jbhrs + (jbot)
replace jbhrs_ota = jbhrs if jbhrs_ota == .
label variable jbhrs_ota "total weekly hours worked included payed and unpaid overtime"
generate grswage = wklabgrs/jbhrs_ota
label variable grswage "gross hourly wage from labour income"

// divide people between no working < 4 hours a week
// part-time 4-30 weekly hours and full time more then 30 h
recode jbhrs_ota (min/4=0) (4/30=1) (30/max=2), gen(jbhrs_ota2)
label define jbhrs_categories 0 "no working" 1"part-time" 2 "full-time"
label values jbhrs_ota2 jbhrs_categories
drop if grswage == .
drop if grswage > 100 | grswage <1
gen lngrswage = ln(grswage)

// drop individuals that do no earn income and work 0 hours weekly
drop if fimnlabgrs_dv <=0
drop if jbhrs_ota2 == 0

***************    MERGE WITH WORK EXPERIENCE   ****************
merge 1:1 pidp wave using "P:\Research projects\grad_gwg\DATA\work experience\workexperience.dta"
* drop when the observation does not match the experience in wave
br pidp wave sex jbstat aidhrs fimnlabgrs_dv grswage jbhrs_ota2 ptexp ftexp 
drop if _merge == 2
drop _merge
label variable ftexp "full-time work experience"
label variable ptexp "part-time work experience"
/*
*********    CREATING GENDER ROLE ATTITUDE   ***********
* by using the 3 variables scofama,b,f.For wave 1 3 5 7 9 11 13 15 17 20 22 28						  *
recode scopfama (-9/-1=.)
recode scopfamb (-9/-1=.)
recode scopfamf (-9/-1=.)

* higher score, more egalitarian views
* lower score, more conservative views
* creatign household/ family score for gender role attitude
bys wave pidp: egen ascore = mean(scopfama)
bys wave pidp: egen bscore = mean(scopfamb)
bys wave pidp: egen fscore = mean(scopfamf)
gen grascore = (ascore+bscore+fscore)/3
label variable grascore "Gender role attitude score by wage pidp"

* generating number of individual in the household
bys wave hidp: gen count = _N 
bys wave hidp: egen hgrascore = mean(grascore) if count>1
label variable hgrascore "Gender role attitude score by wage hidp"
gen hgrascore_ind = 1 if hgrascore <=3
replace hgrascore_ind =2 if hgrascore >3
label define hgrascore_ind 1 "more traditional/gendered view" 2 "more egalitarian view"
label values hgrascore_ind hgrascore_ind
drop count
*/

// drop individuals out of the main woring age
drop if age < 20| age > 65

// drop not employed or self employed
drop if jbstat <=1 | jbstat >2

// drop if proxy for sex
drop if sex < 1

// keep only full time workers
keep if jbhrs_ota2 == 2

// keep only graduate
keep if hiqual_dv ==1

// eliminate null values to allow consistency between specifications
xtset pidp wave, yearly
*drop if birthy > 2001 // only for graph, this is a mistake current year 50
drop if gor_dv ==.
drop if ftexp ==.
drop if ptexp ==.
drop if jbsoc90_cc <=0
drop if jbsic <=0
drop if race <=0
drop if racel_dv <=0
drop if racel_bh <=0
drop if jbsoc00_cc<=0
drop if jbsic92 <=0
drop if jbsic <=0
drop if jbsic07_cc <=0
drop if race == . & wave ==11
*drop if howlng < 0
// change directory from data folder to Do folder
cd "$dofld"
