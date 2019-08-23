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
apiPath <- "http://terrabrasilis.dpi.inpe.br/dashboard/api/v1/redis-cli/"
```

Define calls for application identifiers listing. From that information, it is possible then to make specific requests to other API end-points.

``` r
appIdentifier <- list_datasets(apiPath)

appIdentifier
[1] "prodes_cerrado"      "prodes_amazon"       "prodes_legal_amazon"
```

With that in mind, let's create a prodesCerrado variable.

``` r
prodesCerrado <- appIdentifier[1]

prodesCerrado
[1] "prodes_cerrado"
```

The first question that reminds us to ask to the API is: which periods do Prodes Cerrado contains?

``` r
periods <- list_periods(apiPath, prodesCerrado)

periods
```

``` r
periods
# A tibble: 13 x 6
   startDate.year startDate.month startDate.day endDate.year endDate.month endDate.day
            <int>           <int>         <int>        <int>         <int>       <int>
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
classes <- list_classes(apiPath, prodesCerrado)

classes
```

In this case, it is just one class designating deforestation label. Other thematic mapping projects, however, would contain more than one class or even the same class name.

```r
# A tibble: 1 x 3
     id name          description                                                         
  <int> <chr>         <chr>                                                               
1     1 deforestation It is the process of complete and permanent disappearance of forests
```

Besides responding which classes and periods, users might ask which local of interests (lois) as states, municipalities, conservation units, indigeneous areas, and Landsat Path/Row, the API provides. 

```r
locals <- list_locals(apiPath, prodesCerrado)

locals
```

```r
# A tibble: 5 x 2
    gid name    
  <int> <chr>   
1     1 UF      
2     2 MUN     
3     3 ConsUnit
4     4 Indi    
5     5 Pathrow
```

Nevertheless, locals are not considered the final granularity since each state, municipality, conservation unit, indigeneous areas, and Landsat Path/Row also contain small-scale local of interests.

```r
localOfInterest <- list_local_of_interests(apiPath, prodesCerrado)

localOfInterest[14:23,]
```

```r
# A tibble: 10 x 3
     gid loiname                                                               loi
   <int> <chr>                                                               <dbl>
 1  1586 PARQUE NATURAL MUNICIPAL DO SETOR SANTA CRUZ                            3
 2  1410 RESERVA BIOLÓGICA DO GUARÁ                                              3
 3  1431 MONUMENTO NATURAL ESTADUAL LAPA VERMELHA                                3
 4  1454 FLORESTA ESTADUAL SÃO JUDAS TADEU                                       3
 5  1548 RESERVA PARTICULAR DO PATRIMÔNIO NATURAL INTEGRA O PARQUE               3
 6  1496 ÁREA DE PROTEÇÃO AMBIENTAL MEANDROS DO ARAGUAIA                         3
 7  1481 PARQUE ESTADUAL SERRA VERDE                                             3
 8  1566 RESERVA PARTICULAR DO PATRIMÔNIO NATURAL JOAQUIM THEODORO DE MORAES     3
 9  1567 PARQUE ESTADUAL DE VASSUNUNGA                                           3
10  1404 ESTAÇÃO ECOLÓGICA ITABERÁ                                               3
```

Users are able to filter loinames by one specific loi such as UF.

```r
loiUF = dplyr::filter(locals, grepl("UF", name))$gid

loinamesByLoi <- list_localOfInterestByLocal(apiPath, prodesCerrado, loiUF)

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
filters <- list_filters(apiPath, prodesCerrado)

filters
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
data <- get_dataByLocalOfInterest(apiPath, 
                                  prodesCerrado, 
                                  classes$name, 
                                  loinamesByLoi[1,]$gid)

data
```

```r
             name         clazz startDate.year startDate.month startDate.day endDate.year endDate.month endDate.day loi loiname type      area
1  PRODES CERRADO deforestation           1988               8             1         2000             7          31   1      11    1 38003.720
2  PRODES CERRADO deforestation           1988               8             1         2000             7          31   1      11    2 38286.164
3  PRODES CERRADO deforestation           2000               8             1         2002             7          31   1      11    1  5424.295
4  PRODES CERRADO deforestation           2000               8             1         2002             7          31   1      11    2  5808.921
5  PRODES CERRADO deforestation           2002               8             1         2004             7          31   1      11    1  5723.244
6  PRODES CERRADO deforestation           2002               8             1         2004             7          31   1      11    2  6157.996
7  PRODES CERRADO deforestation           2004               8             1         2006             7          31   1      11    1  4880.821
8  PRODES CERRADO deforestation           2004               8             1         2006             7          31   1      11    2  5257.803
9  PRODES CERRADO deforestation           2006               8             1         2008             7          31   1      11    1  3228.224
10 PRODES CERRADO deforestation           2006               8             1         2008             7          31   1      11    2  3596.751
11 PRODES CERRADO deforestation           2008               8             1         2010             7          31   1      11    1  3245.410
12 PRODES CERRADO deforestation           2008               8             1         2010             7          31   1      11    2  3639.593
13 PRODES CERRADO deforestation           2010               8             1         2012             7          31   1      11    1  3263.893
14 PRODES CERRADO deforestation           2010               8             1         2012             7          31   1      11    2  3481.588
15 PRODES CERRADO deforestation           2012               8             1         2013             7          31   1      11    1  2543.343
16 PRODES CERRADO deforestation           2012               8             1         2013             7          31   1      11    2  2816.817
17 PRODES CERRADO deforestation           2013               8             1         2014             7          31   1      11    1  2006.936
18 PRODES CERRADO deforestation           2013               8             1         2014             7          31   1      11    2  2243.355
19 PRODES CERRADO deforestation           2014               8             1         2015             7          31   1      11    1  2753.371
20 PRODES CERRADO deforestation           2014               8             1         2015             7          31   1      11    2  3063.382
21 PRODES CERRADO deforestation           2015               8             1         2016             7          31   1      11    1  1421.360
22 PRODES CERRADO deforestation           2015               8             1         2016             7          31   1      11    2  1587.207
23 PRODES CERRADO deforestation           2016               8             1         2017             7          31   1      11    1  1498.426
24 PRODES CERRADO deforestation           2016               8             1         2017             7          31   1      11    2  1693.450
25 PRODES CERRADO deforestation           2017               8             1         2018             7          31   1      11    1  1391.557
26 PRODES CERRADO deforestation           2017               8             1         2018             7          31   1      11    2  1530.056
> 
```

The same query can be performed using get data by parameters function. In this case, users pass also as parameters a start and end data. Unlikely the previous call, users will not receive all the available timeline as soon as they really desire.

```r
data <- get_dataByParameters(apiPath, 
                            prodesCerrado, 
                            classes$name, 
                            loinamesByLoi[1,]$gid, 
                            "1988-01-01", 
                            "2001-01-01")


data
```

```r
            name         clazz startDate.year startDate.month startDate.day endDate.year endDate.month endDate.day loi loiname type     area
1 PRODES CERRADO deforestation           1988               8             1         2000             7          31   1      11    1 38003.72
2 PRODES CERRADO deforestation           1988               8             1         2000             7          31   1      11    2 38286.16
> 
``` 

## References

Assis, L. F. F. G. A.; Ferreira, K. R.; Vinhas, L.; Maurano, L.; Almeida, C. A., Nascimento, J. R., Carvalho, A. F. A.; Camargo, C.; Maciel, A. M. TerraBrasilis: A Spatial Data Infrastructure for Disseminating Deforestation Data from Brazil. In Proceeding of the XIX Remote Sensing Brazilian Symposium, 2019.

## Reporting Bugs

Any problem should be reported to prodes@dpi.inpe.br.