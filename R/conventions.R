#' Vérifier qu'une table respecte la grille commune du package
#'
#' Toutes les tables « longues » du package partagent les mêmes clés et les
#' mêmes conventions d'âge :
#'
#' * `annee` : année civile ;
#' * `age3112` : âge atteint au cours de l'année (âge révolu au 31 décembre) ;
#' * `age0101` : âge révolu au 1er janvier, égal à `age3112 - 1` ;
#' * `generation` : année de naissance, égale à `annee - age3112` ;
#' * `sexe` (optionnel) : `"F"` ou `"H"`.
#'
#' La fonction vérifie la présence des clés, la cohérence des colonnes
#' dérivées lorsqu'elles sont présentes et l'absence de doublons.
#'
#' @param x Une table (data.frame ou tibble).
#' @param cles Colonnes identifiant une ligne. Par défaut, `sexe` (si présent),
#'   `annee` et `age3112`.
#'
#' @return `x`, de manière invisible. Une erreur est levée si une convention
#'   n'est pas respectée.
#' @export
#' @examples
#' grille <- data.frame(sexe = "F", annee = 2030, age3112 = 60:62)
#' grille$generation <- grille$annee - grille$age3112
#' valider_grille(grille)
valider_grille <- function(x, cles = NULL) {
  if (!is.data.frame(x)) {
    stop("`x` doit \u00eatre un data.frame.", call. = FALSE)
  }
  if (is.null(cles)) {
    cles <- intersect(c("sexe", "annee", "age3112"), names(x))
  }
  manquantes <- setdiff(c("annee", "age3112"), names(x))
  if (length(manquantes) > 0) {
    stop("Colonnes obligatoires absentes : ",
         paste(manquantes, collapse = ", "), call. = FALSE)
  }
  if ("generation" %in% names(x) &&
      any(x$generation != x$annee - x$age3112, na.rm = TRUE)) {
    stop("`generation` doit \u00eatre \u00e9gale \u00e0 `annee - age3112`.",
         call. = FALSE)
  }
  if ("age0101" %in% names(x) &&
      any(x$age0101 != x$age3112 - 1, na.rm = TRUE)) {
    stop("`age0101` doit \u00eatre \u00e9gal \u00e0 `age3112 - 1`.", call. = FALSE)
  }
  if ("sexe" %in% names(x) && !all(x$sexe %in% c("F", "H"))) {
    stop("`sexe` ne peut prendre que les valeurs \"F\" et \"H\".",
         call. = FALSE)
  }
  if (anyDuplicated(x[cles]) > 0) {
    stop("Doublons sur les cl\u00e9s : ", paste(cles, collapse = ", "),
         call. = FALSE)
  }
  invisible(x)
}

# Ajoute les colonnes dérivées de la grille, dans l'ordre conventionnel.
completer_grille <- function(x) {
  x$generation <- x$annee - x$age3112
  x$age0101 <- x$age3112 - 1
  premieres <- intersect(c("sexe", "generation", "annee", "age0101", "age3112"),
                         names(x))
  x[c(premieres, setdiff(names(x), premieres))]
}
