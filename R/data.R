# Documentation des tables embarquées dans le package. Chaque table est
# construite par un script du dossier data-raw/.

#' Projections de population de l'Insee, scénario central, prolongées
#'
#' Population par sexe, génération, année et âge du scénario central des
#' projections de population de l'Insee (millésime 2026, hypothèse centrale
#' de mortalité), prolongé jusqu'en 2180 par [prolonger_projpop()] (quotients
#' de mortalité de 2125 reconduits) et précédé des séries historiques de
#' 1901 à 1961 ([ajouter_serie_historique()]).
#'
#' Les effectifs sont ceux du champ publié pour chaque année (colonne
#' `champ`) : [corriger_champ()] les ramène au champ France entière. Les
#' écarts avec les données publiées sont détaillés dans
#' `vignette("ecarts-insee")`. Construite par `data-raw/projpop_central.R`.
#'
#' @format Un tibble par `sexe`, `generation`, `annee`, `age0101` et
#'   `age3112` (de 0 à 120 ans), avec `population` (au 1er janvier),
#'   `naissances`, `deces`, `qx`, `solde_migratoire`, `ajustement`,
#'   `population3112` (au 31 décembre), `prolonge`, `champ` et `coef_champ` ;
#'   voir la section « Value » de [prolonger_projpop()]. Les paramètres de
#'   construction, les sources et les coefficients de champ sont dans les
#'   attributs `parametres`, `sources` et `coef_champ`.
#' @source Insee, projections de population 2026, estimations de population
#'   (tableau POP3) ; Licence Ouverte Etalab. Voir
#'   `sources_donnees(c("projpop", "projmort", "popchamp"))`.
"projpop_central"

#' Taux de retraités rétrospectifs construits à partir des EIR
#'
#' Taux de retraités au 31 décembre et taux de nouveaux retraités par sexe,
#' génération et âge, construits à partir des échantillons interrégimes de
#' retraités (EIR) de la DREES empilés et rétropolés. Les générations
#' observées dans les EIR (1906, 1909, 1912, ..., 1940, puis 1942 à 1950)
#' sont complétées par interpolation linéaire entre générations observées, à
#' sexe et âge donnés ([interpoler_generations()]). Construite par
#' `data-raw/taux_retraites_eir.R`.
#'
#' @format Un tibble avec les colonnes :
#' \describe{
#'   \item{sexe}{`"F"` ou `"H"`.}
#'   \item{generation}{Année de naissance.}
#'   \item{annee}{Année.}
#'   \item{age3112}{Âge atteint dans l'année (de 50 à 70 ans).}
#'   \item{tx_retraites}{Part de retraités au 31 décembre.}
#'   \item{tx_nouveaux_retraites}{Part de nouveaux retraités dans l'année.}
#'   \item{interpole}{`TRUE` pour les générations interpolées.}
#' }
#' @source DREES, échantillons interrégimes de retraités ; calculs de
#'   l'auteur.
"taux_retraites_eir"

#' Taux de retraités du scénario central
#'
#' Taux de retraités au 31 décembre et taux de nouveaux retraités par sexe,
#' année et âge, construits par [construire_taux_retraites()] à partir des
#' taux projetés par le COR (rapport annuel de 2025) et des taux
#' rétrospectifs construits à partir des EIR ([taux_retraites_eir]).
#' Construite par `data-raw/tables_centrales.R`.
#'
#' @format Un tibble par `sexe`, `annee` et `age3112`, avec `tx_retraites`,
#'   `tx_nouveaux_retraites` et `source_tx_retraites` ; voir la section
#'   « Value » de [construire_taux_retraites()].
#' @source COR, données complémentaires du rapport annuel de juin 2025 ;
#'   DREES, échantillons interrégimes de retraités. Voir
#'   `sources_donnees("txretr")`.
"taux_retraites_central"

#' Taux d'activité, d'emploi et de chômage par âge fin, scénario central
#'
#' Taux d'activité, d'emploi et de chômage par sexe, année et âge fin,
#' construits par [construire_taux_activite()] à partir de l'enquête Emploi
#' et des projections de population active de l'Insee et des hypothèses du
#' COR (hypothèse de chômage de long terme de 7 %, stockée dans l'attribut
#' `hypothese_chomage`). Les taux sont lissés par âge fin par le package
#' ([lisser_par_age()], avec les effectifs de [projpop_central]) : ils ne
#' correspondent pas aux taux publiés, qui sont rassemblés dans
#' [taux_activite_publies]. Construite par `data-raw/tables_centrales.R`.
#'
#' @format Un tibble par `sexe`, `annee` et `age3112`, avec `tx_activite`,
#'   `tx_emploi`, `tx_chomage`, `source_tx_emploi` et `source_tx_activite` ;
#'   voir la section « Value » de [construire_taux_activite()].
#' @source Insee, enquête Emploi (séries longues) et projections de
#'   population active ; COR, hypothèses ventilées par sexe et âge (2025).
#'   Voir `sources_donnees(c("txempl_obs", "txact", "txempl_proj"))`.
"taux_activite_central"

#' Taux d'activité, d'emploi et de chômage publiés, par tranche d'âge
#'
#' Taux par sexe et tranche d'âge, sans lissage, tels que publiés par
#' l'Insee (taux d'emploi de l'enquête Emploi, taux d'activité des
#' projections de population active) et par le COR (taux d'emploi et de
#' chômage pour chacune des hypothèses de chômage de long terme, taux
#' d'activité déduits). Ce sont les données de départ de
#' [construire_taux_activite()]. Construite par `data-raw/tables_centrales.R`
#' avec [lire_taux_activite_publies()].
#'
#' @format Un tibble avec `source`, `hypothese_chomage`, `sexe`, `annee`,
#'   `age_debut`, `age_fin`, `tx_emploi`, `tx_activite` et `tx_chomage` ;
#'   voir la section « Value » de [lire_taux_activite_publies()].
#' @source Insee, enquête Emploi (séries longues) et projections de
#'   population active ; COR, hypothèses ventilées par sexe et âge (2025).
"taux_activite_publies"
