# Interpoler entre générations

Complète une table disponible pour certaines générations seulement (par
exemple les générations de l'échantillon interrégimes de retraités, EIR)
par interpolation linéaire entre générations observées, pour chaque
combinaison des variables de `groupes` (par défaut à sexe et âge
donnés). Les générations sont complétées entre la plus ancienne et la
plus récente observées dans chaque groupe ; aucune extrapolation n'est
faite au-delà.

## Usage

``` r
interpoler_generations(donnees, variables, groupes = c("sexe", "age3112"))
```

## Arguments

- donnees:

  Table contenant une colonne `generation`, les colonnes de `groupes` et
  les colonnes de `variables`.

- variables:

  Colonnes numériques à interpoler.

- groupes:

  Colonnes définissant les groupes au sein desquels l'interpolation est
  faite.

## Value

La table complétée, avec une colonne `interpole` (`TRUE` pour les
générations ajoutées). Si la table contient `annee` et `age3112`,
`annee` est recalculée pour les lignes ajoutées.

## Examples

``` r
x <- data.frame(sexe = "F", age3112 = 60, generation = c(1940, 1944),
                tx = c(0.2, 0.6))
interpoler_generations(x, "tx")
#> # A tibble: 5 × 5
#>   sexe  age3112 generation    tx interpole
#>   <chr>   <dbl>      <dbl> <dbl> <lgl>    
#> 1 F          60       1940   0.2 FALSE    
#> 2 F          60       1941   0.3 TRUE     
#> 3 F          60       1942   0.4 TRUE     
#> 4 F          60       1943   0.5 TRUE     
#> 5 F          60       1944   0.6 FALSE    
```
