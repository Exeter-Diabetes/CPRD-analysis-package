
<!-- README.md is generated from README.Rmd. Please edit that file -->

# CPRD-analysis-package

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
devtools::install_github("Exeter-Diabetes/CPRD-analysis-package")
```

## Configuration

### Setup

Data and lookup MySQL tables are named as per data-raw/data-tables.yaml
and data-raw/lookup-tables.yaml.

As per vignettes/getting-started.Rmd, users must make a configuration
text file containing username, password and server details to connect to
the MySQL server. The example below will use CPRD Aurum data in a MySQL
database called ‘cprd_data’ and store outputs in a database called
‘cprd_analysis_dev’.

``` yaml
default:
  user: <mysql username>
  password: <sql password>
  server: "localhost"
  port: 3306
  sessionConfig:
    SESSION default_storage_engine: "MyISAM"

test-remote:
  dataDatabase: cprd_data
  analysisDatabase: cprd_analysis_dev
  server: 127.0.0.1
  port: 3307

```

Use ‘test-remote’ to connect with MySQL on a remote server to which an SSH
connection has been established.

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
[CPRD-Codelists](https://github.com/Exeter-Diabetes/CPRD-Codelists).

### Analysis functions

Analysis functions e.g. computing and caching results are stored in
CPRDAnalysis.R and explained in vignettes/setting-up-an-analysis.Rmd.
These can only be executed when connected to a MySQL server.

### Loading data into MySQL

Note that this package contains different branches which were used
to load the raw CPRD data into MySQL for various different downloads.
For info about the different downloads and the names of the databases
they're stored in (which need to be in the ~/.aurum.yaml), see [here](https://github.com/Exeter-Diabetes/CPRD-analysis-package/blob/adc3e1364066eb73ac7746cf51bbdf0fef1c603a/data-raw/setup-databases.sql).
