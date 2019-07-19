dataTransformJSON2tibble <- function(resJSON) {

  "%>%" <- magrittr::`%>%`
  # transform JSON request into tibble format
  resJSON2tibble <- resJSON %>%
    purrr::map_if(is.data.frame, list) %>%
    tibble::as_tibble()
  
  # extract areas from features with loi, loinames and filters
  features <- resJSON2tibble$periods[[1]]$features %>% 
    dplyr::bind_rows() %>% 
    dplyr::bind_cols() %>% 
    dplyr::select(utils::tail(names(.), 1)) %>% 
    tidyr::unnest()
  
  # extract startDate and endDate
  startDate <- resJSON2tibble$periods[[1]]$startDate
  endDate <- resJSON2tibble$periods[[1]]$endDate
  
  # obtain nro of filters 
  nrofilters <- nrow(resJSON2tibble$periods[[1]]$features[[1]]$areas[[1]])
  
  # repeat startDate and endDate parameters for each filter
  periods <- cbind(startDate = startDate[rep(1:nrow(startDate),
                                             each=nrofilters),], 
                   endDate = endDate[rep(1:nrow(endDate),
                                         each=nrofilters),], 
                   features)
  
  # format output result
  result <- resJSON2tibble %>% 
    dplyr::select(-dplyr::one_of("periods")) %>% 
    merge(periods)
  
  return(result);
  
}

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
  
  # transform JSON to tibble
  result <- dataTransformJSON2tibble(resJSON)
  
  # wrangle data by loiname as tibble
  return(result)
  
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
  
  # transform JSON to tibble
  result <- dataTransformJSON2tibble(resJSON)
  
  # wrangle data by parameters respose into tibble
  return(result)
  
}