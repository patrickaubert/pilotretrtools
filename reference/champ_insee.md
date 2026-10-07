# Champ géographique des séries de l'Insee

Renvoie, pour chaque année, le champ géographique des séries de
population de l'Insee :

## Usage

``` r
champ_insee(annee)
```

## Arguments

- annee:

  Années.

## Value

Un vecteur de libellés (`NA` pour les années 1915 à 1919, non couvertes
par les séries).

## Details

- `"metropole_hors_alsace_moselle"` : 1901-1914 (frontières de 1871) et
  1939-1945, sauf 1944 ;

- `"metropole_hors_alsace_moselle_corse"` : 1944 ;

- `"metropole"` : 1920-1938 et 1946-1994 ;

- `"france_hors_mayotte"` : 1995-2013 ;

- `"france"` : à partir de 2014.

## Examples

``` r
champ_insee(c(1910, 1944, 1980, 2000, 2030))
#> [1] "metropole_hors_alsace_moselle"       "metropole_hors_alsace_moselle_corse"
#> [3] "metropole"                           "france_hors_mayotte"                
#> [5] "france"                             
```
