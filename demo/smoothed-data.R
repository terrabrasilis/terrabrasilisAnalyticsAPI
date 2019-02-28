# installing and loading packages
require(lubridate)
require(ggplot2)

# define path for Terrabrasilis Analytics API
tbaAPIPath <- "http://terrabrasilis.dpi.inpe.br/dashboard/api/v1/redis-cli/"

# get all the application identifier
appIdentifier <- tba_list_apps_identifier(tbaAPIPath)

# define PRODES Cerrado variable
prodesCerrado <- appIdentifier$identifier[1]

# get all loinames from states (UF)
loiUF = dplyr::filter(lois, grepl("UF", name))$gid
loinamesByLoi <- tba_list_loinamesByLoi(tbaAPIPath, appIdentifier$identifier[1], loiUF)

# get all data by loiname
data <- tba_get_dataByLoiname(tbaAPIPath, prodesCerrado, classes$name, "all")

# assign start date
startDate <- data$periods$startDate

# assign end date
endDate <- data$periods$endDate

# TO DO: update loop of ggplot for new API signature