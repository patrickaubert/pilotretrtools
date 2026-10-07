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

# base complète du scénario central (population, retraités, actifs),
# disponible hors ligne
base <- construire_base()

# variante : hypothèse de chômage de 10 % (accès à internet nécessaire)
base_chomage_10 <- construire_base(chomage = 10)
```

La vignette « Prise en main » (`vignette("prise-en-main", package =
"pilotretrtools")`) détaille l'enchaînement des fonctions et les variantes.

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
- [x] Décomposition des évolutions du nombre de retraités, des actifs
      occupés et du rapport démographique
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
