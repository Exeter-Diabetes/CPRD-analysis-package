#' list files in a 7z archive using system tool
#'
#' @param zip the path of the the 7z file
#'
#' @return a dataframe with DateTime, Attr, Size, Name columns
#' @export
ls7zip = function(zip) {
  zip = normalizePath(zip)
  tmp = system2(.path7z(),c("l",zip), stdout=TRUE)

  range = which(tmp %>% stringr::str_starts("----"))
  files = tmp[(range[1]+1):(range[2]-1)]
  layout = tmp[range[1]]
  cols = (layout %>% str_locate_all("\\s+"))[[1]]
  names = readr::read_fwf(paste0(tmp[(range[1]-1)],"\n"), col_positions = fwf_positions(c(1,cols[,2]),c(cols[,1],NA)) )
  names = unname(t(names)[,1]) %>% stringr::str_remove_all("\\s+")

  out = readr::read_fwf(
          files,
          col_positions = readr::fwf_positions(c(1,cols[,2]),c(cols[,1],NA),col_names = names)
        )

  out %>%
    filter(Attr == "....A") %>%
    mutate(
      DateTime = as.POSIXct(DateTime),
      Size = as.integer(Size),
      Compressed = as.integer(Compressed)
    )
}

#' extract file sform a 7x archive using system tool
#'
#' @param zip the path of the the 7z file
#' @param path the file within the 7z file or if NULL everything
#' @param dir the directory to extract to
#'
#' @return a lit of file paths of extracted files
#' @export
extract7zip = function(zip, path = NULL, dir = tempdir()) {
  zip = normalizePath(zip)
  dir = normalizePath(dir)
  fs::dir_create(dir)
  cur_dir = setwd(dir)
  if (is.null(path)) {
    system2(.path7z(), c("x","-aoa",zip), stdout=TRUE)
    file = fs::dir_ls(dir,recurse = TRUE,type = "file")
  } else {
    file = lapply(as.list(path), function(p) {
      tmp = system2("7z",c("x","-aoa",zip, p), stdout=TRUE)
      x = fs::path(dir,p)
      if (fs::is_dir(x)) x = fs::dir_ls(x,recurse = TRUE)
      return(x)
    }) %>% unlist()
  }
  setwd(cur_dir)
  return(unlist(unname(file)))
}


.path7z = function() {
  tmp = system2("which","7z", stdout=TRUE)
  if (length(tmp) == 0) stop("cannot find system `7z` command")
  return(tmp)
}
