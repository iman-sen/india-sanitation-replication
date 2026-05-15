

//Statistics for A2
use "$data\analysis_sanitation_NFHS4", clear
tabstat INDICATOR4 [aw=weight_ind] if Sector==1, by(state_name) stats(mean) total

use "$data\analysis_sanitation_NFHS5", clear
tabstat INDICATOR4 [aw=weight_ind] if Sector==1, by(state_name) stats(mean) total
