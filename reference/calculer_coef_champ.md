# Calculer les coefficients de champ à partir des publications de l'Insee

Calcule, par génération et par sexe, les coefficients qui ramènent les
effectifs d'un ancien champ géographique au nouveau, à partir des
populations publiées par l'Insee dans les deux champs (voir
[`lire_pop_champs_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_pop_champs_insee.md))
:

## Usage

``` r
calculer_coef_champ(pop_champs)
```

## Arguments

- pop_champs:

  Table produite par
  [`lire_pop_champs_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_pop_champs_insee.md),
  contenant au moins les années 1995, 2013 et 2014.

## Value

Un tibble par `rupture`, `sexe` et `generation`, avec `coef` et `estime`
(`TRUE` lorsque le coefficient est calculé, `FALSE` lorsqu'il est repris
d'une génération voisine). Il peut être passé à l'argument `coef_champ`
de
[`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md).

## Details

- **1995** (ajout des DROM hors Mayotte) : rapport, au 1er janvier 1995,
  de la population France hors Mayotte à la population de la France
  métropolitaine ;

- **2014** (ajout de Mayotte) : l'Insee ne publiant pas l'année 2014
  dans le champ France hors Mayotte, le coefficient est approché par le
  rapport France / France métropolitaine de 2014 divisé par le rapport
  France hors Mayotte / France métropolitaine de 2013, pour la même
  génération. Cela suppose que le poids des DROM hors Mayotte par
  rapport à la métropole ne varie pas d'une année sur l'autre au sein
  d'une génération. La génération née en 2013, absente au 1er janvier
  2013, reçoit le coefficient de la génération précédente.

Les coefficients sont bornés à 1 : un changement de champ qui ajoute un
territoire ne peut pas réduire l'effectif d'une génération. Pour 2014,
quelques générations âgées présentent un rapport très légèrement
inférieur à 1 (écart de l'ordre de 0,01 %), qui reflète les petites
variations du poids des DROM entre 2013 et 2014.
