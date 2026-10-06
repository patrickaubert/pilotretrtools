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

projpop_central <- prolonger_projpop(projpop_insee, horizon = 2180)
print(projpop_central)

usethis::use_data(projpop_central, overwrite = TRUE, compress = "xz")

# Documentation à ajouter dans R/data.R une fois la table construite :
#
# #' Projections de population de l'Insee, scénario central, prolongées
# #'
# #' Scénario central des projections de population de l'Insee (millésime
# #' 2026), prolongé jusqu'en 2180 par [prolonger_projpop()].
# #'
# #' @format Une liste de classe `projpop_prolongee` (voir
# #'   [prolonger_projpop()]).
# #' @source Insee, projections de population (Licence Ouverte Etalab) ;
# #'   voir `sources_donnees("projpop")`.
# "projpop_central"
