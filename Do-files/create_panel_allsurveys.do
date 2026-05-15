*This file appends all the surveys after some processing

cd "$data"

use analysis_sanitation_NFHS5.dta, clear


keep state_name state_code dist_code_nfhs5 Sector cluster hhid hhsize weight_hh weight_ind soc_grp religion fem_hh_hd child_under5 adult_older_60 wealth_quintile_all_india_nfhs wealth_quintile_rur_nfhs wealth_quintile_urb_nfhs INDICATOR1 INDICATOR2 INDICATOR3 INDICATOR4 

gen survey = "NFHS 2019-21" 

/// add district name to the files

 _strip_labels dist_code_nfhs5

tempfile nfhs5_hh
save `nfhs5_hh', replace 

use Balance_Indicator_Across_Survey_20_Sep.dta, clear


drop if missing(dist_code_nfhs5)
 
tempfile x
save `x', replace  
 
use `nfhs5_hh', clear 
 
merge m:1 dist_code_nfhs5 using `x', keepusing(dist_name_nfhs5)

drop _m

rename dist_name_nfhs5 dist_name

order state_name state_code dist_code Sector cluster hhid hhsize weight_hh weight_ind soc_grp religion fem_hh_hd child_under5 adult_older_60 wealth_quintile_all_india_nfhs wealth_quintile_rur_nfhs wealth_quintile_urb_nfhs INDICATOR1 INDICATOR2 INDICATOR3 INDICATOR4 survey

gen indicator_nfhs5 = 1

tempfile nfhs5_hh
save `nfhs5_hh', replace

use analysis_sanitation_NFHS4.dta, clear

keep dist_code_nfhs4 Sector cluster hhid hhsize weight_hh weight_ind soc_grp religion fem_hh_hd religion child_under5 adult_older_60 wealth_quintile_all_india_nfhs wealth_quintile_rur_nfhs wealth_quintile_urb_nfhs INDICATOR1 INDICATOR2 INDICATOR3 INDICATOR4 

gen survey = "NFHS 2015-16"

merge m:m dist_code_nfhs4 using Balance_Indicator_Across_Survey_20_Sep.dta, keepusing(dist_code_nfhs5 state_code_nfhs5 state_name_nfhs5 dist_name_nfhs5 indicator_nfhs4)

rename state_name_nfhs5 state_name 
rename state_code_nfhs5 state_code 
rename dist_name_nfhs5 dist_name 


order dist_code_nfhs5 Sector cluster hhid hhsize weight_hh weight_ind fem_hh_hd soc_grp religion child_under5 adult_older_60 wealth_quintile_all_india_nfhs wealth_quintile_rur_nfhs wealth_quintile_urb_nfhs INDICATOR1 INDICATOR2 INDICATOR3 INDICATOR4 survey indicator_nfhs4 dist_code_nfhs4

tempfile nfhs4_hh
save `nfhs4_hh', replace


use `nfhs5_hh', clear
append using `nfhs4_hh'

tempfile nfhs_hh
save `nfhs_hh', replace

*Creating Data for household indicator for NSS 


use analysis_sanitation_NSS.dta, clear


keep Sector dist_code_nss state_name cluster hhid hhsize weight_hh weight_ind fem_hh_hd soc_grp religion child_under5 adult_older_60 mpce_quintile_all_india_nss mpce_quintile_rural_nss mpce_quintile_urban_nss INDICATOR1 INDICATOR2 INDICATOR3 INDICATOR4 INDICATOR1_1 INDICATOR4_1

replace Sector = 0 if Sector == 2
replace Sector = 1 if Sector == 1

gen sector = Sector
drop Sector
ren sector Sector
ren state_name state_name_nss

merge m:m dist_code_nss using Balance_Indicator_Across_Survey_20_Sep.dta, keepusing(dist_code_nfhs5 state_code_nfhs5 state_name_nfhs5 dist_name_nfhs5 indicator_nss)

drop _m

rename state_name_nfhs5 state_name 
rename state_code_nfhs5 state_code 
rename dist_name_nfhs5 dist_name 

replace state_name = state_name_nss if state_name ==""
drop state_name_nss

order state_name state_code dist_name dist_code_nfhs5 Sector cluster hhid hhsize weight_hh weight_ind fem_hh_hd soc_grp religion child_under5 adult_older_60 mpce_quintile_all_india_nss mpce_quintile_rural_nss mpce_quintile_urban_nss INDICATOR1 INDICATOR2 INDICATOR3 INDICATOR4 INDICATOR1_1 INDICATOR4_1 indicator_nss dist_code_nss


gen survey = "NSS 76"

tempfile nss76_hh

save `nss76_hh', replace

*Creating Data for household indicator for NARSS1 


use Analysis_Sanitation_NARSS1, clear

gen survey = "NARSS 1"

gen Sector = 1

rename State state_name_narss

rename District_Ministry dist_name_narss1

keep dist_name_narss1 state_name_narss Sector cluster hhid hhsize weight_hh weight_ind fem_hh_hd soc_grp poverty child_under5 adult_older_60 INDICATOR1 INDICATOR2 INDICATOR3 INDICATOR4 INDICATOR1_1 INDICATOR4_1 survey


tempfile narss1_hh
save `narss1_hh', replace


use Balance_Indicator_Across_Survey_20_Sep.dta, clear

drop if missing(dist_name_narss1)
 
tempfile x
save `x', replace  

use `narss1_hh', clear

merge m:1 dist_name_narss1 using `x', keepusing(dist_code_nfhs5 state_code_nfhs5 state_name_nfhs5 dist_name_nfhs5 indicator_narss1 dist_code_narss1)

drop _merge

rename state_name_nfhs5 state_name 
rename state_code_nfhs5 state_code 
rename dist_name_nfhs5 dist_name 

//first clean the narss state names for those we will update to match NFHS names
ereplace state_name_narss = sieve(state_name_narss), omit(0123456789())
replace state_name_narss = strrtrim(state_name_narss)
replace state_name_narss = "Andaman & Nicobar" if state_name_narss=="A & N Islands" 
replace state_name_narss = "Dadra & Nagar Haveli" if state_name_narss=="DADRA AND NAGAR HAVELI" 
replace state_name_narss= strproper(state_name_narss)

//now replace missing states
replace state_name = state_name_narss if state_name ==""
drop state_name_narss

order state_name state_code dist_name dist_code_nfhs5 Sector cluster hhid hhsize weight_hh weight_ind fem_hh_hd soc_grp poverty child_under5 adult_older_60 INDICATOR1 INDICATOR2 INDICATOR3 INDICATOR4 INDICATOR1_1 INDICATOR4_1 survey indicator_narss1 dist_code_narss1 dist_name_narss1 

save `narss1_hh', replace

*Creating Data for household indicator for NARSS2

use Analysis_Sanitation_NARSS2, clear


gen Sector = 1

gen survey = "NARSS 2"

rename District_Ministry dist_name_narss2

keep dist_name_narss2 Sector cluster hhid hhsize weight_hh weight_ind fem_hh_hd soc_grp poverty child_under5 adult_older_60 INDICATOR1 INDICATOR2 INDICATOR3 INDICATOR4 INDICATOR1_1 INDICATOR4_1 survey


tempfile narss2_hh

save `narss2_hh', replace

use `narss2_hh', clear

merge m:m dist_name_narss2 using Balance_Indicator_Across_Survey_20_Sep.dta, keepusing(dist_code_nfhs5 state_code_nfhs5 state_name_nfhs5 dist_name_nfhs5 indicator_narss2 dist_code_narss2)

drop _merge

rename state_name_nfhs5 state_name 
rename state_code_nfhs5 state_code 
rename dist_name_nfhs5 dist_name 

replace state_name = "West Bengal" if dist_name_narss2 == "ALIPUDUAR (575)"
replace state_name = "West Bengal" if dist_name_narss2 == "JHARGRAM (737)"
replace state_name = "West Bengal" if dist_name_narss2 == "SILIGURI (572)"
replace state_name = "Manipur" if dist_name_narss2 == "KAKCHING (753)"
replace state_name = "Manipur" if dist_name_narss2 == "KAMJONG (755)"
replace state_name = "Manipur" if dist_name_narss2 == "KANGPOKPI (752)"
replace state_name = "Manipur" if dist_name_narss2 == "NONEY (756)"
replace state_name = "Manipur" if dist_name_narss2 == "PHERZAWL (757)"
replace state_name = "Manipur" if dist_name_narss2 == "TENGNOUPAL (754)"


order state_name state_code dist_name dist_code_nfhs5 Sector cluster hhid hhsize weight_hh weight_ind fem_hh_hd soc_grp poverty child_under5 adult_older_60 INDICATOR1 INDICATOR2 INDICATOR3 INDICATOR4 INDICATOR1_1 INDICATOR4_1 survey indicator_narss2 dist_code_narss2 dist_name_narss2

save `narss2_hh', replace

/////

///// Creating Data for household indicator for NARSS3

use Analysis_Sanitation_NARSS3, clear


gen Sector = 1

gen survey = "NARSS 3"

rename District_Ministry dist_name_narss3

keep dist_name_narss3 Sector cluster hhid hhsize weight_hh weight_ind fem_hh_hd soc_grp poverty child_under5 adult_older_60 INDICATOR1 INDICATOR2 INDICATOR3 INDICATOR4 INDICATOR1_1 INDICATOR4_1 survey


tempfile narss3_hh

save `narss3_hh', replace

use `narss3_hh', clear

merge m:m dist_name_narss3 using Balance_Indicator_Across_Survey_20_Sep.dta, keepusing(dist_code_nfhs5 state_code_nfhs5 state_name_nfhs5 dist_name_nfhs5 indicator_narss3 dist_code_narss3)


drop _merge

rename state_name_nfhs5 state_name 
rename state_code_nfhs5 state_code 
rename dist_name_nfhs5 dist_name 

replace state_name = "West Bengal" if dist_name_narss3 == "ALIPUDUAR(575)"
replace state_name = "West Bengal" if dist_name_narss3 == "JHARGRAM(737)"
replace state_name = "West Bengal" if dist_name_narss3 == "SILIGURI(572)"
replace state_name = "Manipur" if dist_name_narss3 == "KAKCHING(753)"
replace state_name = "Manipur" if dist_name_narss3 == "KANGPOKPI(752)"
replace state_name = "Manipur" if dist_name_narss3 == "PHERZAWL(757)"


order state_name state_code dist_name dist_code_nfhs5 Sector cluster hhid hhsize weight_hh weight_ind fem_hh_hd soc_grp poverty INDICATOR1 INDICATOR2 INDICATOR3 INDICATOR4 INDICATOR1_1 INDICATOR4_1 survey indicator_narss3 dist_code_narss3 dist_name_narss3

save `narss3_hh', replace

///// Appending all files together

use `nfhs_hh', clear

append using `nss76_hh' `narss1_hh' `narss2_hh' `narss3_hh'

order state_name state_code dist_name dist_code_nfhs5 Sector cluster hhid hhsize weight_hh weight_ind fem_hh_hd soc_grp religion child_under5 adult_older_60 INDICATOR1 INDICATOR2 INDICATOR3 INDICATOR4 INDICATOR1_1 INDICATOR4_1 wealth_quintile_all_india_nfhs wealth_quintile_rur_nfhs wealth_quintile_urb_nfhs mpce_quintile_all_india_nss mpce_quintile_rural_nss mpce_quintile_urban_nss poverty indicator_nfhs5 indicator_nfhs4 indicator_nss indicator_narss1 indicator_narss2 indicator_narss3 dist_code_nfhs4 dist_code_nss dist_code_narss1 dist_code_narss2 dist_code_narss3 dist_name_narss1 dist_name_narss2 dist_name_narss3

gen year = 1 if survey == "NFHS 2015-16"
replace year = 2 if survey == "NARSS 1"
replace year = 3 if survey == "NSS 76"
replace year = 4 if survey == "NARSS 2"
replace year = 5 if survey == "NARSS 3"
replace year = 6 if survey == "NFHS 2019-21"

sort year state_name dist_code_nfhs5

save Final_Appended_HH_Across_Survey_Jun_2023.dta, replace

drop _m

merge m:m dist_code_nfhs5 using Balance_Indicator_Across_Survey_20_Sep.dta, keepusing(balance_indicator)


drop _merge

//update the state_code if missing (missing for 13 states, just updating manually)
replace state_code = 35 if state_name == "Andaman & Nicobar" & state_code ==.
replace state_code = 28 if state_name == "Andhra Pradesh" & state_code ==.
replace state_code = 25 if state_name == "Dadra & Nagar Haveli" & state_code ==.
replace state_code = 30 if state_name == "Goa" & state_code ==.
replace state_code = 24 if state_name == "Gujarat" & state_code ==.
replace state_code = 29 if state_name == "Karnataka" & state_code ==.
replace state_code = 32 if state_name == "Kerala" & state_code ==.
replace state_code = 27 if state_name == "Maharastra" & state_code ==.
replace state_code = 14 if state_name == "Manipur" & state_code ==.
replace state_code = 34 if state_name == "Puducherry" & state_code ==.
replace state_code = 33 if state_name == "Tamil Nadu" & state_code ==.
replace state_code = 36 if state_name == "Telangana" & state_code ==.
replace state_code = 19 if state_name == "West Bengal" & state_code ==.


//label a few variables 
label variable Sector "Rural_Urban"
label define rur_urb 1 "Rural" 0 "Urban"
label values Sector rur_urb
label variable cluster "Village"
label variable hhsize "Household size"
label variable weight_hh "Household weight"
label variable weight_ind "Individual weight"
label variable fem_hh_hd "Indicator for female headed household"
label variable soc_grp "Social group"
label variable religion "Religion"
label variable child_under5 "Number of children 5 and under in household"
label variable adult_older_60 "Number of adults 60 and over in household"
label variable INDICATOR1 "Regular use of own improved sanitation"
label variable INDICATOR2 "Regular use of own any sanitation"
label variable INDICATOR3 "Regular use of improved own or shared sanitation"
label variable INDICATOR4 "Regular use of any sanitation"
label variable INDICATOR1_1 "Usual use of own improved sanitation"
label variable INDICATOR4_1 "Usual use of any sanitation"
label variable poverty "APL/BPL indicator from NARSS surveys"
label variable indicator_nfhs5 "indicator_nfhs5"
label variable survey "Surveys"
label variable year "year"


save Final_Appended_HH_Across_Survey_Jun_2023.dta, replace

