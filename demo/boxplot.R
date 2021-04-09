# installing and loading packages
require(terrabrasilisAnalyticsAPI)
library(dplyr)
library(ggplot2)

# define path for Terrabrasilis Analytics API
apiPath <- "http://terrabrasilis.dpi.inpe.br/dashboard/api/v1/redis-cli/"

# get all the application identifier
appIdentifier <- list_datasets(apiPath)

# define PRODES Cerrado variable
prodesCerrado <- appIdentifier[1]

# list periods
periods <- list_periods(apiPath, prodesCerrado)
  
# list locals
locals <- list_locals(apiPath, prodesCerrado)

# list local of interests from first local
localOfInterestByLocal <- list_localOfInterestByLocal(apiPath, prodesCerrado, locals$gid[2])

# list classes
classes <- list_classes(apiPath, prodesCerrado)

# list filters
filters <- list_filters(apiPath, prodesCerrado)

# get data from all loinames from one specific loi
all <- tibble()
for (i in localOfInterestByLocal$gid) {
  cat(i, "\n")
  data <- get_dataByLocalOfInterest(apiPath = apiPath, 
                                    appIdentifier = prodesCerrado, 
                                    class = classes$name,
                                    loiname = i)
  all <- rbind(all, data)
}

f625 <- all[all$type == 1,]


ggplot(f625, aes(x=endDate.year, y=area, color=endDate.year, group=endDate.year)) + 
  geom_boxplot(outlier.shape = NA) +
  scale_y_continuous(limits = quantile(all$area, c(0.1, 0.9))) +
  expand_limits(y=25) + 
  labs(colour = "Date") + labs(x = "Years") + labs(y = "Areas km\u00B2") +
  theme(text = element_text(size=28))



