

use "$data\Final_Appended_HH_Across_Survey_Jun_2023", clear



//Pre-processing from Juan files
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

*rename time variables


//label the two indicators we will use
label variable INDICATOR1 "Regular use, own toilet"
label variable INDICATOR4 "Regular use, any toilet"

//Balanced
//keep if balance ==1

//svyset hh weight + district strata (note weights for a balanced panel)
svyset cluster [pw=weight], strata( dist_code)

********************************************************************
*Regressions (full sample)

*generating interaction terms

gen year1=(year==1)
gen year2=(year==2)
gen year3=(year==3)
gen year4=(year==4)
gen year5=(year==5)
gen year6=(year==6)

gen SC_year1=SC*year1
gen SC_year2=SC*year2
gen SC_year3=SC*year3
gen SC_year4=SC*year4
gen SC_year5=SC*year5
gen SC_year6=SC*year6

gen ST_year1=ST*year1
gen ST_year2=ST*year2
gen ST_year3=ST*year3
gen ST_year4=ST*year4
gen ST_year5=ST*year5
gen ST_year6=ST*year6

gen OBC_year1=OBC*year1
gen OBC_year2=OBC*year2
gen OBC_year3=OBC*year3
gen OBC_year4=OBC*year4
gen OBC_year5=OBC*year5
gen OBC_year6=OBC*year6



eststo clear

qui svy: logit INDICATOR4 i.year ib4.social_group fem_hh_hd child_under5_ind adult_older_60_ind hhsize i.dist_code 
eststo margin: margins, dydx(i.year ib4.social_group fem_hh_hd child_under5_ind adult_older_60_ind hhsize) post
estimates store a1


qui svy: logit INDICATOR4 i.year ib4.social_group SC_year2 SC_year3 SC_year4 SC_year5 SC_year6 ST_year2 ST_year3 ST_year4 ST_year5 ST_year6 OBC_year2 OBC_year3 OBC_year4 OBC_year5 OBC_year6  fem_hh_hd child_under5_ind  adult_older_60_ind hhsize i.dist_code 

eststo margin: margins, dydx(i.year ib4.social_group SC_year2 SC_year3 SC_year4 SC_year5 SC_year6 ST_year2 ST_year3 ST_year4 ST_year5 ST_year6 OBC_year2 OBC_year3 OBC_year4 OBC_year5 OBC_year6 fem_hh_hd child_under5_ind  adult_older_60_ind hhsize) post
estimates store a2

esttab a1 a2, cells(b(star fmt(3)) t(par fmt(2))) 

**********************************************************************************
*Regressions (NFHS only)


keep if year==1 | year==6

qui svy: logit INDICATOR4 ib4.social_group i.year SC_year6 ST_year6 OBC_year6 fem_hh_hd  child_under5_ind  adult_older_60_ind hhsize i.state_code  
eststo margin: margins, dydx(ib4.social_group i.year SC_year6 ST_year6 OBC_year6 fem_hh_hd  child_under5_ind  adult_older_60_ind hhsize) post
estimates store m1

qui svy: logit INDICATOR4 ib4.social_group i.year SC_year6 ST_year6 OBC_year6 fem_hh_hd  child_under5_ind  adult_older_60_ind hhsize i.state_code  if wealth_quintile_rur_nfhs==1
eststo margin: margins, dydx(ib4.social_group i.year SC_year6 ST_year6 OBC_year6 fem_hh_hd  child_under5_ind  adult_older_60_ind hhsize) post
estimates store m2


qui svy: logit INDICATOR4 ib4.social_group i.year SC_year6 ST_year6 OBC_year6 fem_hh_hd  child_under5_ind  adult_older_60_ind hhsize i.state_code  if wealth_quintile_rur_nfhs==2
eststo margin: margins, dydx(ib4.social_group i.year SC_year6 ST_year6 OBC_year6 fem_hh_hd child_under5_ind adult_older_60_ind hhsize) post
estimates store m3 

qui svy: logit INDICATOR4 ib4.social_group i.year SC_year6 ST_year6 OBC_year6 fem_hh_hd  child_under5_ind  adult_older_60_ind hhsize i.state_code  if wealth_quintile_rur_nfhs==3
eststo margin: margins, dydx(ib4.social_group i.year SC_year6 ST_year6 OBC_year6 fem_hh_hd child_under5_ind adult_older_60_ind hhsize) post
estimates store m4


qui svy: logit INDICATOR4 ib4.social_group i.year SC_year6 ST_year6 OBC_year6 fem_hh_hd  child_under5_ind  adult_older_60_ind hhsize i.state_code  if wealth_quintile_rur_nfhs==4
eststo margin: margins, dydx(ib4.social_group i.year SC_year6 ST_year6 OBC_year6 fem_hh_hd child_under5_ind adult_older_60_ind hhsize) post
estimates store m5

qui svy: logit INDICATOR4 ib4.social_group i.year SC_year6 ST_year6 OBC_year6 fem_hh_hd  child_under5_ind  adult_older_60_ind hhsize i.state_code  if wealth_quintile_rur_nfhs==5
eststo margin: margins, dydx(ib4.social_group i.year SC_year6 ST_year6 OBC_year6 fem_hh_hd child_under5_ind adult_older_60_ind hhsize) post
estimates store m6


esttab m1 m2 m3 m4 m5 m6, cells(b(star fmt(3)) t(par fmt(2))) 
***************************************************************
