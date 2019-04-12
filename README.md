# R Client Terrabrasilis Analytics API

**terrabrasilisAnalyticsAPI** is an R client package for Terrabrasilis Analytics API. 

## Getting started

Installing and loading terrabrasilisAnalyticsAPI package in R

``` r
devtools::install_github("terrabrasilis/terrabrasilisAnalyticsAPI") # github group name is terrabrasilis
library(terrabrasilisAnalyticsAPI) # R package name is terrabrasilisAnalyticsAPI
```

Initialize Terrabrasilis Analytics API path variable

``` r 
tbaAPIPath <- "http://terrabrasilis.dpi.inpe.br/dashboard/api/v1/redis-cli/"
```

Define calls for application identifiers listing. From that information, it is possible then to make specific requests to other API end-points.

``` r
appIdentifier <- tba_list_apps_identifier(tbaAPIPath)
```

``` r
           identifier                                               name          created
1      prodes_cerrado             Dashboard of the Prodes in the Cerrado 2019-03-20 23:30
2       prodes_amazon       Dashboard of the Prodes in the Amazon Forest 2019-03-20 23:30
3 prodes_legal_amazon Dashboard of the Prodes in the Legal Amazon Forest 2019-03-20 23:37
```

With that in mind, let's create a prodesCerrado variable.

``` r
prodesCerrado <- appIdentifier$identifier[1]
```

The first question that reminds us to ask to the API is: which periods do Prodes Cerrado contains? 

``` r
periods <- tba_list_periods(tbaAPIPath, prodesCerrado)

periods
```

``` r
# A tibble: 12 x 6
   startDate.year startDate.month startDate.day endDate.year endDate.month endDate.day
 *          <int>           <int>         <int>        <int>         <int>       <int>
 1           1988               8             1         2000             7          31
 2           2000               8             1         2002             7          31
 3           2002               8             1         2004             7          31
 4           2004               8             1         2006             7          31
 5           2006               8             1         2008             7          31
 6           2008               8             1         2010             7          31
 7           2010               8             1         2012             7          31
 8           2012               8             1         2013             7          31
 9           2013               8             1         2014             7          31
10           2014               8             1         2015             7          31
11           2015               8             1         2016             7          31
12           2016               8             1         2017             7          31
13           2017               8             1         2018             7          31
```

Users can also ask to the API, for example, which classes do PRODES Cerrado contains?

```r
classes <- tba_list_classes(tbaAPIPath, prodesCerrado)

classes
```

In this case, it is just one class designating deforestation label. Other thematic mapping projects, however, would contain more than one class or even the same class name.

```r
# A tibble: 1 x 3
     id name          description                                                         
* <int> <chr>         <chr>                                                               
1     1 deforestation It is the process of complete and permanent disappearance of forests
```

Besides responding which classes and periods, users might ask which local of interests (lois) as states, municipalities, conservation units, indigeneous areas, and Landsat Path/Row, the API provides. 

```r
lois <- tba_list_lois(tbaAPIPath, prodesCerrado)

lois
```

```r
# A tibble: 5 x 2
    gid name    
  <int> <chr>   
1     1 UF      
2     3 ConsUnit
3     4 Indi    
4     2 MUN     
5     5 Pathrow 
```
Nevertheless, lois are not considered the final granularity since each state, municipality, conservation unit, indigeneous areas, and Landsat Path/Row also contains small-scale local of interests, also known here as local of interests names (loinames).

```r
loinames <- tba_list_loinames(tbaAPIPath, prodesCerrado)

loinames[20:30,]
```

```r
# A tibble: 11 x 3
     gid loiname                                                               loi
   <int> <chr>                                                               <dbl>
 1  1481 PARQUE ESTADUAL SERRA VERDE                                             3
 2  1566 RESERVA PARTICULAR DO PATRIMÔNIO NATURAL JOAQUIM THEODORO DE MORAES     3
 3  1567 PARQUE ESTADUAL DE VASSUNUNGA                                           3
 4  1404 ESTAÇÃO ECOLÓGICA ITABERÁ                                               3
 5  1421 ÁREA DE PROTEÇÃO AMBIENTAL LAGO DE PEIXE/ANGICAL                        3
 6  1405 ÁREA DE PROTEÇÃO AMBIENTAL DO SALTO MAGESSI                             3
 7  1446 ESTAçãO ECOLóGICA DE SANTA BáRBARA                                      3
 8  1603 RESERVA DE DESENVOLVIMENTO SUSTENTáVEL NASCENTES GERAIZEIRAS            3
 9  1649 RESERVA EXTRATIVISTA EXTREMO NORTE DO TOCANTINS                         3
10  1626 RESERVA BIOLÓGICA DA CONTAGEM                                           3
11  1658 RESERVA PARTICULAR DO PATRIMÔNIO NATURAL PONTE DE PEDRA                 3
```

Users are able to filter loinames by one specific loi such as UF.

```r
loiUF = dplyr::filter(lois, grepl("UF", name))$gid

loinamesByLoi <- tba_list_loinamesByLoi(tbaAPIPath, prodesCerrado, loiUF)

loinamesByLoi
```

```r
# A tibble: 13 x 2
     gid loiname           
   <int> <chr>             
 1    11 TOCANTINS         
 2     7 MINAS GERAIS      
 3    10 SÃO PAULO         
 4     9 PIAUÍ             
 5    12 PARANÁ            
 6    13 RONDÔNIA          
 7     4 MARANHÃO          
 8     5 MATO GROSSO       
 9     2 DISTRITO FEDERAL  
10     1 BAHIA             
11     3 GOIÁS             
12     6 MATO GROSSO DO SUL
13     8 PARÁ  
```

In order to fit data into governmental needs, we also considered filters for each data recognized that as type in the data API call.

```r
datafilters <- tba_list_filters(tbaAPIPath, prodesCerrado)

datafilters
```

```r
# A tibble: 2 x 2
     id type              
  <int> <chr>             
1     1 fid_area >= 0.0625
2     2 fid_area >= 0.01  
```

All this data is used to gather specific thematic map area values produced by government agencies such as the National Institute for Space Research. In this example, users are able to acquire data by loiname, that is, the function accepts as parameters, the class name and loiname gid as well.

```r
data <- tba_get_dataByLoiname(tbaAPIPath, prodesCerrado, classes$name, loinamesByLoi[1,]$gid)

startDate <- data$periods$startDate[1,]

endDate <- data$periods$endDate[1,]

loi <- data$periods$features[[1]]$loi

loiname <- data$periods$features[[1]]$loiname

areas <- data$periods$features[[1]]$areas

finalDF <- cbind(loi = loi, 
                 loiname = loiname, 
                 startDate = startDate, 
                 endDate = endDate, 
                 areas,
                 row.names = NULL)

finalDF
```

```r
  loi loiname startDate.year startDate.month startDate.day endDate.year endDate.month endDate.day type
1   1      11           1988               8             1         2000             7          31    1
2   1      11           1988               8             1         2000             7          31    2
      area
1 38003.72
2 38286.16
> 
```

The same query can be performed using get data by parameters function. In this case, users pass also as parameters a start and end data. Unlikely the previous call, users will not receive all the available timeline as soon as they really desire.

```r
data <- tba_get_dataByParameters(tbaAPIPath, prodesCerrado, classes$name, loinames[1,]$gid, "1988-01-01", "2001-01-01")

startDate <- data$periods$startDate[1,]

endDate <- data$periods$endDate[1,]

loi <- data$periods$features[[1]]$loi

loiname <- data$periods$features[[1]]$loiname

areas <- data$periods$features[[1]]$areas

finalDF <- cbind(loi = loi, 
                 loiname = loiname, 
                 startDate = startDate, 
                 endDate = endDate, 
                 areas,
                 row.names = NULL)

finalDF
```

```r
  loi loiname startDate.year startDate.month startDate.day endDate.year endDate.month endDate.day type
1   1      11           1988               8             1         2000             7          31    1
2   1      11           1988               8             1         2000             7          31    2
      area
1 38003.72
2 38286.16
> 
```

A more deep analysis can be seen [here](demo/smoothed-data.R). Figure 1 depicts predicted values of deforestation data for all Brazilian Cerrado States as a result of such analysis. 

<p align="center">
<img src="inst/extdata/smoothed-data.png" alt="Figure 1 - Linear smooth of deforestation data for all the Brazilian Cerrado States."  />
<p class="caption" align="center">
Figure 1 - Linear smooth of deforestation data for all the Brazilian Cerrado States.
</p>
</p>

## References

Assis, L. F. F. G. A.; Ferreira, K. R.; Vinhas, L.; Maurano, L.; Almeida, C. A., Nascimento, J. R., Carvalho, A. F. A.; Camargo, C.; Maciel, A. M. TerraBrasilis: A Spatial Data Infrastructure for Disseminating Deforestation Data from Brazil. In Proceeding of the XIX Remote Sensing Brazilian Symposium, 2019.

## Reporting Bugs

Any problem should be reported to prodes@dpi.inpe.br.