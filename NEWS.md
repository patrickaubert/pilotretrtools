# pilotretrtools 0.0.0.9000

* Squelette du package : conventions de la grille génération × âge × année
  (`valider_grille()`), registre des sources (`sources_donnees()`,
  `url_source()`), téléchargement avec cache (`telecharger_source()`).
* Module démographique, première brique : lecture d'un scénario des
  projections de population de l'Insee (`lire_projpop_insee()`,
  `lire_mortalite_insee()`, `lire_onglet_insee()`) et prolongation au-delà
  de 2070 (`prolonger_projpop()`).
