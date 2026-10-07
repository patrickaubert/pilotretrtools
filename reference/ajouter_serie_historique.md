# Ajouter les séries historiques de population

Ajoute au début d'une table de population (produite par
[`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md))
les populations au 1er janvier par sexe et âge détaillé des années
antérieures, tirées du tableau POP3 de l'Insee (France métropolitaine
depuis 1901), afin de disposer des séries les plus longues possibles.

## Usage

``` r
ajouter_serie_historique(
  population,
  url = url_source("popchamp"),
  annees = NULL
)
```

## Arguments

- population:

  Table produite par
  [`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md).

- url:

  Adresse (ou chemin local) du tableau POP3.

- annees:

  Années à ajouter ; par défaut toutes celles du tableau antérieures à
  la première année de `population`.

## Value

La table complétée, triée, avec les mêmes colonnes et attributs.
L'attribut `parametres` indique les années historiques ajoutées.

## Details

Pour ces années :

- seules les populations au 1er janvier sont disponibles ; la population
  au 31 décembre est celle de la même génération au 1er janvier suivant
  (manquante lorsque l'année suivante n'est pas couverte) ; les décès,
  les quotients de mortalité, les soldes migratoires et les naissances
  sont manquants ;

- les âges couverts par le groupe ouvert (« 99 ou plus » ou « 100 ou
  plus » selon les années) sont manquants ;

- les années 1915 à 1919, absentes du tableau, ne sont pas ajoutées ;

- le champ géographique varie (voir
  [`champ_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/champ_insee.md))
  : l'Alsace-Moselle est exclue de 1901 à 1914 et de 1939 à 1945 (ainsi
  que la Corse en 1944). Ces ruptures ne sont pas corrigées : seule la
  colonne `champ` les signale. La colonne `coef_champ` corrige, comme
  pour les années suivantes, l'absence des DROM et de Mayotte.

## Examples

``` r
if (FALSE) { # \dontrun{
projpop <- prolonger_projpop(lire_projpop_insee()) |>
  ajouter_serie_historique()
} # }
```
