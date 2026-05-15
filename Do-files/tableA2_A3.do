
//regression tables A2 and A3
use "$data\Final_Appended_HH_Across_Survey_Jun_2023", clear

rename dist_code_nfhs5 dist_code
label variable dist_code dist_code_nfhs5
label define year ///
1 "2014-15" ///
2 "2017-18" ///
3 "2018" ///
4 "2018-19" ///
5 "2019-20" ///
6 "2019-21"
label values year year
drop survey
rename balance_indicator balance
order indicator_nfhs5, after( indicator_nfhs4 )
label variable indicator_nfhs5 indicator_nfhs5
replace cluster = subinstr( cluster , "PSU"      , "" , . )
replace cluster = subinstr( cluster , "Village-" , "" , . )
generate long kluster = year * 1000000 + real( cluster )
order kluster, after( cluster )
drop cluster
rename kluster cluster
generate double weight = weight_hh if balance
order weight, before( weight_hh )
label variable weight "HH Weight (if balanced)"

label define sc ///
 1 "Jammu_and_Kashmir" ///
 2 "Himachal_Pradesh" ///
 3 "Punjab" ///
 4 "Chandigarh" ///
 5 "Uttarakhand" ///
 6 "Haryana" ///
 7 "Delhi" ///
 8 "Rajasthan" ///
 9 "Uttar_Pradesh" ///
10 "Bihar" ///
11 "Sikkim" ///
12 "Arunachal_Pradesh" ///
13 "Nagaland" ///
14 "Manipur" ///
15 "Mizoram" ///
16 "Tripura" ///
17 "Meghalaya" ///
18 "Assam" ///
19 "West_Bengal" ///
20 "Jharkhand" ///
21 "Odisha" ///
22 "Chhattisgarh" ///
23 "Madhya_Pradesh" ///
24 "Gujarat" ///
25 "Dadra_and_Nagar_Haveli" ///
27 "Maharashtra" ///
28 "Andhra_Pradesh" ///
29 "Karnataka" ///
30 "Goa" ///
31 "Lakshadweep" ///
32 "Kerala" ///
33 "Tamil_Nadu" ///
34 "Puducherry" ///
35 "Andaman_and_Nicobar" ///
36 "Telangana" ///
37 "Ladakh"
label values state_code sc



capture drop sd
capture drop ss
capture drop state_dist

generate int   sd = 1000 * Sector +  dist_code
label variable sd "Sector+District"
generate int   ss = 1000 * Sector + state_code
label variable ss "Sector+State"

generate state_dist = 1000 * dist_code + state_code
label variable ss "District+State"


//keep rural
keep if Sector == 1

//generate a few variables

//social group indicators for each category
gen SC=1 if soc_grp=="SC"
replace SC = 0 if inlist(soc_grp, "GEN", "ST", "OBC")
gen ST=1 if soc_grp=="ST"
replace ST = 0 if inlist(soc_grp, "GEN", "SC", "OBC")
gen OBC = 1 if soc_grp=="OBC"
replace OBC = 0 if inlist(soc_grp, "GEN", "SC", "ST")
gen other = 1 if soc_grp =="GEN"
replace other = 0 if inlist(soc_grp, "OBC", "SC", "ST")


//indicator for both SC and ST
gen SCST = 1 if inlist(soc_grp, "ST", "SC")
replace SCST = 0 if inlist(soc_grp, "GEN", "OBC")

//social group, alternative definiton

gen social_group=.
replace social_group=1 if soc_grp=="SC"
replace social_group=2 if soc_grp=="ST"
replace social_group=3 if soc_grp=="OBC"
replace social_group=4 if soc_grp=="GEN"

label define social_group 1 "SC" 2"ST" 3 "OBC" 4 "Others"
label values social_group social_group

//children <= 5 indicator
gen child_under5_ind = (child_under5 > 0) 
 
//adult over 60 indicator
gen adult_older_60_ind = (adult_older_60 > 0) 

//religion: define groups by Hindi, Muslim, Christian Others
gen hindu = 1 if religion == "Hindu"
replace hindu = 0 if inlist(religion, "Christian", "Muslim", "Others")

gen muslim = 1 if religion == "Muslim"
replace muslim = 0 if inlist(religion, "Christian", "Hindu", "Others")

gen christian = 1 if religion == "Christian"
replace christian = 0 if inlist(religion, "Muslim", "Hindu", "Others")
 
//Religion, alternative option
gen religion_2=.
replace religion_2=1 if religion=="Hindu"
replace religion_2=2 if religion=="Muslim"
replace religion_2=3 if religion=="Christian"
replace religion_2=4 if religion=="Others"


//label the two indicators we will use
label variable INDICATOR1 "Regular use, own toilet"
label variable INDICATOR4 "Regular use, any toilet"

 
//svyset hh weight + district strata (note weights for a balanced panel)
svyset cluster [pw=weight], strata( dist_code  )
 
********************************************************************

areg INDICATOR4 i.year ib4.social_group fem_hh_hd child_under5_ind adult_older_60_ind hhsize [pweight = weight_ind], abs(dist_code) cluster(cluster)
outreg2 using "$regs\tableA2.xls",  replace label stat(coef se) dec(3) noparen ctitle(1) sideway

areg INDICATOR4 i.year ib4.social_group fem_hh_hd child_under5_ind  adult_older_60_ind hhsize ib4.social_group#i.year  [pweight = weight_ind], abs(dist_code) cluster(cluster)
outreg2 using "$regs\tableA2.xls", append  label stat(coef se) dec(3) noparen ctitle(2) sideway


****************************************************************

keep if year==1 | year==6
 gen time = 0 if year==1
replace time=1 if year==6
 gen bottom_20=(wealth_quintile_rur_nfhs<2 )
replace bottom_20=. if wealth_quintile_rur_nfhs==.
 gen bottom_40=(wealth_quintile_rur_nfhs<3 )
replace bottom_40=. if wealth_quintile_rur_nfhs==.


areg INDICATOR4 ib4.social_group##year fem_hh_hd hhsize child_under5_ind  adult_older_60_ind [pweight = weight_ind], abs(dist_code) cluster(cluster)
outreg2 using "$regs\tableA3.xls", replace label stat(coef se) dec(3) ctitle(All) 

areg INDICATOR4 ib4.social_group##year fem_hh_hd hhsize child_under5_ind  adult_older_60_ind if wealth_quintile_rur_nfhs==1 [pweight = weight_ind], abs(dist_code) cluster(cluster) 
outreg2 using "$regs\tableA3.xls",   append label stat(coef se) dec(3) ctitle(Wealth Quintile=1) 

areg INDICATOR4 ib4.social_group##year fem_hh_hd hhsize child_under5_ind  adult_older_60_ind if wealth_quintile_rur_nfhs==2 [pweight = weight_ind], abs(dist_code) cluster(cluster)
outreg2 using "$regs\tableA3.xls",  append label stat(coef se) dec(3) ctitle(Wealth Quintile=2) 

areg INDICATOR4 ib4.social_group##year fem_hh_hd hhsize child_under5_ind  adult_older_60_ind if wealth_quintile_rur_nfhs==3 [pweight = weight_ind], abs(dist_code) cluster(cluster)
outreg2 using "$regs\tableA3.xls",  append label stat(coef se) dec(3) ctitle(Wealth Quintile=3) 

areg INDICATOR4 ib4.social_group##year fem_hh_hd hhsize child_under5_ind  adult_older_60_ind if wealth_quintile_rur_nfhs==4 [pweight = weight_ind], abs(dist_code) cluster(cluster)
outreg2 using "$regs\tableA3.xls", append label stat(coef se) dec(3) ctitle(Wealth Quintile=4) 

areg INDICATOR4 ib4.social_group##year fem_hh_hd hhsize child_under5_ind  adult_older_60_ind if wealth_quintile_rur_nfhs==5 [pweight = weight_ind], abs(dist_code) cluster(cluster)
outreg2 using "$regs\tableA3.xls",  append label stat(coef se) dec(3) ctitle(Wealth Quintile=5)



************************************************************
