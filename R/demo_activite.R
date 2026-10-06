# --- lecture des sources ------------------------------------------------------

# Bornes d'une tranche d'âge à partir de son libellé : « De 15 à 19 ans »,
# « 15-19 ans », « 75 ans ou plus », « 70 ans et plus ».
parser_tranche <- function(libelle) {
  nombres <- regmatches(libelle, gregexpr("[0-9]+", libelle))
  debut <- vapply(nombres, function(x) as.numeric(x[1]), numeric(1))
  fin <- vapply(nombres, function(x) if (length(x) >= 2) as.numeric(x[2]) else
    NA_real_, numeric(1))
  ouvert <- grepl("plus", libelle)
  fin[ouvert] <- NA_real_
  tibble::tibble(age_debut = debut, age_fin = fin, ouverte = ouvert)
}

texte_onglet <- function(fichier, onglet) {
  brut <- openxlsx::read.xlsx(telecharger_source(fichier), sheet = onglet,
                              colNames = FALSE, skipEmptyRows = FALSE,
                              skipEmptyCols = FALSE)
  trimws(matrix(vapply(brut, as.character, character(nrow(brut))),
                nrow = nrow(brut)))
}

sexe_depuis_libelle <- function(libelle) {
  libelle <- tolower(libelle)
  dplyr::case_when(grepl("^femme", libelle) ~ "F",
                   grepl("^homme", libelle) ~ "H",
                   TRUE ~ NA_character_)
}

#' Lire les taux d'emploi observés de l'enquête Emploi
#'
#' Lit le tableau T207 des séries longues de l'enquête Emploi de l'Insee
#' (taux d'emploi par sexe et âge quinquennal, en moyenne annuelle). Seules
#' les tranches quinquennales et la tranche ouverte des âges élevés sont
#' conservées (les regroupements plus larges sont écartés).
#'
#' @param url Adresse (ou chemin local) du fichier.
#' @param onglet Nom de l'onglet (par défaut le premier).
#'
#' @return Un tibble par `sexe`, `annee` et tranche d'âge (`age_debut`,
#'   `age_fin`, `NA` pour la tranche ouverte), avec `tx_emploi` (entre 0 et
#'   1).
#' @export
lire_taux_emploi_eec <- function(url = url_source("txempl_obs"), onglet = 1) {
  texte <- texte_onglet(url, onglet)
  est_annee <- matrix(grepl("^(19|20)[0-9]{2}$", texte), nrow = nrow(texte))
  entete <- which(rowSums(est_annee) >= 2)[1]
  colonnes <- which(est_annee[entete, ])
  colonne_age <- min(colonnes) - 1
  lignes <- which(!is.na(sexe_depuis_libelle(texte[, 1])) &
                    seq_len(nrow(texte)) > entete)
  tranches <- parser_tranche(texte[lignes, colonne_age])
  garder <- tranches$ouverte |
    (!is.na(tranches$age_fin) & tranches$age_fin - tranches$age_debut == 4)
  lignes <- lignes[garder]
  tranches <- tranches[garder, ]

  tibble::tibble(
    sexe = rep(sexe_depuis_libelle(texte[lignes, 1]), times = length(colonnes)),
    annee = rep(as.numeric(texte[entete, colonnes]), each = length(lignes)),
    age_debut = rep(tranches$age_debut, times = length(colonnes)),
    age_fin = rep(tranches$age_fin, times = length(colonnes)),
    tx_emploi = en_nombre(texte[lignes, colonnes]) / 100
  ) |>
    dplyr::filter(!is.na(.data$tx_emploi)) |>
    dplyr::arrange(.data$sexe, .data$annee, .data$age_debut)
}

#' Lire les taux d'activité des projections de population active de l'Insee
#'
#' Lit l'onglet des taux d'activité des projections de population active
#' (PPA) de l'Insee : années en lignes, tranches d'âge en colonnes, avec un
#' bloc de colonnes par sexe (ensemble, femmes, hommes). Seuls les blocs des
#' femmes et des hommes sont conservés.
#'
#' @param url Adresse (ou chemin local) du fichier.
#' @param onglet Nom de l'onglet.
#'
#' @return Un tibble par `sexe`, `annee` et tranche d'âge (`age_debut`,
#'   `age_fin`), avec `tx_activite` (entre 0 et 1).
#' @export
lire_taux_activite_ppa <- function(url = url_source("txact"),
                                   onglet = "taux_activit\u00e9") {
  texte <- texte_onglet(url, onglet)
  entete <- which(apply(texte, 1, function(l) sum(grepl("ans", l)) >= 2))[1]
  libelles_sexe <- texte[entete - 1, ]
  for (j in seq_along(libelles_sexe)[-1]) {
    if (is.na(libelles_sexe[j])) libelles_sexe[j] <- libelles_sexe[j - 1]
  }
  colonnes <- which(grepl("ans", texte[entete, ]) &
                      !is.na(sexe_depuis_libelle(libelles_sexe)))
  lignes <- which(grepl("^(19|20)[0-9]{2}$", texte[, 1]) &
                    seq_len(nrow(texte)) > entete)
  tranches <- parser_tranche(texte[entete, colonnes])

  tibble::tibble(
    sexe = rep(sexe_depuis_libelle(libelles_sexe[colonnes]),
               each = length(lignes)),
    annee = rep(as.numeric(texte[lignes, 1]), times = length(colonnes)),
    age_debut = rep(tranches$age_debut, each = length(lignes)),
    age_fin = rep(tranches$age_fin, each = length(lignes)),
    tx_activite = en_nombre(texte[lignes, colonnes]) / 100
  ) |>
    dplyr::arrange(.data$sexe, .data$annee, .data$age_debut)
}

#' Lire les hypothèses d'emploi et de chômage du COR
#'
#' Lit, pour une hypothèse de taux de chômage de long terme, les taux
#' d'emploi et de chômage par sexe et tranche d'âge quinquennale du fichier
#' d'hypothèses du COR (onglets `Emploi_x%` et `Chômage_x%`), et en déduit
#' les taux d'activité : taux d'activité = taux d'emploi / (1 - taux de
#' chômage). La dernière tranche (70 ans) est traitée comme une tranche
#' ouverte.
#'
#' Les années doivent se suivre ; une année mal étiquetée dans le fichier
#' (par exemple 2070 à la place de 2090 dans la dernière ligne des onglets
#' de 2025) est corrigée, avec un message.
#'
#' @param url Adresse (ou chemin local) du fichier.
#' @param chomage Hypothèse de taux de chômage de long terme, en % (5, 7 ou
#'   10 dans le fichier de 2025).
#'
#' @return Un tibble par `sexe`, `annee` et tranche d'âge (`age_debut`,
#'   `age_fin`), avec `tx_emploi`, `tx_chomage` et `tx_activite` (entre 0 et
#'   1).
#' @export
lire_hypotheses_cor <- function(url = url_source("txempl_proj"), chomage = 7) {
  lire <- function(onglet, variable) {
    texte <- texte_onglet(url, onglet)
    codes <- grepl("^[FH][0-9]+S$", texte)
    entete <- which(rowSums(matrix(codes, nrow = nrow(texte))) >= 2)[1]
    colonnes <- which(grepl("^[FH][0-9]+S$", texte[entete, ]))
    lignes <- which(grepl("^(19|20)[0-9]{2}$", texte[, 1]) &
                      seq_len(nrow(texte)) > entete)
    annees <- as.numeric(texte[lignes, 1])
    for (i in seq_along(annees)[-1]) {
      if (annees[i] != annees[i - 1] + 1) {
        message("Onglet \"", onglet, "\" : ann\u00e9e ", annees[i],
                " corrig\u00e9e en ", annees[i - 1] + 1, ".")
        annees[i] <- annees[i - 1] + 1
      }
    }
    codes <- texte[entete, colonnes]
    debut <- as.numeric(gsub("[^0-9]", "", codes))
    sortie <- tibble::tibble(
      sexe = rep(substr(codes, 1, 1), each = length(lignes)),
      annee = rep(annees, times = length(colonnes)),
      age_debut = rep(debut, each = length(lignes)),
      age_fin = rep(ifelse(debut == max(debut), NA_real_, debut + 4),
                    each = length(lignes)),
      valeur = en_nombre(texte[lignes, colonnes]) / 100
    )
    names(sortie)[5] <- variable
    sortie
  }
  emploi <- lire(paste0("Emploi_", chomage, "%"), "tx_emploi")
  taux_chomage <- lire(paste0("Ch\u00f4mage_", chomage, "%"), "tx_chomage")
  sortie <- emploi |>
    dplyr::inner_join(taux_chomage,
                      by = c("sexe", "annee", "age_debut", "age_fin")) |>
    dplyr::mutate(tx_activite = .data$tx_emploi / (1 - .data$tx_chomage)) |>
    dplyr::arrange(.data$sexe, .data$annee, .data$age_debut)
  attr(sortie, "hypothese_chomage") <- chomage
  sortie
}

# --- construction des taux par âge fin ----------------------------------------

#' Construire les taux d'activité et d'emploi par âge fin
#'
#' Assemble les taux d'emploi et d'activité par sexe et tranche d'âge
#' quinquennale, les lisse par âge fin ([lisser_par_age()]) pour chaque sexe
#' et chaque année, puis en déduit les taux de chômage.
#'
#' Sources selon les années :
#' * jusqu'à l'année précédant la première année du COR : emploi observé de
#'   l'enquête Emploi, activité des projections de population active (PPA)
#'   de l'Insee (années observées) ;
#' * de la première année du COR à la dernière année observée de l'enquête
#'   Emploi : emploi observé, activité déduite de l'emploi observé et du
#'   chômage du COR (taux d'activité = taux d'emploi / (1 - taux de
#'   chômage)) ;
#' * au-delà : emploi et activité du COR, selon l'hypothèse de chômage
#'   retenue dans `cor` ;
#' * après la dernière année du COR : taux reconduits à chaque âge.
#'
#' Le raccordement entre l'emploi observé et l'emploi projeté par le COR
#' présente un saut de niveau (point ouvert).
#'
#' Les taux d'emploi et d'activité sont lissés séparément, ce qui respecte
#' les moyennes par tranche des deux taux (sauf lorsque la borne à 0 joue,
#' aux âges extrêmes). Le lissage est fait de `age_min` à `age_max` ; la
#' tranche ouverte des âges élevés est lissée comme si elle s'arrêtait à
#' `age_max`, et les taux sont nuls en dehors de cet intervalle. Le taux
#' d'activité est porté au niveau du taux d'emploi s'il lui est inférieur.
#' Le taux de chômage est déduit des deux taux lissés. Aux âges où le taux
#' d'activité est inférieur à `seuil_activite` ou le taux d'emploi nul (âges
#' extrêmes, où les deux lissages indépendants donnent des rapports sans
#' signification), actifs et actifs occupés sont confondus : le taux
#' d'activité est pris égal au taux d'emploi et le chômage est nul. Lorsque
#' les sources ne découpent pas les âges élevés de la même façon (tranche
#' « 70 ans et plus » de la PPA et du COR, tranches « 70-74 ans » et
#' « 75 ans et plus » de l'enquête Emploi), les tranches de l'enquête Emploi
#' sont regroupées, en moyenne pondérée par la population, avant le lissage,
#' pour que les profils par âge des deux taux soient comparables.
#'
#' @param eec Taux d'emploi observés ([lire_taux_emploi_eec()]).
#' @param ppa Taux d'activité de la PPA ([lire_taux_activite_ppa()]).
#' @param cor Hypothèses du COR ([lire_hypotheses_cor()]).
#' @param population Table de population servant de pondération pour le
#'   lissage (colonnes `sexe`, `annee`, `age3112`, `population3112`), par
#'   exemple `projpop_central`. `NULL` pour des poids uniformes.
#' @param age_min,age_max Âges extrêmes du lissage.
#' @param seuil_activite Taux d'activité en deçà duquel actifs et actifs
#'   occupés sont confondus.
#' @param horizon Dernière année en sortie.
#'
#' @return Un tibble par `sexe`, `annee` et `age3112`, avec `tx_activite`,
#'   `tx_emploi`, `tx_chomage`, et la source des taux d'emploi et
#'   d'activité (`source_tx_emploi`, `source_tx_activite`). L'hypothèse de
#'   chômage du COR est stockée dans l'attribut `hypothese_chomage`.
#' @export
construire_taux_activite <- function(eec, ppa, cor, population = NULL,
                                     age_min = 15, age_max = 79,
                                     seuil_activite = 0.01,
                                     horizon = 2180) {
  premiere_cor <- min(cor$annee)
  derniere_eec <- max(eec$annee)
  derniere_cor <- max(cor$annee)

  # tranches harmonisées : au-delà du début de la tranche ouverte commune
  # (70 ans), les tranches de l'enquête Emploi sont regroupées en moyenne
  # pondérée par la population
  debut_ouverte <- max(c(min(ppa$age_debut[is.na(ppa$age_fin)]),
                         min(cor$age_debut[is.na(cor$age_fin)])))
  ponderation <- function(sexe, annee, debut, fin) {
    if (is.null(population)) return(rep(1, length(debut)))
    fin <- dplyr::coalesce(fin, age_max)
    vapply(seq_along(debut), function(i) {
      p <- population$population3112[population$sexe == sexe[i] &
                                       population$annee == annee[i] &
                                       population$age3112 >= debut[i] &
                                       population$age3112 <= fin[i]]
      if (length(p) == 0 || anyNA(p)) 1 else sum(p)
    }, numeric(1))
  }
  eec <- dplyr::bind_rows(
    eec |> dplyr::filter(.data$age_debut < debut_ouverte),
    eec |> dplyr::filter(.data$age_debut >= debut_ouverte) |>
      dplyr::mutate(poids = ponderation(.data$sexe, .data$annee,
                                        .data$age_debut, .data$age_fin)) |>
      dplyr::summarise(tx_emploi = stats::weighted.mean(.data$tx_emploi,
                                                        .data$poids),
                       .by = c("sexe", "annee")) |>
      dplyr::mutate(age_debut = debut_ouverte, age_fin = NA_real_)
  ) |>
    dplyr::arrange(.data$sexe, .data$annee, .data$age_debut)

  emploi <- dplyr::bind_rows(
    eec |> dplyr::mutate(source = "EEC"),
    cor |> dplyr::filter(.data$annee > derniere_eec) |>
      dplyr::mutate(source = "COR")
  ) |>
    dplyr::select("sexe", "annee", "age_debut", valeur = "tx_emploi", "source")

  # chômage par tranche, rapporté aux tranches de l'emploi : la tranche de
  # la source de chômage dont le début est le plus proche par valeur
  # inférieure (70 ans et plus -> 70-74 et 75 ans et plus)
  vers_tranches_emploi <- function(chomage) {
    emploi |>
      dplyr::select("sexe", "annee", "age_debut") |>
      dplyr::inner_join(chomage, by = c("sexe", "annee"),
                        suffix = c("", "_chomage"),
                        relationship = "many-to-many") |>
      dplyr::filter(.data$age_debut_chomage <= .data$age_debut) |>
      dplyr::slice_max(.data$age_debut_chomage, n = 1,
                       by = c("sexe", "annee", "age_debut")) |>
      dplyr::select(-"age_debut_chomage")
  }
  chomage_cor <- cor |>
    dplyr::filter(.data$annee >= premiere_cor) |>
    dplyr::transmute(.data$sexe, .data$annee,
                     age_debut_chomage = .data$age_debut,
                     valeur = .data$tx_chomage, source = "COR") |>
    vers_tranches_emploi()
  activite <- dplyr::bind_rows(
    ppa |> dplyr::filter(.data$annee < premiere_cor) |>
      dplyr::transmute(.data$sexe, .data$annee, .data$age_debut,
                       valeur = .data$tx_activite, source = "PPA"),
    emploi |> dplyr::filter(.data$annee >= premiere_cor,
                            .data$annee <= derniere_eec) |>
      dplyr::inner_join(chomage_cor, by = c("sexe", "annee", "age_debut"),
                        suffix = c("", "_chomage")) |>
      dplyr::transmute(.data$sexe, .data$annee, .data$age_debut,
                       valeur = .data$valeur / (1 - .data$valeur_chomage),
                       source = "EEC et COR"),
    cor |> dplyr::filter(.data$annee > derniere_eec) |>
      dplyr::transmute(.data$sexe, .data$annee, .data$age_debut,
                       valeur = .data$tx_activite, source = "COR")
  )
  poids <- function(sexe, annee) {
    uniformes <- rep(1, age_max - age_min + 1)
    if (is.null(population)) return(uniformes)
    p <- population$population3112[population$sexe == sexe &
                                     population$annee == annee &
                                     population$age3112 >= age_min &
                                     population$age3112 <= age_max]
    if (length(p) != length(uniformes) || anyNA(p) || any(p <= 0)) {
      return(uniformes)
    }
    p
  }
  lisser <- function(tranches) {
    tranches |>
      dplyr::filter(.data$age_debut >= age_min, .data$age_debut <= age_max) |>
      dplyr::arrange(.data$sexe, .data$annee, .data$age_debut) |>
      dplyr::reframe(
        age3112 = seq(age_min, age_max),
        valeur = lisser_par_age(.data$valeur, .data$age_debut, age_min,
                                age_max, poids(.data$sexe[1], .data$annee[1])),
        source = .data$source[1],
        .by = c("sexe", "annee")
      )
  }
  lisse_emploi <- lisser(emploi) |>
    dplyr::rename(tx_emploi = "valeur", source_tx_emploi = "source")
  lisse_activite <- lisser(activite) |>
    dplyr::rename(tx_activite = "valeur", source_tx_activite = "source")

  taux <- tidyr::expand_grid(sexe = c("F", "H"),
                             annee = seq(min(emploi$annee), horizon),
                             age3112 = seq(0, 120)) |>
    dplyr::left_join(lisse_emploi, by = c("sexe", "annee", "age3112")) |>
    dplyr::left_join(lisse_activite, by = c("sexe", "annee", "age3112")) |>
    dplyr::mutate(
      hors_ages = .data$age3112 < age_min | .data$age3112 > age_max,
      dplyr::across(c("tx_emploi", "tx_activite"),
                    ~ dplyr::if_else(.data$hors_ages, 0, .x))
    ) |>
    dplyr::arrange(.data$sexe, .data$age3112, .data$annee) |>
    dplyr::group_by(.data$sexe, .data$age3112) |>
    tidyr::fill("tx_emploi", "tx_activite", "source_tx_emploi",
                "source_tx_activite", .direction = "down") |>
    dplyr::ungroup() |>
    dplyr::mutate(
      prolonge = .data$annee > derniere_cor,
      dplyr::across(c("source_tx_emploi", "source_tx_activite"),
                    ~ dplyr::case_when(.data$hors_ages ~ "convention",
                                       .data$prolonge ~ "prolongation",
                                       TRUE ~ .x)),
      tx_activite = dplyr::if_else(
        .data$tx_activite < seuil_activite | .data$tx_emploi == 0,
        .data$tx_emploi, pmax(.data$tx_activite, .data$tx_emploi)),
      tx_chomage = dplyr::if_else(.data$tx_activite > 0,
                                  1 - .data$tx_emploi / .data$tx_activite, 0)
    ) |>
    dplyr::select("sexe", "annee", "age3112", "tx_activite", "tx_emploi",
                  "tx_chomage", "source_tx_emploi", "source_tx_activite") |>
    dplyr::arrange(.data$sexe, .data$annee, .data$age3112)
  attr(taux, "hypothese_chomage") <- attr(cor, "hypothese_chomage")
  taux
}

#' Ajouter les actifs et les actifs occupés à une table de population
#'
#' Ajoute à une table de population les taux d'activité, d'emploi et de
#' chômage ([construire_taux_activite()]) et les nombres d'actifs et
#' d'actifs occupés au 31 décembre. Les taux, mesurés en moyenne annuelle,
#' sont appliqués à la population au 31 décembre, par cohérence avec les
#' taux de retraités.
#'
#' Pour des effectifs corrigés des ruptures de champ, appliquer
#' [corriger_champ()] à la population **avant** cette fonction.
#'
#' @param population Table de population (colonnes `sexe`, `annee`,
#'   `age3112`, `population3112`).
#' @param taux_activite Taux produits par [construire_taux_activite()].
#'
#' @return La table de population avec les colonnes `tx_activite`,
#'   `tx_emploi`, `tx_chomage`, `nb_actifs` et `nb_actifs_occupes`.
#' @export
ajouter_actifs <- function(population, taux_activite) {
  attributs <- attributes(population)[c("parametres", "sources",
                                        "coef_champ", "champ_corrige")]
  attributs <- attributs[!vapply(attributs, is.null, logical(1))]
  sortie <- population |>
    dplyr::select(-dplyr::any_of(c("tx_activite", "tx_emploi", "tx_chomage",
                                   "nb_actifs", "nb_actifs_occupes"))) |>
    dplyr::left_join(taux_activite[c("sexe", "annee", "age3112",
                                     "tx_activite", "tx_emploi",
                                     "tx_chomage")],
                     by = c("sexe", "annee", "age3112")) |>
    dplyr::mutate(nb_actifs = .data$population3112 * .data$tx_activite,
                  nb_actifs_occupes = .data$population3112 * .data$tx_emploi)
  attributes(sortie)[names(attributs)] <- attributs
  sortie
}
