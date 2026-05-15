
** Code to recreate figure 7

use "$data\Final_Appended_HH_Across_Survey_Jun_2023", clear

//set scheme for figures
set scheme white_tableau

//Pre-processing from Juan 
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
svyset cluster [pw=weight_ind], strata( state_code)


//Figure 7

//Group A
//UP
svy: mean INDICATOR4 if state_code==9, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

gen y=_n if !missing(b11)
foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f
twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Uttar Pradesh") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(UP, replace)
 
 matrix drop b1
 drop b11 b12 b13  
 
//Chattisgarh 
svy: mean INDICATOR4 if state_code==22, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f

twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Chattisgarh") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(Ch, replace)
 
 matrix drop b1
 drop b11 b12 b13 

//Telangana
svy: mean INDICATOR4 if state_code==36, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f

twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Telangana") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(Te, replace)
 
 matrix drop b1
 drop b11 b12 b13 
 
 //Karnataka
svy: mean INDICATOR4 if state_code==29, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f

twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Karnataka") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(Ka, replace)
 
 matrix drop b1
 drop b11 b12 b13
 
 
 //Gujarat
svy: mean INDICATOR4 if state_code==24, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f

twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Gujarat") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21",  labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(Gu, replace)
 
 matrix drop b1
 drop b11 b12 b13
 
  //HP
svy: mean INDICATOR4 if state_code==2, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f

twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Himachal Pradesh") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(HP, replace)
 
 matrix drop b1
 drop b11 b12 b13  
 //Combine graphs for Group A
 graph combine UP Ch Te Ka Gu HP
 graph export "$figures/figureA4_grpA.png", replace
 
 
 
//Group B
//Jharkhand
svy: mean INDICATOR4 if state_code==20, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f
twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Jharkhand") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(Jh, replace)
 
 matrix drop b1
 drop b11 b12 b13  
 
//Madhya Pradesh 
svy: mean INDICATOR4 if state_code==23, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f

twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Madhya Pradesh") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(Mp, replace)
 
matrix drop b1
drop b11 b12 b13 

//Tamil Nadu
svy: mean INDICATOR4 if state_code==33, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f

twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Tamil Nadu") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(Tn, replace)
 
 matrix drop b1
 drop b11 b12 b13 
 
 //Rajasthan
svy: mean INDICATOR4 if state_code==8, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f

twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Rajasthan") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(Ra, replace)
 
 matrix drop b1
 drop b11 b12 b13
 
 
 //Andhra Pradesh
svy: mean INDICATOR4 if state_code==28, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f

twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Andhra Pradesh") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(Ap, replace)
 
 matrix drop b1
 drop b11 b12 b13
 
  //Maharashtra
svy: mean INDICATOR4 if state_code==27, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f

twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Maharashtra") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(Ma, replace)
 
 matrix drop b1
 drop b11 b12 b13  
 
   //West Bengal
svy: mean INDICATOR4 if state_code==19, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f

twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("West Bengal") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(Wb, replace)
 
 matrix drop b1
 drop b11 b12 b13  
 
 //Combine graphs for Group B
 graph combine Jh Mp Tn Ra Ap Ma Wb
 graph export "$figures/figureA4_grpB.png", replace
 
 
 
//Group C
//Bihar
svy: mean INDICATOR4 if state_code==10, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f
twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Bihar") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(Bi, replace)
 
 matrix drop b1
 drop b11 b12 b13  
 
//Odisha 
svy: mean INDICATOR4 if state_code==21, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f

twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Odisha") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(Od, replace)
 
matrix drop b1
drop b11 b12 b13 

//Assam
svy: mean INDICATOR4 if state_code==18, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f

twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Assam") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100,labsize(medium)) ysc(r(0 100)) legend(off) name(As, replace)
 
 matrix drop b1
 drop b11 b12 b13 
 
 //Uttarakhand
svy: mean INDICATOR4 if state_code==5, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f

twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Uttarakhand") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100,labsize(medium)) ysc(r(0 100)) legend(off) name(Ut, replace)
 
 matrix drop b1
 drop b11 b12 b13
 
 
 //Haryana
svy: mean INDICATOR4  if state_code==6, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f

twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Haryana") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(Ha, replace)
 
 matrix drop b1
 drop b11 b12 b13
 
 //Punjab
svy: mean INDICATOR4 if state_code==3, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f

twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Punjab") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(Pu, replace)
 
 matrix drop b1
 drop b11 b12 b13  
 
   //Kerala
svy: mean INDICATOR4 if state_code==32, over(year)
mat b1= (r(table)[1, 1..6]\ r(table)[5..6, 1..6])'

svmat b1  

foreach var of varlist b11-b13{
	
	replace `var' = `var'*100
}

format b?? %2.0f

twoway (connected b11 y) ///
(rcap b12 b13 y, sort pstyle(ci) color(black)  ), ///
 title("Kerala") ytitle("") xtitle("") xlab(1 "2015-16" 2 "2017-18" 3 "2018" 4 "2018-19" 5 "2019-20" 6 "2019-21", labsize(medium) angle(45)) ylabel(0(25)100, labsize(medium)) ysc(r(0 100)) legend(off) name(Ke, replace)
 
 matrix drop b1
 drop b11 b12 b13  
 
 //Combine graphs for Group C
 graph combine Bi Od As Ut Ha Pu Ke
 graph export "$figures/figureA4_grpC.png", replace
 

 // CI estimates reported in paper related to figure 
 
 svy: mean INDICATOR4 if state_code==22 & inlist(year, 1, 6), over(year) coeflegend
 lincom _b[c.INDICATOR4@6.year] - _b[c.INDICATOR4@1bn.year]

 svy: mean INDICATOR4 if state_code==20 & inlist(year, 1, 6), over(year) coeflegend
 lincom _b[c.INDICATOR4@6.year] - _b[c.INDICATOR4@1bn.year]
 
  svy: mean INDICATOR4 if state_code==23 & inlist(year, 1, 6), over(year) coeflegend
 lincom _b[c.INDICATOR4@6.year] - _b[c.INDICATOR4@1bn.year]
 
  svy: mean INDICATOR4 if state_code==9 & inlist(year, 1, 6), over(year) coeflegend
 lincom _b[c.INDICATOR4@6.year] - _b[c.INDICATOR4@1bn.year]