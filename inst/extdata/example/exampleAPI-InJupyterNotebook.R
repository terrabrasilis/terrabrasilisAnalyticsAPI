# Example that can be used in jupyter notebook

# Installing and loading terrabrasilisAnalyticsAPI package in R
# devtools::install_github("terrabrasilis/terrabrasilisAnalyticsAPI") # github group name is terrabrasilis
# install.packages("vctrs")
library(terrabrasilisAnalyticsAPI) # R package name is terrabrasilisAnalyticsAPI
library(dplyr)
library(ggplot2) 
options(warn=-1) 
options(scipen=999) # disable scientific notation

# Initialize Terrabrasilis Analytics API path variable
apiPath <- "http://terrabrasilis.dpi.inpe.br/dashboard/api/v1/redis-cli/"
apiPath

# Define calls for application identifiers listing. From that information, it is possible then to make specific requests to other API end-points.
appIdentifier <- list_datasets(apiPath)
appIdentifier

# With that in mind, let's create a prodesCerrado variable.
prodesCerrado <- appIdentifier[1]
prodesCerrado

# The first question that reminds us to ask to the API is: which periods do Prodes Cerrado contains?
periods <- list_periods(apiPath, prodesCerrado)
periods

# Users can also ask to the API, for example, which classes do PRODES Cerrado contains?
classes <- list_classes(apiPath, prodesCerrado)
classes

# In this case, it is just one class designating deforestation label. Other thematic mapping projects, however, would contain more than one class or even the same class name.
# Besides responding which classes and periods, users might ask which local of interests (lois) as states, municipalities, conservation units, indigeneous areas, and Landsat Path/Row, the API provides. 
locals <- list_locals(apiPath, prodesCerrado)
locals

# Nevertheless, locals are not considered the final granularity since each state, municipality, conservation unit, indigeneous areas, and Landsat Path/Row also contain small-scale local of interests.
localOfInterest <- list_local_of_interests(apiPath, prodesCerrado)
localOfInterest[450:458,] # select lines from 45 to 60

# Users are able to filter loinames by one specific loi such as UF.
loiUF = dplyr::filter(locals, grepl("uf", name))$gid
loinamesByLoi <- list_localOfInterestByLocal(apiPath, prodesCerrado, loiUF)
loinamesByLoi

# In order to fit data into governmental needs, we also considered filters for each data recognized that as type in the data API call.
filters <- list_filters(apiPath, prodesCerrado)
filters

# All this data is used to gather specific thematic map area values produced by government agencies such as the National Institute for Space Research. In this example, users are able to acquire data by loiname, that is, the function accepts as parameters, the class name and loiname gid as well.
loinamesByLoi[10,] # loiname - Sao Paulo 
data <- get_dataByLocalOfInterest(apiPath, prodesCerrado, classes$name, loinamesByLoi[10,]$gid) %>% 
  dplyr::filter(.,type==2) %>% 
  dplyr::filter(.,endDate.year!=2000) %>% 
  dplyr::select(name, clazz, endDate.year, area)
tail(data)

f1 <- data
ggplot(f1, aes(x=as.factor(endDate.year), y=area, fill=clazz)) + 
  geom_text(aes(label=as.numeric(round(f1$area, 2))), vjust=-0.5, hjust=0.3, size = 3) + # angle = 75,
  geom_bar(stat = "identity", width = 0.8, fill = "#008080") +
  scale_x_discrete("Year", labels = as.character(f1$endDate.year), breaks = f1$endDate.year) +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5)) +
  labs(colour = "Date") + labs(x = "Years") + labs(y = "Areas (km\u00B2)") + 
  labs(title = loinamesByLoi[10,]$loiname) + labs(fill = "class")

# The same query can be performed using get data by parameters function. In this case, users pass also as parameters a start and end data. Unlikely the previous call, users will not receive all the available timeline as soon as they really desire.
data1 <- get_dataByParameters(apiPath, prodesCerrado, classes$name, loinamesByLoi[10,]$gid, "2015-01-01", "2020-12-31") %>% 
  dplyr::filter(.,type==2) %>% 
  dplyr::filter(.,endDate.year!=2000) %>% 
  dplyr::select(name, clazz, startDate.year, endDate.year, area)

data1

f11=data1
ggplot(f11, aes(x=as.factor(endDate.year), y=area, fill=clazz)) + 
  geom_text(aes(label=as.numeric(round(f11$area, 2))), vjust=-0.5, hjust=0.3, size = 4) +
  geom_bar(stat = "identity", width = 0.8, fill = "#008080") +
  scale_x_discrete("Year", labels = as.character(f11$endDate.year), breaks = f11$endDate.year) +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5)) +
  labs(colour = "Date") + labs(x = "Years") + labs(y = "Areas (km\u00B2)") + 
  labs(title = loinamesByLoi[10,]$loiname) + labs(fill = "class")

# Compare with SAO PAULO http://www.terrabrasilis.dpi.inpe.br/app/dashboard/deforestation/biomes/cerrado/increments




# In these examples, users are able to acquire data for all loinames, for this, each loiname was mapped

# get data from all loinames from one specific loi
all <- NULL
for (i in loinamesByLoi$gid) {
  cat(i, "\n")
  data <- get_dataByLocalOfInterest(apiPath = apiPath, appIdentifier = prodesCerrado, class = classes$name, loiname = i)
  #all <- rbind(all, data)
  all <- plyr::rbind.fill(all, data)
}
head(all)

# define own colors
myCol = c("pink1", "violet", "slateblue1", "purple", "turquoise4", "skyblue", "steelblue", 
          "orange", "red2", "yellowgreen", "tan3", "brown", "grey30")

# select all years different of 2000
allStd <- all[all$type == 2 & all$endDate.year != 2000,]

# define names in legend
legendNames <- unique(factor(allStd$loiname))
names(legendNames) <- loinamesByLoi$loiname

# plot data set by states
ggplot(allStd, aes(x=as.factor(endDate.year), y=area, fill=factor(loiname))) + 
  geom_bar(stat = "identity", width = 0.8) +
  scale_x_discrete("Year", labels = as.character(allStd$endDate.year), 
                   breaks = allStd$endDate.year) +
  scale_fill_manual(values=myCol, labels = names(legendNames)) +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5)) +
  labs(colour = "Date") + labs(x = "Years") + labs(y = "Areas (km\u00B2)") + 
  labs(title = "Deforestation by states") + labs(fill = "classes")


# plot data set complete
ggplot(allStd, aes(x=factor(reorder(endDate.year, loiname)), y=area)) +  # , fill=clazz  
  geom_bar(stat = "identity", width = 0.9, fill = "#008080", alpha = 0.9) +
  stat_summary(
    aes(label = stat(round(y, 2))), fun.y = 'sum', geom = 'text', col = 'white', vjust = 1.5
  ) + 
  scale_x_discrete("Year", labels = as.character(allStd$endDate.year), 
                   breaks = allStd$endDate.year) +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5)) +
  labs(colour = "Date") + labs(x = "Years") + labs(y = "Areas (km\u00B2)") +
  labs(title = "Deforestation") #+ labs(fill = "classes")


state_names <- c("1185" = "BAHIA", "1186" = "DISTRITO FEDERAL", "1187" = "GOIÁS", "1188" = "MARANHÃO",
                 "1189" = "MATO GROSSO", "1190" = "MATO GROSSO DO SUL", "1191" = "MINAS GERAIS", 
                 "1192" = "PARÁ", "1193" = "PIAUÍ", "1194" = "SÃO PAULO", "1195" = "TOCANTINS",
                 "1196" = "PARANÁ", "1197" = "RONDÔNIA")

# plot data set - With grid or wrap
ggplot(allStd, aes(x=as.factor(endDate.year), y=area, fill=factor(loiname))) + #
  geom_bar(stat = "identity", width = 0.8) + # , fill = "#008080"
  facet_wrap(loiname ~ ., ncol = 7, labeller = as_labeller(state_names)) +
  scale_x_discrete("Year", labels = as.character(allStd$endDate.year), 
                   breaks = allStd$endDate.year) +
  scale_fill_manual(values=myCol, labels = names(legendNames)) +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5), legend.position="none") +
  labs(colour = "Date") + labs(x = "Years") + labs(y = "Areas (km\u00B2)") + 
  labs(title = "Deforestation by states") + labs(fill = "classes")


# Shape of the deforestation areas in Cerrado municipalities (center point and variability)
ggplot(allStd, aes(x=as.factor(endDate.year), y=area, color=endDate.year, group=endDate.year)) + 
  geom_boxplot(outlier.shape = NA) +
  scale_x_discrete("Year", labels = as.character(allStd$endDate.year), 
                   breaks = allStd$endDate.year) +
  scale_y_continuous(limits = quantile(all$area, c(0.1, 0.9))) +
  expand_limits(y=25) + 
  labs(colour = "Date") + labs(x = "Years") + labs(y = "Areas (km\u00B2)") +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5))







