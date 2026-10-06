# Registre des sources de données

Renvoie la table des fichiers sources utilisés par le package
(organisme, publication, millésime, scénario, adresse). Ce registre,
stocké dans `inst/extdata/sources.csv`, est le seul endroit à modifier
lorsqu'un organisme publie une version actualisée de ses projections.

## Usage

``` r
sources_donnees(objet = NULL)
```

## Arguments

- objet:

  Filtre facultatif sur le type de données (par exemple `"projpop"` ou
  `"projmort"`).

## Value

Un tibble.

## Examples

``` r
sources_donnees()
#> # A tibble: 7 × 8
#>   objet       organisme publication       millesime scenario onglets url   note 
#>   <chr>       <chr>     <chr>                 <int> <chr>    <chr>   <chr> <chr>
#> 1 projpop     Insee     Projections de p…      2026 central  popula… http… "Les…
#> 2 projmort    Insee     Quotients de mor…      2026 tous     <hypot… http… "Un …
#> 3 txretr      COR       Rapport annuel d…      2025 central  Tx_ret… http… "À a…
#> 4 txact       Insee     Projections de p…      2022 central  taux_a… http… ""   
#> 5 txempl_obs  Insee     Activité, emploi…      2026 tous     EEC_T2… http… "Sér…
#> 6 txempl_proj COR       Hypothèses du CO…      2025 central  Emploi… http… "Ong…
#> 7 eco         COR       Hypothèses de sa…      2025 tous     SMPT, … http… ""   
sources_donnees("projpop")
#> # A tibble: 1 × 8
#>   objet   organisme publication           millesime scenario onglets url   note 
#>   <chr>   <chr>     <chr>                     <int> <chr>    <chr>   <chr> <chr>
#> 1 projpop Insee     Projections de popul…      2026 central  popula… http… Les …
```
