#' Interpoler entre générations
#'
#' Complète une table disponible pour certaines générations seulement (par
#' exemple les générations de l'échantillon interrégimes de retraités, EIR)
#' par interpolation linéaire entre générations observées, pour chaque
#' combinaison des variables de `groupes` (par défaut à sexe et âge donnés).
#' Les générations sont complétées entre la plus ancienne et la plus récente
#' observées dans chaque groupe ; aucune extrapolation n'est faite au-delà.
#'
#' @param donnees Table contenant une colonne `generation`, les colonnes de
#'   `groupes` et les colonnes de `variables`.
#' @param variables Colonnes numériques à interpoler.
#' @param groupes Colonnes définissant les groupes au sein desquels
#'   l'interpolation est faite.
#'
#' @return La table complétée, avec une colonne `interpole` (`TRUE` pour les
#'   générations ajoutées). Si la table contient `annee` et `age3112`,
#'   `annee` est recalculée pour les lignes ajoutées.
#' @export
#' @examples
#' x <- data.frame(sexe = "F", age3112 = 60, generation = c(1940, 1944),
#'                 tx = c(0.2, 0.6))
#' interpoler_generations(x, "tx")
interpoler_generations <- function(donnees, variables,
                                   groupes = c("sexe", "age3112")) {
  interpoler <- function(x, y) {
    connus <- !is.na(y)
    if (sum(connus) < 2) return(y)
    stats::approx(x[connus], y[connus], xout = x)$y
  }
  grille <- donnees |>
    dplyr::summarise(premiere = min(.data$generation),
                     derniere = max(.data$generation),
                     .by = dplyr::all_of(groupes)) |>
    dplyr::reframe(generation = seq(.data$premiere, .data$derniere),
                   .by = dplyr::all_of(groupes))

  sortie <- grille |>
    dplyr::left_join(donnees, by = c(groupes, "generation")) |>
    dplyr::arrange(dplyr::across(dplyr::all_of(groupes)), .data$generation) |>
    dplyr::mutate(
      interpole = is.na(.data[[variables[1]]]),
      dplyr::across(dplyr::all_of(variables),
                    ~ interpoler(.data$generation, .x)),
      .by = dplyr::all_of(groupes)
    )
  if (all(c("annee", "age3112") %in% names(sortie))) {
    sortie$annee <- sortie$generation + sortie$age3112
  }
  tibble::as_tibble(sortie)
}
