#' Champ géographique des séries de l'Insee
#'
#' Renvoie, pour chaque année, le champ géographique des séries de
#' population de l'Insee :
#'
#' * `"metropole_hors_alsace_moselle"` : 1901-1914 (frontières de 1871) et
#'   1939-1945, sauf 1944 ;
#' * `"metropole_hors_alsace_moselle_corse"` : 1944 ;
#' * `"metropole"` : 1920-1938 et 1946-1994 ;
#' * `"france_hors_mayotte"` : 1995-2013 ;
#' * `"france"` : à partir de 2014.
#'
#' @param annee Années.
#'
#' @return Un vecteur de libellés (`NA` pour les années 1915 à 1919, non
#'   couvertes par les séries).
#' @export
#' @examples
#' champ_insee(c(1910, 1944, 1980, 2000, 2030))
champ_insee <- function(annee) {
  dplyr::case_when(
    annee <= 1914 ~ "metropole_hors_alsace_moselle",
    annee <= 1919 ~ NA_character_,
    annee <= 1938 ~ "metropole",
    annee == 1944 ~ "metropole_hors_alsace_moselle_corse",
    annee <= 1945 ~ "metropole_hors_alsace_moselle",
    annee <= 1994 ~ "metropole",
    annee <= 2013 ~ "france_hors_mayotte",
    TRUE ~ "france"
  )
}

#' Ajouter les séries historiques de population
#'
#' Ajoute au début d'une table de population (produite par
#' [prolonger_projpop()]) les populations au 1er janvier par sexe et âge
#' détaillé des années antérieures, tirées du tableau POP3 de l'Insee
#' (France métropolitaine depuis 1901), afin de disposer des séries les plus
#' longues possibles.
#'
#' Pour ces années :
#'
#' * seules les populations au 1er janvier sont disponibles ; la population
#'   au 31 décembre est celle de la même génération au 1er janvier suivant
#'   (manquante lorsque l'année suivante n'est pas couverte) ; les décès, les
#'   quotients de mortalité, les soldes migratoires et les naissances sont
#'   manquants ;
#' * les âges couverts par le groupe ouvert (« 99 ou plus » ou « 100 ou
#'   plus » selon les années) sont manquants ;
#' * les années 1915 à 1919, absentes du tableau, ne sont pas ajoutées ;
#' * le champ géographique varie (voir [champ_insee()]) : l'Alsace-Moselle
#'   est exclue de 1901 à 1914 et de 1939 à 1945 (ainsi que la Corse en
#'   1944). Ces ruptures ne sont pas corrigées : seule la colonne `champ` les
#'   signale. La colonne `coef_champ` corrige, comme pour les années
#'   suivantes, l'absence des DROM et de Mayotte.
#'
#' @param population Table produite par [prolonger_projpop()].
#' @param url Adresse (ou chemin local) du tableau POP3.
#' @param annees Années à ajouter ; par défaut toutes celles du tableau
#'   antérieures à la première année de `population`.
#'
#' @return La table complétée, triée, avec les mêmes colonnes et attributs.
#'   L'attribut `parametres` indique les années historiques ajoutées.
#' @export
#' @examples
#' \dontrun{
#' projpop <- prolonger_projpop(lire_projpop_insee()) |>
#'   ajouter_serie_historique()
#' }
ajouter_serie_historique <- function(population, url = url_source("popchamp"),
                                     annees = NULL) {
  premiere <- min(population$annee)
  disponibles <- suppressWarnings(as.numeric(
    openxlsx::getSheetNames(telecharger_source(url))))
  if (is.null(annees)) annees <- disponibles[disponibles < premiere]
  annees <- sort(intersect(annees, disponibles[disponibles < premiere]))
  if (length(annees) == 0) {
    message("Aucune ann\u00e9e historique \u00e0 ajouter.")
    return(population)
  }
  attributs <- attributes(population)[c("parametres", "sources",
                                        "coef_champ", "champ_corrige")]
  attributs <- attributs[!vapply(attributs, is.null, logical(1))]

  historique <- lire_pop_champs_insee(url, annees) |>
    dplyr::filter(.data$champ == "metropole") |>
    dplyr::select("sexe", "annee", "age3112", "population")
  age_max <- max(population$age3112)
  historique <- tidyr::expand_grid(sexe = c("F", "H"), annee = annees,
                                   age3112 = seq(0, age_max)) |>
    dplyr::left_join(historique, by = c("sexe", "annee", "age3112")) |>
    dplyr::mutate(population = dplyr::if_else(.data$age3112 == 0, 0,
                                              .data$population))

  # population au 31/12 : même génération au 1er janvier suivant
  suivante <- dplyr::bind_rows(
    historique,
    population[population$annee == premiere,
               c("sexe", "annee", "age3112", "population")]
  ) |>
    dplyr::transmute(.data$sexe, annee = .data$annee - 1,
                     age3112 = .data$age3112 - 1,
                     population3112 = .data$population)
  historique <- historique |>
    dplyr::left_join(suivante, by = c("sexe", "annee", "age3112")) |>
    dplyr::mutate(prolonge = FALSE, coef_champ = 1) |>
    completer_grille()

  # coefficients des ruptures de champ, étendus aux générations anciennes
  if (!is.null(attributs$coef_champ)) {
    coefficients <- completer_coef_champ(
      attributs$coef_champ[c("rupture", "sexe", "generation", "coef",
                             "estime")],
      dplyr::bind_rows(historique, population))
    historique <- appliquer_coef_champ(historique, coefficients)
    attributs$coef_champ <- coefficients
  }

  sortie <- dplyr::bind_rows(historique, population) |>
    dplyr::mutate(champ = champ_insee(.data$annee)) |>
    dplyr::arrange(.data$sexe, .data$annee, .data$age3112)
  sortie <- sortie[union(names(population), "champ")]
  valider_grille(sortie)
  attributs$parametres$annees_historiques <- annees
  attributes(sortie)[names(attributs)] <- attributs
  sortie
}
