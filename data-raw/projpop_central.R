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

projpop_central <- prolonger_projpop(projpop_insee, horizon = 2180,
                                     prolongation_mortalite = "constante",
                                     coef_champ = coef_champ_insee)
str(attr(projpop_central, "parametres"))

usethis::use_data(projpop_central, overwrite = TRUE, compress = "xz")

