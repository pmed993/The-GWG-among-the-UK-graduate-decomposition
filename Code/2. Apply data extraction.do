// import data after first extraction
use "P:\Research projects\grad_gwg\DATA\UKHLS_extr\BHPS 1-18\longfile.dta", clear
use "P:\Research projects\grad_gwg\DATA\UKHLS_extr\UKHLS 1-11\longfile.dta", clear

// Appending BHPS and UKHLS waves 
// change value of wave to allow appending file
global ukhls_nwave		13
forvalues i = 1/$ukhls_nwave{
	local bhps_nwave = 18
	replace wave = wave + `bhps_nwave' if wave == `i'
	}

append using "P:\Research projects\grad_gwg\DATA\UKHLS_extr\BHPS 1-18\longfile.dta"
cd "P:\Research projects\grad_gwg\DATA\UKHLS_extr"
save extrapp.dta, replace
