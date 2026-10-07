# --- mortalité de référence ---------------------------------------------------

#' Définir une mortalité de référence
#'
#' Définit la mortalité de référence utilisée pour mesurer l'effet des gains
#' de mortalité ([projeter_mortalite_reference()],
#' [decomposer_evolutions()]) :
#'
#' * `mortalite_annee(annee)` : quotients de mortalité par âge d'une année
#'   donnée, appliqués à toutes les générations pour les années postérieures
#'   à cette année (gains mesurés depuis l'année de référence) ;
#' * `mortalite_generation(generation)` : quotients de mortalité par âge
#'   d'une génération donnée, appliqués à toutes les générations (gains
#'   mesurés par rapport à la génération de référence, négatifs pour les
#'   générations plus anciennes dont la mortalité était plus forte) ;
#' * `mortalite_annee_age(age)` : pour chaque génération, quotients de
#'   l'année où elle atteint l'âge donné (gains mesurés depuis cette année,
#'   propre à chaque génération).
#'
#' @param annee,generation,age Année, génération ou âge de référence.
#'
#' @return Un objet de classe `reference_mortalite`.
#' @name reference_mortalite
#' @examples
#' mortalite_annee(1982)
#' mortalite_generation(1950)
NULL

#' @rdname reference_mortalite
#' @export
mortalite_annee <- function(annee = 1982) {
  structure(list(type = "annee", valeur = annee), class = "reference_mortalite")
}

#' @rdname reference_mortalite
#' @export
mortalite_generation <- function(generation) {
  structure(list(type = "generation", valeur = generation),
            class = "reference_mortalite")
}

#' @rdname reference_mortalite
#' @export
mortalite_annee_age <- function(age = 60) {
  structure(list(type = "annee_age", valeur = age),
            class = "reference_mortalite")
}

#' @export
format.reference_mortalite <- function(x, ...) {
  switch(x$type,
         annee = paste("mortalit\u00e9 de l'ann\u00e9e", x$valeur),
         generation = paste("mortalit\u00e9 de la g\u00e9n\u00e9ration", x$valeur),
         annee_age = paste("mortalit\u00e9 de l'ann\u00e9e des", x$valeur,
                           "ans de chaque g\u00e9n\u00e9ration"))
}

#' @export
print.reference_mortalite <- function(x, ...) {
  cat("<reference_mortalite>", format(x), "\n")
  invisible(x)
}

#' Projeter la population avec une mortalité de référence
#'
#' Calcule, pour chaque génération, la population qu'elle aurait eue si sa
#' mortalité était restée celle de la référence (voir
#' [reference_mortalite]) à partir de l'âge `age_debut`, toutes choses égales
#' par ailleurs (mêmes soldes migratoires et ajustements).
#'
#' Le gain de population dû aux gains de mortalité est mesuré comme l'écart
#' entre deux projections menées de la même façon, à partir du même point de
#' départ : l'une avec les quotients de mortalité effectifs, l'autre avec
#' ceux de la référence. Comparer directement la population observée à la
#' projection de référence mêlerait aux gains de mortalité l'écart entre les
#' décès observés et ceux que donne la formule à partir des quotients.
#'
#' La projection de référence part, pour chaque génération, de la première
#' cellule où la mortalité de référence s'applique (âge `age_debut`, ou
#' première année postérieure à l'année de référence, ou première année des
#' données), avec la population effective au 1er janvier.
#'
#' @param population Table de population (par exemple [prolonger_projpop()]),
#'   de préférence corrigée des ruptures de champ ([corriger_champ()]).
#' @param reference Mortalité de référence (voir [reference_mortalite]).
#' @param age_debut Âge (atteint dans l'année) à partir duquel la mortalité
#'   de référence s'applique.
#'
#' @return La table de population avec les colonnes `gain_mortalite`
#'   (population supplémentaire au 31 décembre due aux gains de mortalité
#'   par rapport à la référence) et `population3112_ref` (population au
#'   31 décembre avec la mortalité de référence : `population3112 -
#'   gain_mortalite`). La référence est stockée dans l'attribut
#'   `reference_mortalite`.
#' @export
projeter_mortalite_reference <- function(population,
                                         reference = mortalite_annee(1982),
                                         age_debut = 60) {
  if (!inherits(reference, "reference_mortalite")) {
    stop("`reference` doit \u00eatre cr\u00e9\u00e9e par mortalite_annee(), ",
         "mortalite_generation() ou mortalite_annee_age().", call. = FALSE)
  }
  attributs <- attributes(population)[c("parametres", "sources",
                                        "coef_champ", "champ_corrige")]
  attributs <- attributs[!vapply(attributs, is.null, logical(1))]

  # quotient de référence de chaque cellule
  annee_qx <- switch(reference$type,
                     annee = rep(reference$valeur, nrow(population)),
                     generation = reference$valeur + population$age3112,
                     annee_age = population$generation + reference$valeur)
  quotients <- population[c("sexe", "annee", "age3112", "qx")]
  q_ref <- quotients$qx[match(
    paste(population$sexe, annee_qx, population$age3112),
    paste(quotients$sexe, quotients$annee, quotients$age3112))]
  if (anyNA(q_ref[population$age3112 >= age_debut])) {
    stop("Quotients de mortalit\u00e9 de r\u00e9f\u00e9rence indisponibles pour ",
         "certaines cellules : la r\u00e9f\u00e9rence sort de la p\u00e9riode couverte.",
         call. = FALSE)
  }
  applique <- population$age3112 >= age_debut &
    (reference$type != "annee" | population$annee > reference$valeur)

  ordre <- order(population$sexe, population$generation, population$age3112)
  pop <- population[ordre, ]
  q_ref <- q_ref[ordre]
  applique <- applique[ordre]

  # projection, âge par âge, vectorisée sur les générations
  cle <- paste(pop$sexe, pop$generation)
  precedente <- match(paste(cle, pop$age3112 - 1),
                      paste(cle, pop$age3112))
  migr <- dplyr::coalesce(pop$solde_migratoire, 0)
  ajust <- dplyr::coalesce(pop$ajustement, 0)
  projeter <- function(q, P_debut) {
    P <- D <- P31 <- rep(NA_real_, nrow(pop))
    for (age in sort(unique(pop$age3112[applique]))) {
      i <- which(pop$age3112 == age & applique)
      j <- precedente[i]
      suite <- !is.na(j)
      suite[suite] <- applique[j[suite]]
      P[i] <- ifelse(suite, P31[j], P_debut[i])
      D[i] <- pmin(pmax((P[i] + migr[i] / 2) * q[i], 0), pmax(P[i] + migr[i], 0))
      P31[i] <- pmax(P[i] + migr[i] - D[i] + ajust[i], 0)
    }
    P31
  }
  effective <- projeter(pop$qx, pop$population)
  avec_reference <- projeter(q_ref, pop$population)
  pop$gain_mortalite <- dplyr::coalesce(effective - avec_reference, 0)
  pop$population3112_ref <- pop$population3112 - pop$gain_mortalite

  sortie <- pop[order(ordre), ]
  attributes(sortie)[names(attributs)] <- attributs
  attr(sortie, "reference_mortalite") <- reference
  attr(sortie, "age_debut_mortalite") <- age_debut
  sortie
}

# --- décomposition ------------------------------------------------------------

#' Décomposer les évolutions du nombre de retraités et du rapport démographique
#'
#' Décompose, année par année, la variation du nombre de retraités, du nombre
#' d'actifs occupés et du rapport démographique (actifs occupés / retraités)
#' en effets des taux (de retraités, d'emploi), de la mortalité et de la
#' taille des générations.
#'
#' Pour un effectif \eqn{N(t) = \sum_a P(t,a) \tau(t,a)} (population au
#' 31 décembre par sexe et âge, multipliée par un taux), la variation annuelle
#' se décompose exactement, à chaque âge, en :
#' * effet des taux : \eqn{\Delta\tau(a)} multipliée par la moyenne de
#'   \eqn{P(a)} sur les deux années ;
#' * effet de la mortalité : variation du gain de population dû aux gains de
#'   mortalité par rapport à la référence ([projeter_mortalite_reference()]),
#'   multipliée par la moyenne de \eqn{\tau(a)} ;
#' * effet de la taille des générations : le reste de la variation de la
#'   population, multiplié par la moyenne de \eqn{\tau(a)}. Il recouvre tous
#'   les déterminants de la taille des générations à l'âge `age_debut` (taille
#'   à la naissance, migrations, mortalité avant cet âge), ainsi que les
#'   migrations après cet âge.
#'
#' Pondérer par des moyennes des deux années rend la décomposition
#' indépendante de l'ordre dans lequel les effets sont considérés. Avec une
#' mortalité de référence fixe, les effets de la mortalité s'additionnent
#' dans le temps : leur somme sur une période est égale à la variation, sur
#' cette période, du surplus de retraités dû aux gains de mortalité
#' (exactement lorsque les taux ne varient pas aux âges où s'appliquent les
#' gains, approximativement sinon, l'interaction entre gains de mortalité et
#' évolution des taux étant comptée dans l'effet des taux).
#'
#' L'effet de la mortalité dépend de la référence retenue : avec une année de
#' référence, il cumule les gains intervenus depuis cette année et croît
#' mécaniquement à mesure qu'on s'en éloigne. Il inclut l'application des
#' gains cumulés à des générations de tailles différentes ; symétriquement,
#' l'effet de la taille des générations est mesuré avec la mortalité de
#' référence.
#'
#' La variation du rapport démographique \eqn{R = E / N} est décomposée de
#' façon exacte par la méthode des moyennes logarithmiques (LMDI) : la
#' contribution d'un effet est \eqn{L(R) (\Delta E_k / L(E) - \Delta N_k /
#' L(N))}, où \eqn{L} est la moyenne logarithmique des valeurs des deux
#' années et \eqn{\Delta E_k}, \eqn{\Delta N_k} les effets sur les actifs
#' occupés et les retraités.
#'
#' @param population Table de population comportant les taux de retraités et
#'   d'emploi ([ajouter_retraites()], [ajouter_actifs()]), corrigée des
#'   ruptures de champ ([corriger_champ()]).
#' @param reference Mortalité de référence (voir [reference_mortalite]).
#' @param age_debut_mortalite Âge à partir duquel les gains de mortalité sont
#'   mesurés.
#' @param age_seuil_emploi Âge séparant les effets des taux d'emploi « avant »
#'   et « après » cet âge.
#'
#' @return Un tibble par `annee`, avec pour les retraités (`nb_retraites`) et
#'   les actifs occupés (`nb_actifs_occupes`) : le niveau, sa variation
#'   (préfixe `d_`), les effets (suffixes `_taux`, `_taux_avant`,
#'   `_taux_apres`, `_mortalite`, `_taille`) et le niveau avec la mortalité
#'   de référence (suffixe `_ref`) ; pour le rapport démographique
#'   (`rapport_demo`) : le niveau, sa variation et les contributions
#'   (`d_rapport_demo_taux_retraites`, `_taux_emploi_avant`,
#'   `_taux_emploi_apres`, `_mortalite`, `_taille`).
#' @export
decomposer_evolutions <- function(population,
                                  reference = mortalite_annee(1982),
                                  age_debut_mortalite = 60,
                                  age_seuil_emploi = 55) {
  manquantes <- setdiff(c("tx_retraites", "tx_emploi", "population3112"),
                        names(population))
  if (length(manquantes) > 0) {
    stop("Colonnes absentes : ", paste(manquantes, collapse = ", "),
         " (voir ajouter_retraites() et ajouter_actifs()).", call. = FALSE)
  }
  if ("coef_champ" %in% names(population) &&
      any(population$coef_champ != 1, na.rm = TRUE)) {
    warning("La population n'est pas corrig\u00e9e des ruptures de champ : les ",
            "ruptures appara\u00eetront comme des effets de taille. Appliquer ",
            "corriger_champ() avant ajouter_retraites() et ajouter_actifs().",
            call. = FALSE)
  }

  cellules <- projeter_mortalite_reference(population, reference,
                                           age_debut_mortalite) |>
    dplyr::select("sexe", "annee", "age3112", P = "population3112",
                  G = "gain_mortalite", tr = "tx_retraites", te = "tx_emploi")
  precedent <- cellules |>
    dplyr::mutate(annee = .data$annee + 1) |>
    dplyr::rename(P0 = "P", G0 = "G", tr0 = "tr", te0 = "te")

  effets <- cellules |>
    dplyr::inner_join(precedent, by = c("sexe", "annee", "age3112")) |>
    dplyr::mutate(
      Pm = (.data$P + .data$P0) / 2,
      dG = .data$G - .data$G0,
      dPref = (.data$P - .data$G) - (.data$P0 - .data$G0),
      avant = .data$age3112 < age_seuil_emploi
    ) |>
    dplyr::summarise(
      d_nb_retraites_taux = sum((.data$tr - .data$tr0) * .data$Pm),
      d_nb_retraites_mortalite = sum((.data$tr + .data$tr0) / 2 * .data$dG),
      d_nb_retraites_taille = sum((.data$tr + .data$tr0) / 2 * .data$dPref),
      d_nb_actifs_occupes_taux_avant =
        sum(((.data$te - .data$te0) * .data$Pm)[.data$avant]),
      d_nb_actifs_occupes_taux_apres =
        sum(((.data$te - .data$te0) * .data$Pm)[!.data$avant]),
      d_nb_actifs_occupes_mortalite = sum((.data$te + .data$te0) / 2 * .data$dG),
      d_nb_actifs_occupes_taille = sum((.data$te + .data$te0) / 2 * .data$dPref),
      .by = "annee"
    )
  niveaux <- cellules |>
    dplyr::summarise(nb_retraites = sum(.data$P * .data$tr),
                     nb_retraites_ref = sum((.data$P - .data$G) * .data$tr),
                     nb_actifs_occupes = sum(.data$P * .data$te),
                     nb_actifs_occupes_ref = sum((.data$P - .data$G) * .data$te),
                     .by = "annee")

  moy_log <- function(x, y) {
    ifelse(abs(x - y) < 1e-12 * abs(x), x, (x - y) / (log(x) - log(y)))
  }
  sortie <- niveaux |>
    dplyr::arrange(.data$annee) |>
    dplyr::left_join(effets, by = "annee") |>
    dplyr::mutate(
      d_nb_retraites = .data$nb_retraites - dplyr::lag(.data$nb_retraites),
      d_nb_actifs_occupes = .data$nb_actifs_occupes -
        dplyr::lag(.data$nb_actifs_occupes),
      rapport_demo = .data$nb_actifs_occupes / .data$nb_retraites,
      d_rapport_demo = .data$rapport_demo - dplyr::lag(.data$rapport_demo),
      lr = moy_log(.data$rapport_demo, dplyr::lag(.data$rapport_demo)),
      le = moy_log(.data$nb_actifs_occupes, dplyr::lag(.data$nb_actifs_occupes)),
      ln = moy_log(.data$nb_retraites, dplyr::lag(.data$nb_retraites)),
      d_rapport_demo_taux_retraites =
        -.data$lr * .data$d_nb_retraites_taux / .data$ln,
      d_rapport_demo_taux_emploi_avant =
        .data$lr * .data$d_nb_actifs_occupes_taux_avant / .data$le,
      d_rapport_demo_taux_emploi_apres =
        .data$lr * .data$d_nb_actifs_occupes_taux_apres / .data$le,
      d_rapport_demo_mortalite = .data$lr *
        (.data$d_nb_actifs_occupes_mortalite / .data$le -
           .data$d_nb_retraites_mortalite / .data$ln),
      d_rapport_demo_taille = .data$lr *
        (.data$d_nb_actifs_occupes_taille / .data$le -
           .data$d_nb_retraites_taille / .data$ln)
    ) |>
    dplyr::select("annee",
                  "nb_retraites", "d_nb_retraites",
                  dplyr::starts_with("d_nb_retraites_"), "nb_retraites_ref",
                  "nb_actifs_occupes", "d_nb_actifs_occupes",
                  dplyr::starts_with("d_nb_actifs_occupes_"),
                  "nb_actifs_occupes_ref",
                  "rapport_demo", "d_rapport_demo",
                  dplyr::starts_with("d_rapport_demo_"))
  attr(sortie, "reference_mortalite") <- reference
  attr(sortie, "age_debut_mortalite") <- age_debut_mortalite
  attr(sortie, "age_seuil_emploi") <- age_seuil_emploi
  sortie
}
