#' Lire un onglet d'un fichier de projections de l'Insee
#'
#' Lit un onglet au format habituel des fichiers de projections de l'Insee :
#' une ligne d'en-tête contenant les années en colonnes, une première colonne
#' contenant l'âge (avec un éventuel groupe ouvert du type « 105+ »).
#'
#' La ligne d'en-tête est repérée par son contenu (première ligne comportant
#' plusieurs années) et non par un numéro de ligne fixe, pour résister aux
#' changements de mise en page d'un millésime à l'autre. Si le libellé de la
#' colonne d'âge mentionne le 1er janvier, l'âge est converti en âge atteint
#' dans l'année (`age3112 = age + 1`) ; sinon il est supposé déjà exprimé
#' ainsi.
#'
#' @param fichier Chemin local ou adresse du fichier xlsx.
#' @param onglet Nom de l'onglet.
#' @param nom_valeur Nom de la colonne de valeurs en sortie.
#'
#' @return Un tibble avec les colonnes `annee`, `age3112` et `nom_valeur`.
#' @export
lire_onglet_insee <- function(fichier, onglet, nom_valeur = onglet) {
  brut <- openxlsx::read.xlsx(
    telecharger_source(fichier), sheet = onglet, colNames = FALSE,
    skipEmptyRows = FALSE, skipEmptyCols = FALSE
  )
  est_annee <- function(x) grepl("^(18|19|20|21)[0-9]{2}$", trimws(x))
  texte <- vapply(brut, as.character, character(nrow(brut)))
  texte <- matrix(texte, nrow = nrow(brut))
  nb_annees <- rowSums(matrix(est_annee(texte[, -1]), nrow = nrow(brut)))
  ligne_entete <- which(nb_annees >= 2)[1]
  if (is.na(ligne_entete)) {
    stop("Ligne d'en-t\u00eate introuvable dans l'onglet \"", onglet, "\".",
         call. = FALSE)
  }
  entete <- trimws(texte[ligne_entete, ])
  colonnes_annees <- setdiff(which(est_annee(entete)), 1)

  corps <- texte[seq(ligne_entete + 1, nrow(brut)), c(1, colonnes_annees),
                 drop = FALSE]
  age_brut <- trimws(corps[, 1])
  garder <- grepl("^[0-9]", age_brut)
  age <- as.numeric(sub("\\+$", "", age_brut[garder]))
  if (grepl("1.*janvier", tolower(entete[1]))) {
    age <- age + 1
  }

  valeurs <- corps[garder, -1, drop = FALSE]
  sortie <- tibble::tibble(
    annee = rep(as.numeric(entete[colonnes_annees]), each = length(age)),
    age3112 = rep(age, times = length(colonnes_annees)),
    valeur = en_nombre(as.vector(valeurs))
  )
  names(sortie)[3] <- nom_valeur
  sortie
}

#' Lire un scénario des projections de population de l'Insee
#'
#' Lit le fichier d'un scénario des projections de population de l'Insee
#' (populations au 1er janvier, décès, quotients de mortalité, soldes
#' migratoires, ajustements, naissances et fécondité) et, si elle est fournie,
#' l'hypothèse de mortalité prolongée diffusée séparément par l'Insee.
#'
#' Les quotients de mortalité sont convertis en probabilités (l'Insee les
#' diffuse pour 100 000). Lorsque le fichier de mortalité prolongée est
#' fourni, ses quotients remplacent ceux du fichier de scénario pour les
#' années qu'il couvre.
#'
#' @param url Adresse (ou chemin local) du fichier du scénario.
#' @param url_mortalite Adresse (ou chemin local) du fichier des quotients de
#'   mortalité prolongés, ou `NULL` pour ne pas l'utiliser.
#' @param hyp_mortalite Hypothèse de mortalité à lire dans ce fichier : les
#'   onglets lus sont `paste0(hyp_mortalite, c("F", "H"))`. L'hypothèse doit
#'   être cohérente avec le scénario lu.
#'
#' @return Une liste de classe `projpop_insee` contenant :
#'   * `population` : tibble par `sexe`, `annee` et `age3112`, avec les
#'     colonnes `population` (au 1er janvier), `deces`, `qx`,
#'     `solde_migratoire` et `ajustement` ;
#'   * `fecondite` : tibble par `annee` et `age3112` (âge de la mère), avec
#'     les colonnes `naissances` et `fecondite` (naissances pour 10 000
#'     femmes) ;
#'   * `sources` : les adresses lues.
#' @export
#' @examples
#' \dontrun{
#' projpop <- lire_projpop_insee()
#' }
lire_projpop_insee <- function(url = url_source("projpop"),
                               url_mortalite = url_source("projmort"),
                               hyp_mortalite = "central") {
  variables <- c(population = "population", deces = "deces",
                 qx = "hyp_mortalite", solde_migratoire = "hyp_soldemig",
                 ajustement = "ajustement")

  population <- lapply(c("F", "H"), function(sexe) {
    tables <- lapply(names(variables), function(nom) {
      lire_onglet_insee(url, paste0(variables[[nom]], sexe), nom)
    })
    tables <- Reduce(function(x, y) {
      dplyr::full_join(x, y, by = c("annee", "age3112"))
    }, tables)
    tables$sexe <- sexe
    tables
  })
  population <- dplyr::bind_rows(population)
  population$qx <- population$qx / 1e5

  if (!is.null(url_mortalite)) {
    mortalite <- lire_mortalite_insee(url_mortalite, hyp_mortalite)
    population <- population |>
      dplyr::full_join(mortalite, by = c("sexe", "annee", "age3112")) |>
      dplyr::mutate(qx = dplyr::coalesce(.data$qx_prolonge, .data$qx)) |>
      dplyr::select(-"qx_prolonge")
  }

  fecondite <- dplyr::full_join(
    lire_onglet_insee(url, "naissance", "naissances"),
    lire_onglet_insee(url, "hyp_fecondite", "fecondite"),
    by = c("annee", "age3112")
  )

  population <- population |>
    dplyr::relocate("sexe", "annee", "age3112") |>
    dplyr::arrange(.data$sexe, .data$annee, .data$age3112)

  structure(
    list(
      population = population,
      fecondite = dplyr::arrange(fecondite, .data$annee, .data$age3112),
      sources = c(scenario = url, mortalite = url_mortalite %||% NA_character_,
                  hyp_mortalite = hyp_mortalite)
    ),
    class = "projpop_insee"
  )
}

#' Lire une hypothèse de mortalité prolongée de l'Insee
#'
#' @param url Adresse (ou chemin local) du fichier des quotients de mortalité.
#' @param hyp_mortalite Hypothèse à lire (onglets `paste0(hyp_mortalite,
#'   c("F", "H"))`).
#'
#' @return Un tibble par `sexe`, `annee` et `age3112`, avec la colonne
#'   `qx_prolonge` (probabilité de décès).
#' @export
lire_mortalite_insee <- function(url = url_source("projmort"),
                                 hyp_mortalite = "central") {
  mortalite <- lapply(c("F", "H"), function(sexe) {
    table <- lire_onglet_insee(url, paste0(hyp_mortalite, sexe), "qx_prolonge")
    table$sexe <- sexe
    table
  })
  mortalite <- dplyr::bind_rows(mortalite)
  mortalite$qx_prolonge <- mortalite$qx_prolonge / 1e5
  mortalite[c("sexe", "annee", "age3112", "qx_prolonge")]
}

#' @export
print.projpop_insee <- function(x, ...) {
  annees <- range(x$population$annee[!is.na(x$population$population)])
  cat("<projpop_insee>\n")
  cat("  Sc\u00e9nario    :", x$sources[["scenario"]], "\n")
  cat("  Mortalit\u00e9   :", x$sources[["mortalite"]],
      paste0("(hypoth\u00e8se \"", x$sources[["hyp_mortalite"]], "\")"), "\n")
  cat("  Populations :", annees[1], "-", annees[2], "\n")
  cat("  Quotients   :", paste(range(x$population$annee[!is.na(x$population$qx)]),
                                collapse = " - "), "\n")
  invisible(x)
}

en_nombre <- function(x) {
  suppressWarnings(as.numeric(gsub(",", ".", gsub("[[:space:]]", "", x))))
}

`%||%` <- function(x, y) if (is.null(x)) y else x
