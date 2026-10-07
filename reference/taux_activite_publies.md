# Taux d'activité, d'emploi et de chômage publiés, par tranche d'âge

Taux par sexe et tranche d'âge, sans lissage, tels que publiés par
l'Insee (taux d'emploi de l'enquête Emploi, taux d'activité des
projections de population active) et par le COR (taux d'emploi et de
chômage pour chacune des hypothèses de chômage de long terme, taux
d'activité déduits). Ce sont les données de départ de
[`construire_taux_activite()`](https://patrickaubert.github.io/pilotretrtools/reference/construire_taux_activite.md).
Construite par `data-raw/tables_centrales.R` avec
[`lire_taux_activite_publies()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_taux_activite_publies.md).

## Usage

``` r
taux_activite_publies
```

## Format

Un tibble avec `source`, `hypothese_chomage`, `sexe`, `annee`,
`age_debut`, `age_fin`, `tx_emploi`, `tx_activite` et `tx_chomage` ;
voir la section « Value » de
[`lire_taux_activite_publies()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_taux_activite_publies.md).

## Source

Insee, enquête Emploi (séries longues) et projections de population
active ; COR, hypothèses ventilées par sexe et âge (2025).
