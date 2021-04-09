#' transform json into tibble
#'
#' @param resJSON server response
#' 
#' @name dataTransformJSON2tibble
#' @export
dataTransformJSON2tibble <- function(resJSON) {

  "%>%" <- magrittr::`%>%`
  
  # transform JSON request into tibble format
  resJSON2tibble <- resJSON %>%
    purrr::map_if(is.data.frame, list) %>%
    tibble::as_tibble()
  
  # remove null elements
  features <- lapply(resJSON2tibble$periods[[1]]$features, function(x) { if(length(x) && nrow(x) != 0) return(x); })
  nrow_null <- if(length(features) && length(which(sapply(features, is.null))) != 0) which(sapply(features, is.null)) else -(1:length(features))
  
  features <- features[-nrow_null]

  # extract areas from features 
  areas <- features %>% 
    dplyr::bind_rows() %>% 
    dplyr::bind_cols() %>% 
    dplyr::select(utils::tail(names(.), 1)) %>% 
    tidyr::unnest()
  
  # extract lois from features 
  lois <- features %>% 
    dplyr::bind_cols() %>% 
    dplyr::select(utils::head(names(.), 2)) 
  
  names(lois) <- c("loi", "loiname")
  
  # merge lois and areas and build a new features
  features <- merge(lois, areas)
  
  # extract startDate and endDate
  startDate <- resJSON2tibble$periods[[1]]$startDate[-nrow_null,]
  endDate <- resJSON2tibble$periods[[1]]$endDate[-nrow_null,]
  
  # obtain nro of filters 
  nrofilters <- lapply(resJSON2tibble$periods[[1]]$features, function(x) {
    if(!length(x)) return(0) else return(nrow(x$areas[[1]]));
  })
  nrofilters <- unlist(nrofilters)
  nrofilters <- nrofilters[nrofilters!=0]
  if(!length(nrofilters)) nrofilters <- 0 else nrofilters <- max(nrofilters)
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
#' @param appIdentifier defines the application identifier
#' @param class label to designate the classes
#' @param loiname local of interest name
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
