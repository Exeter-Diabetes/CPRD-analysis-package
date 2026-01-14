# check dependencies for load scripts
.check_dependencies = function() {

  # Check needed libraries are set up and if no set them up:
  # check for dependencies and install them if needed

  if (!"optparse" %in% rownames(installed.packages()))
    install.packages("optparse", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))
  if (!"tidyverse" %in% rownames(installed.packages()))
    install.packages("tidyverse", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))
  if (!"config" %in% rownames(installed.packages()))
    install.packages("config", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))
  if (!"here" %in% rownames(installed.packages()))
    install.packages("here", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))
  if (!"openssl" %in% rownames(installed.packages()))
    install.packages("openssl", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))
  if (!"slackr" %in% rownames(installed.packages()))
    install.packages("slackr", repos="https://www.stats.bris.ac.uk/R/", lib=Sys.getenv("R_LIBS_USER"))

  if (!require(tidyverse,quietly = TRUE,warn.conflicts = FALSE)) stop("tidyverse package must be installed")
  if (!require(optparse,quietly = TRUE,warn.conflicts = FALSE)) stop("optparse package must be installed")

  # Running this as a script on the command line gave me some issues because
  # the easybuild system does not correctly configure the libPaths. to fix this
  # we are making sure that the easybuild loaded libraries come after the locally
  # installed libraries, so that we are up to date.
  .libPaths(c(
    # non easybuild libraries first
    .libPaths()[!stringr::str_detect(.libPaths(),"easybuild")],
    # then easybuild ones
    .libPaths()[stringr::str_detect(.libPaths(),"easybuild")]
  ))

}

.load_config = function(opt) {
  # check config consistent
  cprdConf = opt$config
  cprdEnv = opt$env

  if(!file.exists(cprdConf)) stop("config file not found: ",cprdConf)
  tmp = yaml::yaml.load(readr::read_file(cprdConf))
  if (!(cprdEnv %in% names(tmp))) stop(sprintf("
--env='%s' is not found in  file: --config='%s'.
allowable values for --env are: %s.
", cprdEnv, cprdConf, paste0("'",names(tmp),"'", collapse=", ")))

  # load configuration and set up the slack bot.
  cfg = config::get(file = cprdConf, config = cprdEnv)
  message("Initialising... using config: ",cprdConf,"; option:",cprdEnv)
  return(cfg)
}


# select unzip method based on file path
.listZip = function(zip) {
  if (fs::path_ext(zip) == "7z") {
    lsZip = ls7zip(zip) %>% rename(timestamp = DateTime, filename = Name)
  } else {
    lsZip = zip::zip_list(zip)
  }
}

# checks for a zip or 7z and unzips i path if needed
# .doUnzip("/slade/DBs/mysql-files/CPRD/master_males/HenleyW20201212090518.zip", dir = tempfile())
# .doUnzip("/slade/DBs/mysql-files/CPRD/whole_aurum_dataset_raw/Aurum_AllPatID_set1_Extract.7z", dir=tempfile())
.doUnzip = function(zip, path = NULL, dir = tempdir()) {
  if (fs::path_ext(zip) == "7z") {
    paths = extract7zip(zip,path,dir)
  } else if (fs::path_ext(zip) == "zip") {
    zip::unzip(zip, files = path, exdir = dir)
    paths = fs::dir_ls(dir, recurse = TRUE)
    if (!is.null(path)) paths = paths[paths %>% stringr::str_ends(path)]
  } else {
    # not a zip or a 7z
    if (zip == fs::path(dir,fs::path_file(zip))) {
      paths = zip
    } else {
      paths = fs::file_copy(zip, fs::path(dir,fs::path_file(zip)))
    }
  }
  return(paths)
}



# a config and an options
.setup_slack = function(cfg) {
  if (!.dry_run()) {
    if (!is.null(cfg$slackToken)) {
      slackr::slackr_setup(channel = cfg$slackChannel, incoming_webhook_url = cfg$slackWebhook, token = cfg$slackToken)
      Sys.setenv(USE_SLACK = "yes")
    } else {
      if (!.dry_run()) warning("No slack set up detected.")
      Sys.setenv(USE_SLACK = "no")
    }
  } else {
    Sys.setenv(USE_SLACK = "no")
  }
}

# send message via slack
# slackr::slackr_setup(channel = cfg$slackChannel, incoming_webhook_url = cfg$slackWebhook, token = cfg$slackToken)
.slack_message = function(..., channel = cfg$slackChannel) {
  if (Sys.getenv("USE_SLACK") == "yes") {
    slackr::slackr_msg(
      txt = c(...),
      channel = channel
    )
  }
  message(paste0(c(...),collapse="\n"))
}

# now disabled
.sleepDuringDay = function() {

  # if (Sys.getenv("IGNORE_SLEEP") != "yes") {
  #
  #   hour = as.numeric(format(Sys.time(),"%H"))
  #   time_to_8pm = as.numeric((as.POSIXct(Sys.Date())+20*60*60) - Sys.time())*3600
  #
  #   if (hour > 8 & hour < 20) {
  #     .slack_message(sprintf("It is %s. Pausing load process... Resuming in %1.2f hours time.", format(Sys.time(),"%H:%M"), time_to_8pm/3600))
  #     Sys.sleep(time_to_8pm)
  #   }
  #
  # }

}
