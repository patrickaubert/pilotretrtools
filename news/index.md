# Changelog

## pilotretrtools (development version)

## pilotretrtools 0.3.0

- [`construire_base()`](https://patrickaubert.github.io/pilotretrtools/reference/construire_base.md)
  : construction de la base complète (population, retraités, actifs,
  actifs occupés) en une ligne, hors ligne pour le scénario central ;
  variantes de scénario Insee, de mortalité et de chômage.
- Nouvelles tables embarquées : `taux_retraites_central` (avec les taux
  de nouveaux retraités), `taux_activite_central` (taux lissés par âge
  fin) et `taux_activite_publies` (taux publiés par l’Insee et le COR,
  non lissés, voir
  [`lire_taux_activite_publies()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_taux_activite_publies.md)).
- Série historique 1901-1961
  ([`ajouter_serie_historique()`](https://patrickaubert.github.io/pilotretrtools/reference/ajouter_serie_historique.md)),
  incluse dans `projpop_central`, et colonne `champ`
  ([`champ_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/champ_insee.md)).
- Décomposition des évolutions du nombre de retraités, des actifs
  occupés et du rapport démographique
  ([`decomposer_evolutions()`](https://patrickaubert.github.io/pilotretrtools/reference/decomposer_evolutions.md)),
  avec une mortalité de référence au choix
  ([`mortalite_annee()`](https://patrickaubert.github.io/pilotretrtools/reference/reference_mortalite.md),
  [`mortalite_generation()`](https://patrickaubert.github.io/pilotretrtools/reference/reference_mortalite.md),
  [`mortalite_annee_age()`](https://patrickaubert.github.io/pilotretrtools/reference/reference_mortalite.md)).
- Sources des taux lissés signalées par la mention « + lissage ».
- Documentation des tables regroupée dans `R/data.R` ; nouvelle vignette
  « Prise en main ».

## pilotretrtools 0.2.0

- Taux de retraités : lecture des projections du COR
  ([`lire_taux_retraites_cor()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_taux_retraites_cor.md)),
  table rétrospective construite à partir des EIR
  (`taux_retraites_eir`), raccordement
  ([`construire_taux_retraites()`](https://patrickaubert.github.io/pilotretrtools/reference/construire_taux_retraites.md))
  et nombres de retraités
  ([`ajouter_retraites()`](https://patrickaubert.github.io/pilotretrtools/reference/ajouter_retraites.md)).
- Taux d’activité et d’emploi : lecture de l’enquête Emploi, de la PPA
  et des hypothèses du COR selon l’hypothèse de chômage, lissage par âge
  fin
  ([`construire_taux_activite()`](https://patrickaubert.github.io/pilotretrtools/reference/construire_taux_activite.md))
  et nombres d’actifs et d’actifs occupés
  ([`ajouter_actifs()`](https://patrickaubert.github.io/pilotretrtools/reference/ajouter_actifs.md)).
- Outils génériques :
  [`interpoler_generations()`](https://patrickaubert.github.io/pilotretrtools/reference/interpoler_generations.md)
  et
  [`lisser_par_age()`](https://patrickaubert.github.io/pilotretrtools/reference/lisser_par_age.md).
- Vignette « Écarts avec les données publiées » complétée (retraités,
  actifs).

## pilotretrtools 0.1.0

## pilotretrtools 0.0.0.9000

- Squelette du package : conventions de la grille génération × âge ×
  année
  ([`valider_grille()`](https://patrickaubert.github.io/pilotretrtools/reference/valider_grille.md)),
  registre des sources
  ([`sources_donnees()`](https://patrickaubert.github.io/pilotretrtools/reference/sources_donnees.md),
  [`url_source()`](https://patrickaubert.github.io/pilotretrtools/reference/url_source.md)),
  téléchargement avec cache
  ([`telecharger_source()`](https://patrickaubert.github.io/pilotretrtools/reference/telecharger_source.md)).
- Module démographique, première brique : lecture d’un scénario des
  projections de population de l’Insee
  ([`lire_projpop_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_projpop_insee.md),
  [`lire_mortalite_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_mortalite_insee.md),
  [`lire_onglet_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_onglet_insee.md))
  et prolongation au-delà de 2070
  ([`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md)).
- Les groupes ouverts des fichiers de l’Insee (« 105+ », ou « 100 » les
  années où le détail s’arrête à 100 ans) sont écartés à la lecture et
  reconstitués par génération lors de la prolongation ; la population ne
  peut plus devenir négative.
- [`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md)
  : nouvelle option `prolongation_mortalite` pour la mortalité au-delà
  de la dernière année disponible (`"constante"` par défaut, ou
  `"tendance"`, avec `duree_tendance`).
- Les âges non détaillés signalés par des zéros au-delà du groupe ouvert
  (ligne « 100 » avant 1999) sont désormais repérés ; les décès calculés
  ne peuvent plus être négatifs.
- [`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md)
  renvoie désormais un tibble (paramètres, sources et coefficients de
  champ en attributs), avec les naissances par sexe en colonne sur les
  lignes d’âge 0.
- Ruptures de champ géographique (1995, 2014) : colonne `coef_champ`,
  [`estimer_coef_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/estimer_coef_champ.md)
  et
  [`corriger_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/corriger_champ.md).
- Nouvelle vignette « Écarts avec les données publiées par l’Insee ».
- Coefficients de champ calculés à partir des populations publiées par
  l’Insee dans les deux champs
  ([`lire_pop_champs_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_pop_champs_insee.md),
  [`calculer_coef_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/calculer_coef_champ.md),
  argument `coef_champ` de
  [`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md))
  ; l’estimation indirecte devient une méthode de repli. Coefficients
  bornés à 1.
