# Example that can be used in jupyter notebook 

library(terrabrasilisAnalyticsAPI) # R package name is terrabrasilisAnalyticsAPI
library(dplyr)
library(ggplot2) 
options(warn=-1) 
options(scipen=999) # disable scientific notation

# Initialize Terrabrasilis Analytics API path variable
apiPath <- "https://terrabrasilis.dpi.inpe.br/dashboard/api/v1/redis-cli/"
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

#---------------------------------------
# Desmatamento acumulado por estados

# Users are able to filter loinames by one specific loi such as UF.
loiUF = dplyr::filter(locals, grepl("uf", name))$gid
loinamesByLoi <- list_localOfInterestByLocal(apiPath, prodesCerrado, loiUF)
loinamesByLoi

# get data from all loinames from one specific loi
all <- NULL
for (i in loinamesByLoi$gid) {
  cat(i, "\n")
  data <- get_dataByLocalOfInterest(apiPath = apiPath, appIdentifier = prodesCerrado, class = classes$name, loiname = i)
  #all <- rbind(all, data)
  all <- plyr::rbind.fill(all, data)
}
head(all)
# select all years different of 2000
allStd <- all[all$type == 2 & all$endDate.year > 2000,]

head(allStd)

aggregatedByState <- allStd %>% 
  dplyr::group_by(loiname) %>% 
  dplyr::summarise(aggregate = sum(area)) 

aggregatedByState
loinamesByLoi

aggregatedByState$loiname[match(aggregatedByState$loiname, loinamesByLoi$gid)] <- loinamesByLoi$loiname
aggregatedByState

# plot data set complete
ggplot(aggregatedByState, aes(x=factor(reorder(loiname, aggregate)), y=aggregate)) +
  geom_bar(stat='identity', width = 0.8, fill = "#008080", alpha = 0.9) +
  geom_text(aes(label=round(aggregate, 2)), vjust=0, hjust=-0.1) +
  coord_flip() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5)) +
  labs(x = "States") + labs(y = "Areas (km\u00B2)") +
  scale_y_continuous(expand=expansion(mult=c(0,0.10))) +
  labs(title = "Accumulated deforestation increments - by States")

#---------------------------------------
# Desmatamento acumulado por municípios

# Users are able to filter loinames by one specific loi such as UF.
loiMUN = dplyr::filter(locals, grepl("mun", name))$gid
loinamesByLoiM <- list_localOfInterestByLocal(apiPath, prodesCerrado, loiMUN)
loinamesByLoiM

# # get data from all loinames from one specific loi
# allM <- NULL
# for (i in loinamesByLoiM$gid) {
#   cat(i, "\n")
#   data <- get_dataByLocalOfInterest(apiPath = apiPath, appIdentifier = prodesCerrado, class = classes$name, loiname = i)
#   #all <- rbind(all, data)
#   allM <- plyr::rbind.fill(allM, data)
# }
# head(allM)

fillYears <- function(data1){
  for(i in 1:nrow(data1)){
    years_jump2 <- data1$startDate.year == data1$startDate.year[i]-1 & data1$endDate.year == data1$startDate.year[i]+1
    
    if (any(years_jump2)){
      
      data1$endDate.year[i] <- ifelse(is.na(data1$endDate.year[i]), data1$startDate.year[i]+1, data1$endDate.year[i])
      data1$loiname[i] <- ifelse(is.na(data1$loiname[i]) & any(years_jump2), data1$loiname[which(years_jump2)], data1$loiname[i])
      data1$area[i] <- ifelse(is.na(data1$area[i]) & any(years_jump2), data1$area[which(years_jump2)]/2, data1$area[i])
      
      idx <- which(years_jump2)
      data1$endDate.year[idx] <- ifelse(which(years_jump2) != 0, data1$endDate.year[idx]-1, data1$endDate.year[idx])
      data1$area[idx] <-ifelse(which(years_jump2) != 0, data1$area[idx]/2, data1$area[idx])  
    } else {
      data1[i,]
    }
  }
  return(data1)
}

fillGapYears <- function(data1){
  for(i in 1:nrow(data1)){
    
    if (any(is.na(data1[i,]))){
      
      data1$endDate.year[i] <- ifelse(is.na(data1$endDate.year[i]), data1$startDate.year[i]+1, data1$endDate.year[i])
      data1$loiname[i] <- unique(na.omit(data1$loiname, ))
      data1$area[i] <- 0.0
      
    } else {
      data1[i,]
    }
  }
  return(data1)
}

get_dataByMultipleLocalOfInterest_year <- function(apiPath, appIdentifier, class, loiname){
  
  allM <- NULL
  
  for (i in loiname$gid) {
    cat(i, "\n")
    data <- get_dataByLocalOfInterest(apiPath = apiPath, appIdentifier = prodesCerrado, class = classes$name, loiname = i) # loinamesByLoiM$gid[i] )
    data <- data[data$type == 2 & data$endDate.year > 2000,]
    
    if(any(data$endDate.year %in% c(2002, 2004, 2006, 2008, 2010, 2012)) == TRUE){
      years <- data$startDate.year[which(data$endDate.year <= 2012)]
      data1 <- tidyr::complete(data, name, clazz, startDate.year = years+1, startDate.month, startDate.day, endDate.month, endDate.day, loi, type)
      data1 <- fillYears(data1) %>% 
        dplyr::arrange(startDate.year)
      
      complete_period <- seq(2000, 2019, by=1)
      gap_years <- complete_period[ ! complete_period  %in%  data1$startDate.year]
      
      if(!identical(gap_years, numeric(0)) & length(gap_years) >= 0){
        data2 <- tidyr::complete(data1, name, clazz, startDate.year = gap_years, startDate.month, startDate.day, endDate.month, endDate.day, loi, type)
        data2 <- fillGapYears(data2) %>% 
          dplyr::arrange(startDate.year)
        allM <- plyr::rbind.fill(allM, data2)  
      } else {
        data2 <- data1
        allM <- plyr::rbind.fill(allM, data2)  
      }
    } else {
      data1 <- data
      allM <- plyr::rbind.fill(allM, data1)  
    }
  }
  return(allM)
}

allM <- get_dataByMultipleLocalOfInterest_year(apiPath = apiPath, appIdentifier = prodesCerrado, class = classes$name, loiname = loinamesByLoiM)

# # save result
# saveRDS(allM, file = "/home/user/github_projects/tbAnalyticsAPI_examples/allMunicipalities.Rds")
# open file
allM <- readRDS(file = "/home/user/github_projects/tbAnalyticsAPI_examples/allMunicipalities.Rds")

allMNames <- allM

allMNames$names <- loinamesByLoiM$loiname[match(allMNames$loiname, loinamesByLoiM$gid)]  
head(allMNames)

allM_names <-  allMNames %>% 
  tidyr::separate(names, into = c("muni","state"), sep = "_") 

write.table(allM_names, file = "/home/user/github_projects/tbAnalyticsAPI_examples/allMunicipalities.csv", 
            quote = FALSE, sep = ";", row.names = FALSE, col.names = TRUE, dec = ",")


#---------------------------------------
# Incrementos de desmatamento acumulado por municipios - top 2020
year <- 2020

aggregatedByMunic <- allMNames %>% 
  dplyr::group_by(names, endDate.year) %>% 
  dplyr::summarise(aggregate = sum(area), .groups = 'drop') %>% 
  dplyr::filter(endDate.year==year) %>% 
  dplyr::top_n(13, aggregate) %>% 
  dplyr::arrange(desc(aggregate))
  
head(aggregatedByMunic)

# plot data by municipalities - 2020
ggplot(aggregatedByMunic, aes(x=factor(reorder(names, aggregate)), y=aggregate)) +
  geom_bar(stat='identity', width = 0.8, fill = "#008080", alpha = 0.9) +
  geom_text(aes(label=round(aggregate, 2)), vjust=0, hjust=-0.1) +
  coord_flip() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5)) +
  labs(x = "Municipalities") + labs(y = "Areas (km\u00B2)") +
  scale_y_continuous(expand=expansion(mult=c(0,0.10))) +
  labs(title = paste0("Accumulated deforestation increments - Municipalities ", year, sep = ""))

#---------------------------------------
# Incrementos de desmatamento acumulado por municpios - agregado de todos os anos

aggregatedByMunicTop13 <- allMNames %>% 
  dplyr::group_by(names) %>% 
  dplyr::summarise(aggregate = sum(area)) %>% 
  dplyr::top_n(13, aggregate) %>% 
  dplyr::arrange(desc(aggregate))

# plot data by municipalities - 2020
ggplot(aggregatedByMunicTop13, aes(x=factor(reorder(names, aggregate)), y=aggregate)) +
  geom_bar(stat='identity', width = 0.8, fill = "#008080", alpha = 0.9) +
  geom_text(aes(label=round(aggregate, 2)), vjust=0, hjust=-0.1) +
  coord_flip() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5)) +
  labs(x = "Municipalities") + labs(y = "Areas (km\u00B2)") +
  scale_y_continuous(expand=expansion(mult=c(0,0.10))) +
  labs(title = "Accumulated deforestation increments all years - Municipalities")

#---------------------------------------
# Incrementos de desmatamento acumulado por municípios - estado específico

state_n <- "MATO GROSSO" # SÃO PAULO

aggregatedByMunicTop13byState <- allMNames %>% 
  tidyr::separate(names, into = c("muni","state"), sep = "_") %>% 
  dplyr::filter(state==state_n) %>% 
  dplyr::group_by(muni) %>% 
  dplyr::summarise(aggregate = sum(area)) %>% 
  dplyr::top_n(13, aggregate) %>% 
  dplyr::arrange(desc(aggregate))

aggregatedByMunicTop13byState

# plot data by municipalities - 2020
ggplot(aggregatedByMunicTop13byState, aes(x=factor(reorder(muni, aggregate)), y=aggregate)) +
  geom_bar(stat='identity', width = 0.8, fill = "#008080", alpha = 0.9) +
  geom_text(aes(label=round(aggregate, 2)), vjust=0, hjust=-0.1) +
  coord_flip() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5)) +
  labs(x = "Municipalities") + labs(y = "Areas (km\u00B2)") +
  scale_y_continuous(expand=expansion(mult=c(0,0.10))) +
  labs(title = paste0("Accumulated deforestation increments - Municipalities - ", state_n, sep=""))

#---------------------------------------
# Incrementos de desmatamento acumulado por municípios - estado específico e ano específico

state_n <- "SÃO PAULO" # MATO GROSSO
year <- 2020

aggregatedByMunicTop13byState <- allMNames %>% 
  tidyr::separate(names, into = c("muni","state"), sep = "_") %>% 
  dplyr::filter(state==state_n) %>% 
  dplyr::group_by(muni) %>% 
  dplyr::filter(endDate.year==year) %>% 
  dplyr::summarise(aggregate = sum(area)) %>% 
  dplyr::top_n(13, aggregate) %>% 
  dplyr::arrange(desc(aggregate))

aggregatedByMunicTop13byState

# plot data by municipalities - 2020
ggplot(aggregatedByMunicTop13byState, aes(x=factor(reorder(muni, aggregate)), y=aggregate)) +
  geom_bar(stat='identity', width = 0.8, fill = "#008080", alpha = 0.9) +
  geom_text(aes(label=round(aggregate, 2)), vjust=0, hjust=-0.1) +
  coord_flip() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5)) +
  labs(x = "Municipalities") + labs(y = "Areas (km\u00B2)") +
  scale_y_continuous(expand=expansion(mult=c(0,0.10))) +
  labs(title = paste0("Accumulated deforestation increments - Municipalities -\n", 
                      state_n, " - ", year, sep=""))

#---------------------------------------
# Incrementos de desmatamento acumulado por municípios - município específico

muni_n <- "BALSAS"# SANTA LÚCIA,FORMOSA DO RIO PRETO, 2468 ADELÂNDIA, PONTO CHIQUE, 2850 CRIXÁS

aggregatedByMunicAllYears <- allMNames %>% 
  tidyr::separate(names, into = c("muni","state"), sep = "_") %>% 
  dplyr::filter(muni==muni_n) %>% 
  #dplyr::filter(endDate.year>=2013) %>% 
  dplyr::group_by(muni) 

head(aggregatedByMunicAllYears)

# plot data by municipalities - 2020
ggplot(aggregatedByMunicAllYears, aes(x=as.factor(endDate.year), end, y=area)) +
  geom_bar(stat='identity', width = 0.8, fill = "#008080", alpha = 0.9) +
  geom_text(aes(label=round(area, 2)), vjust=-0.3, hjust=0.5, size = 4) +
  #geom_text(aes(label=round(area, 2)), vjust=0, hjust=0) +
  #coord_flip() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5)) +
  labs(x = "Years") + labs(y = "Areas (km\u00B2)") +
  scale_y_continuous(expand=expansion(mult=c(0,0.10))) +
  labs(title = paste0("Accumulated deforestation increments - Municipalities -\n", muni_n, " - ", 
                      aggregatedByMunicAllYears$state, sep=" "))




