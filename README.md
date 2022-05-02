
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Exeter\_Diabetes\_aurum\_package

<!-- badges: start -->
<!-- badges: end -->

This package provides functions to query a CPRD Aurum database on a
local or remote MySQL server. It uses the dbplyr package (part of the
tidyverse) to translate dplyr code into SQL. Analyses and outputs are
run/stored on the remote server.

## Installation

You can install the `Exeter_Diabetes_aurum_package` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("drkgyoung/Exeter_diabetes_aurum_package")
```

## Configuration

### Setup

Data and lookup MySQL tables are named as per data-raw/data-tables.yaml
and data-raw/lookup-tables.yaml.

As per vignettes/getting-started.Rmd, users must make a configuration
text file containing username, password and server details to connect to
the MySQL server. The example below will use CPRD Aurum data in a MySQL
database called ‘cprd\_data’ and store outputs in a database called
‘cprd\_analysis\_dev’.

``` yaml
default:
  user: <mysql username>
  password: <sql password>
  server: "localhost"
  port: 3306

test-analysis:
  dataDatabase: cprd_data
  analysisDatabase: cprd_analysis_dev

test-remote:
  dataDatabase: cprd_data
  analysisDatabase: cprd_analysis_dev
  server: 127.0.0.1
  port: 3307

test-vpn:
  dataDatabase: cprd_data
  analysisDatabase: cprd_analysis_dev
  server: slade.ex.ac.uk
  port: 3306
```

Use ‘test-analysis’ to connect to MySQL on a local server, ‘test-remote’
when to connect with MySQL on a remote server to which an SSH connection
has been established, and ‘test-vpn’ to connect with MySQL on a remote
server to which a VPN connection has been established.

Users can then connect by running e.g.

``` r
cprd = CPRDData$new(cprdEnv = "test-remote",cprdConf = "~/.aurum.yaml")
```

where \~/.aurum.yaml is the configuration file detailed above.

### Codelists

Codelists (e.g. of medcodeids or prodcodeids) for use with CPRD Aurum
can be added and deleted from MySQL as outlined in
vignettes/loading-and-using-codesets.Rmd. Codelists developed by the
Exeter Diabetes team can be found at
[Exeter\_Diabetes\_codelists](https://github.com/drkgyoung/Exeter_Diabetes_codelists).

### Analysis functions

Analysis functions e.g. computing and caching results are stored in
CPRDAnalysis.R and explained in vignettes/setting-up-an-analysis.Rmd.
These can only be executed when connected to a MySQL server.

### Biomarker functions

Two functions for cleaning biomarker values are included in this
package, and can be used on local data (loaded into R) or data stored in
MySQL.

`clean_biomarker_values` removes values outside of plausible limits
(limits found in …).

`clean_biomarker_units` retains only values with appropriate unit codes,
or missing unit code (appropriate unit codes found in …).

These functions can be applied to the following biomarkers: \*
Albumin-creatinine ratio (`acr`) \* Alanine aminotransferase (`alt`) \*
Aspartate aminotransferase(`ast`) \* BMI (adults only; `bmi`) \*
Serum/plasma creatinine (`creatinine`) \* Diastolic blood pressure
(`dbp`) \* Fasting glucose
(’fastingglucose`) * HbA1c (`hba1c`) * HDL (`hdl`) * Height (adults only;`height`) * LDL (`ldl`) * Protein-creatinine ratio (`pcr`) * Systolic blood pressure (`sbp`) * Total cholesterol (`totalcholesterol`) * Triglycerides (`triglyceride`) * Weight (weight;`weight\`)

Example:

``` r
clean_sbp <- raw_sbp %>%
  clean_biomarker_values("sbp") %>%
  clean_biomarker_units("sbp")
```

### Cardiovascular risk score functions

Functions for calculating the following cardiovascular risk scores are
included in this package, and can be used on local data (loaded into R)
or data stored in MySQL:

-   QRISK2-2017

Example:

``` r
results <- dataframe %>%
  calculate_qrisk2(age = age_var,
                    sex = sex_var,
                    ethrisk = ethrisk_var,
                    town = town_var,
                    smoking = smoking_var,
                    fh_cvd = fh_cvd_var,
                    renal = renal_var,
                    af = af_var,
                    rheumatoid_arth=rheumatoid_arth_var,
                    bp_med = bp_med_var,
                    cholhdl = cholhdl_var,
                    sbp = sbp_var,
                    bmi = bmi_var,
                    type1 = type1_var,
                    type2 = type2_var,
                    surv = surv_var)
```
