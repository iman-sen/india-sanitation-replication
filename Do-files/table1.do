 ** Code to recreate Table 1

use "$data\Final_Appended_HH_Across_Survey_Jun_2023", clear


//Pre-processing from Juan files
rename dist_code_nfhs5 dist_code
label variable dist_code dist_code_nfhs5
label define year ///
1 "NFHS4" ///
2 "NARSS1" ///
3 "NSS76" ///
4 "NARSS2" ///
5 "NARSS3" ///
6 "NFHS5"
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
  
//svyset ind weight + state strata  
svyset cluster [pw=weight_ind], strata(state_code)

putexcel set "$tables\table1.xlsx", replace
putexcel A1=("State") B1=("NFHS4") C1= ("Diff21") D1=("Diff32") E1= ("Diff43") F1=("Diff54") G1= ("Diff65") 

//Order by Table 
local states 24 2 9 22 36 29 8 19 28 23 33 27 20 10 6 21 5 3 32 18
  
local row = 2
foreach l of local states {

local sn: label (state_code) `l' 

putexcel A`row' = "`sn'"

svy: mean INDICATOR4 if state_code ==`l' & year == 1
local my1 = r(table)[1, 1]*100
local cy1 = r(table)[5, 1]*100
local moe1 = `my1'- `cy1'

local my1_f: display %3.0f `my1'
putexcel B`row' = "`my1_f'"

svy: mean INDICATOR4_1 if state_code ==`l' & year == 2
local my2 = r(table)[1, 1]*100
local cy2 = r(table)[5, 1]*100
local moe2 = `my2'- `cy2'

local md21 : display %3.0f `my2'-`my1'
local moe21:  display %2.0f sqrt(`moe1'^2 + `moe2'^2 )

putexcel C`row' = "`md21' ±`moe21'"

svy: mean INDICATOR4_1 if state_code ==`l' & year == 3
local my3 = r(table)[1, 1]*100
local cy3 = r(table)[5, 1]*100
local moe3 = `my3'- `cy3'

local md32 : display %3.0f `my3'-`my2'
local moe32:  display %2.0f sqrt(`moe2'^2 + `moe3'^2 )

putexcel D`row' = "`md32' ±`moe32'"


svy: mean INDICATOR4_1 if state_code ==`l' & year == 4
local my4 = r(table)[1, 1]*100
local cy4 = r(table)[5, 1]*100
local moe4 = `my4'- `cy4'

local md43 : display %3.0f `my4'-`my3'
local moe43:  display %2.0f sqrt(`moe3'^2 + `moe4'^2 )

putexcel E`row' = "`md43' ±`moe43'"


svy: mean INDICATOR4_1 if state_code ==`l' & year == 5
local my5 = r(table)[1, 1]*100
local cy5 = r(table)[5, 1]*100
local moe5 = `my5'- `cy5'

local md54 : display %3.0f `my5'-`my4'
local moe54:  display %2.0f sqrt(`moe4'^2 + `moe5'^2 )

putexcel F`row' = "`md54' ±`moe54'"

svy: mean INDICATOR4 if state_code ==`l' & year == 6
local my6 = r(table)[1, 1]*100
local cy6 = r(table)[5, 1]*100
local moe6 = `my6'- `cy6'

local md65 : display %3.0f `my6'-`my5'
local moe65:  display %2.0f sqrt(`moe5'^2 + `moe6'^2 )

putexcel G`row' = "`md65' ±`moe65'"

local row = `row' + 1


}

 
