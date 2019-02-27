#' list all loinames
#'
#' @param apiPath path of terrabrasilis analytics server API
#' @param appIdentifier define the application identifier
#' 
#' @name tba_list_loinames
#' @export
tba_list_loinames <- function(apiPath, appIdentifier) {

  # define config header
  h <- tba_configHeader(curl::new_handle(), appIdentifier)

  # request locals of interests with a specific header
  resJSON <- tba_request(paste(apiPath, "config/loinames", sep = ""), h)
  
  # format lois dataframes for loinames rows 
  resJSON <- dplyr::bind_rows(resJSON$lois$loinames)
  
  # initialize loi column
  resJSON <- cbind(resJSON, loi = 0)
  count <- 1
  
  # for each loi binds a new set of values
  for (i in 1:length(resJSON$lois$gid)) {
    size <- nrow(resJSON$lois$loinames[[i]])
    resJSON[,"loi"][count:(count+size-1)] <- rep(resJSON$lois$gid[i], size)
    count = count + size
  }
  
  # wrangle loinames as tibble
  return(tibble::as_tibble(resJSON))

}

#' list all filters
#'
#' @param apiPath path of terrabrasilis analytics server API
#' @param appIdentifier define the application identifier
#' 
#' @name tba_list_filters
#' @export
tba_list_filters <- function(apiPath, appIdentifier) {

  # define config header
  h <- tba_configHeader(curl::new_handle(), appIdentifier)

  # request locals of interests with a specific header
  resJSON <- tba_request(paste(apiPath, "config/filters", sep = ""), h)
  
  # wrangle filters as tibble
  return(tibble::as_tibble(resJSON$filters))

}

#' list all lois
#'
#' @param apiPath a curl handle used to configure a request
#' @param appIdentifier define the application identifier
#' 
#' @name tba_list_lois
#' @export
tba_list_lois <- function(apiPath, appIdentifier) {

  # define config header
  h <- tba_configHeader(curl::new_handle(), appIdentifier)

  # request locals of interests with a specific header
  resJSON <- tba_request(paste(apiPath, "config/lois", sep = ""), h)
  
  # order table by locals of interests
  resJSON$lois <- resJSON$lois[order(resJSON$lois$gid),] 
  
  # wrangle lois as tibble
  return(tibble::as_tibble(resJSON$lois))

}

#' list all classes
#'
#' @param apiPath path of terrabrasilis analytics server API
#' @param appIdentifier define the application identifier
#' 
#' @name tba_list_classes
#' @export
tba_list_classes <- function(apiPath, appIdentifier) {

  # define config header
  h <- tba_configHeader(curl::new_handle(), appIdentifier)

  # request classes with a specific header
  resJSON <- tba_request(paste(apiPath, "config/classes", sep = ""), h)
  
  # wrangle classes as tibble
  return(tibble::as_tibble(resJSON$classes))

}

#' list all periods
#'
#' @param apiPath path of terrabrasilis analytics server API
#' @param appIdentifier define the application identifier
#' 
#' @name tba_list_periods
#' @export
tba_list_periods <- function(apiPath, appIdentifier) {

  # define config header
  h <- tba_configHeader(curl::new_handle(), appIdentifier)

  # request periods with a specific header
  resJSON <- tba_request(paste(apiPath, "config/periods", sep = ""), h)
  
  # wrangle start and end date periods into one
  return(tibble::as_tibble(cbind(startDate = resJSON$periods$startDate, 
                                 endDate = resJSON$periods$endDate)))

}

#' list all loinames by loi
#'
#' @param apiPath path of terrabrasilis analytics server API
#' @param loi define type of local of interest
#' @param appIdentifier define the application identifier
#' 
#' @name tba_list_loinamesByloi
#' @export
tba_list_loinamesByloi <- function(apiPath, loi, appIdentifier) {
  
  # define config header
  h <- tba_configHeader(curl::new_handle(), appIdentifier)
  
  # request periods with a specific header
  resJSON <- tba_request(paste(apiPath, "config/query/loinames?loi=", loi, sep = ""), h)
  
  # wrangle loinames as tibble
  return(tibble::as_tibble(resJSON$lois$loinames))
  
}