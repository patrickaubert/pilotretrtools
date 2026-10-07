# Taux de retraités du scénario central

Taux de retraités au 31 décembre et taux de nouveaux retraités par sexe,
année et âge, construits par
[`construire_taux_retraites()`](https://patrickaubert.github.io/pilotretrtools/reference/construire_taux_retraites.md)
à partir des taux projetés par le COR (rapport annuel de 2025) et des
taux rétrospectifs construits à partir des EIR
([taux_retraites_eir](https://patrickaubert.github.io/pilotretrtools/reference/taux_retraites_eir.md)).
Construite par `data-raw/tables_centrales.R`.

## Usage

``` r
taux_retraites_central
```

## Format

Un tibble par `sexe`, `annee` et `age3112`, avec `tx_retraites`,
`tx_nouveaux_retraites` et `source_tx_retraites` ; voir la section «
Value » de
[`construire_taux_retraites()`](https://patrickaubert.github.io/pilotretrtools/reference/construire_taux_retraites.md).

## Source

COR, données complémentaires du rapport annuel de juin 2025 ; DREES,
échantillons interrégimes de retraités. Voir
`sources_donnees("txretr")`.
