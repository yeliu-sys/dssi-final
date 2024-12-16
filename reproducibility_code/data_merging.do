
* Create country crosswalk
clear
input str2 original_code str2 iso2c str32 full_name
"SL" "SL" "Sierra Leone"
"SN" "SN" "Senegal"
"TZ" "TZ" "Tanzania"
"MW" "MW" "Malawi"
"HN" "HN" "Honduras"
"PE" "PE" "Peru"
"BF" "BF" "Burkina Faso"
"NG" "NG" "Nigeria"
"ET" "ET" "Ethiopia"
"CO" "CO" "Colombia"
"KH" "KH" "Cambodia"
"KE" "KE" "Kenya"
"BO" "BO" "Bolivia"
"AM" "AM" "Armenia"
"CM" "CM" "Cameroon"
"MG" "MG" "Madagascar"
"EG" "EG" "Egypt"
"HT" "HT" "Haiti"
"BJ" "BJ" "Benin"
"RW" "RW" "Rwanda"
"DR" "DO" "Dominican Republic"
"CD" "CD" "Democratic Republic of Congo"
"GH" "GH" "Ghana"
"NP" "NP" "Nepal"
"NE" "NE" "Niger"
"CG" "CG" "Congo"
"GN" "GN" "Guinea"
"JO" "JO" "Jordan"
"NM" "NA" "Namibia"
"GA" "GA" "Gabon"
"ML" "ML" "Mali"
"LR" "LR" "Liberia"
"MZ" "MZ" "Mozambique"
"ZW" "ZW" "Zimbabwe"
"UG" "UG" "Uganda"
"ZM" "ZM" "Zambia"
"BD" "BD" "Bangladesh"
"LS" "LS" "Lesotho"
end
save "country_crosswalk.dta", replace

* Process maternity leave data - reshape from wide to long
use "mat_leave_data.dta", clear

* Reshape from wide to long format
reshape long mtlv_pdr_, i(country) j(year)
rename mtlv_pdr_ mtlv_pdr

* Clean and process
merge m:1 country using "country_crosswalk.dta", keep(match) nogen
sort country year

* Generate lead and lag variables
by country: gen mtlv_lagged = mtlv_pdr[_n-1]  // t-1
by country: gen mtlv_tminus2 = mtlv_pdr[_n-2] // t-2
by country: gen mtlv_tminus3 = mtlv_pdr[_n-3] // t-3
by country: gen mtlv_tplus1 = mtlv_pdr[_n+1]  // t+1
by country: gen mtlv_tplus2 = mtlv_pdr[_n+2]  // t+2
by country: gen mtlv_tplus3 = mtlv_pdr[_n+3]  // t+3

* Remove duplicates
duplicates drop country year, force
save "mat_leave_long.dta", replace

* Import and process WDI data
* Note: Since Stata doesn't have direct WDI API access, assume WDI data is already downloaded
use "wdi_data.dta", clear

* Rename variables
rename NY_GDP_PCAP_CD gdp
rename SH_XPD_CHEX_PC_CD health_pc
rename SH_XPD_CHEX_GD_ZS health_gdp
rename SL_TLF_CACT_FE_ZS flpr1564
rename SP_URB_TOTL_IN_ZS urban
rename GE_EST gov_effect

* Match with country codes
merge m:1 iso2c using "country_crosswalk.dta", keep(match) nogen keepusing(original_code)
rename original_code country
drop iso2c

* Keep relevant years
keep if inrange(year, 1995, 2013)
save "wdi_processed.dta", replace

* Prepare final dataset for merging
use "final_dataset.dta", clear
gen year = real(survey_year)
save "final_dataset_prep.dta", replace

* Perform merges
* First merge with maternity leave data
merge m:1 country year using "mat_leave_long.dta", keep(1 3)
drop _merge

* Then merge with WDI data
merge m:1 country year using "wdi_processed.dta", keep(1 3)
drop _merge

* Save final merged dataset
save "final_merged_df.dta", replace

* Create summary statistics
preserve
collapse (count) n=hforage_mean, by(country year)
list country year n, clean
restore

* Display merging results
tab _merge
sum hforage_mean if !missing(mtlv_pdr)
sum hforage_mean if !missing(gdp)

* Label variables
label variable mtlv_pdr "Paid maternity leave duration"
label variable gdp "GDP per capita (current US$)"
label variable health_pc "Health expenditure per capita"
label variable health_gdp "Health expenditure (% of GDP)"
label variable flpr1564 "Female labor force participation rate"
label variable urban "Urban population (%)"

