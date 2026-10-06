# Lire les hypothèses d'emploi et de chômage du COR

Lit, pour une hypothèse de taux de chômage de long terme, les taux
d'emploi et de chômage par sexe et tranche d'âge quinquennale du fichier
d'hypothèses du COR (onglets `Emploi_x%` et `Chômage_x%`), et en déduit
les taux d'activité : taux d'activité = taux d'emploi / (1 - taux de
chômage). La dernière tranche (70 ans) est traitée comme une tranche
ouverte.

## Usage

``` r
lire_hypotheses_cor(url = url_source("txempl_proj"), chomage = 7)
```

## Arguments

- url:

  Adresse (ou chemin local) du fichier.

- chomage:

  Hypothèse de taux de chômage de long terme, en % (5, 7 ou 10 dans le
  fichier de 2025).

## Value

Un tibble par `sexe`, `annee` et tranche d'âge (`age_debut`, `age_fin`),
avec `tx_emploi`, `tx_chomage` et `tx_activite` (entre 0 et 1).

## Details

Les années doivent se suivre ; une année mal étiquetée dans le fichier
(par exemple 2070 à la place de 2090 dans la dernière ligne des onglets
de 2025) est corrigée, avec un message.
