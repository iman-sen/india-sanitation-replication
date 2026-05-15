
//Create the sanitation indicators and covariates from the NSS data 

cd "$data"

use HHBLOCK5.dta

//// merging this with nss district code file (From Appendix II of NSS76 docs)

gen state_code = STATE
gen district_code = state_code*1000+District


gen cluster=FSU_Serial_No

tostring cluster, replace

 
merge m:1 district_code using nss_state_district_code.dta, keepusing(state_name district_name) 

/// Note: There are 10 new districts whose district codes are not available in appendix II

replace state_name = "West Bengal" if state_code == 19 & _m == 1
replace state_name = "Gujarat" if state_code == 24 & _m == 1  
drop _m

label define sector 1 "Rural" 2 "Urban"
label values Sector sector

label define state 1 "Jammu & Kashmir" 2 "Himachal Pradesh" 3 "Punjab" 4 "Chandigarh" 5 "Uttarakhand" 6 "Haryana" 7 "Delhi" 8 "Rajasthan" 9 "Uttar Pradesh" 10	"Bihar" 11	"Sikkim" 12 "Arunachal Pradesh" 13 "Nagaland"  14 "Manipur" 15 "Mizoram"  16 "Tripura" 17 "Meghalaya" 18 "Assam" 19 "West Bengal" 20 "Jharkhand" 21 "Odisha" 22 "Chhattisgarh" 23 "Madhya Pradesh" 24 "Gujarat" 25 "Daman & Diu" 26 "Dadra & Nagar Haveli" 27 "Maharashtra" 28	"Andhra Pradesh" 29	"Karnataka" 30	"Goa" 31 "Lakshadweep" 32 "Kerala" 33 "Tamil Nadu" 34 "Puducherry" 35 "Andaman & Nicobar Islands" 36 "Telangana"
label values state_code state


///// Access is defined at Household Level and variable taken from HHBLOCK5
	
	gen OWN_HH_TOILET=1 if  Access_hh_latrine==1
    replace OWN_HH_TOILET=0 if  OWN_HH_TOILET==.
	
	//// Access to own or shared toilet 
	
	gen HH_TOILET=1 if  Access_hh_latrine==1 | Access_hh_latrine==2
    replace HH_TOILET=0 if  HH_TOILET==.

	//// Access to shared toilet 
	
	gen SHARED_TOILET=1 if Access_hh_latrine==2
    replace SHARED_TOILET=0 if SHARED_TOILET==.
	
	
*Defining Improved laterine definition based on the Improved latrine mapping across NARSS, NFHS and NSS (Please see excel file on laterine mapping, for detail) 

gen type_latrine_used = Type_latrine_used_byhousehold
	
	gen IMPROVED_LATERINE_1=1  if type_latrine_used==1
	replace IMPROVED_LATERINE_1=1 if type_latrine_used==2
	replace IMPROVED_LATERINE_1=1 if type_latrine_used==3
	replace IMPROVED_LATERINE_1=1 if type_latrine_used==4
	replace IMPROVED_LATERINE_1=1 if type_latrine_used==6
	replace IMPROVED_LATERINE_1=1 if type_latrine_used==7
	replace IMPROVED_LATERINE_1=1 if type_latrine_used==10
	replace IMPROVED_LATERINE_1=0 if IMPROVED_LATERINE_1==.
	

/// Defining any sanitation 
	
	gen IMPROVED_LATERINE_2=1  if type_latrine_used==1
	replace IMPROVED_LATERINE_2=1 if type_latrine_used==2
	replace IMPROVED_LATERINE_2=1 if type_latrine_used==3
	replace IMPROVED_LATERINE_2=1 if type_latrine_used==4
	replace IMPROVED_LATERINE_2=1 if type_latrine_used==6
	replace IMPROVED_LATERINE_2=1 if type_latrine_used==7
	replace IMPROVED_LATERINE_2=1 if type_latrine_used==8
	replace IMPROVED_LATERINE_2=1 if type_latrine_used==10
	replace IMPROVED_LATERINE_2=1 if type_latrine_used==19	
	replace IMPROVED_LATERINE_2=0 if IMPROVED_LATERINE_2==.
	
///Unimproved sanitation

gen UNIMPROVED_LATERINE=1 if type_latrine_used==8
replace UNIMPROVED_LATERINE=1 if type_latrine_used==19
replace UNIMPROVED_LATERINE=1 if UNIMPROVED_LATERINE==.
	
	
*saveold analysis_sanitation_hh.dta, version(13) replace

save analysis_sanitation_hh.dta, replace

*using individual level data set to make assumptions about use
	
use INDBLOCK3, clear	

*Creating variables to define the use status through three different criterion
	
*Individual regular use, at the individual level
gen USE_REGULAR=1 if use_latrine_code==1
	replace USE_REGULAR=0 if USE_REGULAR==.
	
	
	  *Majority Criterion, defined at the household level
	gen USUAL_USE=(count_use_regular>count_mem_half)
		
	*All individual used regularly, defined at the household level
    gen ALL_REGULAR_USE=(mean_regular_use==1)
   	
	gen hhsize=count_mem
	
	gen hh_hd = (Relationship_head == 1)
gen fem_hh_hd =(hh_hd == 1 & Gender == 2)	

//Iman: child <= 5 and adult >=60	
gen child_under5 = (Age<=5)	
gen adult_older_60 = (Age>=60)
	
collapse (mean) ALL_REGULAR_USE USUAL_USE hhsize fem_hh_hd (rawsum) child_under5 adult_older_60 , by(hhid)
	

replace fem_hh_hd = 1 if fem_hh_hd > 0

merge 1:1 hhid using analysis_sanitation_hh.dta
drop _m

*saveold analysis_sanitation_hh.dta, version(13) replace

save analysis_sanitation_hh.dta, replace
	
gen INDICATOR1=(OWN_HH_TOILET== 1 & IMPROVED_LATERINE_1== 1 & ALL_REGULAR_USE == 1)
gen INDICATOR2=(OWN_HH_TOILET== 1 & IMPROVED_LATERINE_2 == 1 & ALL_REGULAR_USE== 1)	
gen INDICATOR3=(HH_TOILET== 1 & IMPROVED_LATERINE_1 == 1 & ALL_REGULAR_USE== 1)
gen INDICATOR4=(HH_TOILET== 1 & IMPROVED_LATERINE_2 == 1 & ALL_REGULAR_USE== 1)	

gen INDICATOR5=(SHARED_TOILET== 1 & IMPROVED_LATERINE_1 == 1 & ALL_REGULAR_USE== 1)
gen INDICATOR6=(OWN_HH_TOILET== 1 & UNIMPROVED_LATERINE == 1 & ALL_REGULAR_USE== 1)	

//robustness check, usual use of sanitation

*Robustness check, using usual use of sanitation

gen INDICATOR1_1=(OWN_HH_TOILET== 1 & IMPROVED_LATERINE_1 == 1 & USUAL_USE == 1)
gen INDICATOR4_1=(HH_TOILET== 1 & IMPROVED_LATERINE_2 == 1 & USUAL_USE == 1)


/*
////// Robustness check, using usual use of sanitation

gen INDICATOR1_1=(OWN_HH_TOILET== 1 & IMPROVED_LATERINE_1 == 1 & USUAL_USE == 1)
gen INDICATOR2_1=(HH_TOILET== 1 & IMPROVED_LATERINE_1 == 1 & USUAL_USE == 1)
gen INDICATOR3_1=(HH_TOILET== 1 & IMPROVED_LATERINE_2 == 1 & USUAL_USE == 1)	

*/

gen weight_ind = hhsize*weight_hh

drop x

gen x= OWN_HH_TOILET*IMPROVED_LATERINE_1

gen y= HH_TOILET*IMPROVED_LATERINE_1


gen soc_grp = ""
replace soc_grp = "SC" if SOCIAL_GROUP == 2
replace soc_grp = "ST" if SOCIAL_GROUP == 1
replace soc_grp = "OBC" if SOCIAL_GROUP == 3
replace soc_grp = "GEN" if (SOCIAL_GROUP == 9)

gen religion = ""
replace religion = "Hindu" if Religion==1 
replace religion = "Muslim" if Religion==2
replace religion = "Christian" if Religion==3
replace religion = "Others" if (Religion>3 & Religion!=.)


xtile mpce_quintile_all_india_nss  = Usual_mpce_hh_ABCD [aw=weight_hh], nq(5)
 
xtile mpce_quintile_rural_nss  = Usual_mpce_hh_ABCD if Sector==1  [aw=weight_hh], nq(5)
 
xtile mpce_quintile_urban_nss  = Usual_mpce_hh_ABCD if Sector==2  [aw=weight_hh], nq(5)


ren district_code dist_code_nss 

save analysis_sanitation_NSS.dta, replace
 
