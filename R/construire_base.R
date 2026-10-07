#' Construire la base complète : population, retraités, actifs
#'
#' Enchaîne toutes les étapes de construction de la base démographique du
#' package et renvoie une table par sexe, année et âge comportant la
#' population, les retraités, les actifs et les actifs occupés :
#'
#' 1. projections de population de l'Insee, prolongées jusqu'à `horizon`
#'    ([lire_projpop_insee()], [prolonger_projpop()]), avec les coefficients
#'    de correction des ruptures de champ ([calculer_coef_champ()]) et,
#'    éventuellement, la série historique depuis 1901
#'    ([ajouter_serie_historique()]) ;
#' 2. correction des ruptures de champ ([corriger_champ()]), si demandée ;
#' 3. taux de retraités ([construire_taux_retraites()]) et nombres de
#'    retraités ([ajouter_retraites()]) ;
#' 4. taux d'activité et d'emploi pour l'hypothèse de chômage retenue
#'    ([construire_taux_activite()]) et nombres d'actifs et d'actifs occupés
#'    ([ajouter_actifs()]).
#'
#' Pour le scénario central (valeurs par défaut des arguments), la fonction
#' utilise les tables embarquées dans le package ([projpop_central],
#' [taux_retraites_central], [taux_activite_central]) et fonctionne hors
#' ligne. Pour toute variante, les tables concernées sont reconstruites à
#' partir des fichiers de l'Insee et du COR, ce qui suppose un accès à
#' internet (les fichiers téléchargés sont conservés en cache).
#'
#' @param url_scenario Adresse du fichier du scénario des projections de
#'   population de l'Insee ; par défaut le scénario central.
#' @param hyp_mortalite Hypothèse de mortalité de l'Insee à associer au
#'   scénario (onglets du fichier de mortalité prolongée).
#' @param chomage Hypothèse de taux de chômage de long terme du COR, en %
#'   (5, 7 ou 10).
#' @param horizon Dernière année de la base.
#' @param prolongation_mortalite Mortalité au-delà de la dernière année
#'   projetée par l'Insee : `"constante"` ou `"tendance"` (voir
#'   [prolonger_projpop()]).
#' @param serie_historique Si `TRUE`, la base commence en 1901 (série
#'   historique de l'Insee, voir [ajouter_serie_historique()]) ; sinon en
#'   1962.
#' @param corriger_champ Si `TRUE`, les effectifs sont ramenés au champ
#'   France entière ([corriger_champ()]).
#'
#' @return Un tibble par `sexe`, `generation`, `annee`, `age0101` et
#'   `age3112`, avec les colonnes de [prolonger_projpop()], celles de
#'   [ajouter_retraites()] et celles de [ajouter_actifs()]. Les choix de
#'   construction sont stockés dans l'attribut `options_base`.
#' @export
#' @examples
#' \dontrun{
#' base <- construire_base()
#' base_chomage_10 <- construire_base(chomage = 10)
#' }
construire_base <- function(url_scenario = url_source("projpop"),
                            hyp_mortalite = "central",
                            chomage = 7,
                            horizon = 2180,
                            prolongation_mortalite = c("constante", "tendance"),
                            serie_historique = TRUE,
                            corriger_champ = TRUE) {
  prolongation_mortalite <- match.arg(prolongation_mortalite)
  population <- donnees_package("projpop_central")
  centrale <- identical(unname(attr(population, "sources")[["scenario"]]),
                        url_scenario) &&
    hyp_mortalite == "central" && horizon == max(population$annee) &&
    prolongation_mortalite == "constante"

  # 1. population
  if (!centrale) {
    message("Reconstruction de la population \u00e0 partir des fichiers de ",
            "l'Insee...")
    population <- prolonger_projpop(
      lire_projpop_insee(url_scenario, hyp_mortalite = hyp_mortalite),
      horizon = horizon, prolongation_mortalite = prolongation_mortalite,
      coef_champ = calculer_coef_champ(lire_pop_champs_insee()))
    if (serie_historique) population <- ajouter_serie_historique(population)
  } else if (!serie_historique) {
    historiques <- attr(population, "parametres")$annees_historiques
    attributs <- attributes(population)
    population <- population[!population$annee %in% historiques, ]
    attributes(population)[c("parametres", "sources", "coef_champ")] <-
      attributs[c("parametres", "sources", "coef_champ")]
  }

  # 2. champ
  if (corriger_champ) population <- corriger_champ(population)

  # 3. retraités
  taux_retraites <- donnees_package("taux_retraites_central")
  if (horizon > max(taux_retraites$annee)) {
    taux_retraites <- construire_taux_retraites(
      lire_taux_retraites_cor(), annees = seq(min(taux_retraites$annee),
                                              horizon))
  }
  population <- ajouter_retraites(population, taux_retraites)

  # 4. actifs et actifs occupés
  taux_activite <- donnees_package("taux_activite_central")
  if (!centrale || chomage != attr(taux_activite, "hypothese_chomage")) {
    message("Reconstruction des taux d'activit\u00e9 et d'emploi \u00e0 partir ",
            "des fichiers de l'Insee et du COR...")
    taux_activite <- construire_taux_activite(
      lire_taux_emploi_eec(), lire_taux_activite_ppa(),
      lire_hypotheses_cor(chomage = chomage), population = population,
      horizon = horizon)
  }
  population <- ajouter_actifs(population, taux_activite)

  attr(population, "options_base") <- list(
    url_scenario = url_scenario, hyp_mortalite = hyp_mortalite,
    chomage = chomage, horizon = horizon,
    prolongation_mortalite = prolongation_mortalite,
    serie_historique = serie_historique, corriger_champ = corriger_champ,
    tables_embarquees = centrale &&
      chomage == attr(donnees_package("taux_activite_central"),
                      "hypothese_chomage"))
  population
}
