# CPRD Aurum extracts (datasets) and databases
## Diabetes dataset from October 2023: data in cprd_data, analysis in cprd_analysis_dev (cprd_data_dev used for testing loading; cprd_analysis not used)
## Full dataset from May 2021: data in full_cprd_data, analysis in full_cprd_analysis_dev (full_cprd_data_dev used for testing loading; full_cprd_analysis not used)
## Diabetes dataset from February 2024: data in cprd_dm24_data, analysis in cprd_dm24_analysis (cprd_dm24_data_dev used for testing loading)

# Create the databases
# CREATE SCHEMA IF NOT EXISTS `cprd_data_dev` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
# CREATE SCHEMA IF NOT EXISTS `cprd_data` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
# CREATE SCHEMA IF NOT EXISTS `cprd_analysis_dev` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
# CREATE SCHEMA IF NOT EXISTS `cprd_analysis` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;

# CREATE SCHEMA IF NOT EXISTS `full_cprd_data_dev` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
# CREATE SCHEMA IF NOT EXISTS `full_cprd_data` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
# CREATE SCHEMA IF NOT EXISTS `full_cprd_analysis_dev` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
# CREATE SCHEMA IF NOT EXISTS `full_cprd_analysis` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;

# Create the roles:
# 1) Loader role
# ideally this should only exist on localhost to stop people from trying to load data remotely
# but it will fail for other reasons if it can't find the data.
CREATE ROLE IF NOT EXISTS `role_cprd_loader`;
# Loads data from CSV files held locally on slade.
GRANT ALL privileges ON `full_cprd_data_dev`.* TO `role_cprd_loader`@`%`;
GRANT ALL privileges ON `full_cprd_data`.* TO `role_cprd_loader`@`%`;
GRANT ALL privileges ON `full_cprd_analysis_dev`.* TO `role_cprd_loader`@`%`;
GRANT ALL privileges ON `full_cprd_analysis`.* TO `role_cprd_loader`@`%`;
GRANT FILE ON *.* TO `role_cprd_loader`@`%;
# Loads data from CSV files held locally on slade.
GRANT ALL privileges ON `cprd_data_dev`.* TO `role_cprd_loader`@`%`;
GRANT ALL privileges ON `cprd_data`.* TO `role_cprd_loader`@`%`;
GRANT ALL privileges ON `cprd_analysis_dev`.* TO `role_cprd_loader`@`%`;
GRANT ALL privileges ON `cprd_analysis`.* TO `role_cprd_loader`@`%`;

# 2) Admin role
CREATE ROLE IF NOT EXISTS `role_cprd_admin`;
# Creates and maintains code sets within the database.
GRANT SELECT ON `full_cprd_data_dev`.* TO `role_cprd_admin`@`%`;
GRANT SELECT ON `full_cprd_data`.* TO `role_cprd_admin`@`%`;
GRANT ALL privileges ON `full_cprd_analysis_dev`.* TO `role_cprd_admin`@`%`;
GRANT ALL privileges ON `full_cprd_analysis`.* TO `role_cprd_admin`@`%`;
# Original
# GRANT SELECT ON `cprd_data_dev` TO `role_cprd_admin`@`%`;
# GRANT SELECT ON `cprd_data` TO `role_cprd_admin`@`%`;
# GRANT ALL privileges ON `cprd_analysis_dev` TO `role_cprd_admin`@`%`;
# GRANT ALL privileges ON `cprd_analysis` TO `role_cprd_admin`@`%`;

# 3) Reader role
CREATE ROLE IF NOT EXISTS `role_cprd_read`;
# creates specific queries for an analysis using existing code sets.
# Can create interim tables in the dev analysis database
GRANT SELECT ON `full_cprd_data_dev`.* TO `role_cprd_read`@`%`;
GRANT SELECT ON `full_cprd_data`.* TO `role_cprd_read`@`%`;
GRANT ALL privileges ON `full_cprd_analysis_dev`.* TO `role_cprd_read`@`%`;
GRANT SELECT ON `full_cprd_analysis`.* TO `role_cprd_read`@`%`;
# Original
# GRANT SELECT ON `cprd_data_dev`.* TO `role_cprd_read`@`%`;
# GRANT SELECT ON `cprd_data`.* TO `role_cprd_read`@`%`;
# GRANT ALL privileges ON `cprd_analysis_dev`.* TO `role_cprd_read`@`%`;
# GRANT SELECT ON `cprd_analysis`.* TO `role_cprd_read`@`%`;
