#' Prolonger les projections de population de l'Insee
#'
#' Prolonge un scénario des projections de population de l'Insee au-delà de
#' son horizon de publication, en reproduisant la méthode des composantes :
#' chaque année, la population de chaque génération est obtenue à partir de
#' celle de l'année précédente, diminuée des décès et augmentée du solde
#' migratoire et de l'ajustement ; les naissances sont calculées à partir de
#' la population féminine et des taux de fécondité par âge (les naissances
#' publiées par l'Insee sont utilisées lorsqu'elles existent).
#'
#' Le calcul est mené année par année, de manière vectorisée sur les âges.
#' Seules les cellules sans population diffusée sont calculées, ainsi que les
#' âges du groupe ouvert (voir `age_ouvert`) : les valeurs publiées par
#' l'Insee sont conservées partout ailleurs.
#'
#' Hypothèses de prolongation :
#' * quotients de mortalité, soldes migratoires, ajustements et taux de
#'   fécondité : à chaque âge, dernière valeur connue reconduite ;
#' * quotients de mortalité aux âges non couverts : valeur de l'âge
#'   inférieur ;
#' * groupe ouvert : à partir de l'année suivant `annee_agregation`, la
#'   population aux âges `age_ouvert` et plus est recalculée par génération ;
#'   le groupe ouvert agrégé de l'année `annee_agregation` n'est pas propagé
#'   (simplification : les générations correspondantes sont considérées comme
#'   éteintes).
#'
#' Pour les années observées, le solde migratoire (non diffusé par l'Insee)
#' est calculé comme résidu de l'équation comptable.
#'
#' @param projpop Objet renvoyé par [lire_projpop_insee()].
#' @param horizon Dernière année de la projection prolongée.
#' @param age_max Âge maximal (en âge atteint dans l'année). Par défaut, le
#'   plus grand âge présent dans les données.
#' @param annee_agregation Première année pour laquelle les fichiers de
#'   l'Insee agrègent les âges élevés en un groupe ouvert ; `NA` si aucune
#'   agrégation.
#' @param age_ouvert Premier âge (atteint dans l'année) du groupe ouvert.
#' @param rapport_masculinite Nombre de naissances de garçons pour une
#'   naissance de fille.
#' @param arrondir Si `TRUE` (défaut), les décès et les naissances sont
#'   arrondis à l'unité, comme dans les projections de l'Insee.
#'
#' @return Une liste de classe `projpop_prolongee` contenant :
#'   * `population` : tibble par `sexe`, `generation`, `annee`, `age0101`,
#'     `age3112`, avec `population` (au 1er janvier), `deces`, `qx`,
#'     `solde_migratoire`, `ajustement`, `population3112` (au 31 décembre)
#'     et `prolonge` (`TRUE` pour les valeurs calculées par la fonction) ;
#'   * `naissances` : tibble par `annee` des naissances utilisées pour les
#'     générations non diffusées (`calculees = TRUE` lorsqu'elles sont
#'     calculées à partir de la fécondité, `FALSE` lorsqu'elles sont reprises
#'     des naissances publiées) ;
#'   * `parametres` et `sources` : les paramètres de prolongation et les
#'     sources lues.
#' @export
#' @examples
#' \dontrun{
#' projpop <- prolonger_projpop(lire_projpop_insee(), horizon = 2180)
#' }
prolonger_projpop <- function(projpop,
                              horizon = 2180,
                              age_max = NULL,
                              annee_agregation = 2023,
                              age_ouvert = 105,
                              rapport_masculinite = 1.05,
                              arrondir = TRUE) {
  if (!inherits(projpop, "projpop_insee")) {
    stop("`projpop` doit \u00eatre produit par lire_projpop_insee().",
         call. = FALSE)
  }
  arrondi <- if (arrondir) round else identity
  donnees <- projpop$population
  annees <- seq(min(donnees$annee), horizon)
  if (is.null(age_max)) age_max <- max(donnees$age3112, na.rm = TRUE)
  ages <- seq(0, age_max)
  n_ages <- length(ages)
  n_annees <- length(annees)

  # --- grille complète et prolongation des hypothèses ----------------------
  grille <- tidyr::expand_grid(sexe = c("F", "H"), annee = annees,
                               age3112 = ages) |>
    dplyr::left_join(donnees, by = c("sexe", "annee", "age3112")) |>
    dplyr::arrange(.data$sexe, .data$age3112, .data$annee) |>
    dplyr::group_by(.data$sexe, .data$age3112) |>
    tidyr::fill("qx", "solde_migratoire", "ajustement", .direction = "down") |>
    dplyr::ungroup() |>
    dplyr::arrange(.data$sexe, .data$annee, .data$age3112) |>
    dplyr::group_by(.data$sexe, .data$annee) |>
    tidyr::fill("qx", .direction = "down") |>
    dplyr::ungroup()

  fecondite <- tidyr::expand_grid(annee = annees, age3112 = ages) |>
    dplyr::left_join(projpop$fecondite, by = c("annee", "age3112")) |>
    dplyr::arrange(.data$age3112, .data$annee) |>
    dplyr::group_by(.data$age3112) |>
    tidyr::fill("fecondite", .direction = "down") |>
    dplyr::ungroup() |>
    dplyr::arrange(.data$annee, .data$age3112)
  taux_fec <- matrix(dplyr::coalesce(fecondite$fecondite, 0),
                     nrow = n_ages, ncol = n_annees) / 1e4
  naissances_publiees <- tapply(fecondite$naissances, fecondite$annee,
                                function(x) if (all(is.na(x))) NA else
                                  sum(x, na.rm = TRUE))

  # --- passage en matrices âge x année, par sexe ---------------------------
  en_matrice <- function(variable, sexe) {
    matrix(grille[[variable]][grille$sexe == sexe], nrow = n_ages,
           ncol = n_annees)
  }
  m <- lapply(c(F = "F", H = "H"), function(sexe) {
    list(P = en_matrice("population", sexe), D = en_matrice("deces", sexe),
         Q = en_matrice("qx", sexe), M = en_matrice("solde_migratoire", sexe),
         J = en_matrice("ajustement", sexe))
  })

  # population au 31/12 sur les années diffusées : équation comptable, à
  # défaut population de la même génération au 1er janvier suivant
  for (s in names(m)) {
    m[[s]]$P[1, ] <- 0
    P31 <- m[[s]]$P + m[[s]]$M - m[[s]]$D + m[[s]]$J
    P31[1, ] <- NA
    suivant <- cbind(m[[s]]$P[-1, -1, drop = FALSE], NA)
    suivant <- rbind(suivant, NA)
    P31[is.na(P31)] <- suivant[is.na(P31)]
    m[[s]]$P31 <- P31
    m[[s]]$prolonge <- matrix(FALSE, n_ages, n_annees)
  }
  naissances <- rep(NA_real_, n_annees)
  naissances_calculees <- rep(FALSE, n_annees)

  # --- projection année par année ------------------------------------------
  for (j in seq(2, n_annees)) {
    en_groupe_ouvert <- !is.na(annee_agregation) &&
      annees[j] > annee_agregation
    for (s in names(m)) {
      x <- m[[s]]
      precedent <- c(NA, x$P31[-n_ages, j - 1])
      if (!is.na(annee_agregation) && annees[j - 1] == annee_agregation) {
        precedent[ages > age_ouvert] <- 0
      }
      a_calculer <- ages >= 1 &
        (is.na(x$P[, j]) | (en_groupe_ouvert & ages >= age_ouvert)) &
        !is.na(precedent)
      x$P[a_calculer, j] <- precedent[a_calculer]

      deces <- a_calculer | (ages >= 1 & is.na(x$D[, j]))
      x$D[deces, j] <- arrondi(
        (x$P[deces, j] + x$M[deces, j] / 2) * x$Q[deces, j])

      stock <- a_calculer | (ages >= 1 & is.na(x$P31[, j]))
      x$P31[stock, j] <- x$P[stock, j] + x$M[stock, j] - x$D[stock, j] +
        dplyr::coalesce(x$J[stock, j], 0)
      x$prolonge[, j] <- a_calculer
      m[[s]] <- x
    }

    # naissances de l'année, lorsque la génération n'est pas diffusée
    if (is.na(m$F$P31[1, j]) || is.na(m$H$P31[1, j])) {
      naissances[j] <- naissances_publiees[[as.character(annees[j])]]
      if (is.na(naissances[j])) {
        femmes <- m$F$P[, j] + (m$F$M[, j] - m$F$D[, j]) / 2
        naissances[j] <- sum(arrondi(femmes * taux_fec[, j]), na.rm = TRUE)
        naissances_calculees[j] <- TRUE
      }
      entrants <- c(F = arrondi(naissances[j] / (1 + rapport_masculinite)))
      entrants["H"] <- naissances[j] - entrants[["F"]]
      for (s in names(m)) {
        x <- m[[s]]
        x$D[1, j] <- arrondi((entrants[[s]] + x$M[1, j] / 2) * x$Q[1, j])
        x$P31[1, j] <- entrants[[s]] + x$M[1, j] - x$D[1, j] +
          dplyr::coalesce(x$J[1, j], 0)
        x$prolonge[1, j] <- TRUE
        m[[s]] <- x
      }
    }
  }

  # --- retour au format long -----------------------------------------------
  population <- dplyr::bind_rows(lapply(names(m), function(s) {
    x <- m[[s]]
    tibble::tibble(
      sexe = s,
      annee = rep(annees, each = n_ages),
      age3112 = rep(ages, times = n_annees),
      population = as.vector(x$P),
      deces = as.vector(x$D),
      qx = as.vector(x$Q),
      solde_migratoire = as.vector(x$M),
      ajustement = as.vector(x$J),
      population3112 = as.vector(x$P31),
      prolonge = as.vector(x$prolonge)
    )
  }))

  population <- population |>
    dplyr::mutate(
      # solde migratoire résiduel sur les années observées
      solde_migratoire = dplyr::if_else(
        is.na(.data$solde_migratoire) & .data$age3112 >= 1,
        .data$population3112 - .data$population + .data$deces -
          dplyr::coalesce(.data$ajustement, 0),
        .data$solde_migratoire),
      # groupe ouvert non suivi : générations considérées comme éteintes
      dplyr::across(c("population", "population3112"),
                    ~ dplyr::if_else(is.na(.x) & .data$age3112 >= age_ouvert,
                                     0, .x))
    ) |>
    completer_grille()

  structure(
    list(
      population = population,
      naissances = tibble::tibble(annee = annees, naissances = naissances,
                                  calculees = naissances_calculees) |>
        dplyr::filter(!is.na(.data$naissances)),
      parametres = list(horizon = horizon, age_max = age_max,
                        annee_agregation = annee_agregation,
                        age_ouvert = age_ouvert,
                        rapport_masculinite = rapport_masculinite,
                        arrondir = arrondir),
      sources = projpop$sources
    ),
    class = "projpop_prolongee"
  )
}

#' @export
print.projpop_prolongee <- function(x, ...) {
  cat("<projpop_prolongee>\n")
  cat("  Sc\u00e9nario :", x$sources[["scenario"]], "\n")
  cat("  Ann\u00e9es   :", paste(range(x$population$annee), collapse = " - "),
      "\n")
  cat("  Valeurs calcul\u00e9es par prolongation :",
      format(mean(x$population$prolonge) * 100, digits = 3), "% des cellules\n")
  invisible(x)
}
