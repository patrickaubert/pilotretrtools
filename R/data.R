#' Projections de population de l'Insee, scénario central, prolongées
#'
#' Scénario central des projections de population de l'Insee (millésime
#' 2026), avec l'hypothèse centrale de mortalité, prolongé jusqu'en 2180 par
#' [prolonger_projpop()] (quotients de mortalité de 2125 reconduits). Les
#' effectifs sont dans le champ publié pour chaque année ; voir
#' [corriger_champ()] pour des séries homogènes en France entière, et
#' `vignette("ecarts-insee")` pour les écarts avec les données publiées.
#' Les années 1901 à 1961 (hors années manquantes de la première guerre mondiale)
#' sont ajoutées par [ajouter_serie_historique()], à partir des publications
#' de l'Insee sur la démographie.
#'
#' @format Un tibble par `sexe`, `generation`, `annee`, `age0101` et
#'   `age3112`, avec les colonnes :
#'   * `population` : population au 1er janvier ;
#'   * `naissances` : naissances de l'année, par sexe, sur les lignes d'âge 0
#'     (`NA` aux autres âges) ;
#'   * `deces`, `qx`, `solde_migratoire`, `ajustement` : décès, quotient de
#'     mortalité, solde migratoire et ajustement de l'année ;
#'   * `population3112` : population au 31 décembre ;
#'   * `prolonge` : `TRUE` pour les effectifs calculés par la fonction ;
#'   * `champ` : champ géographique des données de l'année (voir
#'     [champ_insee()]) ;
#'   * `coef_champ` : coefficient multiplicatif ramenant les effectifs au
#'     champ géographique le plus récent (voir [corriger_champ()]).
#' @source Insee, projections de population 2026 (Licence Ouverte Etalab) ;
#'   voir `sources_donnees(c("projpop", "projmort"))`.
"projpop_central"