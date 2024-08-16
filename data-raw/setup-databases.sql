# CPRD Aurum extracts (datasets) and databases
## Diabetes dataset from October 2020: data in cprd_data, analysis in cprd_analysis_dev (cprd_data_dev used for testing loading; cprd_analysis not used)
## Full dataset from May 2021: data in full_cprd_data, analysis in full_cprd_analysis_dev (full_cprd_data_dev used for testing loading; full_cprd_analysis not used)
## Dementia dataset from February 2024: data in cprd_dementia_data, analysis in cprd_dementia_analysis (cprd_dementia_data_dev used for testing loading)
## Diabetes dataset from February 2024: data in cprd_feb24dm_data, analysis in cprd_feb24dm_analysis (cprd_feb24dm_data_dev used for testing loading)

set role 'role_full_admin';

# Create the databases for 202010 diabetes dataset
# CREATE SCHEMA IF NOT EXISTS `cprd_data_dev` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
# CREATE SCHEMA IF NOT EXISTS `cprd_data` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
# CREATE SCHEMA IF NOT EXISTS `cprd_analysis_dev` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
# CREATE SCHEMA IF NOT EXISTS `cprd_analysis` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;

# Create the databases for 202105 full dataset
# CREATE SCHEMA IF NOT EXISTS `full_cprd_data_dev` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
# CREATE SCHEMA IF NOT EXISTS `full_cprd_data` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
# CREATE SCHEMA IF NOT EXISTS `full_cprd_analysis_dev` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
# CREATE SCHEMA IF NOT EXISTS `full_cprd_analysis` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;

# Create the the databases for 202402 dementia dataset
CREATE SCHEMA IF NOT EXISTS `cprd_dementia_data_dev` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
CREATE SCHEMA IF NOT EXISTS `cprd_dementia_data` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
CREATE SCHEMA IF NOT EXISTS `cprd_dementia_analysis` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;

# Create the the databases for 202402 diabetes dataset
CREATE SCHEMA IF NOT EXISTS `cprd_feb24dm_data_dev` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
CREATE SCHEMA IF NOT EXISTS `cprd_feb24dm_data` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
CREATE SCHEMA IF NOT EXISTS `cprd_feb24dm_analysis` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;

# Create the the databases for 202402 depression dataset
CREATE SCHEMA IF NOT EXISTS `cprd_feb24depression_data_dev` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
CREATE SCHEMA IF NOT EXISTS `cprd_feb24depression_data` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
CREATE SCHEMA IF NOT EXISTS `cprd_feb24depression_analysis` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;

# Create the the databases for 202406 diabetes dataset
CREATE SCHEMA IF NOT EXISTS `cprd_jun24dm_data_dev` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
CREATE SCHEMA IF NOT EXISTS `cprd_jun24dm_data` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
CREATE SCHEMA IF NOT EXISTS `cprd_jun24dm_analysis` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;


# Create the roles:
# 1) Loader role
# ideally this should only exist on localhost to stop people from trying to load data remotely
# but it will fail for other reasons if it can't find the data.
CREATE ROLE IF NOT EXISTS `role_cprd_loader`;
# Loads data from CSV files held locally on slade.
# GRANT ALL privileges ON `cprd_data_dev`.* TO `role_cprd_loader`@`%`;
# GRANT ALL privileges ON `cprd_data`.* TO `role_cprd_loader`@`%`;
# GRANT ALL privileges ON `cprd_analysis_dev`.* TO `role_cprd_loader`@`%`;
# GRANT ALL privileges ON `cprd_analysis`.* TO `role_cprd_loader`@`%`;
# GRANT FILE ON *.* TO `role_cprd_loader`@`%`;

# GRANT ALL privileges ON `full_cprd_data_dev`.* TO `role_cprd_loader`@`%`;
# GRANT ALL privileges ON `full_cprd_data`.* TO `role_cprd_loader`@`%`;
# GRANT ALL privileges ON `full_cprd_analysis_dev`.* TO `role_cprd_loader`@`%`;
# GRANT ALL privileges ON `full_cprd_analysis`.* TO `role_cprd_loader`@`%`;

GRANT ALL privileges ON `cprd_dementia_data_dev`.* TO `role_cprd_loader`@`%`;
GRANT ALL privileges ON `cprd_dementia_data`.* TO `role_cprd_loader`@`%`;
GRANT ALL privileges ON `cprd_dementia_analysis`.* TO `role_cprd_loader`@`%`;

GRANT ALL privileges ON `cprd_feb24dm_data_dev`.* TO `role_cprd_loader`@`%`;
GRANT ALL privileges ON `cprd_feb24dm_data`.* TO `role_cprd_loader`@`%`;
GRANT ALL privileges ON `cprd_feb24dm_analysis`.* TO `role_cprd_loader`@`%`;

GRANT ALL privileges ON `cprd_feb24depression_data_dev`.* TO `role_cprd_loader`@`%`;
GRANT ALL privileges ON `cprd_feb24depression_data`.* TO `role_cprd_loader`@`%`;
GRANT ALL privileges ON `cprd_feb24depression_analysis`.* TO `role_cprd_loader`@`%`;

GRANT ALL privileges ON `cprd_jun24dm_data_dev`.* TO `role_cprd_loader`@`%`;
GRANT ALL privileges ON `cprd_jun24dm_data`.* TO `role_cprd_loader`@`%`;
GRANT ALL privileges ON `cprd_jun24dm_analysis`.* TO `role_cprd_loader`@`%`;


# 2) Admin role
CREATE ROLE IF NOT EXISTS `role_cprd_admin`;
# Creates and maintains code sets within the database.
# GRANT SELECT ON `cprd_data_dev` TO `role_cprd_admin`@`%`;
# GRANT SELECT ON `cprd_data` TO `role_cprd_admin`@`%`;
# GRANT ALL privileges ON `cprd_analysis_dev` TO `role_cprd_admin`@`%`;
# GRANT ALL privileges ON `cprd_analysis` TO `role_cprd_admin`@`%`;

# GRANT SELECT ON `full_cprd_data_dev`.* TO `role_cprd_admin`@`%`;
# GRANT SELECT ON `full_cprd_data`.* TO `role_cprd_admin`@`%`;
# GRANT ALL privileges ON `full_cprd_analysis_dev`.* TO `role_cprd_admin`@`%`;
# GRANT ALL privileges ON `full_cprd_analysis`.* TO `role_cprd_admin`@`%`;

GRANT SELECT ON `cprd_dementia_data_dev`.* TO `role_cprd_admin`@`%`;
GRANT SELECT ON `cprd_dementia_data`.* TO `role_cprd_admin`@`%`;
GRANT ALL privileges ON `cprd_dementia_analysis`.* TO `role_cprd_admin`@`%`;

GRANT SELECT ON `cprd_feb24dm_data_dev`.* TO `role_cprd_admin`@`%`;
GRANT SELECT ON `cprd_feb24dm_data`.* TO `role_cprd_admin`@`%`;
GRANT ALL privileges ON `cprd_feb24dm_analysis`.* TO `role_cprd_admin`@`%`;

GRANT SELECT ON `cprd_feb24depression_data_dev`.* TO `role_cprd_admin`@`%`;
GRANT SELECT ON `cprd_feb24depression_data`.* TO `role_cprd_admin`@`%`;
GRANT ALL privileges ON `cprd_feb24depression_analysis`.* TO `role_cprd_admin`@`%`;

GRANT SELECT ON `cprd_jun24dm_data_dev`.* TO `role_cprd_admin`@`%`;
GRANT SELECT ON `cprd_jun24dm_data`.* TO `role_cprd_admin`@`%`;
GRANT ALL privileges ON `cprd_jun24dm_analysis`.* TO `role_cprd_admin`@`%`;


# 3) Reader role
# Currently not using
CREATE ROLE IF NOT EXISTS `role_cprd_read`;
# creates specific queries for an analysis using existing code sets.
# Can create interim tables in the analysis database (formally only dev analysis)
# GRANT SELECT ON `cprd_data_dev`.* TO `role_cprd_read`@`%`;
# GRANT SELECT ON `cprd_data`.* TO `role_cprd_read`@`%`;
# GRANT ALL privileges ON `cprd_analysis_dev`.* TO `role_cprd_read`@`%`;
# GRANT SELECT ON `cprd_analysis`.* TO `role_cprd_read`@`%`;

# GRANT SELECT ON `full_cprd_data_dev`.* TO `role_cprd_read`@`%`;
# GRANT SELECT ON `full_cprd_data`.* TO `role_cprd_read`@`%`;
# GRANT ALL privileges ON `full_cprd_analysis_dev`.* TO `role_cprd_read`@`%`;
# GRANT SELECT ON `full_cprd_analysis`.* TO `role_cprd_read`@`%`;

# GRANT SELECT ON `cprd_dementia_data_dev`.* TO `role_cprd_read`@`%`;
# GRANT SELECT ON `cprd_dementia_data`.* TO `role_cprd_read`@`%`;
# GRANT SELECT ON `cprd_dementia_analysis`.* TO `role_cprd_read`@`%`;

# GRANT SELECT ON `cprd_feb24dm_data_dev`.* TO `role_cprd_read`@`%`;
# GRANT SELECT ON `cprd_feb24dm_data`.* TO `role_cprd_read`@`%`;
# GRANT SELECT ON `cprd_feb24dm_analysis`.* TO `role_cprd_read`@`%`;
