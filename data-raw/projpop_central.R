# Construction des tables de projection de population embarquées dans le
# package (scénario central de l'Insee, prolongé).
#
# À relancer lorsque l'Insee publie un nouveau millésime : mettre d'abord à
# jour le registre inst/extdata/sources.csv.

devtools::load_all()

projpop_insee <- lire_projpop_insee(
  url = url_source("projpop", scenario = "central"),
  url_mortalite = url_source("projmort"),
  hyp_mortalite = "central"
)
print(projpop_insee)

# mortalité au-delà de 2125 : quotients de 2125 reconduits (option par
# défaut) ; prolonger_projpop(..., prolongation_mortalite = "tendance")
# poursuit leur évolution récente
# coefficients de correction des ruptures de champ géographique (1995, 2014),
# calculés à partir des populations publiées dans les deux champs
coef_champ_insee <- calculer_coef_champ(lire_pop_champs_insee())

# séries historiques 1901-1961 (France métropolitaine, tableau POP3) ajoutées
# au début de la table
projpop_central <- prolonger_projpop(projpop_insee, horizon = 2180,
                                     prolongation_mortalite = "constante",
                                     coef_champ = coef_champ_insee) |>
  ajouter_serie_historique()
dplyr::count(projpop_central, champ)
str(attr(projpop_central, "parametres"))

usethis::use_data(projpop_central, overwrite = TRUE, compress = "xz")

# Documentation à ajouter dans R/data.R une fois la table construite :
#
# #' Projections de population de l'Insee, scénario central, prolongées
# #'
# #' Scénario central des projections de population de l'Insee (millésime
# #' 2026), avec l'hypothèse centrale de mortalité, prolongé jusqu'en 2180 par
# #' [prolonger_projpop()] (quotients de mortalité de 2125 reconduits). Les
# #' effectifs sont dans le champ publié pour chaque année ; voir
# #' [corriger_champ()] pour des séries homogènes en France entière, et
# #' `vignette("ecarts-insee")` pour les écarts avec les données publiées.
# #'
# #' @format Un tibble par sexe, génération, année et âge ; voir la section
# #'   « Value » de [prolonger_projpop()] pour la description des colonnes.
# #' @source Insee, projections de population 2026 (Licence Ouverte Etalab) ;
# #'   voir `sources_donnees(c("projpop", "projmort"))`.
# "projpop_central"
