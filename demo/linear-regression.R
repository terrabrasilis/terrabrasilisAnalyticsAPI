# installing and loading packages
require(terrabrasilisAnalyticsAPI)
library(dplyr)
library(purrr)
library(ggplot2)
library(gridExtra)
library(grid)

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
localOfInterestByLocal <- list_localOfInterestByLocal(apiPath, prodesCerrado, locals$gid[1])

# list classes
classes <- list_classes(apiPath, prodesCerrado)

# create tibble data for request input
data <- tibble(path = apiPath, 
               dataset = prodesCerrado, 
               class = classes$name, 
               local = localOfInterestByLocal$gid)

# get data from all loinames from one specific loi
myfn <- function(var1, var2, var3, var4) { 
  data <- get_dataByLocalOfInterest(apiPath = var1, 
                                    appIdentifier = var2, 
                                    class = var3,
                                    loiname = var4)
  return(list(data))
}

result <- data %>%
  rowwise() %>%
  mutate(t = myfn(path, dataset, class, local))


# update loop of ggplot for new API signature
plot_group <- function(df) {
  title = localOfInterestByLocal[which(localOfInterestByLocal$gid == unique(df$loiname)), ]$loiname
  plot_object <-
    ggplot(df, aes(x = startDate.year, y = area)) +
    geom_line(aes(colour = factor(type))) + 
    geom_smooth(method = "lm") + 
    scale_colour_manual(values = c("red", "blue"),
                        name="Area Filtering:",
                        labels=c("> 6.25ha", "> 1.00ha")) +
    labs(title=title,
         x ="Year", 
         y = "Area in Km") +
    theme(legend.position="top")
  return(plot_object)
}

df <- lapply(result$t, plot_group)

grid.arrange(
  df[[1]],
  df[[2]],
  df[[3]],
  df[[4]],
  df[[5]],
  df[[6]],
  df[[7]],
  df[[8]],
  df[[13]],
  df[[10]],
  df[[11]],
  df[[12]],
  nrow = 4,
  top = "Deforestation Data in Cerrado Biome"
)
