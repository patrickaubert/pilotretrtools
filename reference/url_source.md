# Adresse d'un fichier source

Renvoie l'adresse du fichier correspondant à un type de données, un
scénario et un millésime. Par défaut, le millésime le plus récent du
registre est retenu.

## Usage

``` r
url_source(objet, scenario = "central", millesime = NULL)
```

## Arguments

- objet:

  Type de données (voir
  [`sources_donnees()`](https://patrickaubert.github.io/pilotretrtools/reference/sources_donnees.md)).

- scenario:

  Scénario (par défaut `"central"`).

- millesime:

  Millésime ; `NULL` pour le plus récent.

## Value

Une chaîne de caractères.

## Examples

``` r
url_source("projpop")
#> [1] "https://www.insee.fr/fr/statistiques/fichier/8990852/00_central.xlsx"
```
