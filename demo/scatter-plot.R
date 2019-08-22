library(ggplot2)
library(viridis)
library(tidyverse)
library(dplyr)
library(ggpubr)

# installing and loading packages
require(terrabrasilisAnalyticsAPI)
library(dplyr)
library(MASS)
library(ggplot2)

# define path for Terrabrasilis Analytics API
apiPath <- "http://terrabrasilis.dpi.inpe.br/dashboard/api/v1/redis-cli/"

# get all the application identifier
appIdentifier <- list_datasets(apiPath)

# define PRODES Legal Amazon variable
prodesLegalAmazon <- appIdentifier[1]

# list periods
periods <- list_periods(apiPath, prodesLegalAmazon)

# list locals
locals <- list_locals(apiPath, prodesLegalAmazon)

# list local of interests from first local
localOfInterestByLocal <- list_localOfInterestByLocal(apiPath, prodesLegalAmazon, locals$gid[4])

# list classes
classes <- list_classes(apiPath, prodesLegalAmazon)

# list filters
filters <- list_filters(apiPath, prodesLegalAmazon)

# get data from all loinames from one specific loi  
all <- tibble()
for (i in localOfInterestByLocal$gid) {
  cat(i, "\n")
  data <- get_dataByLocalOfInterest(apiPath = apiPath, 
                                    appIdentifier = prodesLegalAmazon, 
                                    class = classes$name,
                                    loiname = i)
  all <- rbind(all, data)
}

f625 <- all[all$type == 1,]

# TODO: analysis indigeneous areas and conservation units
