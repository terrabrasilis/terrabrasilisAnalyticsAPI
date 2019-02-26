#' set header for configs
#'
#' @param apiPath a curl handle used to configure a request
#' @param appIdentifier define the application identifier
#' 
#' @name tba_list_apps_identifier
#' @export
tba_list_apps_identifier <- function(apiPath, appIdentifier) {
  
  h <- tba_configHeader(curl::new_handle)
  
  resJSON <- tba_request(paste(apiPath, "apps/identifier", sep = ""))
  
}