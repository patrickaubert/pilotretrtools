# Lire les taux d'activité des projections de population active de l'Insee

Lit l'onglet des taux d'activité des projections de population active
(PPA) de l'Insee : années en lignes, tranches d'âge en colonnes, avec un
bloc de colonnes par sexe (ensemble, femmes, hommes). Seuls les blocs
des femmes et des hommes sont conservés.

## Usage

``` r
lire_taux_activite_ppa(url = url_source("txact"), onglet = "taux_activité")
```

## Arguments

- url:

  Adresse (ou chemin local) du fichier.

- onglet:

  Nom de l'onglet.

## Value

Un tibble par `sexe`, `annee` et tranche d'âge (`age_debut`, `age_fin`),
avec `tx_activite` (entre 0 et 1).
