#' list all local of interest names
#'
#' @param apiPath path of terrabrasilis analytics server API
#' @param appIdentifier define the application identifier
#' 
#' @name list_local_of_interests
#' @export
list_local_of_interests <- function(apiPath, appIdentifier) {

  # define config header
  h <- configHeader(curl::new_handle(), appIdentifier)

  # request locals of interests with a specific header
  resJSON <- request(paste(apiPath, "config/loinames", sep = ""), h)
  
  # format lois dataframes for loinames rows 
  resTibble <- dplyr::bind_rows(resJSON$lois$loinames)
  
  # initialize loi column
  resTibble <- cbind(resTibble, loi = 0)
  count <- 1
  
  # for each loi binds a new set of values
  for (i in 1:length(resJSON$lois$gid)) {
    size <- nrow(resJSON$lois$loinames[[i]])
    resTibble[,"loi"][count:(count+size-1)] <- rep(resJSON$lois$gid[i], size)
    count = count + size
  }
  
  # wrangle loinames as tibble
  return(tibble::as_tibble(resTibble))

}

#' list all filters
#'
#' @param apiPath path of terrabrasilis analytics server API
#' @param appIdentifier define the application identifier
#' 
#' @name list_filters
#' @export
list_filters <- function(apiPath, appIdentifier) {

  # define config header
  h <- configHeader(curl::new_handle(), appIdentifier)

  # request locals of interests with a specific header
  resJSON <- request(paste(apiPath, "config/filters", sep = ""), h)
  
  # wrangle filters as tibble
  return(tibble::as_tibble(resJSON$filters))

}

#' list all locals
#'
#' @param apiPath a curl handle used to configure a request
#' @param appIdentifier define the application identifier
#' 
#' @name list_locals
#' @export
list_locals <- function(apiPath, appIdentifier) {

  # define config header
  h <- configHeader(curl::new_handle(), appIdentifier)

  # request locals of interests with a specific header
  resJSON <- request(paste(apiPath, "config/lois", sep = ""), h)
  
  # order table by locals of interests
  resJSON$lois <- resJSON$lois[order(resJSON$lois$gid),] 
  
  # wrangle lois as tibble
  return(tibble::as_tibble(resJSON$lois[,1:2]))

}

#' list all classes
#'
#' @param apiPath path of terrabrasilis analytics server API
#' @param appIdentifier define the application identifier
#' 
#' @name list_classes
#' @export
list_classes <- function(apiPath, appIdentifier) {

  # define config header
  h <- configHeader(curl::new_handle(), appIdentifier)

  # request classes with a specific header
  resJSON <- request(paste(apiPath, "config/classes", sep = ""), h)
  
  # wrangle classes as tibble
  return(tibble::as_tibble(resJSON$classes))

}

#' list all periods
#'
#' @param apiPath path of terrabrasilis analytics server API
#' @param appIdentifier define the application identifier
#' 
#' @name list_periods
#' @export
list_periods <- function(apiPath, appIdentifier) {

  # define config header
  h <- configHeader(curl::new_handle(), appIdentifier)

  # request periods with a specific header
  resJSON <- request(paste(apiPath, "config/periods", sep = ""), h)
  
  # wrangle start and end date periods into one
  return(tibble::as_tibble(cbind(startDate = resJSON$periods$startDate, 
                                 endDate = resJSON$periods$endDate)))

}

#' list all loinames by loi
#'
#' @param apiPath path of terrabrasilis analytics server API
#' @param appIdentifier define the application identifier
#' @param loi define type of local of interest
#'  
#' @name list_localOfInterestByLocal
#' @export
list_localOfInterestByLocal <- function(apiPath, appIdentifier, loi) {
  
  # define config header
  h <- configHeader(curl::new_handle(), appIdentifier)
  
  # request periods with a specific header
  resJSON <- request(paste(apiPath, "config/query/loinames?loi=", loi, sep = ""), h)
  
  # wrangle loinames as tibble
  return(tibble::as_tibble(resJSON$lois$loinames[[1]]))
  
}