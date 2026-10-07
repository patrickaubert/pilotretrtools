# Projections de population de l'Insee, scénario central, prolongées

Population par sexe, génération, année et âge du scénario central des
projections de population de l'Insee (millésime 2026, hypothèse centrale
de mortalité), prolongé jusqu'en 2180 par
[`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md)
(quotients de mortalité de 2125 reconduits) et précédé des séries
historiques de 1901 à 1961
([`ajouter_serie_historique()`](https://patrickaubert.github.io/pilotretrtools/reference/ajouter_serie_historique.md)).

## Usage

``` r
projpop_central
```

## Format

Un tibble par `sexe`, `generation`, `annee`, `age0101` et `age3112` (de
0 à 120 ans), avec `population` (au 1er janvier), `naissances`, `deces`,
`qx`, `solde_migratoire`, `ajustement`, `population3112` (au 31
décembre), `prolonge`, `champ` et `coef_champ` ; voir la section « Value
» de
[`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md).
Les paramètres de construction, les sources et les coefficients de champ
sont dans les attributs `parametres`, `sources` et `coef_champ`.

## Source

Insee, projections de population 2026, estimations de population
(tableau POP3) ; Licence Ouverte Etalab. Voir
`sources_donnees(c("projpop", "projmort", "popchamp"))`.

## Details

Les effectifs sont ceux du champ publié pour chaque année (colonne
`champ`) :
[`corriger_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/corriger_champ.md)
les ramène au champ France entière. Les écarts avec les données publiées
sont détaillés dans
[`vignette("ecarts-insee")`](https://patrickaubert.github.io/pilotretrtools/articles/ecarts-insee.md).
Construite par `data-raw/projpop_central.R`.
