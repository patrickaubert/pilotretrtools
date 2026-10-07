# Package index

## Conventions et outils

- [`valider_grille()`](https://patrickaubert.github.io/pilotretrtools/reference/valider_grille.md)
  : Vérifier qu'une table respecte la grille commune du package
- [`interpoler_generations()`](https://patrickaubert.github.io/pilotretrtools/reference/interpoler_generations.md)
  : Interpoler entre générations
- [`lisser_par_age()`](https://patrickaubert.github.io/pilotretrtools/reference/lisser_par_age.md)
  : Lisser par âge fin des taux connus par tranche d'âge

## Construction de la base

- [`construire_base()`](https://patrickaubert.github.io/pilotretrtools/reference/construire_base.md)
  : Construire la base complète : population, retraités, actifs

## Données

- [`projpop_central`](https://patrickaubert.github.io/pilotretrtools/reference/projpop_central.md)
  : Projections de population de l'Insee, scénario central, prolongées
- [`taux_retraites_central`](https://patrickaubert.github.io/pilotretrtools/reference/taux_retraites_central.md)
  : Taux de retraités du scénario central
- [`taux_activite_central`](https://patrickaubert.github.io/pilotretrtools/reference/taux_activite_central.md)
  : Taux d'activité, d'emploi et de chômage par âge fin, scénario
  central
- [`taux_activite_publies`](https://patrickaubert.github.io/pilotretrtools/reference/taux_activite_publies.md)
  : Taux d'activité, d'emploi et de chômage publiés, par tranche d'âge
- [`taux_retraites_eir`](https://patrickaubert.github.io/pilotretrtools/reference/taux_retraites_eir.md)
  : Taux de retraités rétrospectifs construits à partir des EIR

## Sources de données

- [`sources_donnees()`](https://patrickaubert.github.io/pilotretrtools/reference/sources_donnees.md)
  : Registre des sources de données
- [`url_source()`](https://patrickaubert.github.io/pilotretrtools/reference/url_source.md)
  : Adresse d'un fichier source
- [`telecharger_source()`](https://patrickaubert.github.io/pilotretrtools/reference/telecharger_source.md)
  : Télécharger un fichier source, avec mise en cache
- [`vider_cache()`](https://patrickaubert.github.io/pilotretrtools/reference/vider_cache.md)
  : Vider le cache des fichiers téléchargés

## Démographie

- [`lire_onglet_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_onglet_insee.md)
  : Lire un onglet d'un fichier de projections de l'Insee
- [`lire_projpop_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_projpop_insee.md)
  : Lire un scénario des projections de population de l'Insee
- [`lire_mortalite_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_mortalite_insee.md)
  : Lire une hypothèse de mortalité prolongée de l'Insee
- [`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md)
  : Prolonger les projections de population de l'Insee
- [`ajouter_serie_historique()`](https://patrickaubert.github.io/pilotretrtools/reference/ajouter_serie_historique.md)
  : Ajouter les séries historiques de population
- [`champ_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/champ_insee.md)
  : Champ géographique des séries de l'Insee

## Retraités

- [`lire_taux_retraites_cor()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_taux_retraites_cor.md)
  : Lire les taux de retraités projetés par le COR
- [`construire_taux_retraites()`](https://patrickaubert.github.io/pilotretrtools/reference/construire_taux_retraites.md)
  : Construire les taux de retraités par sexe, âge et année
- [`ajouter_retraites()`](https://patrickaubert.github.io/pilotretrtools/reference/ajouter_retraites.md)
  : Ajouter les retraités à une table de population

## Activité et emploi

- [`lire_taux_emploi_eec()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_taux_emploi_eec.md)
  : Lire les taux d'emploi observés de l'enquête Emploi
- [`lire_taux_activite_ppa()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_taux_activite_ppa.md)
  : Lire les taux d'activité des projections de population active de
  l'Insee
- [`lire_hypotheses_cor()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_hypotheses_cor.md)
  : Lire les hypothèses d'emploi et de chômage du COR
- [`construire_taux_activite()`](https://patrickaubert.github.io/pilotretrtools/reference/construire_taux_activite.md)
  : Construire les taux d'activité et d'emploi par âge fin
- [`lire_taux_activite_publies()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_taux_activite_publies.md)
  : Rassembler les taux d'activité, d'emploi et de chômage publiés
- [`ajouter_actifs()`](https://patrickaubert.github.io/pilotretrtools/reference/ajouter_actifs.md)
  : Ajouter les actifs et les actifs occupés à une table de population

## Décomposition

- [`mortalite_annee()`](https://patrickaubert.github.io/pilotretrtools/reference/reference_mortalite.md)
  [`mortalite_generation()`](https://patrickaubert.github.io/pilotretrtools/reference/reference_mortalite.md)
  [`mortalite_annee_age()`](https://patrickaubert.github.io/pilotretrtools/reference/reference_mortalite.md)
  : Définir une mortalité de référence
- [`projeter_mortalite_reference()`](https://patrickaubert.github.io/pilotretrtools/reference/projeter_mortalite_reference.md)
  : Projeter la population avec une mortalité de référence
- [`decomposer_evolutions()`](https://patrickaubert.github.io/pilotretrtools/reference/decomposer_evolutions.md)
  : Décomposer les évolutions du nombre de retraités et du rapport
  démographique

## Ruptures de champ géographique

- [`lire_pop_champs_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_pop_champs_insee.md)
  : Lire la population par âge détaillé dans les différents champs
  géographiques
- [`calculer_coef_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/calculer_coef_champ.md)
  : Calculer les coefficients de champ à partir des publications de
  l'Insee
- [`estimer_coef_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/estimer_coef_champ.md)
  : Estimer les coefficients de correction des ruptures de champ
  géographique
- [`corriger_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/corriger_champ.md)
  : Corriger les ruptures de champ géographique
