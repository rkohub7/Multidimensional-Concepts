**********************************************************************
***MEASURING CHILD POVERTY FROM 2022 KENYA DEMOGRAPHIC SURVEY****
*Installing the MPI and other Package
ssc install mpi
ssc install tabout

*****>>STEP 1: MAKE SURE YOUR FILES ARE IN ComputeMPI FOLDER IN DRIVE C
cd "C:\ComputeMPI"
dir
use KDHS22_indicators.dta,clear

*****>>STEP 2: MINOR CHECKS

des,s    //Indicators on 72,849 children
*Checking Age groups: two age groups(underfives & 5-17 years)
tab age_group

****>>STEP 3: PERUSING INDICATORS FOR EACH GROUP

***Indicators for children underfive**********
**********************************************
codebook stunting healthcarddep underweight  info_devicedep water_sourcedep Sanitationdep dwellingdep airpollution if age_group==1,compact

***Indicators for children 5-17 years**********
**********************************************
codebook Sch_attendancedep info_devicedep water_sourcedep Sanitationdep dwellingdep airpollution if age_group==2,compact


*****>>STEP 4: MEASURING MULTIDIMENSIONAL POVERTY INDEX FOR UNDER5'S
*******Multidimensional Index for the Underfives*************************
svyset [pw=weight], psu(cluster) strata(strata)
codebook stunting healthcarddep underweight  info_devicedep water_sourcedep Sanitationdep dwellingdep airpollution if age_group==1,compact
*Note 1: There six dimensions for underfives, hence equal weight is (1/6)
display  1/6 // 0.166
display 1/12 // 0.083
*******>>>Implementation 

mpi d1(stunting) w1(0.166) d2(healthcarddep underweight) w2(0.083  0.083) d3(info_devicedep) w3(0.166) d4(water_sourcedep) w4(0.166) d5(Sanitationdep) w5(0.166) d6(dwellingdep airpollution) w6(0.083  0.083) svy if age_group==1, cutoff(0.33) deprivedscore(mpiscores1) depriveddummy(mpisdummy1) 

la var mpiscores1 "Weighted child deprivation scores-underfive"
la var mpisdummy1 "Proportion of poor underfives"
tab mpisdummy1   // 67.5 underfives are Multidimensionally poor
sum mpiscores1   //Average weighted deprivation scores among underfives is 42.18%

/*Tabulation across residence and County*/
tabout rur_urban mpisdummy1 using Geography.xls if age_group==1,c(row) f(2)  replace
tabout county mpisdummy1 using Geography.xls if age_group==1,c(row) f(2) append
shell Geography.xls



*****>>STEP 5: MEASURING MULTIDIMENSIONAL POVERTY INDEX FOR 5-17 YRS
**********Multidimensional Index 5-17 years*************************
codebook Sch_attendancedep info_devicedep water_sourcedep Sanitationdep dwellingdep airpollution if age_group==2,compact
*Note: there are five dimensions for children 5-17 years
display 1/5 // 0.20

mpi d1(Sch_attendancedep) w1(0.20) d2(info_devicedep) w2(0.2)  d3(water_sourcedep)w3(0.2) d4(Sanitationdep) w4(0.2) d5(dwellingdep airpollution) w5(0.1 0.1) svy if age_group==2, cutoff(0.33) deprivedscore(mpiscores2) depriveddummy(mpisdummy2) 

la var mpiscores2 "Weighted child deprivation scores-5-17"
la var mpisdummy2 "Proportion of poor children(5-17) years"
tab mpisdummy2   // 64.3 underfives are Multidimensionally poor
sum mpiscores2   //Average weighted deprivation scores among underfives is 46.5%


*****>>STEP 6: HARMONISING THE SCORES FOR THE TWO GROUPS******************
**********for Inferential Analyses****************************************
*Deprivation scores
clonevar Depscores=mpiscores1
replace Depscores=mpiscores2 if mpiscores1==.
sum Depscores
la var Depscores "Weighted child deprivation scores"
sum Depscores

*Multidimensional dummy
clonevar MPIdummy=mpisdummy1 
replace MPIdummy=mpisdummy2 if mpisdummy1==.
tab MPIdummy
la var MPIdummy "Proportion poor children"
tab MPIdummy  // 65.08 percent of children are poor overall 




