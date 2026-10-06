# Projections de population de l'Insee, scénario central, prolongées

Scénario central des projections de population de l'Insee (millésime
2026), avec l'hypothèse centrale de mortalité, prolongé jusqu'en 2180
par
[`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md)
(quotients de mortalité de 2125 reconduits). Les effectifs sont dans le
champ publié pour chaque année ; voir
[`corriger_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/corriger_champ.md)
pour des séries homogènes en France entière, et
[`vignette("ecarts-insee")`](https://patrickaubert.github.io/pilotretrtools/articles/ecarts-insee.md)
pour les écarts avec les données publiées.

## Usage

``` r
projpop_central
```

## Format

Un tibble par sexe, génération, année et âge ; voir la section « Value »
de
[`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md)
pour la description des colonnes.

## Source

Insee, projections de population 2026 (Licence Ouverte Etalab) ; voir
`sources_donnees(c("projpop", "projmort"))`.
