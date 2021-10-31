#' Get a handle to the CPRD data databse
#'
#' This function sets up a connection to the cprd data databse, and provides a set of basic functions for manipulating the CPRD
#' @keywords CPRD
#' @export
CPRDCodeSets = R6::R6Class("CPRDCodeSets", inherit = AbstractCPRDConnection, public=list(

  #' @field .data - internal the pointer to the cprdDatabase
  .data = NULL,

  #' @field codeSets - the med code sets table
  codeSets = NULL,


  #### Constructor ----

  #' @description Get a new CPRD codes sets container.
  #' @param cprdData an existing cprd data container
  #' @return A new CPRDCodeSets container.
  initialize = function(cprdData) {

    super$initialize(cprdConnection = cprdData)
    self$.data = cprdData

    analysisDb = self$.analysisDb
    con = self$.con

    #TODO: remove this as we should not need admin role to create tables in analysisDb
    self$enableAdmin()

    # data tables
    if (!self$tableExists(aurum::codeSetsSql$naming$codeSets)) {
      self$execSql(template = aurum::codeSetsSql$tables$codeSets$create)
    }
    self$codeSets = dplyr::tbl(con, dbplyr::in_schema(analysisDb, aurum::codeSetsSql$naming$codeSets))


  },


  #### Code set handling functions ----

  #' @description load a new medcode set into the CPRD data from an R dataframe.
  #' @param codeSetDf a dataframe with minimally a single column of medcode ids.
  #' @param category (optional) column containing category code. If set to NULL, all values are NULL.
  #' @param name the name of the codeset
  #' @param version the version of the codeset
  #' @param colname (optional) the name of the column containing the medcode. If set to NULL defaults to the first column.
  #' @return A TRUE/FALSE depending on if the code set was successfully loaded.
  loadMedCodeSet = function(codeSetDf, category=NULL, name, version, colname=NULL) {
    self$loadCodeSet(codeSetDf=codeSetDf, category=category, name=name, version=version, colname=colname, type="medcodeid")
  },

  #' @description load a new prodcode set into the CPRD data from an R dataframe.
  #' @param codeSetDf a dataframe with minimally a single column of prodcode ids.
  #' @param category (optional) column containing category code. If set to NULL, all values are NULL.
  #' @param name the name of the codeset
  #' @param version the version of the codeset
  #' @param colname (optional) the name of the column containing the prodcode. If set to NULL defaults to the first column.
  #' @return A TRUE/FALSE depending on if the code set was successfully loaded.
  loadProdCodeSet = function(codeSetDf, category=NULL, name, version, colname=NULL) {
    self$loadCodeSet(codeSetDf=codeSetDf, category=category, name=name, version=version, colname=colname, type="prodcodeid")
  },

  #' @description load a new ICD10 set into the CPRD data from an R dataframe.
  #' @param codeSetDf a dataframe with minimally a single column of ICD10 codes.
  #' @param category (optional) column containing category code. If set to NULL, all values are NULL.
  #' @param name the name of the codeset
  #' @param version the version of the codeset
  #' @param colname (optional) the name of the column containing the ICD10 code If set to NULL defaults to the first column.
  #' @return A TRUE/FALSE depending on if the code set was successfully loaded.
  loadICD10CodeSet = function(codeSetDf, category=NULL, name, version, colname=NULL) {
    self$loadCodeSet(codeSetDf=codeSetDf, category=category, name=name, version=version, colname=colname, type="icd10")
  },
  
  #' @description load a new ICD10 set into the CPRD data from an R dataframe.
  #' @param codeSetDf a dataframe with minimally a single column of ICD10 codes.
  #' @param category (optional) column containing category code. If set to NULL, all values are NULL.
  #' @param name the name of the codeset
  #' @param version the version of the codeset
  #' @param colname (optional) the name of the column containing the ICD10 code If set to NULL defaults to the first column.
  #' @return A TRUE/FALSE depending on if the code set was successfully loaded.
  loadOPCS4CodeSet = function(codeSetDf, category=NULL, name, version, colname=NULL) {
    self$loadCodeSet(codeSetDf=codeSetDf, category=category, name=name, version=version, colname=colname, type="opcs4")
  },
  
  #' @description load a new code set into the CPRD data from an R dataframe.
  #' @param codeSetDf a dataframe with minimally a single column of medcode ids or prodcode ids.
  #' @param category (optional) column containing category code. If set to NULL defaults to the third column.
  #' @param name the name of the codeset
  #' @param version the version of the codeset
  #' @param colname the name of the column containing the medcode or prodcode. If set to NULL defaults to the first column.
  #' @param type the type of the code as the column name it will match on e.g. medcodeid, prodcodeid. This can be used for any kind of codeid column
  #' @return A TRUE/FALSE depending on if the code set was successfully loaded.
  loadCodeSet = function(codeSetDf, category=NULL, name, version, colname=NULL, type) {
    if (!type %in% aurum::lookupSql$keys) stop("type must be one of: ",paste0(aurum::lookupSql$keys,collapse = ", "))
    table = names(lookupSql$keys[lookupSql$keys==type])
    # colname or first col
    if(is.null(colname)) {
      colname = colnames(codeSetDf)[1]
      message("codeid colname was not defined... using: ",colname)
    }
    colname = as.symbol(colname)
    if(!(codeSetDf %>% dplyr::pull(!!colname) %>% class() %in% c("character","integer64")))
      stop("Code sets can only be defined using character or bit64::integer64 data types, otherwise all sorts of problems may occur. Load data using the readr package and the col_types = cols(.default=col_character()) option")
    if((codeSetDf %>% dplyr::pull(!!colname) %>% class() == "character") & (codeSetDf %>% dplyr::pull(!!colname) %>% nchar %>% max > 6)) {
      codeSetDf = codeSetDf %>% dplyr::mutate(!!colname := bit64::as.integer64(stringr::str_remove_all(!!colname,"[^0-9]")))
    }
    # category
    if(is.null(category)) {
      codeSetDf = codeSetDf %>% dplyr::mutate(empty_category=NA)
      category="empty_category"
      message("no category field specified")
    }
    category = as.symbol(category)

        codeSetDf = codeSetDf %>% dplyr::select(codeid = !!colname,category = !!category) %>% dplyr::arrange(codeid) %>% dplyr::distinct()
    if(any(is.na(codeSetDf$codeid))) message("removing rows with empty codes in ",name," v.",version)
    codeSetDf = codeSetDf %>% dplyr::filter(!is.na(codeid))

    if (codeSetDf %>% nrow() == 0) {
      message("Aborting load... no non empty rows found for ",name," v.",version)
      return(FALSE)
    }

    hash = codeSetDf %>% dplyr::mutate(codeid := bit64::as.integer64(stringr::str_remove_all(codeid,"[^0-9]"))) %>% dplyr::pull(codeid) %>% as.raw() %>% openssl::md5() %>% as.character()
    codeSetDf = codeSetDf %>% dplyr::mutate(setname = name, version = version, type=type, hash=hash)

    previous= self$codeSets %>% dplyr::filter(setname == name & version==version) %>% dplyr::collect()
    if( previous %>% nrow() > 0) {
      if(all(previous$hash == hash)) {
        message("This code set version exists in the database")
        return(FALSE)
      } else {
        stop("A different code set with the same name and version already exists. Delete this first or change the version.")
      }
    }
    # no previous version exists

    codeSetDf %>% self$appendDf(table = aurum::codeSetsSql$naming$codeSets, database = self$.analysisDb)

    return(TRUE)
  },

  #' @description load a set of med codes from tab separated text files into the CPRD database.
  #' The names of the codesets will be defined by the filenames. Files will not be loaded if they have the same hash,
  #' name and version as an existing code set.
  #' @param paths a list of file paths to try and load.
  #' @param version the version of the codesets that are being loaded
  #' @return Nothing
  loadAll = function(paths,version) {
    files = unlist(lapply(paths, function(x) paste0(x,"/",list.files(x,pattern=".*\\.(txt)",recursive=TRUE))))
    for (file in files) {
      parts = fs::path_file(file) %>% stringr::str_split("\\.") %>% unlist()
      name = tolower(stringr::str_remove_all(parts[1],"exeter_medcodelist_"))
      name = tolower(stringr::str_remove_all(name,"exeter_prodcodelist_"))
      name = tolower(stringr::str_remove_all(name,"exeter_"))
      ext = parts[2]
      tryCatch({
        if(ext == "txt") {
          codelist = readr::read_tsv(file,col_types = cols(.default=col_character()))
        } else {
          codelist = readr::read_csv(file,col_types = cols(.default=col_character()))
        }
        codelist = codelist %>% rename_with(.fn = stringr::str_to_lower)
        if (any(colnames(codelist) %in% aurum::lookupSql$keys)) {
          type = colnames(codelist)[colnames(codelist) %in% aurum::lookupSql$keys]
          message("Loading ",file," as a ",type)
          self$loadCodeSet(codelist,name = name,version=version,colname=type,type=type)
        } else {
          message("Skipping ",file," - did not find code column")
        }
      }, error=function(e) message("error processing ",file))
    }
  },

  #' @description list the codes, and their descriptions, in a given named version of a code set. The medcodeid or prodcodeid
  #' @param name the code set name
  #' @param version the code set version
  #' @return a lazy dataframe containing the codes and their descriptions
  getCodeSetDetails = function(name,category=NULL,version=NULL) {
    if (is.null(version) & is.null(category)) {
      previous = self$codeSets %>% dplyr::filter(setname==name & version==max(version,na.rm=TRUE))
      message("no category field specified, all will be included")
      message("no version specified, will use latest")
    } else if (!is.null(version) & is.null(category)) {
      vs = version
      previous = self$codeSets %>% dplyr::filter(setname==name & version==local(vs))
      message("no category field specified, all will be included")
    } else if (is.null(version) & !is.null(category)) {
      chosen_cat = category
      previous = self$codeSets %>% dplyr::filter(setname==name & category==local(chosen_cat) & version==max(version,na.rm=TRUE))
      message("no version specified, will use latest")
    } else if (!is.null(version) & !is.null(category)) {
      vs = version
      chosen_cat = category
      previous = self$codeSets %>% dplyr::filter(setname==name & category==local(chosen_cat) & version==local(vs))
    }
    key = previous %>% select(type) %>% distinct() %>% pull(type) %>% unique()
    if (length(key)!=1) {warning("problem with name and version..."); browser()} #TODO identify further
    table = names(aurum::lookupSql$keys[aurum::lookupSql$keys==key])
    tableid = aurum::lookupSql$naming[[table]]
    catname = paste0(name,"_cat")
    return(
      previous %>%
        dplyr::inner_join(
          self$.data$tables[[table]],
          by = c("codeid"=key)
        ) %>% rename(!!key := codeid, !!catname := category)
    )
    # return(self$lazySql(
    #   aurum::codeSetsSql$tables$codeSets$getFromTableKeyByNameVersion,
    #   table = DBI::dbQuoteIdentifier(self$.con, tableid),
    #   key = DBI::dbQuoteIdentifier(self$.con, key),
    #   name= name,
    #   version= version
    # ))
    # in codeSetsSql
    # getFromTableKeyByNameVersion: |
    #   SELECT c.*,t.* FROM {dataDb}.{table} t, {analysisDb}.{codeSets} c WHERE t.{key} = c.codeid AND c.setname={name} AND c.version={version}
  },

  #' @description list the codes only in a named code set.
  #' @param name the code set name
  #' @param version (optional) the code set version, if not sepcified returns the maximium code
  #' @return a lazy dataframe containing the code only
  getCodeSet = function(name,category=NULL,version = NULL) {
    if (is.null(version) & is.null(category)) {
      previous = self$codeSets %>% dplyr::filter(setname==name & version==max(version,na.rm=TRUE))
      message("no category field specified, all will be included")
      message("no version specified, will use latest")
    } else if (!is.null(version) & is.null(category)) {
      vs = version
      previous = self$codeSets %>% dplyr::filter(setname==name & version==local(vs))
      message("no category field specified, all will be included")
    } else if (is.null(version) & !is.null(category)) {
      chosen_cat = category
      previous = self$codeSets %>% dplyr::filter(setname==name & category==local(chosen_cat) & version==max(version,na.rm=TRUE))
      message("no version specified, will use latest")
    } else if (!is.null(version) & !is.null(category)) {
      vs = version
      chosen_cat = category
      previous = self$codeSets %>% dplyr::filter(setname==name & category==local(chosen_cat) & version==local(vs))
    }
    
    key = previous %>% select(type) %>% distinct() %>% pull(type) %>% unique()
    if (length(key)!=1) {warning("problem with name and version..."); browser()} #TODO identify further
    #table = names(aurum::lookupSql$keys[aurum::lookupSql$keys==key])
    #tableid = aurum::lookupSql$naming[[table]]
    catname = paste0(name,"_cat")
    return(previous %>% select(!!key := codeid,category) %>% rename(!!catname := category))
  },

  getAllCodeSetVersion = function(version) {
    v = version
    tmp = self$listCodeSets() %>% filter(version==v) %>% pull(setname)
    out = list()
    for (name in tmp) {
      out[[name]]=self$getCodeSet(name=name,version=v)
    }
    return(out)
  },

  #' @description list the codes only in a named code set.
  #' @return a lazy dataframe containing the code only
  listCodeSets = function() {
    self$codeSets %>% dplyr::group_by(setname,version,type,hash) %>% dplyr::count() %>% dplyr::collect()
  },

  #' @description delete a code set version. This will affect all users of the CPRD database.
  #' @param name the code set name
  #' @param version the code set version
  deleteCodeSetVersion = function(name,version) {
    self$execSql(aurum::codeSetsSql$tables$codeSets$deleteNamedVersion, name=name, version=version)
  },

  #' @description delete all versions of a code set. This will affect all users of the CPRD database.
  #' @param name the code set name
  deleteCodeSet = function(name) {
    self$execSql(aurum::codeSetsSql$tables$codeSets$deleteNamed, name=name)
  },

  #' @description
  #' Prints the database connection information.
  #' @return nothing.
  print = function() {
    print("CPRD Code Sets")
    super$print()
  }
))
