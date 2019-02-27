#' list data by loiname
#'
#' @param apiPath path of terrabrasilis analytics server API
#' @param appIdentifier define the application identifier
#' @param class define the application identifier
#' @param loiname define the application identifier
#' 
#' @name tba_get_dataByLoiname
#' @export
tba_get_dataByLoiname <- function(apiPath, appIdentifier, class, loiname) {
  
  # define config header
  h <- tba_dataHeader(curl::new_handle(), appIdentifier)
  
  # request locals of interests with a specific header
  resJSON <- tba_request(paste(apiPath, "data/", class, "/", loiname, sep = ""), h)
  
  # wrangle data by loiname as tibble
  return(resJSON)
  
}

#' list data by querying parameters
#'
#' @param apiPath a curl handle used to configure a request
#' @param appIdentifier defines the application identifier
#' @param class label to designate the classes
#' @param loiname  local of interest name
#' @param startDate initial date from the interval
#' @param endDate final date from the interval
#' 
#' @name tba_get_dataByParameters
#' @export
tba_get_dataByParameters <- function(apiPath, appIdentifier, class, loiname, startDate, endDate) {
  
  # define config header
  h <- tba_configHeader(curl::new_handle(), appIdentifier)
  
  # request locals of interests with a specific header
  resJSON <- tba_request(paste(apiPath, 
                               "data/query?class=", class, 
                               "&loiname=", loiname, 
                               "&startdate=", startDate, 
                               "&enddate=", endDate, sep = ""), h)
  
  # wrangle data by parameters respose into tibble
  return(resJSON)
  
}