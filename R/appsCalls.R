#' set header for configs
#'
#' @param apiPath a curl handle used to configure a request
#' 
#' @name list_datasets
#' @export
list_datasets <- function(apiPath) {
  
  h <- appsHeader(curl::new_handle())
  
  resJSON <- request(paste(apiPath, "apps/identifier", sep = ""), h)
  
  datasets <- resJSON$identifier
  
  return(datasets)
  
}