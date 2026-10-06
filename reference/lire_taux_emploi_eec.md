# Lire les taux d'emploi observés de l'enquête Emploi

Lit le tableau T207 des séries longues de l'enquête Emploi de l'Insee
(taux d'emploi par sexe et âge quinquennal, en moyenne annuelle). Seules
les tranches quinquennales et la tranche ouverte des âges élevés sont
conservées (les regroupements plus larges sont écartés).

## Usage

``` r
lire_taux_emploi_eec(url = url_source("txempl_obs"), onglet = 1)
```

## Arguments

- url:

  Adresse (ou chemin local) du fichier.

- onglet:

  Nom de l'onglet (par défaut le premier).

## Value

Un tibble par `sexe`, `annee` et tranche d'âge (`age_debut`, `age_fin`,
`NA` pour la tranche ouverte), avec `tx_emploi` (entre 0 et 1).
