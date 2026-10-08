#' Données d'un graphique de décomposition
#'
#' Met en forme, pour un graphique, les effets calculés par
#' [decomposer_evolutions()] pour un indicateur : une ligne par année et par
#' effet, avec un libellé lisible et un ordre d'affichage. Les données
#' peuvent ensuite être représentées avec n'importe quel outil graphique
#' (voir `vignette("decomposition")` pour un exemple avec `ggplot2`).
#'
#' @param decomposition Table produite par [decomposer_evolutions()].
#' @param indicateur `"retraites"`, `"actifs_occupes"` ou `"rapport_demo"`.
#' @param annees Années à retenir (par défaut toutes celles où les effets
#'   sont calculés).
#'
#' @return Un tibble avec `annee`, `effet` (facteur ordonné, libellés en
#'   clair), `valeur` (contribution à la variation annuelle, en nombre de
#'   personnes ou en points de rapport démographique) et `variation`
#'   (variation totale de l'année).
#' @export
#' @examples
#' \dontrun{
#' donnees_graph_decomposition(decomposer_evolutions(construire_base()),
#'                             "actifs_occupes", annees = 1980:2070)
#' }
donnees_graph_decomposition <- function(decomposition,
                                        indicateur = c("retraites",
                                                       "actifs_occupes",
                                                       "rapport_demo"),
                                        annees = NULL) {
  indicateur <- match.arg(indicateur)
  libelles <- switch(
    indicateur,
    retraites = c(d_nb_retraites_taux = "Taux de retrait\u00e9s",
                  d_nb_retraites_mortalite = "Mortalit\u00e9",
                  d_nb_retraites_taille = "Taille des g\u00e9n\u00e9rations"),
    actifs_occupes = c(
      d_nb_actifs_occupes_taux_avant = "Taux d'emploi avant le seuil",
      d_nb_actifs_occupes_taux_apres = "Taux d'emploi apr\u00e8s le seuil",
      d_nb_actifs_occupes_mortalite = "Mortalit\u00e9",
      d_nb_actifs_occupes_taille = "Taille des g\u00e9n\u00e9rations"),
    rapport_demo = c(
      d_rapport_demo_taux_retraites = "Taux de retrait\u00e9s",
      d_rapport_demo_taux_emploi_avant = "Taux d'emploi avant le seuil",
      d_rapport_demo_taux_emploi_apres = "Taux d'emploi apr\u00e8s le seuil",
      d_rapport_demo_mortalite = "Mortalit\u00e9",
      d_rapport_demo_taille = "Taille des g\u00e9n\u00e9rations")
  )
  seuil <- attr(decomposition, "age_seuil_emploi")
  if (!is.null(seuil)) {
    libelles <- sub("le seuil", paste(seuil, "ans"), libelles)
  }
  totale <- c(retraites = "d_nb_retraites",
              actifs_occupes = "d_nb_actifs_occupes",
              rapport_demo = "d_rapport_demo")[[indicateur]]

  sortie <- decomposition |>
    dplyr::select("annee", variation = dplyr::all_of(totale),
                  dplyr::all_of(names(libelles))) |>
    dplyr::filter(!is.na(.data$variation)) |>
    tidyr::pivot_longer(dplyr::all_of(names(libelles)), names_to = "effet",
                        values_to = "valeur") |>
    dplyr::mutate(effet = factor(libelles[.data$effet], levels = libelles)) |>
    dplyr::select("annee", "effet", "valeur", "variation")
  if (!is.null(annees)) sortie <- sortie[sortie$annee %in% annees, ]
  sortie
}
