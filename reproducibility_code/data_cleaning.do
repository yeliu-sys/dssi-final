
* Data Cleaning and Processing in Stata
clear all
set more off

* Set working directory (modify as needed)
cd "/Users/username/data"

* Process height and weight data (HW files)
capture program drop process_hw_file
program define process_hw_file
    args filepath
    
    display "Processing file: `filepath'"
    use "`filepath'", clear
    
    * Identify ID variable
    local id_vars "hwcaseid hwhhid hhid"
    foreach var of local id_vars {
        capture confirm variable `var'
        if !_rc {
            local id_var "`var'"
            continue, break
        }
    }
    
    display "Using ID variable: `id_var'"
    
    * Clean ID and extract cluster/household
    gen clean_id = strtrim(subinstr(`id_var', "  ", " ", .))
    
    * Extract cluster and household numbers
    gen str cluster_household = ""
    replace cluster_household = clean_id if regexm(clean_id, "[0-9]+\s+[0-9]+")
    replace cluster_household = substr(clean_id, 1, 3) + " " + ///
        substr(clean_id, 4, 5) if regexm(clean_id, "^[0-9]{3,}")
    
    * Convert to numeric
    gen cluster = real(word(cluster_household, 1))
    gen household = real(word(cluster_household, 2))
    
    * Process height-for-age data
    gen hforage = .
    replace hforage = hc70/100 if !missing(hc70) & hc70 != 9999 & ///
        abs(hc70) < 600 & hc70/100 > -6 & hc70/100 < 6
    
    * Keep valid observations and calculate means
    keep if !missing(cluster) & !missing(household) & !missing(hforage) & ///
        cluster > 0 & cluster < 1000 & household > 0 & household < 100 & ///
        hforage > -6 & hforage < 6
    
    * Calculate household-level means
    collapse (mean) hforage_mean=hforage ///
             (mean) stunted_mean=stunted ///
             (count) n_children=hforage, ///
             by(cluster household)
    
    * Generate stunting indicator
    replace stunted_mean = (hforage_mean < -2)
    
    * Display summary statistics
    sum hforage_mean
    display "Records processed: " _N
    display "Height-for-age range: " %4.2f r(min) " to " %4.2f r(max)
    
    * Save temporary results
    save "temp_hw.dta", replace
end

* Process wealth index data (WI files)
capture program drop process_wi_file
program define process_wi_file
    args filepath
    
    display "Processing WI file: `filepath'"
    use "`filepath'", clear
    
    * Check for wealth index variables
    capture confirm variable wlthind5
    if _rc {
        capture confirm variable wlthindf
        if _rc {
            display "No wealth index variables found"
            exit
        }
    }
    
    * Clean ID and extract cluster/household
    gen clean_id = strtrim(subinstr(whhid, "  ", " ", .))
    gen cluster = real(word(clean_id, 1))
    gen household = real(word(clean_id, 2))
    
    * Process wealth index
    gen v190 = wlthind5
    replace v190 = wlthindf if missing(v190)
    
    keep if !missing(cluster) & !missing(household) & !missing(v190)
    keep cluster household v190
    
    * Save temporary results
    save "temp_wi.dta", replace
end

* Display notes about usage
display "Note: This code processes DHS survey data files."
display "Required files: HW (height/weight), WI (wealth index)"
display "Make sure input files are in Stata format (.dta)"

* Process individual recode data (IR files)
capture program drop process_ir_file
program define process_ir_file
    args filepath
    
    display "Processing IR file: `filepath'"
    use "`filepath'", clear
    
    * Convert cluster and household to numeric
    gen cluster = real(v001)
    gen household = real(v002)
    
    * Process survey year
    gen survey_year = .
    replace survey_year = v007 if v007 >= 1900 & v007 <= 2024
    replace survey_year = 1900 + v007 if v007 >= 25 & v007 < 100
    replace survey_year = 2000 + v007 if v007 < 25
    
    * Calculate birth order
    egen bord = rownonmiss(bidx_*)
    
    * Process rural/urban status
    gen rural = .
    capture confirm variable v025
    if !_rc {
        replace rural = (v025 == 2)
    }
    else {
        capture confirm variable v102
        if !_rc {
            replace rural = (v102 == 2)
        }
    }
    
    * Collapse to household level means
    collapse (first) survey_year ///
            (mean) weight_mean = v005 ///
            (mean) rural_mean = rural ///
            (mean) mat_lit_mean = v106 ///
            (mean) mat_height_mean = v438 ///
            (mean) matwork_mean = v714 ///
            (mean) household_size_mean = v136 ///
            (mean) bord_mean = bord ///
            (mean) season_0_mean = season_0 ///
            (mean) season_1_mean = season_1 ///
            (mean) season_2_mean = season_2 ///
            (mean) season_3_mean = season_3, ///
            by(cluster household)
    
    * Adjust weight to proper scale
    replace weight_mean = weight_mean/1000000
    
    * Create literacy indicator
    replace mat_lit_mean = (mat_lit_mean > 0)
    
    * Create work status indicator
    replace matwork_mean = (matwork_mean == 1) if !missing(matwork_mean)
    
    * Create seasonal indicators
    gen month = v006
    gen season_0 = inrange(month, 1, 3)
    gen season_1 = inrange(month, 4, 6)
    gen season_2 = inrange(month, 7, 9)
    gen season_3 = inrange(month, 10, 12)
    
    * Save temporary results
    save "temp_ir.dta", replace
    
    display "Successfully processed `filepath'"
    display "Survey years in data: " survey_year
end

* Process all files in directory
capture program drop process_all_files
program define process_all_files
    args directory
    
    * Create log file
    log using "`directory'/processing_log.txt", replace
    
    * Get list of files
    local files : dir "`directory'" files "*.dta"
    display "Total files found: `=wordcount(`"`files'"')'"
    
    * Process each country
    foreach country in "BD" "LS" "UG" "ZM" "ZW" {
        display _n "=== Processing country: `country' ==="
        
        * Process IR files
        local ir_files : dir "`directory'" files "`country'ir*fl.dta"
        foreach file of local ir_files {
            process_ir_file "`directory'/`file'"
        }
        
        * Process HW files
        local hw_files : dir "`directory'" files "`country'hw*fl.dta"
        foreach file of local hw_files {
            process_hw_file "`directory'/`file'"
        }
        
        * Process WI files
        local wi_files : dir "`directory'" files "`country'wi*fl.dta"
        foreach file of local wi_files {
            process_wi_file "`directory'/`file'"
        }
        
        * Merge files
        use "temp_hw.dta", clear
        merge 1:1 cluster household using "temp_ir.dta"
        drop if _merge != 3
        merge 1:1 cluster household using "temp_wi.dta", keep(1 3)
        
        * Add country identifier
        gen country = "`country'"
        gen status = cond(inlist(country, "BD", "LS", "UG", "ZM", "ZW"), "Treated", "Control")
        
        * Save country results
        save "`directory'/`country'_processed.dta", replace
    }
    
    * Combine all country files
    clear
    foreach country in "BD" "LS" "UG" "ZM" "ZW" {
        append using "`directory'/`country'_processed.dta"
    }
    
    * Final dataset preparation
    sort country survey_year
    label variable country "Country code"
    label variable status "Treatment status"
    label variable hforage_mean "Mean height-for-age z-score"
    
    * Save final dataset
    save "`directory'/final_dataset.dta", replace
    export delimited using "`directory'/final_dataset.csv", replace
    
    * Clean up temporary files
    erase "temp_hw.dta"
    erase "temp_ir.dta"
    erase "temp_wi.dta"
    
    log close
end

* Execute the processing
cd "/path/to/data/directory"
process_all_files "${pwd}"
