# R Client Terrabrasilis Analytics API

**terrabrasilisAnalyticsAPI** is an R client package for Terrabrasilis Analytics API. 

## Getting started

Installing and loading wtss package

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
      identifier                                         name          created
1 prodes_cerrado       Dashboard of the Prodes in the Cerrado 2018-12-12 09:22
2  prodes_amazon Dashboard of the Prodes in the Amazon Forest 2018-12-12 09:22
```

With that in mind, examples let's create a prodes_cerrado variable

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
```

Users can also ask to the API, for example, which classes do PRODES Cerrado contains?

```r
classes <- tba_list_classes(tbaAPIPath, prodesCerrado)

classes
```

In this case, it is just one class designating deforestation label. Other thematic mapping, however, would contain more than one class or even the same class name.

```r
# A tibble: 1 x 3
     id name          description                                                         
* <int> <chr>         <chr>                                                               
1     1 deforestation It is the process of complete and permanent disappearance of forests
```

Besides responding which classes and periods, users can ask which local of interests (lois) as states, municipalities, conservation units, indigeneous areas, and Landsat Path/Row they are interested for. 

```r
lois <- tba_list_lois(tbaAPIPath, prodesCerrado)

lois
```

```r
# A tibble: 5 x 2
    gid name    
* <int> <chr>   
1     1 UF      
2     2 MUN     
3     3 ConsUnit
4     4 Indi    
5     5 Pathrow 
```
Nevertheless, they are not considered the final granularity since each state, municipality, conservation unit, indigeneous areas, and Landsat Path/Row also contains small-scale local of interests, also known here as local of interests names (loinames).

```r
loinames <- tba_list_loinames(tbaAPIPath, prodesCerrado)

loinames[20:30,]
```

```r
# A tibble: 11 x 3
     gid loiname                                             loi
   <int> <chr>                                             <dbl>
 1 10555 PARQUE ESTADUAL ALTAMIRO DE MOURA PACHECO             3
 2 10463 ESTAçãO ECOLóGICA DE AVARé                            3
 3 10689 FLORESTA ESTADUAL DE ASSIS                            3
 4 10697 PARQUE NACIONAL DA CHAPADA DOS VEADEIROS              3
 5 10566 PARQUE ESTADUAL SERRA DO INTENDENTE                   3
 6 10715 PARQUE NATURAL MUNICIPAL PEDRO GERALDO DE MENEZES     3
 7 10596 RPPN TOCA DA PACA                                     3
 8 10503 PARQUE ESTADUAL PAU FURADO                            3
 9 10642 ÁREA DE PROTEçãO AMBIENTAL DO LIMOEIRO                3
10 10613 RPPN FLOR DO CERRADO III                              3
11 10704 ESTAÇÃO ECOLÓGICA DE RIBEIRÃO PRETO                   3```
```

User are able to filter loinames by one specific loi such as UF.

```r
loiUF = dplyr::filter(lois, grepl("UF", name))$gid

loinamesByLoi <- tba_list_loinamesByLoi(tbaAPIPath, appIdentifier$identifier[1], loiUF)

loinamesByLoi
```

```r
# A tibble: 13 x 2
     gid loiname           
 * <int> <chr>             
 1  9050 MATO GROSSO       
 2  9051 MATO GROSSO DO SUL
 3  9049 MARANHÃO          
 4  9055 SÃO PAULO         
 5  9047 DISTRITO FEDERAL  
 6  9052 MINAS GERAIS      
 7  9056 TOCANTINS         
 8  9046 BAHIA             
 9  9048 GOIÁS             
10  9054 PIAUÍ             
11  9057 PARANÁ            
12  9053 PARÁ              
13  9058 RONDÔNIA  
```

All this data is used to gather specific thematic map area values produced by government agencies such as the National Institute for Space Research. In this example, users are able to see an acquisition of data by loiname, that is, the function acepts as parameters, the class name and loiname gid as well.

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
  loi loiname startDate.year startDate.month startDate.day endDate.year endDate.month endDate.day type      area
1   1    9050           1988               8             1         2000             7          31    1   293.613
2   1    9050           1988               8             1         2000             7          31    2 90877.468
> 
```

A more deep analysis can be seen here. Figure 1 depicts predicted values of deforestation data for all Brazilian Cerrado States as a result of such analysis. 

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