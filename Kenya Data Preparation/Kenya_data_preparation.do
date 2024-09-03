cd "C:\Users\USER\Documents\GIT\Multidimensional-Concepts\Kenya Data Preparation"
clear all
set maxvar 32000
dir 
use KEPR8AFL.DTA,clear
merge m:1 hhid using KEHR8AFL.DTA, nogen

//Stunted
gen nt_ch_stunt= 0 if hv103==1
replace nt_ch_stunt=. if hc70>=9996
replace nt_ch_stunt=1 if hc70<-200 & hv103==1 
label values nt_ch_stunt yesno
label var nt_ch_stunt "Stunted child under 5 years"
fre nt_ch_stunt
clonevar stunting=nt_ch_stunt 

//Underweight
gen nt_ch_underwt= 0 if hv103==1
replace nt_ch_underwt=. if hc71>=9996
replace nt_ch_underwt=1 if hc71<-200 & hv103==1 
label values nt_ch_underwt yesno
label var nt_ch_underwt "Underweight child under 5 years"
clonevar underweight=nt_ch_underwt
des stunting underweight

*des fre h1a
*lookfor health card

*School attendence 
clonevar age = hv105  
label var age "Age of household member"
des hv121
fre hv121
codebook hv121, tab (10)
clonevar attendance = hv121 
fre attendance
recode attendance (2=1) 
codebook attendance, tab (10)	
des hv109
replace attendance = 0 if (attendance==9 | attendance==.) & hv109==0 
replace attendance = . if  attendance==9 & hv109!=0
fre attendance
gen	child_schoolage = (age>=6 & age<=17)
fre attendance if child_schoolage==1
gen sch_att=attendance if child_schoolage==1
fre sch_att
recode sch_att (0=1 Yes) (1=0 No),gen(Sch_attendancedep)
fre Sch_attendancedep
la var Sch_attendancedep "child not attendingschool"
des stunting underweight Sch_attendancedep 

*Household assets
des hv208  hv207 hv221 hv243a hv243a hv209 hv212 hv210 hv211 hv243e hv243c
clonevar television = hv208 
*clonevar bw_television = hv208
clonevar radio = hv207 
clonevar telephone =  hv221 
clonevar mobiletelephone = hv243a  
clonevar refrigerator = hv209 
clonevar car = hv212  	
clonevar bicycle = hv210 
clonevar motorbike = hv211 
clonevar computer = hv243e
clonevar animal_cart = hv243c	


foreach var in television radio telephone mobiletelephone refrigerator ///
			   car bicycle motorbike computer animal_cart {
replace `var' = . if `var'==9 | `var'==99 | `var'==8 | `var'==98 
}

	//Combine information on telephone and mobilephone 	
replace telephone=1 if telephone==0 & mobiletelephone==1
replace telephone=1 if telephone==. & mobiletelephone==1

des television radio computer
egen inf=rowtotal(television radio)
fre inf
replace inf=1 if inf==2
fre inf
recode inf (0=1 Yes) (1=0 No),gen(info_devicedep)
fre info_devicedep
la var info_devicedep "Information devices deprivation"
des stunting underweight Sch_attendancedep info_devicedep

* Source of Water deprivation
des hv201 hv204 hv202
clonevar water = hv201  
clonevar timetowater = hv204  
codebook water, tab(99)
clonevar ndwater = hv202

*** Standard MPI ***
/* Members of the household are considered deprived if the household 
does not have access to improved drinking water (according to the SDG 
guideline) or safe drinking water is at least a 30-minute walk from 
home, roundtrip */
**# Bookmark #6
fre water 
gen	water_mdg = 1 if water<=31 | water==41 | water==51 | ///
water==61 | water==62 | water==71 | water==72

replace water_mdg = 0 if water==32 | water==42 | water==43 | water==96 

replace water_mdg = 0 if water_mdg==1 & timetowater>=30 & ///
						 timetowater!=. & timetowater!=. & ///
						 timetowater!=995 & timetowater!=996 & ///
						 timetowater!=998 

replace water_mdg = . if water==.
lab var water_mdg "HH has safe drinking water"
tab water water_mdg, m
fre water_mdg
recode water_mdg (0=1 Yes) (1=0 No),gen(water_sourcedep)
fre water_sourcedep
la var water_sourcedep "Water source deprivation"
fre water_sourcedep
des stunting underweight Sch_attendancedep info_devicedep water_sourcedep


*Sanitation deprivation
des hv205
clonevar toilet = hv205  
fre hv205
codebook toilet, tab(30) 
fre hv225
codebook hv225, tab(30)  
clonevar shared_toilet = hv225 
recode shared_toilet (2=1)
fre shared_toilet

gen	toilet_mdg = (toilet<23 & shared_toilet!=1) 
replace toilet_mdg = 0 if toilet==13 | toilet==14 | toilet==15 
replace toilet_mdg=1 if toilet==41
replace toilet_mdg = . if toilet==.  | toilet==99
lab var toilet_mdg "Household has improved sanitation with SDG Standards"
tab toilet toilet_mdg,m
tab toilet_mdg
recode toilet_mdg (0=1 Yes) (1=0 No),gen(Sanitationdep)
la var Sanitationdep "Improved sanitation deprivation"
fre Sanitationdep
codebook stunting underweight Sch_attendancedep info_devicedep water_sourcedep Sanitationdep,compact 

*Housing: natural floor, roof and external walls
des  hv213 
fre  hv213
clonevar floor = hv213 
codebook floor, tab(99)
gen	floor_imp = 1
replace floor_imp = 0 if floor<=12 | floor==96  	
replace floor_imp = . if floor==. | floor==99 
lab var floor_imp "Household has floor that it is not earth/sand/dung"
tab floor floor_imp, miss		


/* Members of the household are considered deprived if the household has wall 
made of natural or rudimentary materials */
des hv214 
fre hv214
clonevar wall = hv214 
codebook wall, tab(99)	
gen	wall_imp = 1 
fre hv214 
replace wall_imp = 0 if wall<=26 | wall==96  
replace wall_imp = . if wall==. | wall==99 
lab var wall_imp "Household has wall that it is not of low quality materials"
tab wall wall_imp, miss	
	
	
/* Members of the household are considered deprived if the household has roof 
made of natural or rudimentary materials */
des  hv215
fre hv215
clonevar roof = hv215
codebook roof, tab(99)		
gen	roof_imp = 1 
replace roof_imp = 0 if roof<=24 | roof==96  	
replace roof_imp = . if roof==. | roof==99 	
lab var roof_imp "Household has roof that it is not of low quality materials"
tab roof roof_imp, miss
tab roof_imp

*** Standard MPI ***
/* Members of the household is deprived in housing if the roof, 
floor OR walls are constructed from low quality materials.*/
**************************************************************
gen housing_1 = 1
replace housing_1 = 0 if floor_imp==0 | wall_imp==0 | roof_imp==0
replace housing_1 = . if floor_imp==. & wall_imp==. & roof_imp==.
lab var housing_1 "Household has roof, floor & walls that it is not low quality material"
tab housing_1, miss
recode housing_1 (0=1 Yes) (1=0 No),gen(dwellingdep)
la var dwellingdep "Dwelling material deprivation"

codebook stunting underweight Sch_attendancedep info_devicedep water_sourcedep Sanitationdep dwellingdep,compact 


*Indoor pollution risk
fre hv226
clonevar cookingfuel = hv226  
codebook cookingfuel, tab(99)
fre cookingfuel
gen	cooking_mdg = 1
replace cooking_mdg = 0 if cookingfuel>=5 & cookingfuel<95 
replace cooking_mdg = . if cookingfuel==. |cookingfuel==99
lab var cooking_mdg "Househod has cooking fuel according to SDG standards"			 
tab cookingfuel cooking_mdg, miss
fre cooking_mdg
recode cooking_mdg (0=1 Yes) (1=0 No),gen(airpollution)
fre airpollution
la var airpollution "Indoor polution"

codebook stunting underweight Sch_attendancedep info_devicedep water_sourcedep Sanitationdep dwellingdep airpollution,compact
save pr_temp,replace

dir 
use KEKR8AFL.DTA, clear
fre b16
duplicates list v001 v002 b16
drop if b16==0 | b16==.
isid v001 v002 b16
des,s
save child_temp,replace

use pr_temp,clear
duplicates list hv001 hv002 hvidx
renames hv001 hv002 hvidx \ v001 v002 b16
merge 1:1 v001 v002 b16 using "child_temp.dta"
*keep if _m==3
fre age

lookfor health card
fre h1a
recode h1a (0=1 Yes) (1/8=0 No) (.a=.),gen(healthcarddep)
fre healthcarddep

lookfor age of child 
fre hw1
clonevar age_months=hw1
la var age_months "Age in months"
codebook stunting underweight Sch_attendancedep info_devicedep water_sourcedep Sanitationdep dwellingdep airpollution healthcarddep,compact

fre age
keep if age<18
fre stunting underweight
replace stunting =. if age_months==. 
replace underweight =. if age_months==. 
fre stunting
fre underweight
fre healthcarddep

recode age (0/4=1 "Under-five") (5/17=2 "5-17yrs" ),gen(age_group)
fre age_group
drop if age_group==1 & age_months==.
fre age_group
la var age_group "Age group"
replace healthcarddep=0 if healthcarddep==. & age_group==1 
codebook stunting underweight Sch_attendancedep info_devicedep water_sourcedep Sanitationdep dwellingdep airpollution healthcarddep,compact

*underfives
mdesc stunting underweight healthcarddep info_devicedep water_sourcedep Sanitationdep dwellingdep airpollution healthcarddep
gen missing=1 if (stunting==. | underweight==. ) & age_group==1
fre missing
drop if missing==1
mdesc stunting underweight healthcarddep info_devicedep water_sourcedep Sanitationdep dwellingdep airpollution  if age_group==1

fre Sch_attendancedep
replace Sch_attendancedep=0 if Sch_attendancedep==. & age_group==2

mdesc Sch_attendancedep info_devicedep water_sourcedep Sanitationdep dwellingdep airpollution  if age_group==2

la var healthcarddep  "health card deprivation"
codebook stunting underweight healthcarddep info_devicedep water_sourcedep Sanitationdep dwellingdep airpollution Sch_attendancedep ,compact

fre stunting underweight healthcarddep  if age_group==1
codebook stunting underweight healthcarddep if age_group==1, compact

codebook  info_devicedep water_sourcedep Sanitationdep dwellingdep airpollution Sch_attendancedep if age_group==2,compact

clonevar strata=hv022  
la var strata "strata"
gen weight=(hv005/1000000)
la var weight "hv005/1000000"
gen wt=hv005
la var wt "Nominal weight"
lookfor cluster
clonevar survey_year=hv007
fre survey_year
des survey_year wt
codebook v001
clonevar cluster=v001
la var cluster "cluster"
lookfor rural
fre hv025
recode hv025 (1=1 urban) (2=0 rural),gen(rur_urban)
la var rur_urban "Place of residence"

*Region
lookfor region
fre hv024 
clonevar county=hv024
fre county
la var county "county"
clonevar wealthquintile=hv270
des survey_year wt rur_urban county
la var wealthquintile "Wealth index category" 
codebook v001 v002 b16 strata weight  survey_year cluster wt stunting underweight healthcarddep info_devicedep water_sourcedep Sanitationdep dwellingdep airpollution Sch_attendancedep rur_urban county wealthquintile ,compact
la var age_group "Age group of children"

order hhid v001 v002 b16 strata weight wt survey_year cluster age_group stunting healthcarddep underweight Sch_attendancedep info_devicedep water_sourcedep Sanitationdep dwellingdep airpollution  rur_urban county wealthquintile

keep hhid v001 v002 b16 strata weight wt survey_year cluster age_group stunting underweight healthcarddep info_devicedep water_sourcedep Sanitationdep dwellingdep airpollution Sch_attendancedep rur_urban county wealthquintile 
save "C:\Users\USER\Documents\GIT\Multidimensional-Concepts\Kenya  Child Poverty\KDHS22_indicators", replace 

**********************************************************************
***MEASURING CHILD POVERTY FROM 2022 KENYA DEMOGRAPHIC SURVEY****

*****>>STEP 1: CHANGE DIRECTORY AND CALL IN DATA 

cd "C:\Users\USER\Documents\GIT\Multidimensional-Concepts\Kenya  Child Poverty"
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

**************************************************************************Multidimensional Index for the Underfives*************************
svyset [pw=weight], psu(cluster) strata(strata)
codebook stunting healthcarddep underweight  info_devicedep water_sourcedep Sanitationdep dwellingdep airpollution if age_group==1,compact
*Note 1: There six dimensions for underfives, hence equal weight is (1/6)
display  1/6 // 0.166
display 1/12 // 0.083


mpi d1(stunting) w1(0.166) d2(healthcarddep underweight) w2(0.083  0.083) d3(info_devicedep) w3(0.166) d4(water_sourcedep) w4(0.166) d5(Sanitationdep) w5(0.166) d6(dwellingdep airpollution) w6(0.083  0.083) svy if age_group==1, cutoff(0.33) deprivedscore(mpiscores1) depriveddummy(mpisdummy1) 

la var mpiscores1 "Weighted child deprivation scores-underfive"
la var mpisdummy1 "Proportion of poor underfives"
tab mpisdummy1   // 67.5 underfives are Multidimensionally poor
sum mpiscores1   //Average weighted deprivation scores among underfives is 42.18%


*****>>STEP 5: MEASURING MULTIDIMENSIONAL POVERTY INDEX FOR 5-17 YRS
***************************************************************************Multidimensional Index 5-17 years*************************
codebook Sch_attendancedep info_devicedep water_sourcedep Sanitationdep dwellingdep airpollution if age_group==2,compact
*Note: there are five dimensions for children 5-17 years
display 1/5 // 0.20

mpi d1(Sch_attendancedep) w1(0.20) d2(info_devicedep) w2(0.2)  d3(water_sourcedep)w3(0.2) d4(Sanitationdep) w4(0.2) d5(dwellingdep airpollution) w5(0.1 0.1) svy if age_group==2, cutoff(0.33) deprivedscore(mpiscores2) depriveddummy(mpisdummy2) 


la var mpiscores2 "Weighted child deprivation scores-5-17"
la var mpisdummy2 "Proportion of poor children(5-17) years"
tab mpisdummy2   // 64.3 underfives are Multidimensionally poor
sum mpiscores2   //Average weighted deprivation scores among underfives is 46.5%





 