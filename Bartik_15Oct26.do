  * This do file is written to compute the regional trade shocks using Bartik decomposition.
* Trade data come from UN Comtrade (WITS), labor shares are computed using HH data.

* Countries to be included:
* Australia * Belgium-Luxembourg * Brazil * Canada * China * Finland * France * Germany * Hong Kong * India 
* Italy * Japan * Kuwait * Malaysia * Netherlands * Nigeria * Philippines * Saudi Arabia * Singapore * South Korea 
* Spain * Sweden * Switzerland * Thailand * United Arab Emirates * United Kingdom * United States * Vietnam
* (1.Top 20 trading partners ecxcept Brunei as there is no data of trade between Indn and Brunei in UN comtrade,
* and it only makes top 20 in last two years with very small trading volumn. 
*  2. South Korea-Indn trade is not in UN comtrade data
*  3. Finland is excluded as it only appeared in top 20 in 1996)

* WITS provides additional country grouping, e.g: countries by income level; WTO member countries by income;
*												  non-WTO member countries etc.

* Years: 1990-1996 2002-2006; 1990-2006

* WITS provides trade by 3-digit ISIC rev 3, no need to use crosswalk

* Written by: Yawen Liang
* Last updated: Oct 25th, 2015
*******************************************************************************************************************

clear
set more off
cd "C:\PhD Study\Year 3\Projects\Job Porlarization\Arranged Files"

**********************************************************************
* 1. use (1990) HH data to compute task shares in each region-industry
**********************************************************************

use "data\temp\HH9006_15Aug30_cln.dta",clear /* generated by Bartick_15Oct17.do */
*** drop agriculture workers
* drop farming supervisor
drop if isco68_2d==60
* drop farmers
drop if isco68_2d==61
* drop other agriculture workers
drop if isco68_2d>=62 & isco68_2d<=64

*** drop agriculture industries
drop if LFSind>=11 & LFSind<=18

keep if year==1990|year==2002

* use the region correspondence table to get consistent region code
gen kabkode = prov*100+kabu
replace kabkode = kabu if kabu>99
sort year
levelsof year, local(yr)
gen code1990_temp=.
gen name1990_temp=.
tostring(name1990), replace force
foreach val in `yr'{
gen code`val' = kabkode if year==`val'
merge m:1 code`val' using "data\temp\code90`val'.dta" /* these files are generated in regressionsYawen_15Jul07.do */
drop if _merge!=3 & year==`val'
replace code1990_temp = code1990 if year==`val'
replace name1990_temp = name1990 if year==`val'
drop code1990 name1990 code`val' name`val' _merge
}
ren code1990_temp code1990 /* the 1990 name and code are used for all years */
ren name1990_temp name1990 /* the 1990 name and code are used for all years */
drop if kabkode==.
gen l = 1

*keep if year==1990|year==2002
*keep if year==1990

collapse (sum) l dRTI abstract routine manual [aweight=wtper], by(code1990 LFSind year)
ren l L_indkab

gen abstract_shr_indkab = abstract/L_indkab
gen routine_shr_indkab = routine/L_indkab
gen manual_shr_indkab = manual/L_indkab
gen dRTI_shr_indkab = dRTI/L_indkab

bys code1990 year: egen L_kab = sum(L_indkab) 
gen Lind_shr_kab = L_indkab/L_kab

gen aind_shr_kab = abstract_shr_indkab*Lind_shr_kab
gen rind_shr_kab = routine_shr_indkab*Lind_shr_kab
gen mind_shr_kab = manual_shr_indkab*Lind_shr_kab

gen id = code1990*100+LFSind
xtset id year
foreach task in a r m{
gen `task'ind_shr_kab_1990 = `task'ind_shr_kab if year==1990
replace `task'ind_shr_kab_1990 = L12.`task'ind_shr_kab if year==2002
}

expand 2, gen(dexp)
replace year=1996 if year==1990 & dexp==1
replace year=2006 if year==2002 & dexp==1

save "data\temp\taskind_shr_kab.dta",replace

****************************
* 2. combine with trade data
****************************

use "data\output\WITS_Mimp_LFSind_Aug18.dta", clear /* generated by Mimport_LFSind.do */
keep if year==1990|year==1996|year==2002|year==2006
drop if LFSind==.
* drop agriculture industries
drop if LFSind>=11 & LFSind<=18
save "data\temp\WITS_Mimp_devLFS979806_dreshape.dta",replace

foreach part in CHN deved20 deving20 top20 WLD WTOALL WTODevg WTOHigh WTOLM WTONOT{
gen nx`part'=exp`part'-imp`part'
}
merge 1:1 LFSind year using "data\output\exptariff_LFSind.dta" /* generated by Bartik_15Oct17.do */
* drop agriculture industries
drop if LFSind>=11 & LFSind<=18
drop if _merge==2
drop _merge

merge 1:m LFSind year using "data\temp\taskind_shr_kab.dta"
drop if _merge==1

drop if LFSind==.|LFSind==99|LFSind==98 /* unknown industry */

foreach part in CHN deved20 deving20 top20 WLD WTOALL WTODevg WTOHigh WTOLM WTONOT{
foreach flow in imp exp nx Mimp{
replace `flow'`part'=0 if _merge==2
}
}

***************************
* 2. get regional variables
***************************

foreach part in CHN deved20 deving20 top20 WLD WTOALL WTODevg WTOHigh WTOLM WTONOT{
foreach flow in imp exp nx Mimp{
foreach task in a r m{
gen `flow'`part'_`task'_kab =  `task'ind_shr_kab*`flow'`part'
gen `flow'`part'_`task'_kab1990 =  `task'ind_shr_kab_1990*`flow'`part'
}
}
}

foreach task in a r m{
gen tariff_`task'_kab = `task'ind_shr_kab*avgtariff
gen tariff_`task'_kab1990 = `task'ind_shr_kab_1990*avgtariff
}

collapse (sum) *_a_kab *_r_kab *_m_kab *_a_kab1990 *_r_kab1990 *_m_kab1990 , by(code1990 year)

xtset code1990 year
foreach part in CHN top20 WLD{
foreach flow in imp exp nx Mimp{
foreach task in a r m{
*gen ln`flow'`part'_`task'_kab  = ln(`flow'`part'_`task'_kab)
gen d`flow'`part'_`task'_kab = `flow'`part'_`task'_kab-L6.`flow'`part'_`task'_kab if year==1996
replace d`flow'`part'_`task'_kab = `flow'`part'_`task'_kab-L4.`flow'`part'_`task'_kab if year==2006
gen dln`flow'`part'_`task'_kab  = ln(`flow'`part'_`task'_kab/L6.`flow'`part'_`task'_kab) if year==1996 /* change in log */
replace dln`flow'`part'_`task'_kab = ln(`flow'`part'_`task'_kab/L4.`flow'`part'_`task'_kab) if year==2006  /* change in log */
replace dln`flow'`part'_`task'_kab=0 if d`flow'`part'_`task'_kab==0

*gen ln`flow'`part'_`task'_kab1990  = ln(`flow'`part'_`task'_kab1990 )
gen d`flow'`part'_`task'_kab1990 = `flow'`part'_`task'_kab1990-L6.`flow'`part'_`task'_kab1990 if year==1996
replace d`flow'`part'_`task'_kab1990 = `flow'`part'_`task'_kab1990-L4.`flow'`part'_`task'_kab1990 if year==2006
gen dln`flow'`part'_`task'_kab1990 = ln(`flow'`part'_`task'_kab1990/L6.`flow'`part'_`task'_kab1990) if year==1996 /* change in log */
replace dln`flow'`part'_`task'_kab1990  = ln(`flow'`part'_`task'_kab1990/L4.`flow'`part'_`task'_kab1990) if year==2006  /* change in log */
replace dln`flow'`part'_`task'_kab1990=0 if d`flow'`part'_`task'_kab1990==0
}
}
}

foreach task in a r m{
gen dtariff_`task'_kab = tariff_`task'_kab-L6.tariff_`task'_kab if year==1996
replace dtariff_`task'_kab = tariff_`task'_kab-L4.tariff_`task'_kab if year==2006
gen dtariff_`task'_kab1990 = tariff_`task'_kab1990-L6.tariff_`task'_kab1990 if year==1996
replace dtariff_`task'_kab1990 = tariff_`task'_kab1990-L4.tariff_`task'_kab1990 if year==2006

gen dlntariff_`task'_kab = ln(tariff_`task'_kab/L6.tariff_`task'_kab) if year==1996
replace dlntariff_`task'_kab = ln(tariff_`task'_kab/L4.tariff_`task'_kab) if year==2006
replace dlntariff_`task'_kab=0 if dtariff_`task'_kab==0
gen dlntariff_`task'_kab1990 = ln(tariff_`task'_kab1990/L6.tariff_`task'_kab1990) if year==1996
replace dlntariff_`task'_kab1990 = ln(tariff_`task'_kab1990/L4.tariff_`task'_kab1990) if year==2006
replace dlntariff_`task'_kab1990=0 if dtariff_`task'_kab1990
}

*drop *temp

merge 1:1 code1990 year using "data\output\kabexp_shr_Oct26.dta" /* generate by delta_15Oct22.do */
drop if _merge==2
* check that the signs of delta and regional trade are consistent
xtset code1990 year
foreach task in a r m{
gen test_`task' = delta_`task'_kab*nxWLD_`task'_kab>=0
}

keep if year==1996|year==2006
*keep if test_a==1& test_r==1 & test_m==1
drop _merge


save "data\output\WITS_kabyr9006bg_15Oct26.dta",replace












