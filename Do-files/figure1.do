*============================================================
* Figure 1 (simple version) — toilet coverage across surveys
* Same output as figure1.do, but each survey written out
* explicitly instead of using a loop.
* NFHS4 and NFHS5 excluded; 4 surveys remaining.
*============================================================

local alpha  = 0.05
local z_crit = invnormal(1 - `alpha'/2)

*------------------------------------------------------------
* PANEL A — any toilet (Own = OWN_HH_TOILET, Any = HH_TOILET)
*------------------------------------------------------------
tempname pfA
tempfile resA
postfile `pfA' survey_n str20 variable double(mean lo hi) using "`resA'", replace

* --- 1) NARSS1 (2017-18) -----------------------------------
use "$data\Analysis_Sanitation_NARSS1", clear

sum OWN_HH_TOILET [aw=weight_hh]
local m  = r(mean)
local me = `z_crit' * r(sd)/sqrt(r(N))
post `pfA' (1) ("Own") (`m') (`m'-`me') (`m'+`me')

sum HH_TOILET [aw=weight_hh]
local m  = r(mean)
local me = `z_crit' * r(sd)/sqrt(r(N))
post `pfA' (1) ("Own_or_Shared") (`m') (`m'-`me') (`m'+`me')

* --- 2) NSS 76 (2018) --------------------------------------
use "$data\Analysis_Sanitation_NSS", clear

sum x [aw=weight_hh]
local m  = r(mean)
local me = `z_crit' * r(sd)/sqrt(r(N))
post `pfA' (2) ("Own") (`m') (`m'-`me') (`m'+`me')

sum y [aw=weight_hh]
local m  = r(mean)
local me = `z_crit' * r(sd)/sqrt(r(N))
post `pfA' (2) ("Own_or_Shared") (`m') (`m'-`me') (`m'+`me')

* --- 3) NARSS2 (2018-19) -----------------------------------
use "$data\Analysis_Sanitation_NARSS2", clear

sum OWN_HH_TOILET [aw=weight_hh]
local m  = r(mean)
local me = `z_crit' * r(sd)/sqrt(r(N))
post `pfA' (3) ("Own") (`m') (`m'-`me') (`m'+`me')

sum HH_TOILET [aw=weight_hh]
local m  = r(mean)
local me = `z_crit' * r(sd)/sqrt(r(N))
post `pfA' (3) ("Own_or_Shared") (`m') (`m'-`me') (`m'+`me')

* --- 4) NARSS3 (2019-20) -----------------------------------
use "$data\Analysis_Sanitation_NARSS3", clear

sum OWN_HH_TOILET [aw=weight_hh]
local m  = r(mean)
local me = `z_crit' * r(sd)/sqrt(r(N))
post `pfA' (4) ("Own") (`m') (`m'-`me') (`m'+`me')

sum HH_TOILET [aw=weight_hh]
local m  = r(mean)
local me = `z_crit' * r(sd)/sqrt(r(N))
post `pfA' (4) ("Own_or_Shared") (`m') (`m'-`me') (`m'+`me')

postclose `pfA'

* --- Plot Panel A ------------------------------------------
use "`resA'", clear
encode variable, gen(var)
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
    xlabel(1 "2017-18" 2 "2018" 3 "2018-19" 4 "2019-20", angle(30)) ///
    xtitle("Survey year") ytitle("Households (%)") ///
    ylabel(0(20)100, angle(0) format(%2.0f)) ///
    legend(order(1 "Own" 2 "Own or Shared") rows(1) pos(6)) ///
    title("A. Any Toilet Access", size(medium) pos(11)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig1a, replace)

graph export "$figures\figure1a.png", replace width(1800)

*------------------------------------------------------------
* PANEL B — improved toilet only
* (x = OWN_HH_TOILET * IMPROVED, y = HH_TOILET * IMPROVED)
* NSS already has x and y built in.
*------------------------------------------------------------
tempname pfB
tempfile resB
postfile `pfB' survey_n str20 variable double(mean lo hi) using "`resB'", replace

* --- 1) NARSS1 (2017-18) -----------------------------------
use "$data\Analysis_Sanitation_NARSS1", clear
capture drop x y
gen x = OWN_HH_TOILET * IMPROVED_LATRINE_1
gen y = HH_TOILET    * IMPROVED_LATRINE_1

sum x [aw=weight_hh]
local m  = r(mean)
local me = `z_crit' * r(sd)/sqrt(r(N))
post `pfB' (1) ("Own") (`m') (`m'-`me') (`m'+`me')

sum y [aw=weight_hh]
local m  = r(mean)
local me = `z_crit' * r(sd)/sqrt(r(N))
post `pfB' (1) ("Own_or_Shared") (`m') (`m'-`me') (`m'+`me')

* --- 2) NSS 76 (2018) --------------------------------------
use "$data\Analysis_Sanitation_NSS", clear

sum x [aw=weight_hh]
local m  = r(mean)
local me = `z_crit' * r(sd)/sqrt(r(N))
post `pfB' (2) ("Own") (`m') (`m'-`me') (`m'+`me')

sum y [aw=weight_hh]
local m  = r(mean)
local me = `z_crit' * r(sd)/sqrt(r(N))
post `pfB' (2) ("Own_or_Shared") (`m') (`m'-`me') (`m'+`me')

* --- 3) NARSS2 (2018-19) -----------------------------------
use "$data\Analysis_Sanitation_NARSS2", clear
capture drop x y
gen x = OWN_HH_TOILET * IMPROVED_LATRINE_1
gen y = HH_TOILET    * IMPROVED_LATRINE_1

sum x [aw=weight_hh]
local m  = r(mean)
local me = `z_crit' * r(sd)/sqrt(r(N))
post `pfB' (3) ("Own") (`m') (`m'-`me') (`m'+`me')

sum y [aw=weight_hh]
local m  = r(mean)
local me = `z_crit' * r(sd)/sqrt(r(N))
post `pfB' (3) ("Own_or_Shared") (`m') (`m'-`me') (`m'+`me')

* --- 4) NARSS3 (2019-20) -----------------------------------
use "$data\Analysis_Sanitation_NARSS3", clear
capture drop x y
gen x = OWN_HH_TOILET * IMPROVED_LATRINE_1
gen y = HH_TOILET    * IMPROVED_LATRINE_1

sum x [aw=weight_hh]
local m  = r(mean)
local me = `z_crit' * r(sd)/sqrt(r(N))
post `pfB' (4) ("Own") (`m') (`m'-`me') (`m'+`me')

sum y [aw=weight_hh]
local m  = r(mean)
local me = `z_crit' * r(sd)/sqrt(r(N))
post `pfB' (4) ("Own_or_Shared") (`m') (`m'-`me') (`m'+`me')

postclose `pfB'

* --- Plot Panel B ------------------------------------------
use "`resB'", clear
encode variable, gen(var)
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
    xlabel(1 "2017-18" 2 "2018" 3 "2018-19" 4 "2019-20", angle(30)) ///
    xtitle("Survey year") ytitle("Households (%)") ///
    ylabel(0(20)100, angle(0) format(%2.0f)) ///
    legend(order(1 "Own" 2 "Own or Shared") rows(1) pos(6)) ///
    title("B. Improved Toilet Access", size(medium) pos(11)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig1b, replace)

graph export "$figures\figure1b.png", replace width(1800)
