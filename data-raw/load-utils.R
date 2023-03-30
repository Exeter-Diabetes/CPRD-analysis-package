
# select unzip method based on file path
.listZip = function(zip) {
  if (fs::path_ext(zip) == "7z") {
    lsZip = ls7zip(zip) %>% rename(timestamp = DateTime, filename = Name)
  } else {
    lsZip = zip::zip_list(zip)
  }
}

# checks for a zip or 7z and unzips i path if needed
.doUnzip = function(zip, path = NULL, dir = tempdir()) {
  if (fs::path_ext(zip) == "7z") {
    paths = extract7zip(zip,path,dir)
  } else if (fs::path_ext(zip) == "zip") {
    zip::unzip(zip,files = path,exdir = target)
    paths = fs::dir_ls(recurse = TRUE)
    paths = paths[paths %>% stringr::str_ends(path)]
  } else {
    if (zip == fs::path(dir,fs::path_file(zip))) {
      paths = zip
    } else {
      paths = fs::file_copy(zip, fs::path(dir,fs::path_file(zip)))
    }
  }
  return(paths)
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


.sleepDuringDay = function() {

  if (Sys.getenv("IGNORE_SLEEP") != "yes") {

    hour = as.numeric(format(Sys.time(),"%H"))
    time_to_8pm = as.numeric((as.POSIXct(Sys.Date())+20*60*60) - Sys.time())*3600

    if (hour > 8 & hour < 20) {
      .slack_message(sprintf("It is %s. Pausing load process... Resuming in %1.2f hours time.", format(Sys.time(),"%H:%M"), time_to_8pm/3600))
      Sys.sleep(time_to_8pm)
    }

  }

}
