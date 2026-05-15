 
//Create the sanitation indicators and covariates from the NARSS3 data 


///// Access is defined at Household Level 
cd "$data" 

use NARSSHH3_With_District.dta, clear

rename _merge merge_dist

duplicates drop UID, force

gen cluster=PSUName

gen hhid=UID

tostring hhid, replace

gen OWN_HH_TOILET=1 if Q1_HH=="Private (only for family members)"
replace OWN_HH_TOILET=0 if OWN_HH_TOILET==.

//// Access to own or shared toilet

gen HH_TOILET=1 if Q1_HH=="Private (only for family members)" | Q1_HH=="Shared (used by multiple families)"
replace HH_TOILET=0 if HH_TOILET==.

// Access to shared toilet
gen SHARED_TOILET=1 if Q1_HH=="Shared (used by multiple families)"
replace SHARED_TOILET=0 if SHARED_TOILET==.

///Access to own, shared or public
gen ALL_TOILET=1 if Q1_HH=="Yes- We have access to toilet Exclusively used by our family" | Q1_HH=="Yes- We have access to toilet used by multiple families" | Q1_HH=="Yes- We have access to a Public toilet facility (toilet is"
replace ALL_TOILET=0 if ALL_TOILET==.

* Common defn of improved sanitation as per the mapping strict definiton

gen IMPROVED_LATRINE_1=1 if  Q4_HH=="A closed drain with Sewer system"
replace IMPROVED_LATRINE_1=1 if  Q4_HH=="Closed Pit"
replace IMPROVED_LATRINE_1=1 if  Q4_HH=="Double leach  pit toilet"
replace IMPROVED_LATRINE_1=1 if  Q4_HH=="Single leach  pit toilet"
replace IMPROVED_LATRINE_1=1 if  Q4_HH=="Septic tank with no overflow /discharge to surface / open"
replace IMPROVED_LATRINE_1=0 if IMPROVED_LATRINE_1==.

/// Common defn of improved sanitation as per the mapping removing only open defecation

gen IMPROVED_LATRINE_2=1 if  Q4_HH=="A closed drain with Sewer system"
replace IMPROVED_LATRINE_2=1 if  Q4_HH=="Closed Pit"
replace IMPROVED_LATRINE_2=1 if  Q4_HH=="Double leach  pit toilet"
replace IMPROVED_LATRINE_2=1 if  Q4_HH=="Single leach  pit toilet"
replace IMPROVED_LATRINE_2=1 if  Q4_HH=="Septic tank with no overflow /discharge to surface / open"
replace IMPROVED_LATRINE_2=1 if  Q4_HH=="Septic tank with overflow /discharge to surface / open drain"
replace IMPROVED_LATRINE_2=1 if  Q4_HH=="Open pit"
replace IMPROVED_LATRINE_2=1 if  Q4_HH=="Don't Know"
replace IMPROVED_LATRINE_2=0 if IMPROVED_LATRINE_2==.

///unimproved sanitation
gen UNIMPROVED_LATRINE=1 if Q4_HH=="Septic tank with overflow /discharge to surface / open drain"
replace UNIMPROVED_LATRINE=1 if Q4_HH=="Open pit"
replace UNIMPROVED_LATRINE=1 if Q4_HH=="Don't Know"

save analysis_sanitation_narss3_hh, replace

*using individual level data set to make assumptions about use
	
use NARSSIND3.dta, clear
*Creating hhsize variable
gen x=1
collapse(sum) x , by(UID)
sort UID
save temp1, replace

use NARSSIND3.dta, clear
sort UID
merge m:1 UID using temp1
drop _m

/// This is the total number of individual in the household including children less than 3 yrs of age
gen hhsize=x+Q8A_HH  
gen MEM_3Plus=hhsize-Q8A_HH
gen MEM_3Plus_Half=MEM_3Plus/2

*Always use at the indivisuakl level
gen USAGE_ALWAYS=1 if  Q7E_HH_=="Always"
replace USAGE_ALWAYS=0 if USAGE_ALWAYS==.
save analysis_sanitation_narss3, replace

use analysis_sanitation_narss3.dta, clear
collapse(mean) USAGE_ALWAYS, by(UID)
ren USAGE_ALWAYS USAGE_ALWAYSHH
sort UID
save temp2, replace

use analysis_sanitation_narss3.dta
collapse(sum) USAGE_ALWAYS, by(UID)
ren USAGE_ALWAYS COUNT_USAGE_ALWAYS
sort UID
merge 1:1 UID using temp2
drop _m
sort UID
save temp3, replace
use analysis_sanitation_narss3.dta, clear
sort UID 
merge m:1 UID using temp3
drop _m

gen USAGE_ALWAYSHH1= (USAGE_ALWAYSHH==1)
gen USAGE_USUALHH= (COUNT_USAGE_ALWAYS>MEM_3Plus_Half)
save analysis_sanitation_narss3, replace

collapse (mean) USAGE_ALWAYSHH1 USAGE_USUALHH hhsize, by(UID)

merge 1:1 UID using analysis_sanitation_narss3_hh.dta

gen INDICATOR1= (OWN_HH_TOILET == 1 & IMPROVED_LATRINE_1 == 1 & USAGE_ALWAYSHH1 == 1)
gen INDICATOR2= (OWN_HH_TOILET == 1 & IMPROVED_LATRINE_2 == 1 & USAGE_ALWAYSHH1 ==1)
gen INDICATOR3= (HH_TOILET == 1 & IMPROVED_LATRINE_1 == 1 & USAGE_ALWAYSHH1==1)
gen INDICATOR4= (HH_TOILET == 1 & IMPROVED_LATRINE_2 == 1 & USAGE_ALWAYSHH1 ==1)


gen INDICATOR5= (SHARED_TOILET == 1 & IMPROVED_LATRINE_1 == 1 & USAGE_ALWAYSHH1 ==1)
gen INDICATOR6= (OWN_HH_TOILET == 1 & UNIMPROVED_LATRINE == 1 & USAGE_ALWAYSHH1 ==1)


*Robustness check, using usual use of sanitation

gen INDICATOR1_1=(OWN_HH_TOILET== 1 & IMPROVED_LATRINE_1 == 1 & USAGE_USUALHH == 1)
gen INDICATOR4_1=(HH_TOILET== 1 & IMPROVED_LATRINE_2 == 1 & USAGE_USUALHH == 1)



/* Robustness check, using usual use of sanitation

gen INDICATOR1_1=(OWN_HH_TOILET== 1 & IMPROVED_LATRINE_1 == 1 & USAGE_USUALHH == 1)
gen INDICATOR2_1=(HH_TOILET== 1 & IMPROVED_LATRINE_1 == 1 & USAGE_USUALHH == 1)
gen INDICATOR3_1=(HH_TOILET== 1 & IMPROVED_LATRINE_2 == 1 & USAGE_USUALHH == 1)	
*/

gen weight_hh=Weights
gen weight_ind = Weights*hhsize

gen soc_grp = ""
replace soc_grp = "SC" if D3_HH_New == "Scheduled Caste"
replace soc_grp = "ST" if D3_HH_New == "Scheduled Tribe"
replace soc_grp = "OBC" if D3_HH_New == "Other Backward Class"
replace soc_grp = "GEN" if (D3_HH_New == "General" | D3_HH_New == "Don't Know/Can't Say")

gen fem_hh_hd = (GENDER_MEM1 == 2)
gen poverty = D2_HH


//child <=5 and adult >=60
gen child_under5 = 0
gen adult_older_60 = 0

local  age_vars Q7C_HH_1 Q7C_HH_2 Q7C_HH_3 Q7C_HH_4 Q7C_HH_5 Q7C_HH_6 Q7C_HH_7 Q7C_HH_8 Q7C_HH_9 Q7C_HH_10 Q7C_HH_11 Q7C_HH_12 Q7C_HH_13 Q7C_HH_14 Q7C_HH_15 Q7C_HH_16 Q7C_HH_17 Q7C_HH_18 Q7C_HH_19 Q7C_HH_20

destring `age_vars', replace


foreach var of varlist `age_vars'{
	
	replace child_under5 = child_under5 + 1 if  `var' <=5
	replace adult_older_60 = adult_older_60 + 1 if  `var' >=60 & `var'!=.

}
//add variable with number of children under 3
replace child_under5 = child_under5+ Q8A_HH



save Analysis_Sanitation_NARSS3.dta, replace

 