#' Lire les taux de retraités projetés par le COR
#'
#' Lit les taux de retraités par sexe, âge et année des données
#' complémentaires du rapport annuel du Conseil d'orientation des retraites.
#' L'onglet comporte plusieurs tableaux (ensemble, femmes, hommes), chacun
#' avec sa propre ligne d'années ; ils sont repérés par leur contenu, et
#' seuls les tableaux des femmes et des hommes sont conservés. Dans chaque
#' tableau, l'âge est lu dans la colonne située juste à gauche de la
#' première année, et le sexe dans les colonnes précédentes.
#'
#' @param url Adresse (ou chemin local) du fichier.
#' @param onglet Nom de l'onglet.
#'
#' @return Un tibble par `sexe`, `annee` et `age3112`, avec `tx_retraites`
#'   (part de retraités au 31 décembre, entre 0 et 1).
#' @export
#' @examples
#' \dontrun{
#' lire_taux_retraites_cor()
#' }
lire_taux_retraites_cor <- function(url = url_source("txretr"),
                                    onglet = "Tx_retrait\u00e9s_an") {
  brut <- openxlsx::read.xlsx(telecharger_source(url), sheet = onglet,
                              colNames = FALSE, skipEmptyRows = FALSE,
                              skipEmptyCols = FALSE)
  texte <- trimws(matrix(vapply(brut, as.character, character(nrow(brut))),
                         nrow = nrow(brut)))
  est_annee <- matrix(grepl("^(19|20|21)[0-9]{2}$", texte), nrow = nrow(texte))
  entetes <- which(rowSums(est_annee) >= 2)
  if (length(entetes) == 0) {
    stop("Aucun tableau rep\u00e9r\u00e9 dans l'onglet \"", onglet, "\".",
         call. = FALSE)
  }

  tableaux <- lapply(entetes, function(h) {
    # colonnes repérées par rapport à la première colonne d'années : l'âge
    # juste à gauche, le libellé du sexe dans les colonnes précédentes
    colonnes <- which(est_annee[h, ])
    colonne_age <- min(colonnes) - 1
    if (colonne_age < 2) return(NULL)
    colonnes_libelle <- seq_len(colonne_age - 1)

    lignes <- seq(h + 1, nrow(texte))
    est_age <- grepl("^[0-9]+$", texte[lignes, colonne_age])
    fin <- which(!est_age)[1]
    if (!is.na(fin)) lignes <- lignes[seq_len(fin - 1)]
    if (length(lignes) == 0) return(NULL)

    libelles <- c(t(texte[c(lignes, h), colonnes_libelle, drop = FALSE]))
    libelle <- tolower(libelles[!is.na(libelles)][1])
    sexe <- if (isTRUE(grepl("^femme", libelle))) "F" else
      if (isTRUE(grepl("^homme", libelle))) "H" else NA_character_
    if (is.na(sexe)) return(NULL)
    tibble::tibble(
      sexe = sexe,
      annee = rep(as.numeric(texte[h, colonnes]), each = length(lignes)),
      age3112 = rep(as.numeric(texte[lignes, colonne_age]),
                    times = length(colonnes)),
      tx_retraites = en_nombre(texte[lignes, colonnes])
    )
  })
  taux <- dplyr::bind_rows(tableaux)
  if (nrow(taux) == 0) {
    stop("Aucun tableau des femmes ou des hommes dans l'onglet \"", onglet,
         "\".", call. = FALSE)
  }
  if (max(taux$tx_retraites, na.rm = TRUE) > 1.5) {
    taux$tx_retraites <- taux$tx_retraites / 100
  }
  valider_grille(taux)
  dplyr::arrange(taux, .data$sexe, .data$annee, .data$age3112)
}

#' Construire les taux de retraités par sexe, âge et année
#'
#' Assemble les taux de retraités au 31 décembre sur une grille complète de
#' sexes, d'années et d'âges :
#'
#' * taux projetés par le COR ([lire_taux_retraites_cor()]) pour les années
#'   qu'ils couvrent ;
#' * taux rétrospectifs construits à partir des EIR (par défaut la table
#'   [taux_retraites_eir]) pour les années antérieures, à partir de la
#'   première année où ils couvrent tous les âges de `age_min_retraite` à
#'   `age_max_retraite` ;
#' * par convention, taux nul avant `age_min_retraite` et égal à 1 après
#'   `age_max_retraite` ;
#' * au-delà de la dernière année du COR, à chaque âge, dernier taux connu
#'   reconduit.
#'
#' Les années antérieures au début des données rétrospectives restent
#' manquantes (`NA`).
#'
#' @param taux_cor Taux du COR, tels que produits par
#'   [lire_taux_retraites_cor()].
#' @param taux_retro Taux rétrospectifs (colonnes `sexe`, `annee`,
#'   `age3112`, `tx_retraites`) ; par défaut la table [taux_retraites_eir].
#'   `NULL` pour n'utiliser que les taux du COR.
#' @param annees Années de la grille.
#' @param age_max Âge maximal de la grille.
#' @param age_min_retraite,age_max_retraite Âges en deçà desquels le taux
#'   est nul et au-delà desquels il vaut 1.
#' @param annee_debut_retro Première année retenue pour les taux
#'   rétrospectifs ; par défaut, première année où ils couvrent tous les
#'   âges de `age_min_retraite` à `age_max_retraite`.
#'
#' Le taux de nouveaux retraités d'une génération à un âge donné est la
#' différence entre son taux de retraités à cet âge et à l'âge précédent
#' (année précédente). Il peut être légèrement négatif lorsque le taux de
#' retraités baisse d'une génération à l'autre.
#'
#' @return Un tibble par `sexe`, `annee` et `age3112`, avec `tx_retraites`,
#'   `tx_nouveaux_retraites` et `source_tx_retraites` (`"COR"`, `"EIR"`,
#'   `"convention"` ou `"prolongation"`).
#' @export
construire_taux_retraites <- function(taux_cor,
                                      taux_retro = donnees_package("taux_retraites_eir"),
                                      annees = 1962:2180,
                                      age_max = 120,
                                      age_min_retraite = 50,
                                      age_max_retraite = 70,
                                      annee_debut_retro = NULL) {
  ages_retraite <- seq(age_min_retraite, age_max_retraite)
  premiere_annee_cor <- min(taux_cor$annee)
  derniere_annee_cor <- max(taux_cor$annee)

  if (!is.null(taux_retro)) {
    taux_retro <- taux_retro[!is.na(taux_retro$tx_retraites),
                             c("sexe", "annee", "age3112", "tx_retraites")]
    if (is.null(annee_debut_retro)) {
      couverture <- taux_retro |>
        dplyr::filter(.data$age3112 %in% ages_retraite) |>
        dplyr::summarise(n = dplyr::n(), .by = "annee")
      complete <- couverture$annee[couverture$n == 2 * length(ages_retraite)]
      annee_debut_retro <- if (length(complete) > 0) min(complete) else Inf
    }
    taux_retro <- taux_retro |>
      dplyr::filter(.data$annee >= annee_debut_retro,
                    .data$annee < premiere_annee_cor) |>
      dplyr::rename(tx_retro = "tx_retraites")
  }

  grille <- tidyr::expand_grid(sexe = c("F", "H"), annee = annees,
                               age3112 = seq(0, age_max)) |>
    dplyr::left_join(dplyr::rename(taux_cor, tx_cor = "tx_retraites"),
                     by = c("sexe", "annee", "age3112"))
  if (!is.null(taux_retro)) {
    grille <- dplyr::left_join(grille, taux_retro,
                               by = c("sexe", "annee", "age3112"))
  } else {
    grille$tx_retro <- NA_real_
  }

  grille |>
    dplyr::mutate(
      source_tx_retraites = dplyr::case_when(
        !is.na(.data$tx_cor) ~ "COR",
        !is.na(.data$tx_retro) ~ "EIR",
        .data$age3112 < age_min_retraite | .data$age3112 > age_max_retraite ~
          "convention",
        .data$annee > derniere_annee_cor ~ "prolongation",
        TRUE ~ NA_character_
      ),
      tx_retraites = dplyr::case_when(
        .data$source_tx_retraites == "COR" ~ .data$tx_cor,
        .data$source_tx_retraites == "EIR" ~ .data$tx_retro,
        .data$age3112 < age_min_retraite ~ 0,
        .data$age3112 > age_max_retraite ~ 1,
        TRUE ~ NA_real_
      )
    ) |>
    dplyr::arrange(.data$sexe, .data$age3112, .data$annee) |>
    dplyr::group_by(.data$sexe, .data$age3112) |>
    dplyr::mutate(tx_retraites = dplyr::if_else(
      .data$annee > derniere_annee_cor,
      dplyr::last(.data$tx_retraites[.data$annee <= derniere_annee_cor]),
      .data$tx_retraites)) |>
    dplyr::ungroup() |>
    calculer_nouveaux_retraites() |>
    dplyr::select("sexe", "annee", "age3112", "tx_retraites",
                  "tx_nouveaux_retraites", "source_tx_retraites") |>
    dplyr::arrange(.data$sexe, .data$annee, .data$age3112)
}

# Taux de nouveaux retraités : différence entre le taux de retraités de la
# génération à l'âge a (année t) et à l'âge a - 1 (année t - 1).
calculer_nouveaux_retraites <- function(taux) {
  precedent <- taux |>
    dplyr::transmute(.data$sexe, annee = .data$annee + 1,
                     age3112 = .data$age3112 + 1,
                     tx_precedent = .data$tx_retraites)
  taux |>
    dplyr::select(-dplyr::any_of("tx_nouveaux_retraites")) |>
    dplyr::left_join(precedent, by = c("sexe", "annee", "age3112")) |>
    dplyr::mutate(
      tx_precedent = dplyr::if_else(.data$age3112 == 0, 0, .data$tx_precedent),
      tx_nouveaux_retraites = .data$tx_retraites - .data$tx_precedent
    ) |>
    dplyr::select(-"tx_precedent")
}

#' Ajouter les retraités à une table de population
#'
#' Ajoute à une table de population (par exemple [prolonger_projpop()]) le
#' taux et le nombre de retraités au 31 décembre, ainsi que le taux et le
#' nombre de nouveaux retraités de l'année. Le taux de nouveaux retraités est
#' la hausse du taux de retraités de la génération entre la fin de l'année
#' précédente et la fin de l'année : \eqn{tx(t, a) - tx(t-1, a-1)} (voir
#' [construire_taux_retraites()]). Il peut être légèrement négatif lorsque
#' le taux de retraités baisse d'une génération à l'autre.
#'
#' Pour des effectifs corrigés des ruptures de champ, appliquer
#' [corriger_champ()] à la population **avant** cette fonction.
#'
#' @param population Table de population (colonnes `sexe`, `generation`,
#'   `annee`, `age3112`, `population3112`).
#' @param taux_retraites Taux produits par [construire_taux_retraites()].
#'
#' @return La table de population avec les colonnes `tx_retraites`,
#'   `nb_retraites`, `tx_nouveaux_retraites` et `nb_nouveaux_retraites`.
#' @export
ajouter_retraites <- function(population, taux_retraites) {
  attributs <- attributes(population)[c("parametres", "sources",
                                        "coef_champ", "champ_corrige")]
  attributs <- attributs[!vapply(attributs, is.null, logical(1))]
  if (!"tx_nouveaux_retraites" %in% names(taux_retraites)) {
    taux_retraites <- calculer_nouveaux_retraites(taux_retraites)
  }
  sortie <- population |>
    dplyr::select(-dplyr::any_of(c("tx_retraites", "nb_retraites",
                                   "tx_nouveaux_retraites",
                                   "nb_nouveaux_retraites"))) |>
    dplyr::left_join(taux_retraites[c("sexe", "annee", "age3112",
                                      "tx_retraites", "tx_nouveaux_retraites")],
                     by = c("sexe", "annee", "age3112")) |>
    dplyr::mutate(
      nb_retraites = .data$population3112 * .data$tx_retraites,
      nb_nouveaux_retraites = .data$population3112 * .data$tx_nouveaux_retraites
    )
  attributes(sortie)[names(attributs)] <- attributs
  sortie
}

# Charge une table de données du package (utile pour les valeurs par défaut,
# qui ne peuvent pas référencer directement les données paresseuses).
donnees_package <- function(nom) {
  environnement <- new.env()
  trouvee <- suppressWarnings(
    utils::data(list = nom, package = "pilotretrtools", envir = environnement)
  )
  if (!nom %in% ls(environnement)) {
    stop("La table `", nom, "` n'est pas disponible dans le package ; ",
         "construisez-la avec le script data-raw correspondant.",
         call. = FALSE)
  }
  environnement[[nom]]
}
