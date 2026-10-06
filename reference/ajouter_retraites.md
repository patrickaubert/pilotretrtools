# Ajouter les retraités à une table de population

Ajoute à une table de population (par exemple
[`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md))
le taux et le nombre de retraités au 31 décembre, ainsi que le taux et
le nombre de nouveaux retraités de l'année. Le taux de nouveaux
retraités est approché par la hausse du taux de retraités de la
génération entre la fin de l'année précédente et la fin de l'année :
\\tx(t, a) - tx(t-1, a-1)\\. Il peut être légèrement négatif lorsque le
taux de retraités baisse d'une génération à l'autre.

## Usage

``` r
ajouter_retraites(population, taux_retraites)
```

## Arguments

- population:

  Table de population (colonnes `sexe`, `generation`, `annee`,
  `age3112`, `population3112`).

- taux_retraites:

  Taux produits par
  [`construire_taux_retraites()`](https://patrickaubert.github.io/pilotretrtools/reference/construire_taux_retraites.md).

## Value

La table de population avec les colonnes `tx_retraites`, `nb_retraites`,
`tx_nouveaux_retraites` et `nb_nouveaux_retraites`.

## Details

Pour des effectifs corrigés des ruptures de champ, appliquer
[`corriger_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/corriger_champ.md)
à la population **avant** cette fonction.
