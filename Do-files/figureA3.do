/************************************************************************************  
Create the 2 maps for Figure 3
*************************************************************************************/

clear
set more off

cd "$mapdata"

shp2dta using "IND_adm2.shp", database(INDdb) coordinates(INDcoord) genid(id) replace

use INDdb, clear

/// merging shapefile crosswalk with the shapefile database 

merge 1:1 id using "Shapefile NFHS crosswalk.dta", keepusing(nfhs4_code nfhs5_code)

drop _m

save INDdb_1, replace

//// Import All India district level sanitaiton for NFHS5
/// File contains weighted averages of NFHS 5 districts for INDICATOR 4 
import excel "NFHS5 district level Rural.xls", sheet("Sheet1") firstrow clear

rename INDICATOR4 INDICATOR4_nfhs5

rename OD OD_nfhs5 

format INDICATOR4_nfhs5 OD_nfhs5 %5.0f

rename dist_code nfhs5_code

destring nfhs5_code, replace

save district_ave_nfhs5, replace

use INDdb_1, clear

merge m:1 nfhs5_code using district_ave_nfhs5, keepusing(INDICATOR4_nfhs5)

drop if _m == 2

drop _m


spmap INDICATOR4_nfhs5 using INDcoord.dta, id(id) fcolor(Oranges) clmethod(custom) clbreaks (0 25 50 75 100) clnumber(4) ndfcolor(gs14) ndlabel("No Data") ///
legend(symy(*1) symx(*1) size(*0.8)) legend(region(lcolor(black))) legend(ring(1) position(8))  legstyle(2) ///
legorder(lohi) 
graph export "$figures\figure2_nfhs5.png", replace


// Import all India district level sanitaiton for NFHS4

import excel "NFHS4 district level Rural.xlsx", sheet("Sheet1") firstrow clear

rename INDICATOR4 INDICATOR4_nfhs4

rename OD OD_nfhs4

format INDICATOR4_nfhs4 OD_nfhs4 %5.0f

rename district_code nfhs4_code

save district_ave_nfhs4, replace

use INDdb_1, clear

merge m:1 nfhs4_code using district_ave_nfhs4, keepusing(INDICATOR4_nfhs4)

drop if _m == 2
drop _m

spmap INDICATOR4_nfhs4 using INDcoord.dta, id(id) fcolor(Oranges) clmethod(custom) clbreaks (0 25 50 75 100) clnumber(4) ndfcolor(gs14) ndlabel("No Data")  ///
legend(symy(*1) symx(*1) size(*0.8)) legend(region(lcolor(black))) legend(ring(1) position(8))  legstyle(2) ///
legorder(lohi) 
graph export "$figures\figure2_nfhs4.png", replace
