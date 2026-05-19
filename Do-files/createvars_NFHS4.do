
//Create the sanitation indicators and covariates from the NFHS 4 data 

cd "$data"

use "NFHS4", clear

gen state_code = hv024

gen cluster=hv001

tostring cluster, replace 

merge m:1 state_code using state_code_NFHS4.dta

keep if _merge==3

drop _merge

gen Sector=0
replace Sector=1 if hv025==2

gen weight_hh = hv005

gen hhsize = hv009

gen weight_ind = weight_hh*hhsize

rename shdistri dist_code_nfhs4

*Common defn of improved sanitation as per the mapping strict definiton

gen IMPROVED_SANIT=1 if hv205==11
replace IMPROVED_SANIT=1 if hv205==12
replace IMPROVED_SANIT=1 if hv205==13
replace IMPROVED_SANIT=1 if hv205==15
replace IMPROVED_SANIT=1 if hv205==21
replace IMPROVED_SANIT=1 if hv205==22
replace IMPROVED_SANIT=1 if hv205==41
replace IMPROVED_SANIT=0  if IMPROVED_SANIT==.


/// Common defn of improved sanitation as per the mapping removing only open defecation (hv205 == 31 is for open defecation, this is not matching with the nfhs questionnaire codes)

gen IMPROVED_SANIT_2=1 if hv205==11
replace IMPROVED_SANIT_2=1 if hv205==12
replace IMPROVED_SANIT_2=1 if hv205==13
replace IMPROVED_SANIT_2=1 if hv205==14
replace IMPROVED_SANIT_2=1 if hv205==15
replace IMPROVED_SANIT_2=1 if hv205==21
replace IMPROVED_SANIT_2=1 if hv205==22
replace IMPROVED_SANIT_2=1 if hv205==23
replace IMPROVED_SANIT_2=1 if hv205==41  // composting
replace IMPROVED_SANIT_2=1 if hv205==44  // dry toilet
replace IMPROVED_SANIT_2=0  if IMPROVED_SANIT_2==.

gen UNIMPROVED_SANIT=1 if hv205==14
replace UNIMPROVED_SANIT=1 if hv205==23
replace UNIMPROVED_SANIT=1 if hv205==44
replace UNIMPROVED_SANIT=1 if hv205==96
replace UNIMPROVED_SANIT=0 if UNIMPROVED_SANIT==.


*Access to own toilet based on use

gen OWN_HH_TOILET=1 if  hv225 == 0 
replace OWN_HH_TOILET=0 if  OWN_HH_TOILET==.
	

//// Access to shared toilet based on use

gen SHARED_TOILET=1 if  hv225 == 1 
replace SHARED_TOILET=0 if  SHARED_TOILET==.

gen HH_TOILET=1 if  hv225 == 0 | hv225 == 1 
replace HH_TOILET=0 if HH_TOILET==.


//// Household with improved and own sanitation 

gen imp_san_own = IMPROVED_SANIT*OWN_HH_TOILET

//// Household with improved and shared sanitation 

gen imp_san_hh = IMPROVED_SANIT*HH_TOILET

//// Household with unimproved sanitation

gen unimp_san_hh = IMPROVED_SANIT_2*HH_TOILET

// save analysis_sanitation_hh, replace

tabstat imp_san_own imp_san_hh unimp_san_hh [aw=weight_ind] if Sector==1, by(state_name) stats(mean)


///// %age of HHs having access to own toilet

//// Household with improved and own sanitation 

gen INDICATOR1 = IMPROVED_SANIT*OWN_HH_TOILET

//// Household with unimproved and own sanitation 

gen INDICATOR2 = IMPROVED_SANIT_2*OWN_HH_TOILET

//// Household with improved and shared sanitation 

gen INDICATOR3 = IMPROVED_SANIT*HH_TOILET

//// Household with unimproved sanitation

gen INDICATOR4 = IMPROVED_SANIT_2*HH_TOILET

///household with improved shared sanitation_hh
gen INDICATOR5 = IMPROVED_SANIT*SHARED_TOILET

///household with own unimproved sanitation_hh
gen INDICATOR6 = UNIMPROVED_SANIT*OWN_HH_TOILET


/// social group

gen soc_grp = ""
replace soc_grp = "SC" if sh36 == 1
replace soc_grp = "ST" if sh36 == 2
replace soc_grp = "OBC" if sh36 == 3
replace soc_grp = "GEN" if (sh36 == 4 | sh36 == 8)

/// dummy for household head religion

gen religion = ""
replace religion = "Hindu" if sh34==1 
replace religion = "Muslim" if sh34==2
replace religion = "Christian" if sh34==3
replace religion = "Others" if (sh34>3 & sh34!=.)

///// Creating dummy for female household head (1 for female household, 0 otherwise)

gen fem_hh_hd = (hv219 == 2)

ren hv270 wealth_quintile_all_india_nfhs
ren sv270r wealth_quintile_rur_nfhs
ren sv270u wealth_quintile_urb_nfhs


//// add number of children 5 and under, and number of adults older than 60 
gen child_under5 = hv014
gen adult_older_60 = 0


local  age_vars  hv105_01 hv105_02 hv105_03 hv105_04 hv105_05 hv105_06 hv105_07 hv105_08 hv105_09 hv105_10 hv105_11 hv105_12 hv105_13 hv105_14 hv105_15 hv105_16 hv105_17 hv105_18 hv105_19 hv105_20 hv105_21 hv105_22 hv105_23 hv105_24 hv105_25 hv105_26 hv105_27 hv105_28 hv105_29 hv105_30 hv105_31 hv105_32 hv105_33 hv105_34 hv105_35 hv105_36 hv105_37 hv105_38 hv105_39 hv105_40 hv105_41


foreach var of varlist `age_vars'{
	
	replace adult_older_60 = adult_older_60 + 1 if (`var'>=60 & `var'!=98 & `var' !=.)
}



save "analysis_sanitation_NFHS4.dta", replace
 