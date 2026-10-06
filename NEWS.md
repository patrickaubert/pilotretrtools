# pilotretrtools 0.0.0.9000

* Squelette du package : conventions de la grille génération × âge × année
  (`valider_grille()`), registre des sources (`sources_donnees()`,
  `url_source()`), téléchargement avec cache (`telecharger_source()`).
* Module démographique, première brique : lecture d'un scénario des
  projections de population de l'Insee (`lire_projpop_insee()`,
  `lire_mortalite_insee()`, `lire_onglet_insee()`) et prolongation au-delà
  de 2070 (`prolonger_projpop()`).
* Les groupes ouverts des fichiers de l'Insee (« 105+ », ou « 100 » les
  années où le détail s'arrête à 100 ans) sont écartés à la lecture et
  reconstitués par génération lors de la prolongation ; la population ne
  peut plus devenir négative.
* `prolonger_projpop()` : nouvelle option `prolongation_mortalite` pour la
  mortalité au-delà de la dernière année disponible (`"constante"` par
  défaut, ou `"tendance"`, avec `duree_tendance`).
* Les âges non détaillés signalés par des zéros au-delà du groupe ouvert
  (ligne « 100 » avant 1999) sont désormais repérés ; les décès calculés ne
  peuvent plus être négatifs.
* `prolonger_projpop()` renvoie désormais un tibble (paramètres, sources et
  coefficients de champ en attributs), avec les naissances par sexe en
  colonne sur les lignes d'âge 0.
* Ruptures de champ géographique (1995, 2014) : colonne `coef_champ`,
  `estimer_coef_champ()` et `corriger_champ()`.
* Nouvelle vignette « Écarts avec les données publiées par l'Insee ».
* Coefficients de champ calculés à partir des populations publiées par
  l'Insee dans les deux champs (`lire_pop_champs_insee()`,
  `calculer_coef_champ()`, argument `coef_champ` de `prolonger_projpop()`) ;
  l'estimation indirecte devient une méthode de repli. Coefficients bornés
  à 1.
