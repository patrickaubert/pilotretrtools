# Lire la population par âge détaillé dans les différents champs géographiques

Lit le tableau POP3 des données nationales de l'Insee (population au 1er
janvier par sexe et âge détaillé), qui comporte un onglet par année et,
pour chaque année, la population de la France métropolitaine et celle du
champ « France » de l'époque (France hors Mayotte jusqu'en 2013, France
entière à partir de 2014).

## Usage

``` r
lire_pop_champs_insee(
  url = url_source("popchamp"),
  annees = c(1995, 2013, 2014)
)
```

## Arguments

- url:

  Adresse (ou chemin local) du fichier.

- annees:

  Années (onglets) à lire.

## Value

Un tibble par `annee`, `champ` (`"metropole"`, `"france_hors_mayotte"`
ou `"france"`), `sexe`, `generation` et `age3112`, avec la colonne
`population` (au 1er janvier).

## Details

Les groupes ouverts (« 100 ou plus », « 105 ou plus ») sont écartés.

## Examples

``` r
if (FALSE) { # \dontrun{
lire_pop_champs_insee(annees = c(1995, 2013, 2014))
} # }
```
