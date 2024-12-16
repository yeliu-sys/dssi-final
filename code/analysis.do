
ssc install reghdfe
ssc install estout

* Load and prepare final merged dataset
use "final_merged_df.dta", clear

* Data preprocessing
gen weight_adj = weight_mean/mean(weight_mean)
gen mtlv_lagged_month = -(mtlv_lagged/4.3)
replace hforage_mean = . if abs(hforage_mean) > 6

* Generate treatment variables
gen treated = (status == "Treated")
gen post_2006 = (year >= 2006)
gen treatment_effect = treated * post_2006

* Generate standardized country-level variables
egen log_gdp_std = std(log(gdp)), by(country)
egen urban_std = std(urban), by(country)
egen log_health_pc_std = std(log(health_pc)), by(country)
egen log_health_gdp_std = std(log(health_gdp)), by(country)
egen flpr1564_std = std(flpr1564), by(country)

* Label variables
label variable mtlv_lagged_month "Maternity leave (months)"
label variable hforage_mean "Height-for-age z-score"
label variable weight_adj "Adjusted weights"
label variable treated "Treatment group"
label variable post_2006 "Post-2006 period"

* Keep relevant sample
keep if year >= 1995 & year <= 2013
keep if !missing(hforage_mean) & !missing(mtlv_lagged_month) & !missing(weight_adj)

* Model 1: Base model with fixed effects
reghdfe hforage_mean mtlv_lagged_month [aweight=weight_adj], ///
    absorb(country year) vce(cluster country)
est store model1

* Model 2: Add individual and household controls
reghdfe hforage_mean mtlv_lagged_month ///
    mat_height_mean bord_mean mat_lit_mean rural_mean i.v190 ///
    matwork_mean household_size_mean i.month_cat ///
    [aweight=weight_adj], absorb(country year) vce(cluster country)
est store model2

* Model 3: Add country-level controls
reghdfe hforage_mean mtlv_lagged_month ///
    mat_height_mean bord_mean mat_lit_mean rural_mean i.v190 ///
    matwork_mean household_size_mean i.month_cat ///
    log_gdp_std urban_std log_health_pc_std log_health_gdp_std flpr1564_std ///
    [aweight=weight_adj], absorb(country year) vce(cluster country)
est store model3

* Display results
esttab model1 model2 model3, ///
    b(%9.2f) se(%9.2f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    keep(mtlv_lagged_month) ///
    title("Effect of Maternity Leave on Height-for-age Z-score") ///
    mtitles("Model 1" "Model 2" "Model 3") ///
    stats(N r2, fmt(%9.0f %9.3f) labels("Observations" "R-squared"))

* Additional sample characteristics
tabstat hforage_mean mtlv_lagged_month, by(status) stats(n mean sd min max)
tab status


