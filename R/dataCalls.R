#' get data by local of interest
#'
#' @param apiPath path of terrabrasilis analytics server API
#' @param appIdentifier define the application identifier
#' @param class define the application identifier
#' @param loiname define the application identifier
#' 
#' @name get_dataByLocalOfInterest
#' @export
get_dataByLocalOfInterest <- function(apiPath, appIdentifier, class, loiname) {
  
  # define config header
  h <- dataHeader(curl::new_handle(), appIdentifier)
  
  # request locals of interests with a specific header
  resJSON <- request(paste(apiPath, "data/", class, "/", loiname, sep = ""), h)
  
  startDate <- resJSON$periods$startDate[1,]
  
  endDate <- resJSON$periods$endDate[1,]
  
  loi <- resJSON$periods$features[[1]]$loi
  
  loiname <- resJSON$periods$features[[1]]$loiname
  
  areas <- resJSON$periods$features[[1]]$areas
  
  finalDF <- cbind(loi = loi, 
                   loiname = loiname, 
                   startDate = startDate, 
                   endDate = endDate, 
                   areas,
                   row.names = NULL)
  
  # wrangle data by loiname as tibble
  return(finalDF)
  
}

#' get data by querying parameters
#'
#' @param apiPath a curl handle used to configure a request
#' @param appIdentifier defines the application identifier
#' @param class label to designate the classes
#' @param loiname  local of interest name
#' @param startDate initial date from the interval
#' @param endDate final date from the interval
#' 
#' @name get_dataByParameters
#' @export
get_dataByParameters <- function(apiPath, appIdentifier, class, loiname, startDate, endDate) {
  
  # define config header
  h <- configHeader(curl::new_handle(), appIdentifier)
  
  # request locals of interests with a specific header
  resJSON <- request(paste(apiPath, 
                           "data/query?class=", class, 
                           "&loiname=", loiname, 
                           "&startdate=", startDate, 
                           "&enddate=", endDate, sep = ""), h)
  
  startDate <- resJSON$periods$startDate[1,]
  
  endDate <- resJSON$periods$endDate[1,]
  
  loi <- resJSON$periods$features[[1]]$loi
  
  loiname <- resJSON$periods$features[[1]]$loiname
  
  areas <- resJSON$periods$features[[1]]$areas
  
  finalDF <- cbind(loi = loi, 
                   loiname = loiname, 
                   startDate = startDate, 
                   endDate = endDate, 
                   areas,
                   row.names = NULL)
  
  # wrangle data by parameters respose into tibble
  return(finalDF)
  
}