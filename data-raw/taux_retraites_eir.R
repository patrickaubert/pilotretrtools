# Taux de retraités rétrospectifs construits à partir des EIR empilés.
#
# Fichier source : data-raw/taux_retraites_eir.csv.gz (variables ai, sexe,
# age, txretr, txnouvretr, annee ; sexe en "Femme", "Homme", "Ensemble").
# Seules les générations de l'EIR sont présentes : les autres sont obtenues
# par interpolation linéaire, à sexe et âge donnés.

devtools::load_all()

brut <- read.csv2(gzfile("data-raw/taux_retraites_eir.csv.gz"),
                  encoding = "UTF-8")

taux_retraites_eir <- brut |>
  dplyr::filter(sexe %in% c("Femme", "Homme")) |>
  dplyr::transmute(
    sexe = dplyr::recode(sexe, "Femme" = "F", "Homme" = "H"),
    generation = ai,
    annee,
    age3112 = age,
    tx_retraites = txretr,
    tx_nouveaux_retraites = txnouvretr
  ) |>
  interpoler_generations(c("tx_retraites", "tx_nouveaux_retraites"))

valider_grille(taux_retraites_eir)
stopifnot(all(taux_retraites_eir$annee ==
                taux_retraites_eir$generation + taux_retraites_eir$age3112))
dplyr::count(taux_retraites_eir, sexe, interpole)

usethis::use_data(taux_retraites_eir, overwrite = TRUE, compress = "xz")
