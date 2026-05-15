*============================================================
* Figure 1 — toilet coverage across surveys (Stata-native)
* Replicates figure2.do without going through Excel
*============================================================

local alpha = 0.05
local z_crit = invnormal(1 - `alpha'/2)

label define yearlbl 1 "2015-16" 2 "2017-18" 3 "2018" ///
                    4 "2018-19" 5 "2019-20" 6 "2019-21", replace

*------------------------------------------------------------
* Panel A — share of HHs with a toilet
*------------------------------------------------------------
tempname pfA
tempfile resA
postfile `pfA' survey_n str20 variable double(mean lo hi) ///
    using "`resA'", replace

foreach spec in ///
    "1 analysis_sanitation_NFHS4  1 OWN_HH_TOILET HH_TOILET" ///
    "2 Analysis_Sanitation_NARSS1 0 OWN_HH_TOILET HH_TOILET" ///
    "3 Analysis_Sanitation_NSS    0 x             y"         ///
    "4 Analysis_Sanitation_NARSS2 0 OWN_HH_TOILET HH_TOILET" ///
    "5 Analysis_Sanitation_NARSS3 0 OWN_HH_TOILET HH_TOILET" ///
    "6 analysis_sanitation_NFHS5  1 OWN_HH_TOILET HH_TOILET" {

    tokenize `"`spec'"'
    local n     = `1'
    local file  `2'
    local rural = `3'
    local own   `4'
    local any   `5'

    use "$data\\`file'", clear
    if `rural'==1 keep if Sector==1

    foreach pair in "Own `own'" "Own_or_Shared `any'" {
        tokenize `"`pair'"'
        local lab `1'
        local v   `2'
        sum `v' [aw=weight_hh]
        local m  = r(mean)
        local me = `z_crit' * r(sd)/sqrt(r(N))
        post `pfA' (`n') ("`lab'") (`m') (`m'-`me') (`m'+`me')
    }
}
postclose `pfA'

use "`resA'", clear
encode variable, gen(var)
label values survey_n yearlbl
gen pos = survey_n + cond(var==1, -0.18, 0.18)
replace mean = mean*100
replace lo   = lo*100
replace hi   = hi*100
gen pct_lab = string(round(mean), "%2.0f") + "%"
gen lab_y   = hi + 2.5

twoway ///
    (bar  mean pos if var==1, barw(0.32) color(blue%80)) ///
    (bar  mean pos if var==2, barw(0.32) color(orange%80)) ///
    (rcap hi lo pos, lcolor(black) lwidth(medthin)) ///
    (scatter lab_y pos, msymbol(none) mlabel(pct_lab) ///
        mlabposition(0) mlabsize(medium) mlabcolor(black)) , ///
    xlabel(1 "2015-16" 2 "2017-18" 3 "2018" ///
           4 "2018-19" 5 "2019-20" 6 "2019-21", angle(30)) ///
    xtitle("Survey year") ytitle("Households (%)") ///
    ylabel(0(20)100, angle(0) format(%2.0f)) ///
    legend(order(1 "Own" 2 "Own or Shared") rows(1) pos(6)) ///
    title("A. Any Toilet Access", size(medium) pos(11)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig2a, replace)

graph export "$figures\figure1a.png", replace width(1800)

*------------------------------------------------------------
* Panel B — share of HHs with an improved toilet
*------------------------------------------------------------
tempname pfB
tempfile resB
postfile `pfB' survey_n str20 variable double(mean lo hi) ///
    using "`resB'", replace

* Surveys differ in (a) the improved-toilet variable, (b) whether x/y
* are pre-built (NSS), (c) whether to restrict to rural (Sector==1).
foreach spec in ///
    "1 analysis_sanitation_NFHS4  1 OWN_HH_TOILET HH_TOILET IMPROVED_SANIT"     ///
    "2 Analysis_Sanitation_NARSS1 0 OWN_HH_TOILET HH_TOILET IMPROVED_LATRINE_1" ///
    "3 Analysis_Sanitation_NSS    0 x             y         ."                  ///
    "4 Analysis_Sanitation_NARSS2 0 OWN_HH_TOILET HH_TOILET IMPROVED_LATRINE_1" ///
    "5 Analysis_Sanitation_NARSS3 0 OWN_HH_TOILET HH_TOILET IMPROVED_LATRINE_1" ///
    "6 analysis_sanitation_NFHS5  1 OWN_HH_TOILET HH_TOILET IMPROVED_SANIT"     {

    tokenize `"`spec'"'
    local n     = `1'
    local file  `2'
    local rural = `3'
    local own   `4'
    local any   `5'
    local imp   `6'

    use "$data\\`file'", clear
    if `rural'==1 keep if Sector==1

    * NSS already has x/y; everyone else needs them built
    if "`imp'" != "." {
        capture drop x y
        gen x = `own' * `imp'
        gen y = `any' * `imp'
    }

    foreach pair in "Own x" "Own_or_Shared y" {
        tokenize `"`pair'"'
        local lab `1'
        local v   `2'
        sum `v' [aw=weight_hh]
        local m  = r(mean)
        local me = `z_crit' * r(sd)/sqrt(r(N))
        post `pfB' (`n') ("`lab'") (`m') (`m'-`me') (`m'+`me')
    }
}
postclose `pfB'

use "`resB'", clear
encode variable, gen(var)
label values survey_n yearlbl
gen pos = survey_n + cond(var==1, -0.18, 0.18)
replace mean = mean*100
replace lo   = lo*100
replace hi   = hi*100
gen pct_lab = string(round(mean), "%2.0f") + "%"
gen lab_y   = hi + 2.5

twoway ///
    (bar  mean pos if var==1, barw(0.32) color(blue%80)) ///
    (bar  mean pos if var==2, barw(0.32) color(orange%80)) ///
    (rcap hi lo pos, lcolor(black) lwidth(medthin)) ///
    (scatter lab_y pos, msymbol(none) mlabel(pct_lab) ///
        mlabposition(0) mlabsize(medium) mlabcolor(black)) , ///
    xlabel(1 "2015-16" 2 "2017-18" 3 "2018" ///
           4 "2018-19" 5 "2019-20" 6 "2019-21", angle(30)) ///
    xtitle("Survey year") ytitle("Households (%)") ///
    ylabel(0(20)100, angle(0) format(%2.0f)) ///
    legend(order(1 "Own" 2 "Own or Shared") rows(1) pos(6)) ///
    title("B. Improved Toilet Access", size(medium) pos(11)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig2b, replace)

graph export "$figures\figure1b.png", replace width(1800)

*------------------------------------------------------------
* Combined two-panel figure
*------------------------------------------------------------
graph combine fig2a fig2b, ///
    rows(1) graphregion(color(white)) ///
    name(fig2, replace)

graph export "$figures\figure1.png", replace width(2400)
