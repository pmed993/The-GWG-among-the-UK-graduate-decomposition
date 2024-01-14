// generate dummies to be used in the decomposition
tab gor_dv, gen(dgor)
tab race, gen(drace)
tab racel_dv, gen(dracel_dv)
tab jbsic, gen(djbsic)
tab jbsoc90_cc, gen(djbsoc90_cc)
set matsize 2500
tab jbsic92, gen(djbsic92)
tab jbsoc00_cc, gen(djbsoc00_cc)
tab jbsic07_cc, gen(djbsic07)
gen ftexp2 = ftexp^2
gen ptexp2 = ptexp^2
