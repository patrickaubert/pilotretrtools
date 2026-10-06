#' Estimer les coefficients de correction des ruptures de champ géographique
#'
#' Les séries historiques de l'Insee changent de champ géographique : France
#' métropolitaine jusqu'en 1994, France hors Mayotte de 1995 à 2013, France
#' entière à partir de 2014. Ces ruptures sont réelles, mais elles
#' introduisent des sauts dans les séries longues. Cette fonction estime,
#' pour chaque rupture, un coefficient par génération et par sexe qui ramène
#' les effectifs de l'ancien champ au nouveau.
#'
#' Pour une génération et un sexe, on calcule chaque année le rapport
#' \deqn{R(t) = \frac{P(t+1)}{P(t) + N(t) - D(t)}}{R(t) = P(t+1) / (P(t) + N(t) - D(t))}
#' entre la population au 1er janvier suivant et la population de l'année
#' (augmentée des naissances \eqn{N} pour l'âge 0) diminuée des décès. En
#' dehors des ruptures, ce rapport ne reflète que les migrations ; l'année
#' de rupture, il reflète aussi le changement de champ. Le coefficient est
#' le rapport de l'année de rupture divisé par la moyenne des rapports des
#' `annees_voisines` années de part et d'autre, ce qui neutralise la
#' migration « normale ».
#'
#' Le coefficient n'est pas estimé lorsque l'effectif concerné a été
#' reconstitué par [prolonger_projpop()] (grands âges), lorsque le
#' dénominateur est nul, ou pour les générations qui ont quitté la table
#' (au-delà de l'âge maximal) avant la rupture : il est alors repris de la
#' génération la plus proche pour laquelle il l'est. Les générations nées à partir de l'année
#' de rupture n'ont pas de coefficient (elles sont nées dans le nouveau
#' champ).
#'
#' Hypothèse sous-jacente : la part de l'ancien champ dans chaque génération
#' est supposée constante avant la rupture, ce qui ignore les migrations
#' passées entre territoires (par exemple entre les DROM et la métropole).
#' Les coefficients sont bornés à 1.
#'
#' Cette méthode indirecte est imprécise lorsque l'effet de la rupture est
#' du même ordre que les migrations annuelles (cas de Mayotte en 2014). Elle
#' ne sert que de repli : lorsque l'Insee publie les deux champs pour
#' l'année de rupture, [calculer_coef_champ()] est préférable.
#'
#' @param population Table produite par [prolonger_projpop()].
#' @param ruptures Années de rupture (première année dans le nouveau champ).
#' @param annees_voisines Nombre d'années de part et d'autre de la rupture
#'   utilisées pour neutraliser les migrations.
#'
#' @return Un tibble par `rupture`, `sexe` et `generation`, avec le rapport
#'   de l'année de rupture (`ratio_rupture`), la moyenne des rapports voisins
#'   (`ratio_voisins`), le coefficient (`coef`) et `estime` (`FALSE` lorsque
#'   le coefficient est repris d'une génération voisine).
#' @export
estimer_coef_champ <- function(population, ruptures = c(1995, 2014),
                               annees_voisines = 2) {
  base <- population |>
    dplyr::transmute(
      .data$sexe, .data$generation, .data$annee,
      denominateur = .data$population + dplyr::coalesce(.data$naissances, 0) -
        .data$deces,
      .data$prolonge
    )
  suivant <- population |>
    dplyr::transmute(.data$sexe, .data$generation, annee = .data$annee - 1,
                     population_suivante = .data$population,
                     prolonge_suivant = .data$prolonge)
  rapports <- base |>
    dplyr::inner_join(suivant, by = c("sexe", "generation", "annee")) |>
    dplyr::mutate(
      ratio = .data$population_suivante / .data$denominateur,
      fiable = !.data$prolonge & !.data$prolonge_suivant &
        .data$denominateur > 0 & is.finite(.data$ratio)
    )

  generations <- unique(population[c("sexe", "generation")])

  dplyr::bind_rows(lapply(ruptures, function(r) {
    voisines <- setdiff(seq(r - 1 - annees_voisines, r - 1 + annees_voisines),
                        ruptures - 1)
    ratios_voisins <- rapports |>
      dplyr::filter(.data$annee %in% voisines, .data$fiable) |>
      dplyr::summarise(ratio_voisins = mean(.data$ratio),
                       .by = c("sexe", "generation"))
    rapports |>
      dplyr::filter(.data$annee == r - 1, .data$generation < r) |>
      dplyr::select("sexe", "generation", ratio_rupture = "ratio", "fiable") |>
      dplyr::right_join(generations[generations$generation < r, ],
                        by = c("sexe", "generation")) |>
      dplyr::left_join(ratios_voisins, by = c("sexe", "generation")) |>
      dplyr::mutate(
        coef = .data$ratio_rupture / .data$ratio_voisins,
        estime = dplyr::coalesce(.data$fiable, FALSE) & is.finite(.data$coef),
        coef = dplyr::if_else(.data$estime, pmax(.data$coef, 1), NA_real_)
      ) |>
      dplyr::arrange(.data$sexe, .data$generation) |>
      dplyr::group_by(.data$sexe) |>
      tidyr::fill("coef", .direction = "updown") |>
      dplyr::ungroup() |>
      dplyr::mutate(rupture = r) |>
      dplyr::select("rupture", "sexe", "generation", "ratio_rupture",
                    "ratio_voisins", "coef", "estime")
  }))
}

# Complète une table de coefficients pour toutes les générations de la
# population nées avant chaque rupture, en reprenant le coefficient de la
# génération la plus proche.
completer_coef_champ <- function(coefficients, population) {
  generations <- unique(population[c("sexe", "generation")])
  dplyr::bind_rows(lapply(unique(coefficients$rupture), function(r) {
    coefficients[coefficients$rupture == r, ] |>
      dplyr::select(-"rupture") |>
      dplyr::full_join(generations[generations$generation < r, ],
                       by = c("sexe", "generation")) |>
      dplyr::filter(.data$generation < r) |>
      dplyr::mutate(estime = dplyr::coalesce(.data$estime, FALSE),
                    rupture = r) |>
      dplyr::arrange(.data$sexe, .data$generation) |>
      dplyr::group_by(.data$sexe) |>
      tidyr::fill("coef", .direction = "updown") |>
      dplyr::ungroup() |>
      dplyr::relocate("rupture")
  }))
}

# Ajoute la colonne coef_champ : produit des coefficients des ruptures
# postérieures à l'année, pour les générations nées avant ces ruptures.
appliquer_coef_champ <- function(population, coefficients) {
  population$coef_champ <- 1
  for (r in unique(coefficients$rupture)) {
    coef_r <- coefficients[coefficients$rupture == r,
                           c("sexe", "generation", "coef")]
    population <- population |>
      dplyr::left_join(coef_r, by = c("sexe", "generation")) |>
      dplyr::mutate(coef_champ = .data$coef_champ * dplyr::if_else(
        .data$annee < r & !is.na(.data$coef), .data$coef, 1)) |>
      dplyr::select(-"coef")
  }
  population
}

#' Corriger les ruptures de champ géographique
#'
#' Ramène tous les effectifs au champ géographique le plus récent (France
#' entière), en multipliant les effectifs des années antérieures aux
#' ruptures par la colonne `coef_champ` (voir [estimer_coef_champ()]). Sont
#' corrigés la population au 1er janvier, les naissances, les décès et
#' l'ajustement. Pour les années antérieures à la dernière rupture, la
#' population au 31 décembre est prise égale à la population corrigée de la
#' même génération au 1er janvier suivant, et le solde migratoire est
#' recalculé comme résidu, ce qui supprime les sauts liés au changement de
#' champ. Les quotients de mortalité et les taux ne
#' sont pas modifiés.
#'
#' @param population Table produite par [prolonger_projpop()].
#'
#' @return La même table, effectifs corrigés et `coef_champ` égal à 1.
#' @export
#' @examples
#' \dontrun{
#' projpop_central |> corriger_champ()
#' }
corriger_champ <- function(population) {
  if (!"coef_champ" %in% names(population)) {
    stop("La table ne contient pas de colonne `coef_champ`.", call. = FALSE)
  }
  if (all(population$coef_champ == 1)) {
    warning("Aucune correction \u00e0 appliquer (coef_champ \u00e9gal \u00e0 1 ",
            "partout) : la table a peut-\u00eatre d\u00e9j\u00e0 \u00e9t\u00e9 corrig\u00e9e.",
            call. = FALSE)
    return(population)
  }
  derniere_rupture <- max(c(attr(population, "parametres")$ruptures_champ,
                            population$annee[population$coef_champ != 1] + 1))
  attributs <- attributes(population)[c("parametres", "sources", "coef_champ")]

  population <- population |>
    dplyr::mutate(
      dplyr::across(c("population", "naissances", "deces", "ajustement",
                      "population3112"),
                    ~ .x * .data$coef_champ))
  suivante <- population |>
    dplyr::transmute(.data$sexe, .data$generation, annee = .data$annee - 1,
                     population_suivante = .data$population)
  population <- population |>
    dplyr::left_join(suivante, by = c("sexe", "generation", "annee")) |>
    dplyr::mutate(
      population3112 = dplyr::if_else(
        .data$annee < derniere_rupture & !is.na(.data$population_suivante),
        .data$population_suivante, .data$population3112),
      solde_migratoire = dplyr::if_else(
        .data$annee < derniere_rupture & .data$age3112 >= 1,
        .data$population3112 - .data$population + .data$deces -
          dplyr::coalesce(.data$ajustement, 0),
        .data$solde_migratoire * .data$coef_champ),
      coef_champ = 1
    ) |>
    dplyr::select(-"population_suivante")

  attributes(population)[names(attributs)] <- attributs
  attr(population, "champ_corrige") <- TRUE
  population
}
