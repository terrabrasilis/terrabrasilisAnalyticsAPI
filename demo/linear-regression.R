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

# define PRODES Amazon variable
prodesAmazon <- appIdentifier[2]

# list periods
periods <- list_periods(apiPath, prodesAmazon)
  
# list locals
locals <- list_locals(apiPath, prodesAmazon)

# list local of interests from first local
localOfInterestByLocal <- list_localOfInterestByLocal(apiPath, prodesAmazon, locals$gid[1])

# list classes
classes <- list_classes(apiPath, prodesAmazon)

# create tibble data for request input
data <- tibble(path = apiPath, 
               dataset = prodesAmazon, 
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
  df[[9]],
  nrow = 3,
  top = "Deforestation Data in Amazon Biome"
  #bottom = textGrob(
  #  "this footnote is right-justified",
  #  gp = gpar(fontface = 3, fontsize = 9),
  #  hjust = 1,
  #  x = 1
  #)
)


