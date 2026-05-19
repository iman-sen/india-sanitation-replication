 
use "$data\Final_Appended_HH_Across_Survey_Jun_2023", clear

//set scheme for figures
set scheme white_tableau

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

//svyset: individual weights + state strata 
svyset cluster [pw=weight_ind], strata( state_code)

//first change strata to district
svyset cluster [pw=weight_ind], strata( dist_code )
 
egen dm42 = mean(INDICATOR4) if year ==1 & balance ==1, by(dist_code_nfhs4)
xtile i4_quart2= dm42, n(4)
bys dist_code:  egen i4_quart_all2 = max(i4_quart2)

svy: mean INDICATOR4 if i4_quart_all2==1 & balance==1, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svy: mean INDICATOR4 if i4_quart_all2==2 & balance==1, over(year)
mat b2= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svy: mean INDICATOR4 if i4_quart_all2==3 & balance==1, over(year)
mat b3= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svy: mean INDICATOR4 if i4_quart_all2==4 & balance==1, over(year)
mat b4= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

mat b= b1, b2,b3, b4
svmat b  

gen y=_n if !missing(b1)
foreach var of varlist b1-b12{
	
	replace `var' = `var'*100
}

label variable y "Survey,Year"
format b? %2.0f
format b10 %2.0f
format b11 %2.0f
format b12 %2.0f


twoway (connected b1 y,  msy(none) mlab(b1) mlabpos(2)) ///
(connected b4 y,   msy(none) mlab(b4) mlabpos(12))  /// 
(connected b7 y,  msy(none) mlab(b7) mlabpos(12)) ///
(connected b10 y,  msy(none) mlab(b10) mlabpos(11)) ///
(rcap b2 b3 y, sort pstyle(ci) color(black)  ) ///
(rcap b5 b6 y, sort pstyle(ci) color(black)    ) ///
(rcap b8 b9 y, sort pstyle(ci) color(black)  ) ///
(rcap b11 b12 y, sort pstyle(ci) color(black)  ), ///
 ytitle("Percentage Use") xlab(1 "NFHS,2015-2016" 2 "NARSS,2017-2018" 3 "NSS,2018" 4 "NARSS,2018-2019" 5 "NARSS,2019-2020" 6 "NFHS,2019-21", labsize(vsmall) angle(45)) ///
 ylabel(10(10)100) ysc(r(10 100)) legend(pos(5) ring(0) col(1) region(lwidth(none)) order(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4"))

graph export "$figures\figure5.png" 
 