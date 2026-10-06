# pilotretrtools

<!-- badges: start -->
[![R-CMD-check](https://github.com/patrickaubert/pilotretrtools/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/patrickaubert/pilotretrtools/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`pilotretrtools` rassemble des fonctions, des tables et des applications pour
illustrer le pilotage d'un régime de retraite par annuités, en particulier le
régime général français :

- lecture et prolongation des projections de population de l'Insee, pour
  calculer des indicateurs par génération sur l'ensemble du cycle de vie ;
- décomposition des effets de la démographie, de l'activité et des départs à
  la retraite sur le nombre de retraités et le rapport démographique ;
- simulation de l'équilibrage d'un régime à partir d'un cas type normatif
  représentatif de chaque génération, selon le levier mobilisé.

## Installation

```r
# install.packages("remotes")
remotes::install_github("patrickaubert/pilotretrtools")
```

Pour reproduire un résultat publié, installer la version utilisée :
`remotes::install_github("patrickaubert/pilotretrtools@v0.1.0")`.

## Premiers pas

```r
library(pilotretrtools)

# sources de données utilisées
sources_donnees()

# lecture et prolongation du scénario central de l'Insee
projpop <- lire_projpop_insee()
projpop_prolongee <- prolonger_projpop(projpop, horizon = 2180)

# séries homogènes en France entière (ruptures de champ de 1995 et 2014)
projpop_homogene <- corriger_champ(projpop_prolongee)
```

Les conventions communes à toutes les fonctions sont décrites dans
`vignette("conventions", package = "pilotretrtools")`, et les écarts avec les
données publiées par l'Insee dans
`vignette("ecarts-insee", package = "pilotretrtools")`.

## État d'avancement

- [x] Squelette, conventions, registre des sources
- [x] Lecture et prolongation des projections de population de l'Insee
- [x] Taux de retraités (COR, rétropolation EIR) et nombre de retraités
- [x] Taux d'activité et d'emploi lissés par âge fin ; nombre d'actifs et
      d'actifs occupés
- [ ] Décomposition des évolutions du nombre de retraités et du rapport
      démographique
- [ ] Modèle de cas type et règles d'équilibrage
- [ ] Applications Shiny

## Points ouverts

- Raccordement des taux d'emploi observés (enquête Emploi) et projetés
  (COR) : saut de niveau entre la dernière année observée et la première
  année projetée (par exemple -1,8 point à 45 ans pour les femmes entre 2025
  et 2026).
- Lissage par âge fin des taux d'activité et d'emploi : hypothèse
  approximative aux âges de la retraite, où les taux présentent des ruptures
  aux âges légaux de départ ; à remplacer à terme par des taux calculés
  directement par âge fin.

## Sources et licences

Le code est diffusé sous licence EUPL (version 1.2 ou ultérieure). Les
données embarquées proviennent de l'Insee (Licence Ouverte Etalab), du
Conseil d'orientation des retraites et des barèmes IPP ; leurs sources
précises sont indiquées dans `sources_donnees()` et dans la documentation de
chaque table.
