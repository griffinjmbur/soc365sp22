capture log close
clear
set more off

log using "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Do/Exercise_10.log", replace

*FILE:    Exercise_10.do
*PURPOSE: Answer key to Exercise 10


*This should be the path to your Original data folder, where you have saved the raw data file you just created.
cd "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Original data"

use psid_extract.dta, clear

describe

tab wedc1970, miss
tab hedc1970, miss

**************
* QUESTION 2 *
**************

  foreach num of numlist 1970 1980 1990 2001 2009 {
   gen wcol`num' = (wedc`num' == 4)
	replace wcol`num' = . if wedc`num' == .
   gen hcol`num' = (hedc`num' == 4)
	replace hcol`num' = . if hedc`num' == .
	}
 
   *Check variable creation
  foreach num of numlist 1970 1980 1990 2001 2009 {
   tab wedc`num' wcol`num', miss
   tab hedc`num' hcol`num', miss
   }

   *How much has college completion changed for husbands and wives?
   foreach num of numlist 1970 2009 {
	tab wcol`num'
	tab hcol`num'
   }

   *Wives' college completion went up from 7.74% in 1970 to 30.46% in 2009.
   *Husbands' went up from 13.63% to 30.41%. Wives' college completion rates
   *rose more quickly over this period.
 
 
**************
* QUESTION 3 *
**************
 
   *Create relative education variables
   foreach num of numlist 1970 1980 1990 2001 2009 {
	gen     rel_edc`num' = 2 if (hedc`num' > wedc`num' & hedc`num' ~= . )
	replace rel_edc`num' = 1 if (hedc`num' < wedc`num' & wedc`num' ~= . )
	replace rel_edc`num' = 0 if (hedc`num' == wedc`num' & wedc`num' ~= . )
   }
 
   *Check variable creation -- it works
  foreach num of numlist 1970 1980 1990 2001 2009 {
   bysort rel_edc`num': tab hedc`num' wedc`num', miss
   }
   sort fid
   list rel_edc2009 hedc2009 wedc2009 in 1/50
 
   *Label variables
   lab def rel_edc_lbl 2 "2:Hedc>Wedc" 1 "1:Hedc<Wedc" 0 "0:Hedc=Wedc"
 
   foreach num of numlist 1970 1980 1990 2001 2009 {
	lab val rel_edc`num' rel_edc_lbl
   }
 
   *Analysis
   foreach num of numlist 1970 2009 {
	tab rel_edc`num'
   }
 
	*A smaller proportion of couples have the same education level and there is a
	*larger proportion of couples in which wives have more education than their 
	*husbands. The proportion of couples in which husbands have more education 
	*than wives has stayed relatively constant. 
 
log close
exit
 
