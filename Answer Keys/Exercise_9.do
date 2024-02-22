capture log close
clear
set more off

log using "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Do/Exercise_9.log", replace

*FILE:    Exercise_9.do
*PURPOSE: Answer key to Exercise 9


*This should be the path to your Original data folder, where you have saved the raw data file you just created.
cd "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Original data"


use psid_extract.dta, clear
describe //I can see this data is in a "wide" format


**************
* QUESTION 2 *
**************

	*Reshape from wide to long
	reshape long wedy hedy wedc hedc, i(fid wfpid hdpid) j(year)

	*Generate college dummy
	gen hcoll = (hedc == 4) if hedc != .
	gen wcoll = (wedc == 4) if wedc != .


	*Check -- it works
	tab hedc hcoll, miss
	tab wedc wcoll, miss


	*How much has college completion for husbands changed between 1970 and 2009?
	tab year hcol, row

	*College completion for husbands has more than doubled between 1970-2009 (from
	*about 14% to 30%).


**************
* QUESTION 3 *
**************

	*Relative education variable
	gen     rel_edc = 2 if (hedc > wedc & hedc != . )
	replace rel_edc = 1 if (hedc < wedc & wedc != . )
	replace rel_edc = 0 if (hedc == wedc & wedc != . )

 
	*Check -- it works
	bysort rel_edc: tab hedc wedc, miss
	sort fid
	list rel_edc hedc wedc in 1/50
 
	*label variable and values
	lab var rel_edc "Relative Education, Couples"
	lab def rel_edc_lbl 2 "2:Hedc>Wedc" 1 "1:Hedc<Wedc" 0 "0:Hedc=Wedc"
	lab val rel_edc rel_edc_lbl
 
 
**************
* QUESTION 4 *
**************

	tab year rel_edc, row nof

 
	*A smaller proportion of couples have the same education level and there is a
	*larger proportion of couples in which wives have more education than their 
	*husbands. The proportion of couples in which husbands have more education 
	*than wives has stayed relatively constant. 


**************
* QUESTION 5 *
**************
 
	collapse hedy, by(rel_edc year)
 
	list
 
	*Husbands in couples where husbands have more education than wives have the
	*highest years of schooling, followed by those that have equal levels of 
	*schooling, and then by those who have less than their wives. It looks like
	*husbands' years of schooling increased fastest among couples who shared the
	*same education and slowest for couples where husbands had more education than
	*wives.
 
	log close
 
 
 
