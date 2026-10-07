# Construire la base complète : population, retraités, actifs

Enchaîne toutes les étapes de construction de la base démographique du
package et renvoie une table par sexe, année et âge comportant la
population, les retraités, les actifs et les actifs occupés :

## Usage

``` r
construire_base(
  url_scenario = url_source("projpop"),
  hyp_mortalite = "central",
  chomage = 7,
  horizon = 2180,
  prolongation_mortalite = c("constante", "tendance"),
  serie_historique = TRUE,
  corriger_champ = TRUE
)
```

## Arguments

- url_scenario:

  Adresse du fichier du scénario des projections de population de
  l'Insee ; par défaut le scénario central.

- hyp_mortalite:

  Hypothèse de mortalité de l'Insee à associer au scénario (onglets du
  fichier de mortalité prolongée).

- chomage:

  Hypothèse de taux de chômage de long terme du COR, en % (5, 7 ou 10).

- horizon:

  Dernière année de la base.

- prolongation_mortalite:

  Mortalité au-delà de la dernière année projetée par l'Insee :
  `"constante"` ou `"tendance"` (voir
  [`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md)).

- serie_historique:

  Si `TRUE`, la base commence en 1901 (série historique de l'Insee, voir
  [`ajouter_serie_historique()`](https://patrickaubert.github.io/pilotretrtools/reference/ajouter_serie_historique.md))
  ; sinon en 1962.

- corriger_champ:

  Si `TRUE`, les effectifs sont ramenés au champ France entière
  ([`corriger_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/corriger_champ.md)).

## Value

Un tibble par `sexe`, `generation`, `annee`, `age0101` et `age3112`,
avec les colonnes de
[`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md),
celles de
[`ajouter_retraites()`](https://patrickaubert.github.io/pilotretrtools/reference/ajouter_retraites.md)
et celles de
[`ajouter_actifs()`](https://patrickaubert.github.io/pilotretrtools/reference/ajouter_actifs.md).
Les choix de construction sont stockés dans l'attribut `options_base`.

## Details

1.  projections de population de l'Insee, prolongées jusqu'à `horizon`
    ([`lire_projpop_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_projpop_insee.md),
    [`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md)),
    avec les coefficients de correction des ruptures de champ
    ([`calculer_coef_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/calculer_coef_champ.md))
    et, éventuellement, la série historique depuis 1901
    ([`ajouter_serie_historique()`](https://patrickaubert.github.io/pilotretrtools/reference/ajouter_serie_historique.md))
    ;

2.  correction des ruptures de champ
    ([`corriger_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/corriger_champ.md)),
    si demandée ;

3.  taux de retraités
    ([`construire_taux_retraites()`](https://patrickaubert.github.io/pilotretrtools/reference/construire_taux_retraites.md))
    et nombres de retraités
    ([`ajouter_retraites()`](https://patrickaubert.github.io/pilotretrtools/reference/ajouter_retraites.md))
    ;

4.  taux d'activité et d'emploi pour l'hypothèse de chômage retenue
    ([`construire_taux_activite()`](https://patrickaubert.github.io/pilotretrtools/reference/construire_taux_activite.md))
    et nombres d'actifs et d'actifs occupés
    ([`ajouter_actifs()`](https://patrickaubert.github.io/pilotretrtools/reference/ajouter_actifs.md)).

Pour le scénario central (valeurs par défaut des arguments), la fonction
utilise les tables embarquées dans le package
([projpop_central](https://patrickaubert.github.io/pilotretrtools/reference/projpop_central.md),
[taux_retraites_central](https://patrickaubert.github.io/pilotretrtools/reference/taux_retraites_central.md),
[taux_activite_central](https://patrickaubert.github.io/pilotretrtools/reference/taux_activite_central.md))
et fonctionne hors ligne. Pour toute variante, les tables concernées
sont reconstruites à partir des fichiers de l'Insee et du COR, ce qui
suppose un accès à internet (les fichiers téléchargés sont conservés en
cache).

## Examples

``` r
if (FALSE) { # \dontrun{
base <- construire_base()
base_chomage_10 <- construire_base(chomage = 10)
} # }
```
