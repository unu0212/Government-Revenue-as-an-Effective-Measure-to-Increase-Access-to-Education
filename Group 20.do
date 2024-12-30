log using Group20.log,replace

use Group_20.dta
ssc install estout




keep if state != "united states"
generate rest_exp = total_expenditure - expenditure_education

keep state year total_revenue expenditure_education total_expenditure rest_exp debt_at_end_of_fiscal_year expenditure_public_welfare

gen red_state = inlist(state, "alabama", "alaska", "arkansas", "idaho", "indiana") | inlist(state, "kansas", "kentucky", "louisiana", "mississippi", "missouri") |inlist(state, "montanta", "nebraska", "north dakota", "oklahoma", "south carolina", "south dakota", "tennessee") | inlist(state, "texas", "utah", "west virginia", "wyoming")

egen state_cat = group(state)

gen red_state_rev = red_state * total_revenue

gen log_edu = log(expenditure_education)

gen log_rev = log(total_revenue)

gen log_rest_exp = log(rest_exp)

gen log_debt = log(debt_at_end_of_fiscal_year)

gen log_redinter = red_state * log_rev

gen rest_exp_welfare = total_expenditure - expenditure_public_welfare

gen log_public = log(expenditure_public_welfare)

gen log_rest_welfare = log(rest_exp_welfare)
describe



xtset state_cat year
/*reg  expenditure_education total_revenue, robust
xtreg expenditure_education total_revenue i.state_cat, fe robust
xtreg expenditure_education total_revenue i.state_cat, fe robust
xtreg expenditure_education total_revenue i.state_cat i.year, fe robust
xtreg expenditure_education total_revenue , fe cluster(state_cat)*/

twoway lfit expenditure_education total_revenue || scatter expenditure_education total_revenue,xlabel(1.00e+08 "10" 2.00e+08 "20" 3.00e+08 "30" 4.00e+08 "40") ylabel(2.00e+07 "2" 4.00e+07 "4" 6.00e+07 "6" 8.00e+07 "8" 1.00e+08 "10" )  xtitle("Total Revenue") ytitle("Education Expenditure") note("Values are expressed in billions of USD")


eststo spec1: reg  expenditure_education total_revenue, robust
estadd local hasteffect "No"
estadd local haseffect "No"
estadd local hasCSt "No"
estadd local Fst ""
//
eststo spec2:  reg expenditure_education total_revenue rest_exp debt_at_end_of_fiscal_year, cluster(state_cat)
estadd local hasteffect "No"
estadd local haseffect "No"
estadd local hasCSt "Yes"
testparm rest_exp 
testparm debt_at_end_of_fiscal_year
estadd local frest "27.14"
estadd local frestp "(0.0000)"
estadd local fdebt "14.43"
estadd local fdebtp "(0.0004)"
//
eststo spec3:  xtreg expenditure_education total_revenue rest_exp debt_at_end_of_fiscal_year i.state_cat, cluster(state_cat)
estadd local hasteffect "No"
estadd local haseffect "Yes"
estadd local hasCSt "Yes"
testparm rest_exp 
testparm debt_at_end_of_fiscal_year
estadd local frest "192.81"
estadd local frestp "(0.0000)"
estadd local fdebt "0.86"
estadd local fdebtp "(0.3551)"
//
eststo spec4:  xtreg expenditure_education total_revenue rest_exp debt_at_end_of_fiscal_year i.year,fe  cluster(state_cat)
testparm rest_exp 
testparm debt_at_end_of_fiscal_year
testparm i.year
estadd local hasteffect "Yes"
estadd local haseffect "No"
estadd local hasCSt "Yes"
estadd local ftime "4.42"
estadd local ftimep "(0.0000)"
estadd local frest "233.64"
estadd local frestp "(0.0000)"
estadd local fdebt "2.33"
estadd local fdebtp "(0.1331)"
//
eststo spec5:  xtreg expenditure_education total_revenue rest_exp debt_at_end_of_fiscal_year red_state red_state_rev i.year ,fe cluster(state_cat)
testparm rest_exp 
testparm debt_at_end_of_fiscal_year
testparm i.year
estadd local hasteffect "Yes"
estadd local haseffect "No"
estadd local hasCSt "Yes"
estadd local ftime "5.57"
estadd local ftimep "(0.0000)"
estadd local frest "336.16"
estadd local frestp "(0.0000)"
estadd local fdebt "0.48"
estadd local fdebtp "(0.4896)"

//
eststo spec6: xtreg expenditure_public_welfare total_revenue rest_exp_welfare debt_at_end_of_fiscal_year i.year, fe cluster(state_cat)
testparm rest_exp_welfare
testparm debt_at_end_of_fiscal_year
testparm i.year
estadd local hasteffect "Yes"
estadd local haseffect "No"
estadd local hasCSt "Yes"
estadd local ftime "7.21"
estadd local ftimep "(0.0000)"
estadd local frest "18.57"
estadd local frestp "(0.0001)"
estadd local fdebt "0.03"
estadd local fdebtp "(0.8541)"

esttab using eco375_table2.rtf, drop(2.state_cat 3.state_cat 4.state_cat 5.state_cat 6.state_cat 7.state_cat 8.state_cat 9.state_cat 10.state_cat 11.state_cat 12.state_cat 13.state_cat 14.state_cat 15.state_cat 16.state_cat 17.state_cat 18.state_cat 19.state_cat 20.state_cat 21.state_cat 22.state_cat 23.state_cat 24.state_cat 25.state_cat 26.state_cat 27.state_cat 28.state_cat 29.state_cat 30.state_cat 31.state_cat 32.state_cat 33.state_cat 34.state_cat 35.state_cat 36.state_cat 37.state_cat 38.state_cat 39.state_cat 40.state_cat 41.state_cat 42.state_cat 43.state_cat 44.state_cat 45.state_cat 46.state_cat 47.state_cat 48.state_cat 49.state_cat 50.state_cat  1993.year 1994.year 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year 2008.year 2009.year 2010.year 2011.year 2012.year 2013.year 2014.year 2015.year 2016.year 2017.year 2018.year red_state) wrap se scalars("haseffect State effects" "hasteffect Time effects" "hasCSt Clustered standared errors""Fst F-statistics & p-values: " "ftime Time effects" "ftimep  ." "frest Rest expenditure" "frestp ." "fdebt Debt" "fdebtp .") rename(total_revenue "Total Revenue" rest_exp "Expenditure w/o education" debt_at_end_of_fiscal_year "Debt at the end of fiscal year" red_state_rev "RedState*Total Revenue" rest_exp_welfare "Expenditure w/o welfare" ) r2 obslast nobaselevels addnotes("") replace

 table ( var ) () (), statistic(mean total_revenue expenditure_education expenditure_public_welfare rest_exp rest_exp_welfare debt_at_end_of_fiscal_year ) statistic(sd  expenditure_education total_revenue rest_exp rest_exp_welfare debt_at_end_of_fiscal_year ) statistic(min expenditure_education total_revenue rest_exp rest_exp_welfare debt_at_end_of_fiscal_year ) statistic(max expenditure_education total_revenue rest_exp rest_exp_welfare debt_at_end_of_fiscal_year ) statistic(frequency) nformat(%12.0g)

 collect label levels var total_revenue "Total revenue" expenditure_education "Education expenditure" expenditure_public_welfare "Public Welfare expenditure" rest_exp "Expenditure excluding education expenditure" rest_exp_welfare "Expenditure excluding public welfare expenditure" debt_at_end_of_fiscal_year "Debt at the end of the fiscal year", modify
collect export "eco375_table1", as(docx) replace




log close
exit
