# Taux de retraités rétrospectifs construits à partir des EIR

Taux de retraités au 31 décembre par sexe, génération et âge, construits
à partir des échantillons interrégimes de retraités (EIR) de la DREES
empilés et rétropolés. Les générations observées dans les EIR (1906,
1909, 1912, ..., 1940, puis 1942 à 1950) sont complétées par
interpolation linéaire entre générations observées, à sexe et âge donnés
([`interpoler_generations()`](https://patrickaubert.github.io/pilotretrtools/reference/interpoler_generations.md)).

## Usage

``` r
taux_retraites_eir
```

## Format

Un tibble avec les colonnes :

- sexe:

  `"F"` ou `"H"`.

- generation:

  Année de naissance.

- annee:

  Année.

- age3112:

  Âge atteint dans l'année (de 50 à 70 ans).

- tx_retraites:

  Part de retraités au 31 décembre.

- tx_nouveaux_retraites:

  Part de nouveaux retraités dans l'année.

- interpole:

  `TRUE` pour les générations interpolées.

## Source

DREES, échantillons interrégimes de retraités ; calculs de l'auteur.
Voir le script `data-raw/taux_retraites_eir.R`.
