#' Registre des sources de données
#'
#' Renvoie la table des fichiers sources utilisés par le package (organisme,
#' publication, millésime, scénario, adresse). Ce registre, stocké dans
#' `inst/extdata/sources.csv`, est le seul endroit à modifier lorsqu'un
#' organisme publie une version actualisée de ses projections.
#'
#' @param objet Filtre facultatif sur le type de données (par exemple
#'   `"projpop"` ou `"projmort"`).
#'
#' @return Un tibble.
#' @export
#' @examples
#' sources_donnees()
#' sources_donnees("projpop")
sources_donnees <- function(objet = NULL) {
  fichier <- system.file("extdata", "sources.csv", package = "pilotretrtools")
  registre <- utils::read.csv(fichier, encoding = "UTF-8",
                              stringsAsFactors = FALSE)
  registre <- tibble::as_tibble(registre)
  if (!is.null(objet)) {
    registre <- registre[registre$objet %in% objet, ]
  }
  registre
}

#' Adresse d'un fichier source
#'
#' Renvoie l'adresse du fichier correspondant à un type de données, un
#' scénario et un millésime. Par défaut, le millésime le plus récent du
#' registre est retenu.
#'
#' @param objet Type de données (voir [sources_donnees()]).
#' @param scenario Scénario (par défaut `"central"`).
#' @param millesime Millésime ; `NULL` pour le plus récent.
#'
#' @return Une chaîne de caractères.
#' @export
#' @examples
#' url_source("projpop")
url_source <- function(objet, scenario = "central", millesime = NULL) {
  registre <- sources_donnees(objet)
  registre <- registre[registre$scenario %in% c(scenario, "tous"), ]
  if (!is.null(millesime)) {
    registre <- registre[registre$millesime == millesime, ]
  }
  if (nrow(registre) == 0) {
    stop("Aucune source pour objet = \"", objet, "\", sc\u00e9nario = \"",
         scenario, "\".", call. = FALSE)
  }
  registre$url[which.max(registre$millesime)]
}
