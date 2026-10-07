# Taux d'activité, d'emploi et de chômage par âge fin, scénario central

Taux d'activité, d'emploi et de chômage par sexe, année et âge fin,
construits par
[`construire_taux_activite()`](https://patrickaubert.github.io/pilotretrtools/reference/construire_taux_activite.md)
à partir de l'enquête Emploi et des projections de population active de
l'Insee et des hypothèses du COR (hypothèse de chômage de long terme de
7 %, stockée dans l'attribut `hypothese_chomage`). Les taux sont lissés
par âge fin par le package
([`lisser_par_age()`](https://patrickaubert.github.io/pilotretrtools/reference/lisser_par_age.md),
avec les effectifs de
[projpop_central](https://patrickaubert.github.io/pilotretrtools/reference/projpop_central.md))
: ils ne correspondent pas aux taux publiés, qui sont rassemblés dans
[taux_activite_publies](https://patrickaubert.github.io/pilotretrtools/reference/taux_activite_publies.md).
Construite par `data-raw/tables_centrales.R`.

## Usage

``` r
taux_activite_central
```

## Format

Un tibble par `sexe`, `annee` et `age3112`, avec `tx_activite`,
`tx_emploi`, `tx_chomage`, `source_tx_emploi` et `source_tx_activite` ;
voir la section « Value » de
[`construire_taux_activite()`](https://patrickaubert.github.io/pilotretrtools/reference/construire_taux_activite.md).

## Source

Insee, enquête Emploi (séries longues) et projections de population
active ; COR, hypothèses ventilées par sexe et âge (2025). Voir
`sources_donnees(c("txempl_obs", "txact", "txempl_proj"))`.
