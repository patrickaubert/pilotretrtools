# Ajouter les actifs et les actifs occupés à une table de population

Ajoute à une table de population les taux d'activité, d'emploi et de
chômage
([`construire_taux_activite()`](https://patrickaubert.github.io/pilotretrtools/reference/construire_taux_activite.md))
et les nombres d'actifs et d'actifs occupés au 31 décembre. Les taux,
mesurés en moyenne annuelle, sont appliqués à la population au 31
décembre, par cohérence avec les taux de retraités.

## Usage

``` r
ajouter_actifs(population, taux_activite)
```

## Arguments

- population:

  Table de population (colonnes `sexe`, `annee`, `age3112`,
  `population3112`).

- taux_activite:

  Taux produits par
  [`construire_taux_activite()`](https://patrickaubert.github.io/pilotretrtools/reference/construire_taux_activite.md).

## Value

La table de population avec les colonnes `tx_activite`, `tx_emploi`,
`tx_chomage`, `nb_actifs` et `nb_actifs_occupes`.

## Details

Pour des effectifs corrigés des ruptures de champ, appliquer
[`corriger_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/corriger_champ.md)
à la population **avant** cette fonction.
