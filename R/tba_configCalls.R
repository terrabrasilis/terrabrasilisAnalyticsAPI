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
  h <- tba_configHeader(curl::new_handle, appIdentifier)

  resJSON <- tba_request(paste(apiPath, "/config/query/loinames", sep = ""), h)

}

#' list all loinames
#'
#' @param apiPath path of terrabrasilis analytics server API
#' @param appIdentifier define the application identifier
#' 
#' @name tba_list_loinames
#' @export
tba_list_loinames <- function(apiPath, appIdentifier) {

  # define config header
  h <- tba_configHeader(curl::new_handle, appIdentifier)

  resJSON <- tba_request(paste(apiPath, "/config/loinames", sep = ""), h)

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
  h <- tba_configHeader(curl::new_handle, appIdentifier)

  resJSON <- tba_request(paste(apiPath, "/config/filters", sep = ""), h)

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
  h <- tba_configHeader(curl::new_handle, appIdentifier)

  resJSON <- tba_request(paste(apiPath, "/config/lois", sep = ""), h)

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
  h <- tba_configHeader(curl::new_handle, appIdentifier)

  resJSON <- tba_request(paste(apiPath, "/config/classes", sep = ""), h)

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
  h <- tba_configHeader(curl::new_handle, appIdentifier)

  resJSON <- tba_request(paste(apiPath, "/config/periods", sep = ""), h)

}