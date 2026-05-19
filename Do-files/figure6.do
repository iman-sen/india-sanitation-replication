 
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


//figure 6

svy: mean INDICATOR4 if soc_grp=="SC", over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svy: mean INDICATOR4 if soc_grp=="ST", over(year)
mat b2= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svy: mean INDICATOR4 if soc_grp=="OBC", over(year)
mat b3= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svy: mean INDICATOR4 if (soc_grp=="GEN"), over(year)
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
  
 twoway (bar b4 y, fcolor("68 114 196") lwidth(none) barwidth(0.3) ) ///
 (rcap b5 b6 y, sort pstyle(ci) color(black)) ///
  (scatter b4 y, msymbol(none) mlabel(b4) mlabposition(1) mlabsize(large)), ///  
    ytitle("Percentage Use" , size(medium)) yscale(range(0(10)100)) ylabel(0(10)100 , labsize(medium))  legend(off)   xtitle("Survey, Year", size(medium))  xlab(1 "NFHS,2015-2016" 2 "NARSS,2017-2018" 3 "NSS,2018" 4 "NARSS,2018-2019" 5 "NARSS,2019-2020" 6 "NFHS,2019-21", labsize(medsmall) angle(45) nogrid) 
	graph export "$figures\figure6_panelA.png", replace
	 
	twoway (bar b1 y, fcolor("68 114 196") lwidth(none) barwidth(0.3) ) ///
 (rcap b2 b3 y, sort pstyle(ci) color(black)) ///
  (scatter b1 y, msymbol(none) mlabel(b1) mlabposition(1) mlabsize(large)), ///  
    ytitle("Percentage Use" , size(medium)) yscale(range(0(10)100)) ylabel(0(10)100 , labsize(medium))  legend(off)   xtitle("Survey, Year", size(medium))  xlab(1 "NFHS,2015-2016" 2 "NARSS,2017-2018" 3 "NSS,2018" 4 "NARSS,2018-2019" 5 "NARSS,2019-2020" 6 "NFHS,2019-21", labsize(medsmall) angle(45) nogrid) 
  
  	graph export "$figures\figure6_panelB.png", replace

  	
 twoway (bar b7 y, fcolor("68 114 196") lwidth(none) barwidth(0.3) ) ///
 (rcap b8 b9 y, sort pstyle(ci) color(black)) ///
  (scatter b7 y, msymbol(none) mlabel(b7) mlabposition(1) mlabsize(large)), ///  
    ytitle("Percentage Use" , size(medium)) yscale(range(0(10)100)) ylabel(0(10)100 , labsize(medium))  legend(off)   xtitle("Survey, Year", size(medium))  xlab(1 "NFHS,2015-2016" 2 "NARSS,2017-2018" 3 "NSS,2018" 4 "NARSS,2018-2019" 5 "NARSS,2019-2020" 6 "NFHS,2019-21", labsize(medsmall) angle(45) nogrid) 
 
  	graph export "$figures\figure6_panelC.png", replace

  twoway (bar b10 y, fcolor("68 114 196") lwidth(none) barwidth(0.3) ) ///
 (rcap b11 b12 y, sort pstyle(ci) color(black)) ///
  (scatter b10 y, msymbol(none) mlabel(b10) mlabposition(1) mlabsize(large)), ///  
    ytitle("Percentage Use" , size(medium)) yscale(range(0(10)100)) ylabel(0(10)100 , labsize(medium))  legend(off)   xtitle("Survey, Year", size(medium))  xlab(1 "NFHS,2015-2016" 2 "NARSS,2017-2018" 3 "NSS,2018" 4 "NARSS,2018-2019" 5 "NARSS,2019-2020" 6 "NFHS,2019-21", labsize(medsmall) angle(45) nogrid) 
 
  	graph export "$figures\figure6_panelD.png", replace