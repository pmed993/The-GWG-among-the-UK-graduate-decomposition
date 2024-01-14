*********************************************************************
**********************     OAXACA DECMPOSITION  *********************
*********************************************************************
*** Use UKHLS(1-31) clean and merge with key variables ***
qui{
	// set the do folder
	global dofld "P:\Research projects\grad_gwg\do_files"

	// Clean raw data
	do "${dofld}/1. dataclean.do"
	
	// Create oaxaca dummies variables
	do "${dofld}/Get oaxaca_dummies.do"
	
	// Set result directory
	cd "P:\Research projects\grad_gwg\Results\"
	}

**** wave 2021 ****
// spec 1
oaxaca lngrswage dgor1-dgor12 dracel_dv1-dracel_dv18 ///
	ftexp ftexp2 ptexp ptexp2 if wave == 31, by(sex) pooled relax detail(ftexp: ftexp ftexp2, ///
	ptexp: ptexp ptexp2, region: dgor? dgor??, race: dracel_dv? dracel_dv??)
estimate store oaxaca1_31

reg lngrswage dgor1-dgor12 dracel_dv1-dracel_dv18 ///
	ftexp ftexp2 ptexp ptexp2 if wave == 31  & sex ==1

// spec 2 check if N == 3156
oaxaca lngrswage dgor1-dgor12 dracel_dv1-dracel_dv18 ///
	ftexp ftexp2 ptexp ptexp2 djbsoc00_cc1-djbsoc00_cc82 djbsic071-djbsic0787 ///
	if wave == 31, by(sex) pooled relax detail( ftexp: ftexp ftexp2, ptexp: ptexp ptexp2, ///
	occupation: djbsoc00_cc? djbsoc00_cc??, industry: djbsic07? djbsic07??, ///
	race: dracel_dv? dracel_dv??, region: dgor? dgor??) 
estimate store oaxaca2_31

**** wave 2011 ****
// spec 1
oaxaca lngrswage dgor1-dgor12 dracel_dv1-dracel_dv18 ///
	ftexp ftexp2 ptexp ptexp2 if wave == 21, by(sex) pooled relax detail(ftexp: ftexp ftexp2, ///
	ptexp: ptexp ptexp2, region: dgor? dgor??, race: dracel_dv? dracel_dv??) 
	
estimate store oaxaca1_21
// spec 2 check if N == 5184
oaxaca lngrswage dgor1-dgor12 dracel_dv1-dracel_dv18 ///
	ftexp ftexp2 ptexp ptexp2 djbsoc00_cc1-djbsoc00_cc82 djbsic071-djbsic0787 ///
	if wave == 21, by(sex) pooled relax detail( ftexp: ftexp ftexp2, ptexp: ptexp ptexp2, ///
	occupation: djbsoc00_cc? djbsoc00_cc??, industry: djbsic07? djbsic07??, ///
	race: dracel_dv? dracel_dv??, region: dgor? dgor??) noisily
estimate store oaxaca2_21

outreg2 [oaxaca1_31 oaxaca2_31] using oaxaca_31.xls, replace
outreg2 [oaxaca1_21 oaxaca2_21] using oaxaca_21.xls, replace

**** wave 2001 ****
// spec 1
oaxaca lngrswage  dgor1-dgor12 drace1-drace9 ftexp ftexp2 ptexp ptexp2 ///
	if wave ==11, by(sex) pooled detail(ftexp: ftexp ftexp2, ///
	ptexp: ptexp ptexp2, race: drace?,region: dgor? dgor??) noisily
estimate store oaxaca1_11
// spec 2 check if N == 957
 oaxaca lngrswage dgor1-dgor12 drace1-drace9 ftexp ftexp2 ptexp ptexp2 ///
	djbsoc90_cc1-djbsoc90_cc68 djbsic1-djbsic266 if wave==11, by(sex) pooled ///
	detail(ftexp: ftexp ftexp2, ptexp: ptexp ptexp2, occupation: djbsoc90_cc? ///
	djbsoc90_cc??, industry: djbsic? djbsic?? djbsic???, race: drace?, ///
	region: dgor? dgor??) noisily
estimate store oaxaca2_11

**** wave 1991 ****
// spec 1
oaxaca lngrswage  dgor1-dgor12 drace1-drace9 ftexp ftexp2 ptexp ptexp2 ///
	if wave ==1, by(sex) pooled detail(ftexp: ftexp ftexp2, ///
	ptexp: ptexp ptexp2, race: drace?,region: dgor? dgor??) noisily
estimate store oaxaca1_1

// spec 2 check if N == 429
 oaxaca lngrswage dgor1-dgor12 drace1-drace9 ftexp ftexp2 ptexp ptexp2 ///
	djbsoc90_cc1-djbsoc90_cc68 djbsic1-djbsic266 if wave==1, by(sex) pooled ///
	detail(ftexp: ftexp ftexp2, ptexp: ptexp ptexp2, occupation: djbsoc90_cc? ///
	djbsoc90_cc??, industry: djbsic? djbsic?? djbsic???, race: drace?, ///
	region: dgor? dgor??) noisily
estimate store oaxaca2_1

outreg2 [oaxaca1_11 oaxaca2_11] using oaxaca_11.xls, replace
outreg2 [oaxaca1_1 oaxaca2_1] using oaxaca_1.xls, replace

***** COLLINEARITY ****
*** wave 31
correl gor_dv racel_dv ptexp ptexp2 ftexp ftexp2 if wave == 31
correl gor_dv racel_dv ptexp ptexp2 ftexp ftexp2 jbsoc00_cc jbsic07 if wave == 31
*** wave 21
correl gor_dv racel_dv ptexp ptexp2 ftexp ftexp2 if wave ==21
correl gor_dv racel_dv ptexp ptexp2 ftexp ftexp2 jbsoc00_cc jbsic07 if wave == 21
*** wave 11

correl gor_dv race ptexp ptexp2 ftexp ftexp2 if wave ==11
correl gor_dv race ptexp ptexp2 ftexp ftexp2 jbsoc90_cc jbsic if wave == 11
*** wave 1
correl gor_dv race ptexp ptexp2 ftexp ftexp2 if wave ==1
correl gor_dv race ptexp ptexp2 ftexp ftexp2 jbsoc90_cc jbsic if wave == 1



