
/****   Replication code for "Progress on Sanitation in Rural India: Reconciling Diverse Evidence"     ****/
/****                                    DATE: May, 2026                                               ****/

** 001_Master.do sets paths, installs required packages, and runs the other do files **

clear all
set more off

* Set path to main directory for current user

global main	"C:\Users\iks46\Dropbox\Current Projects\India Sanitation\Data\Replication - Git"

* Subfolders
 
gl do_files			"$main\Do-files" 
gl data			    "$main\Data\StataData"
gl mapdata		    "$main\Data\MapData"
gl output 			"$main\Output"
gl figures		    "$output\Figures"	
gl regs				"$output\Regressions"
gl tables			"$output\Tables"

//make the Output directories
capture mkdir "$output"
capture mkdir "$figures"
capture mkdir "$regs"
capture mkdir "$tables"

 
* Install the following for figures in paper
capture ssc install schemepack
capture ssc install shp2dta
capture ssc install spmap 
capture ssc install ereplace 

* Create the sanition indicators and other covariates required for analysis from each of the public datasets
* Not neecessary to run these files, can directly run the files that creates the tables and figures
/**
do "$do_files\createvars_NFHS4.do"
do "$do_files\createvars_NFHS5.do"
do "$do_files\createvars_NARSS1.do"
do "$do_files\createvars_NARSS2.do"
do "$do_files\createvars_NARSS3.do"
do "$do_files\createvars_NSS.do"
* Create the repeated cross-section dataset
do "$do_files\create_panel_allsurveys.do"
**/

* Output the 8 paper figures and tables 

do "$do_files\figure1.do"
do "$do_files\figure2.do"
do "$do_files\figure3.do"
do "$do_files\figure4.do"
do "$do_files\figure5.do"
do "$do_files\figure6.do"
do "$do_files\table1.do"
do "$do_files\table2.do"


* Methods Section
do "$do_files\table5.do"

* Supplemental Tables and Figures 
** Note: Figure A1 is directly created from the SBM MIS  

** This file outputs the relevant statistics used to create figure in excel 
do "$do_files\figureA2_stats.do"
do   "$do_files\figureA3.do"
do    "$do_files\tableA1.do"
do    "$do_files\tableA2.do"
//Note: takes a long time to run!
do    "$do_files\tableA3_A4.do"


 