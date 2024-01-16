# Create the original data sets
# CREATE SCHEMA IF NOT EXISTS `cprd_data_dev` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
# CREATE SCHEMA IF NOT EXISTS `cprd_data` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
# CREATE SCHEMA IF NOT EXISTS `cprd_analysis_dev` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
# CREATE SCHEMA IF NOT EXISTS `cprd_analysis` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;

# Create the new data sets
CREATE SCHEMA IF NOT EXISTS `full_cprd_data_dev` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
CREATE SCHEMA IF NOT EXISTS `full_cprd_data` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
CREATE SCHEMA IF NOT EXISTS `full_cprd_analysis_dev` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
CREATE SCHEMA IF NOT EXISTS `full_cprd_analysis` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;

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
