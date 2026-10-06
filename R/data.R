#' Projections de population de l'Insee, scénario central, prolongées
#'
#' Scénario central des projections de population de l'Insee (millésime
#' 2026), avec l'hypothèse centrale de mortalité, prolongé jusqu'en 2180 par
#' [prolonger_projpop()] (quotients de mortalité de 2125 reconduits). Les
#' effectifs sont dans le champ publié pour chaque année ; voir
#' [corriger_champ()] pour des séries homogènes en France entière, et
#' `vignette("ecarts-insee")` pour les écarts avec les données publiées.
#'
#' @format Un tibble par sexe, génération, année et âge ; voir la section
#'   « Value » de [prolonger_projpop()] pour la description des colonnes.
#' @source Insee, projections de population 2026 (Licence Ouverte Etalab) ;
#'   voir `sources_donnees(c("projpop", "projmort"))`.
"projpop_central"