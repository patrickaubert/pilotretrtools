#' Prolonger les projections de population de l'Insee
#'
#' Prolonge un scénario des projections de population de l'Insee au-delà de
#' son horizon de publication et reconstitue les effectifs aux âges élevés
#' que l'Insee diffuse sous forme agrégée, par la méthode des composantes :
#' chaque année, la population de chaque génération est obtenue à partir de
#' celle de l'année précédente, diminuée des décès et augmentée du solde
#' migratoire et de l'ajustement. Les naissances sont celles publiées par
#' l'Insee lorsqu'elles existent ; au-delà, elles sont calculées à partir de
#' la population féminine et des taux de fécondité par âge.
#'
#' Les valeurs publiées par l'Insee sont conservées partout où elles existent.
#' Sont calculées par la fonction :
#' * toutes les cellules au-delà de l'horizon des projections ;
#' * les âges couverts par un groupe ouvert dans les fichiers de l'Insee
#'   (« 105+ », ou « 100 » les années où le détail s'arrête à 100 ans), que
#'   [lire_projpop_insee()] a écartés.
#'
#' Hypothèses :
#' * **mortalité** : au-delà de la dernière année disponible (2125 avec le
#'   fichier de mortalité prolongée de l'Insee), selon `prolongation_mortalite` :
#'   - `"constante"` (défaut) : à chaque âge, les quotients de la dernière
#'     année sont reconduits à l'identique ;
#'   - `"tendance"` : à chaque âge, les quotients poursuivent leur évolution
#'     annuelle moyenne observée sur les `duree_tendance` dernières années
#'     disponibles (évolution géométrique, quotients plafonnés à 1) ;
#'
#'   aux âges sans quotient détaillé, le quotient du plus grand âge détaillé
#'   de l'année est reconduit ;
#' * **solde migratoire, ajustement, fécondité** : à chaque âge, dernière
#'   valeur connue reconduite ; solde migratoire et ajustement nuls aux âges
#'   où ils ne sont pas détaillés et sur les années observées (pour les âges
#'   recalculés) ;
#' * **première année** : les âges sans effectif détaillé sont mis à zéro
#'   (générations les plus anciennes, considérées comme éteintes) ;
#' * les décès calculés sont positifs et ne peuvent excéder l'effectif
#'   présent, et la population ne peut devenir négative : une génération
#'   entièrement décédée reste à zéro.
#'
#' Pour les années observées, le solde migratoire (non diffusé par l'Insee)
#' est calculé comme résidu de l'équation comptable. Les naissances
#' publiées, tous sexes confondus, sont réparties par sexe selon
#' `rapport_masculinite`.
#'
#' Les écarts avec les données publiées par l'Insee qui en résultent sont
#' détaillés dans `vignette("ecarts-insee", package = "pilotretrtools")`.
#'
#' @param projpop Objet renvoyé par [lire_projpop_insee()].
#' @param horizon Dernière année de la projection prolongée.
#' @param age_max Âge maximal (en âge atteint dans l'année).
#' @param prolongation_mortalite Hypothèse de mortalité au-delà de la
#'   dernière année disponible : `"constante"` ou `"tendance"`.
#' @param duree_tendance Nombre d'années, en remontant depuis la dernière
#'   année disponible, sur lequel est mesurée l'évolution des quotients
#'   lorsque `prolongation_mortalite = "tendance"`.
#' @param rapport_masculinite Nombre de naissances de garçons pour une
#'   naissance de fille.
#' @param coef_champ Coefficients de correction des ruptures de champ
#'   géographique, tels que produits par [calculer_coef_champ()] à partir
#'   des publications de l'Insee (méthode recommandée). Si `NULL`, ils sont
#'   estimés indirectement par [estimer_coef_champ()] pour les années
#'   `ruptures_champ`.
#' @param ruptures_champ Années de changement du champ géographique
#'   (première année dans le nouveau champ), utilisées lorsque `coef_champ`
#'   est `NULL`. `NULL` pour ne pas corriger les ruptures.
#' @param annees_voisines Nombre d'années de part et d'autre de chaque
#'   rupture utilisées par la méthode indirecte pour neutraliser les
#'   migrations.
#' @param arrondir Si `TRUE` (défaut), les décès et les naissances calculés
#'   sont arrondis à l'unité, comme dans les projections de l'Insee.
#'
#' @return Un tibble par `sexe`, `generation`, `annee`, `age0101` et
#'   `age3112`, avec les colonnes :
#'   * `population` : population au 1er janvier ;
#'   * `naissances` : naissances de l'année, par sexe, sur les lignes d'âge 0
#'     (`NA` aux autres âges) ;
#'   * `deces`, `qx`, `solde_migratoire`, `ajustement` : décès, quotient de
#'     mortalité, solde migratoire et ajustement de l'année ;
#'   * `population3112` : population au 31 décembre ;
#'   * `prolonge` : `TRUE` pour les effectifs calculés par la fonction ;
#'   * `coef_champ` : coefficient multiplicatif ramenant les effectifs au
#'     champ géographique le plus récent (voir [corriger_champ()]).
#'
#'   Les effectifs sont ceux du champ publié par l'Insee pour chaque année.
#'   Les paramètres de prolongation, les sources et le détail des
#'   coefficients de correction de champ sont stockés dans les attributs
#'   `parametres`, `sources` et `coef_champ`.
#' @export
#' @examples
#' \dontrun{
#' projpop <- prolonger_projpop(lire_projpop_insee(), horizon = 2180)
#' }
prolonger_projpop <- function(projpop,
                              horizon = 2180,
                              age_max = 120,
                              prolongation_mortalite = c("constante",
                                                         "tendance"),
                              duree_tendance = 20,
                              rapport_masculinite = 1.05,
                              coef_champ = NULL,
                              ruptures_champ = c(1995, 2014),
                              annees_voisines = 2,
                              arrondir = TRUE) {
  if (!inherits(projpop, "projpop_insee")) {
    stop("`projpop` doit \u00eatre produit par lire_projpop_insee().",
         call. = FALSE)
  }
  prolongation_mortalite <- match.arg(prolongation_mortalite)
  arrondi <- if (arrondir) round else identity
  donnees <- projpop$population
  valider_grille(donnees)
  valider_grille(projpop$fecondite, cles = c("annee", "age3112"))
  donnees <- donnees[donnees$age3112 <= age_max, ]
  annees <- seq(min(donnees$annee), horizon)
  ages <- seq(0, age_max)
  n_ages <- length(ages)
  n_annees <- length(annees)

  # --- grille complète et prolongation des hypothèses ----------------------
  # quotients : tendance éventuelle au-delà de la dernière année, puis
  # dernière valeur reconduite à chaque âge, puis quotient du plus grand âge
  # détaillé reconduit aux âges supérieurs
  grille <- tidyr::expand_grid(sexe = c("F", "H"), annee = annees,
                               age3112 = ages) |>
    dplyr::left_join(donnees, by = c("sexe", "annee", "age3112"))
  if (prolongation_mortalite == "tendance") {
    grille <- prolonger_tendance_qx(grille, duree_tendance)
  }
  grille <- grille |>
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
    valeurs <- grille[[variable]][grille$sexe == sexe]
    stopifnot(length(valeurs) == n_ages * n_annees)
    matrix(valeurs, nrow = n_ages, ncol = n_annees)
  }
  m <- lapply(c(F = "F", H = "H"), function(sexe) {
    list(P = en_matrice("population", sexe), D = en_matrice("deces", sexe),
         Q = en_matrice("qx", sexe), M = en_matrice("solde_migratoire", sexe),
         J = en_matrice("ajustement", sexe))
  })

  # décès d'une cellule : positifs et bornés par l'effectif présent
  calculer_deces <- function(P, M, Q) {
    presents <- pmax(P + dplyr::coalesce(M, 0), 0)
    exposes <- pmax(P + dplyr::coalesce(M, 0) / 2, 0)
    pmin(arrondi(exposes * Q), presents)
  }
  # population au 31/12, jamais négative
  calculer_stock <- function(P, M, D, J) {
    pmax(P + dplyr::coalesce(M, 0) - D + dplyr::coalesce(J, 0), 0)
  }

  # population au 31/12 sur les années diffusées : équation comptable si
  # toutes les composantes sont publiées, à défaut population de la même
  # génération au 1er janvier suivant
  for (s in names(m)) {
    x <- m[[s]]
    x$P[1, ] <- 0
    x$prolonge <- matrix(FALSE, n_ages, n_annees)
    # première année : âges non détaillés mis à zéro
    vides <- is.na(x$P[, 1])
    x$P[vides, 1] <- 0
    x$prolonge[vides, 1] <- TRUE
    P31 <- pmax(x$P + x$M - x$D + x$J, 0)
    P31[1, ] <- NA
    suivant <- rbind(cbind(x$P[-1, -1, drop = FALSE], NA), NA)
    P31[is.na(P31)] <- suivant[is.na(P31)]
    x$P31 <- P31
    m[[s]] <- x
  }
  naissances <- rep(NA_real_, n_annees)
  naissances_calculees <- rep(FALSE, n_annees)

  # --- calcul année par année ----------------------------------------------
  for (j in seq_len(n_annees)) {
    for (s in names(m)) {
      x <- m[[s]]
      if (j > 1) {
        precedent <- c(NA, x$P31[-n_ages, j - 1])
        a_calculer <- ages >= 1 & is.na(x$P[, j]) & !is.na(precedent)
        x$P[a_calculer, j] <- precedent[a_calculer]
        x$prolonge[a_calculer, j] <- TRUE
      }
      a_calculer <- x$prolonge[, j] & ages >= 1

      deces <- ages >= 1 & (a_calculer | is.na(x$D[, j]))
      x$D[deces, j] <- calculer_deces(x$P[deces, j], x$M[deces, j],
                                      x$Q[deces, j])

      stock <- ages >= 1 & (a_calculer | is.na(x$P31[, j]))
      x$P31[stock, j] <- calculer_stock(x$P[stock, j], x$M[stock, j],
                                        x$D[stock, j], x$J[stock, j])
      m[[s]] <- x
    }

    # naissances de l'année, lorsque la génération n'est pas diffusée
    if (is.na(m$F$P31[1, j]) || is.na(m$H$P31[1, j])) {
      naissances[j] <- naissances_publiees[[as.character(annees[j])]]
      if (is.na(naissances[j])) {
        femmes <- m$F$P[, j] + (dplyr::coalesce(m$F$M[, j], 0) - m$F$D[, j]) / 2
        naissances[j] <- sum(arrondi(femmes * taux_fec[, j]), na.rm = TRUE)
        naissances_calculees[j] <- TRUE
      }
      entrants <- c(F = arrondi(naissances[j] / (1 + rapport_masculinite)))
      entrants["H"] <- naissances[j] - entrants[["F"]]
      for (s in names(m)) {
        x <- m[[s]]
        x$D[1, j] <- calculer_deces(entrants[[s]], x$M[1, j], x$Q[1, j])
        x$P31[1, j] <- calculer_stock(entrants[[s]], x$M[1, j], x$D[1, j],
                                      x$J[1, j])
        x$prolonge[1, j] <- TRUE
        m[[s]] <- x
      }
    }
  }

  # naissances publiées des années où elles n'ont pas été nécessaires au
  # calcul, puis répartition par sexe selon le rapport de masculinité
  publiees <- is.na(naissances) &
    !is.na(naissances_publiees[as.character(annees)])
  naissances[publiees] <- naissances_publiees[as.character(annees)][publiees]
  naissances_f <- arrondi(naissances / (1 + rapport_masculinite))
  table_naissances <- tibble::tibble(
    sexe = rep(c("F", "H"), each = n_annees),
    annee = rep(annees, times = 2),
    age3112 = 0,
    naissances = c(naissances_f, naissances - naissances_f)
  )

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

  # solde migratoire résiduel sur les années observées
  population <- population |>
    dplyr::mutate(
      solde_migratoire = dplyr::if_else(
        is.na(.data$solde_migratoire) & .data$age3112 >= 1,
        .data$population3112 - .data$population + .data$deces -
          dplyr::coalesce(.data$ajustement, 0),
        .data$solde_migratoire)
    ) |>
    dplyr::left_join(table_naissances, by = c("sexe", "annee", "age3112")) |>
    dplyr::relocate("naissances", .after = "population") |>
    completer_grille()

  # coefficients de correction des ruptures de champ géographique
  coefficients <- NULL
  methode_champ <- NULL
  population$coef_champ <- 1
  if (!is.null(coef_champ)) {
    coefficients <- completer_coef_champ(coef_champ, population)
    methode_champ <- "publications Insee"
  } else if (length(ruptures_champ) > 0) {
    coefficients <- estimer_coef_champ(population, ruptures_champ,
                                       annees_voisines)
    methode_champ <- "estimation indirecte"
  }
  if (!is.null(coefficients)) {
    ruptures_champ <- sort(unique(coefficients$rupture))
    population <- appliquer_coef_champ(population, coefficients)
  }

  attr(population, "parametres") <- list(
    horizon = horizon, age_max = age_max,
    prolongation_mortalite = prolongation_mortalite,
    duree_tendance = if (prolongation_mortalite == "tendance") duree_tendance,
    rapport_masculinite = rapport_masculinite, arrondir = arrondir,
    ruptures_champ = ruptures_champ, methode_champ = methode_champ,
    annees_voisines = if (identical(methode_champ, "estimation indirecte"))
      annees_voisines,
    naissances_calculees = annees[naissances_calculees]
  )
  attr(population, "sources") <- projpop$sources
  attr(population, "coef_champ") <- coefficients
  population
}

# Prolonge les quotients de mortalité au-delà de la dernière année
# disponible en reconduisant, à chaque âge, leur évolution annuelle moyenne
# sur les `duree` dernières années.
prolonger_tendance_qx <- function(grille, duree) {
  derniere <- max(grille$annee[!is.na(grille$qx)])
  reference <- grille |>
    dplyr::filter(.data$annee %in% c(derniere - duree, derniere)) |>
    dplyr::select("sexe", "age3112", "annee", "qx") |>
    tidyr::pivot_wider(names_from = "annee", values_from = "qx",
                       names_prefix = "q_")
  names(reference)[match(paste0("q_", c(derniere - duree, derniere)),
                         names(reference))] <- c("q_debut", "q_fin")
  reference$evolution <- (reference$q_fin / reference$q_debut)^(1 / duree)
  reference$evolution[!is.finite(reference$evolution) |
                        reference$q_debut <= 0] <- 1

  grille |>
    dplyr::left_join(reference[c("sexe", "age3112", "q_fin", "evolution")],
                     by = c("sexe", "age3112")) |>
    dplyr::mutate(qx = dplyr::if_else(
      .data$annee > derniere & !is.na(.data$q_fin),
      pmin(.data$q_fin * .data$evolution^(.data$annee - derniere), 1),
      .data$qx)) |>
    dplyr::select(-"q_fin", -"evolution")
}
