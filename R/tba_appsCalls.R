#' set header for configs
#'
#' @param apiPath a curl handle used to configure a request
#' 
#' @name tba_list_apps_identifier
#' @export
tba_list_apps_identifier <- function(apiPath) {
  
  h <- tba_appsHeader(curl::new_handle())
  
  resJSON <- tba_request(paste(apiPath, "apps/identifier", sep = ""), h)
  
  return(resJSON)
  
}