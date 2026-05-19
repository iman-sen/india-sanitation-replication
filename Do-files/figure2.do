*============================================================
* Figure 2 — INDICATOR4 by subgroup, NFHS4 vs NFHS5 (rural)
* Replicates figure3.do without going through Excel
*============================================================

local alpha = 0.05
local z_crit = invnormal(1 - `alpha'/2)

*------------------------------------------------------------
* Panel A — by wealth quintile
*------------------------------------------------------------
tempname pfA
tempfile resA
postfile `pfA' survey_n group_n double(mean lo hi) ///
    using "`resA'", replace

foreach spec in ///
    "1 analysis_sanitation_NFHS4" ///
    "2 analysis_sanitation_NFHS5" {

    tokenize `"`spec'"'
    local n     = `1'
    local file  `2'

    use "$data\\`file'", clear
    keep if Sector==1

    forvalues q = 1/5 {
        sum INDICATOR4 if wealth_quintile_rur_nfhs==`q' [aw=weight_ind]
        if r(N) > 0 {
            local m  = r(mean)
            local me = `z_crit' * r(sd)/sqrt(r(N))
            post `pfA' (`n') (`q') (`m') (`m'-`me') (`m'+`me')
        }
    }
}
postclose `pfA'

use "`resA'", clear
replace mean = mean*100
replace lo   = lo*100
replace hi   = hi*100
gen pos = group_n + cond(survey_n==1, -0.18, 0.18)
gen pct_lab = string(round(mean), "%2.0f") + "%"
gen lab_y   = hi + 2.5

twoway ///
    (bar  mean pos if survey_n==1, barw(0.32) color(blue%80)) ///
    (bar  mean pos if survey_n==2, barw(0.32) color(orange%80)) ///
    (rcap hi lo pos, lcolor(black) lwidth(medthin)) ///
    (scatter lab_y pos, msymbol(none) mlabel(pct_lab) ///
        mlabposition(0) mlabsize(medium) mlabcolor(black)) , ///
    xlabel(1 "Q1 (Poorest)" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5 (Richest)", ///
        angle(30)) ///
    xtitle("Wealth quintile") ytitle("Households (%)") ///
    ylabel(0(20)100, angle(0) format(%2.0f)) ///
    legend(order(1 "2015-16" 2 "2019-21") rows(1) pos(6)) ///
    title("A. By wealth quintile", size(medium) pos(11)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig3a, replace)

graph export "$figures\figure2a.png", replace width(1800)

*------------------------------------------------------------
* Panel B — by social group
*------------------------------------------------------------
* Build a consistent group->id mapping from NFHS4 first
use "$data\analysis_sanitation_NFHS4", clear
keep if Sector==1
levelsof soc_grp, local(soc_groups) clean

* Save mapping as locals: g1, g2, ...
local i = 0
foreach g of local soc_groups {
    local ++i
    local g`i' "`g'"
}
local ng = `i'

tempname pfB
tempfile resB
postfile `pfB' survey_n group_n str40 group_label double(mean lo hi) ///
    using "`resB'", replace

foreach spec in ///
    "1 analysis_sanitation_NFHS4" ///
    "2 analysis_sanitation_NFHS5" {

    tokenize `"`spec'"'
    local n     = `1'
    local file  `2'

    use "$data\\`file'", clear
    keep if Sector==1

    forvalues k = 1/`ng' {
        local g "`g`k''"
        sum INDICATOR4 if soc_grp=="`g'" [aw=weight_ind]
        if r(N) > 0 {
            local m  = r(mean)
            local me = `z_crit' * r(sd)/sqrt(r(N))
            post `pfB' (`n') (`k') ("`g'") (`m') (`m'-`me') (`m'+`me')
        }
    }
}
postclose `pfB'

use "`resB'", clear
replace mean = mean*100
replace lo   = lo*100
replace hi   = hi*100
gen pos = group_n + cond(survey_n==1, -0.18, 0.18)
gen pct_lab = string(round(mean), "%2.0f") + "%"
gen lab_y   = hi + 2.5

* Build the xlabel option dynamically from the group->id mapping
local xlbl ""
forvalues k = 1/`ng' {
    local xlbl `xlbl' `k' "`g`k''"
}

twoway ///
    (bar  mean pos if survey_n==1, barw(0.32) color(blue%80)) ///
    (bar  mean pos if survey_n==2, barw(0.32) color(orange%80)) ///
    (rcap hi lo pos, lcolor(black) lwidth(medthin)) ///
    (scatter lab_y pos, msymbol(none) mlabel(pct_lab) ///
        mlabposition(0) mlabsize(medium) mlabcolor(black)) , ///
    xlabel(`xlbl', angle(30)) ///
    xtitle("Social group") ytitle("Households (%)") ///
    ylabel(0(20)100, angle(0) format(%2.0f)) ///
    legend(order(1 "2015-16" 2 "2019-21") rows(1) pos(6)) ///
    title("B. By social group", size(medium) pos(11)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig3b, replace)

graph export "$figures\figure2b.png", replace width(1800)

 
