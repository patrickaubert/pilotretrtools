#' Lire la population par âge détaillé dans les différents champs géographiques
#'
#' Lit le tableau POP3 des données nationales de l'Insee (population au
#' 1er janvier par sexe et âge détaillé), qui comporte un onglet par année
#' et, pour chaque année, la population de la France métropolitaine et celle
#' du champ « France » de l'époque (France hors Mayotte jusqu'en 2013, France
#' entière à partir de 2014).
#'
#' Les groupes ouverts (« 100 ou plus », « 105 ou plus ») sont écartés.
#'
#' @param url Adresse (ou chemin local) du fichier.
#' @param annees Années (onglets) à lire.
#'
#' @return Un tibble par `annee`, `champ` (`"metropole"`,
#'   `"france_hors_mayotte"` ou `"france"`), `sexe`, `generation` et
#'   `age3112`, avec la colonne `population` (au 1er janvier).
#' @export
#' @examples
#' \dontrun{
#' lire_pop_champs_insee(annees = c(1995, 2013, 2014))
#' }
lire_pop_champs_insee <- function(url = url_source("popchamp"),
                                  annees = c(1995, 2013, 2014)) {
  fichier <- telecharger_source(url)
  dplyr::bind_rows(lapply(annees, function(annee) {
    lire_onglet_pop_champs(fichier, annee)
  }))
}

lire_onglet_pop_champs <- function(fichier, annee) {
  brut <- openxlsx::read.xlsx(fichier, sheet = as.character(annee),
                              colNames = FALSE, skipEmptyRows = FALSE,
                              skipEmptyCols = FALSE)
  texte <- matrix(vapply(brut, as.character, character(nrow(brut))),
                  nrow = nrow(brut))
  texte <- trimws(texte)
  ligne_entete <- which(apply(texte, 1, function(l) {
    any(grepl("^\u00c2ge", l)) && any(l %in% "Hommes")
  }))[1]
  if (is.na(ligne_entete)) {
    stop("En-t\u00eate introuvable dans l'onglet ", annee, ".", call. = FALSE)
  }
  col_age <- which(grepl("^\u00c2ge", texte[ligne_entete, ]))[1]

  # libellés de champ : ligne au-dessus de l'en-tête, reportés vers la droite
  libelles <- texte[ligne_entete - 1, ]
  for (j in seq_along(libelles)[-1]) {
    if (is.na(libelles[j])) libelles[j] <- libelles[j - 1]
  }
  champs <- c("France m\u00e9tropolitaine" = "metropole",
              "France hors Mayotte" = "france_hors_mayotte",
              "France" = "france")

  # lignes d'âge détaillé : premier bloc continu d'âges numériques
  age_brut <- texte[seq(ligne_entete + 1, nrow(texte)), col_age]
  est_age <- grepl("^[0-9]+$", age_brut)
  debut <- which(est_age)[1]
  fin <- debut - 1 + (which(!est_age[seq(debut, length(est_age))])[1] - 1)
  if (is.na(fin)) fin <- length(est_age)
  lignes <- ligne_entete + seq(debut, fin)
  age0101 <- as.numeric(texte[lignes, col_age])

  sorties <- list()
  for (j in which(texte[ligne_entete, ] %in% c("Hommes", "Femmes"))) {
    champ <- champs[libelles[j]]
    if (is.na(champ)) next
    sorties[[length(sorties) + 1]] <- tibble::tibble(
      annee = annee,
      champ = unname(champ),
      sexe = if (texte[ligne_entete, j] == "Hommes") "H" else "F",
      age3112 = age0101 + 1,
      population = en_nombre(texte[lignes, j])
    )
  }
  sortie <- dplyr::bind_rows(sorties)
  sortie$generation <- sortie$annee - sortie$age3112
  sortie[c("annee", "champ", "sexe", "generation", "age3112", "population")]
}

#' Calculer les coefficients de champ à partir des publications de l'Insee
#'
#' Calcule, par génération et par sexe, les coefficients qui ramènent les
#' effectifs d'un ancien champ géographique au nouveau, à partir des
#' populations publiées par l'Insee dans les deux champs (voir
#' [lire_pop_champs_insee()]) :
#'
#' * **1995** (ajout des DROM hors Mayotte) : rapport, au 1er janvier 1995,
#'   de la population France hors Mayotte à la population de la France
#'   métropolitaine ;
#' * **2014** (ajout de Mayotte) : l'Insee ne publiant pas l'année 2014 dans
#'   le champ France hors Mayotte, le coefficient est approché par le rapport
#'   France / France métropolitaine de 2014 divisé par le rapport France hors
#'   Mayotte / France métropolitaine de 2013, pour la même génération. Cela
#'   suppose que le poids des DROM hors Mayotte par rapport à la métropole ne
#'   varie pas d'une année sur l'autre au sein d'une génération. La
#'   génération née en 2013, absente au 1er janvier 2013, reçoit le
#'   coefficient de la génération précédente.
#'
#' Les coefficients sont bornés à 1 : un changement de champ qui ajoute un
#' territoire ne peut pas réduire l'effectif d'une génération. Pour 2014,
#' quelques générations âgées présentent un rapport très légèrement
#' inférieur à 1 (écart de l'ordre de 0,01 %), qui reflète les petites
#' variations du poids des DROM entre 2013 et 2014.
#'
#' @param pop_champs Table produite par [lire_pop_champs_insee()], contenant
#'   au moins les années 1995, 2013 et 2014.
#'
#' @return Un tibble par `rupture`, `sexe` et `generation`, avec `coef` et
#'   `estime` (`TRUE` lorsque le coefficient est calculé, `FALSE` lorsqu'il
#'   est repris d'une génération voisine). Il peut être passé à l'argument
#'   `coef_champ` de [prolonger_projpop()].
#' @export
calculer_coef_champ <- function(pop_champs) {
  manquantes <- setdiff(c(1995, 2013, 2014), pop_champs$annee)
  if (length(manquantes) > 0) {
    stop("Ann\u00e9es absentes de `pop_champs` : ",
         paste(manquantes, collapse = ", "), call. = FALSE)
  }
  rapport <- function(annee, numerateur) {
    pop_champs |>
      dplyr::filter(.data$annee == !!annee,
                    .data$champ %in% c(numerateur, "metropole")) |>
      dplyr::select("champ", "sexe", "generation", "population") |>
      tidyr::pivot_wider(names_from = "champ", values_from = "population") |>
      dplyr::transmute(.data$sexe, .data$generation,
                       rapport = .data[[numerateur]] / .data$metropole)
  }

  drom <- rapport(1995, "france_hors_mayotte") |>
    dplyr::transmute(rupture = 1995, .data$sexe, .data$generation,
                     coef = .data$rapport)

  mayotte <- rapport(2014, "france") |>
    dplyr::left_join(rapport(2013, "france_hors_mayotte"),
                     by = c("sexe", "generation"),
                     suffix = c("_2014", "_2013")) |>
    dplyr::transmute(rupture = 2014, .data$sexe, .data$generation,
                     coef = .data$rapport_2014 / .data$rapport_2013)

  dplyr::bind_rows(drom, mayotte) |>
    dplyr::mutate(estime = is.finite(.data$coef),
                  coef = dplyr::if_else(.data$estime, pmax(.data$coef, 1),
                                        NA_real_)) |>
    dplyr::arrange(.data$rupture, .data$sexe, .data$generation) |>
    dplyr::group_by(.data$rupture, .data$sexe) |>
    tidyr::fill("coef", .direction = "updown") |>
    dplyr::ungroup()
}
