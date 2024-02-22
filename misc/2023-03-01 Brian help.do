* debug as needed
rename *,lower
replace v1163 = . if v1163 == -9 | v1163 == 7
replace v1164 = . if v1164 == -9 | v1164 == 7
gen miss_educ = 0 if ~missing(v1163) & ~missing(v1164)
rename v1163 paeduc
rename v1164 maeduc
replace miss_educ = 1 if missing(paeduc) & ~missing(maeduc)
replace miss_educ = 2 if ~missing(paeduc) & missing(maeduc)
replace miss_educ = 3 if missing(paeduc) & missing(maeduc)
label define miss_lab 0 "both present" 1 "missing father" 2 "missing mother" 3 "missing both"
label values miss_educ miss_lab
gen higher_par_ed = . 
replace higher = paeduc if paeduc > maeduc 
replace higher = maeduc if maeduc > paeduc 
replace higher = paeduc if miss_ == 3
replace higher = maeduc if miss_ == 2
replace higher = . if miss_ == 4
tab higher_ miss, mis
tab  miss higher, mis
replace higher = paeduc if paeduc == maeduc 
tab  miss higher, mis

* Finally, another way to check this -- especially if this were a real 
		* project where you'd want to be certain you did this right -- would be
		* to simply try to make it two ways. Here's one more using a function. 
		
			* cond(var1>var2, P, Q , R) is function that returns P if statement
			* is true and nonmissing, Q if it is false, and R if the expression 
			* evalutes to missing.

		gen maxparentsed =cond(daded>momed, daded, momed, .)
			* This says "return dad's ed. if dad's ed. is larger than mom's ed
			* and mom's ed. if this is false". This takes care of cases where 
			* dad's ed. is larger, where dad's ed. is smaller, *and* cases where
			* they are tied (because the statement is false when they are tied,
			* so it just returns mom's ed... which is fine, since mom's ed == 
			* dad's ed == highest parent ed in that case, by definition). 
			replace maxparentsed = momed if missing(daded) & ~missing(momed)
				* Now we just sub in mom's ed. iff ONLY dad's ed is missing
			replace maxparentsed = daded if missing(momed) & ~missing(daded)
				* Now we just sub in dad's ed. iff ONLY mom's ed is missing
			replace maxparentsed = . if missing(momed) & missing(daded)
		
		* Now we can check this quickly. 
		tab maxparentsed highestpaed, mis
			* Checks out -- we only have a diagonal matrix. 
			
		* Here's yet one more way to do this. This is the quickest, if the
		* most advanced, method. 
		egen parentalmaxed = rowmax(daded-momed)
		tab parentalmaxed highestpaed, mis
			* rowmax is a powerful command. Not only will it quickly pull the
			* maximum value from this list of columns, but it will also "ignore"
			* missing values. Now, the documentation on rowmax is not very
			* extensive in the -egen- help file, so it is important to check
			* -- "ignore" is not totally unambiguous. But, it appears that what
			* happens here is that "ignore" probably means that if only one value
			* is missing, it will just take the other value as the max, which is
			* just what we want. Here we can check that. 
		list parentalmaxed momed daded if missing(daded) & ~missing(momed)
			* One complexity is that this method generates two distinct types
			* of missing values, so it appears to be preserving something like
			* the original _form_ of the MV. But mom's ed. and dad's ed. might
			* be different kinds of missing. Ultimately, this is really not a
			* huge deal unless we plan to do heavy duty analysis of missing data,
			* but it is worth nothing. Here, when there is a conflict, a quick
			* check seems to indicate that Stata takes the "type of missingness"
			* from mom's ed. That could be because it is the second column, but
			* the documentation isn't clear enough to tell. At any rate, my
			* alternative methods above don't distinguish between types of MV,
			* so this is probably fine. We might just want to convert all MVs
			* to a simple, unpretentious "." to avoid putting down information
			* that might be misleading. 
		
		* Time to label the successfully created variable. 
		label variable highestpaed ///
			"Highest educational level achieved by parents"
		codebook V1163 // Let's get the value label 
		label values highestpaed V1164
