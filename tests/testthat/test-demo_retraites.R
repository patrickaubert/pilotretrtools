fichier_cor <- creer_fichier_taux_cor()
retro <- tidyr::expand_grid(sexe = c("F", "H"), generation = 1920:1949,
                            age3112 = 50:70) |>
  dplyr::mutate(annee = generation + age3112,
                tx_retraites = (age3112 - 50) / 25)

test_that("lire_taux_retraites_cor ne garde que les femmes et les hommes", {
  taux <- lire_taux_retraites_cor(fichier_cor)
  expect_setequal(unique(taux$sexe), c("F", "H"))
  expect_equal(range(taux$age3112), c(50, 70))
  expect_equal(range(taux$annee), c(2000, 2005))
  expect_equal(max(taux$tx_retraites), 1)
  expect_equal(taux$tx_retraites[taux$sexe == "H" & taux$age3112 == 70][1],
               0.9)
})

test_that("lire_taux_retraites_cor rep\u00e8re les colonnes quelle que soit leur position", {
  sans_colonne_vide <- lire_taux_retraites_cor(
    creer_fichier_taux_cor(colonne_vide = FALSE))
  expect_equal(sans_colonne_vide, lire_taux_retraites_cor(fichier_cor))
})

test_that("construire_taux_retraites raccorde EIR, COR et conventions", {
  taux <- construire_taux_retraites(lire_taux_retraites_cor(fichier_cor),
                                    taux_retro = retro, annees = 1975:2010,
                                    age_max = 80)
  f <- function(annee, age) {
    taux[taux$sexe == "F" & taux$annee == annee & taux$age3112 == age, ]
  }
  expect_equal(f(2002, 60)$source_tx_retraites, "COR")
  expect_equal(f(2002, 60)$tx_retraites, 0.5)
  # EIR de 1990 (premi\u00e8re ann\u00e9e o\u00f9 tous les \u00e2ges de 50 \u00e0 70 ans sont
  # couverts) jusqu'\u00e0 la veille du COR
  expect_equal(min(taux$annee[taux$source_tx_retraites %in% "EIR"]), 1990)
  expect_equal(f(1999, 60)$source_tx_retraites, "EIR")
  expect_equal(f(1999, 60)$tx_retraites, 10 / 25)
  # avant la premi\u00e8re ann\u00e9e couvrant tous les \u00e2ges : manquant
  expect_true(is.na(f(1985, 60)$tx_retraites))
  # conventions et prolongation
  expect_equal(f(1980, 45)$tx_retraites, 0)
  expect_equal(f(1980, 75)$tx_retraites, 1)
  expect_equal(f(2010, 60)$source_tx_retraites, "prolongation")
  expect_equal(f(2010, 60)$tx_retraites, f(2005, 60)$tx_retraites)
  # taux de nouveaux retrait\u00e9s : m\u00eame g\u00e9n\u00e9ration, \u00e2ge pr\u00e9c\u00e9dent
  expect_equal(f(2003, 61)$tx_nouveaux_retraites,
               f(2003, 61)$tx_retraites - f(2002, 60)$tx_retraites)
  expect_equal(f(2003, 50)$tx_nouveaux_retraites, f(2003, 50)$tx_retraites)
})

test_that("ajouter_retraites calcule stocks et nouveaux retrait\u00e9s", {
  fichiers <- creer_fichiers_insee()
  pop <- prolonger_projpop(lire_projpop_insee(fichiers$scenario,
                                              fichiers$mortalite),
                           horizon = 2010, age_max = 10)
  # taux fictifs aux \u00e2ges 3 \u00e0 7 pour la population synth\u00e9tique
  taux <- tidyr::expand_grid(sexe = c("F", "H"), annee = 2000:2010,
                             age3112 = 0:10) |>
    dplyr::mutate(tx_retraites = pmin(pmax((age3112 - 2) / 5, 0), 1))
  avec <- ajouter_retraites(pop, taux)
  ligne <- avec[avec$sexe == "F" & avec$annee == 2005 & avec$age3112 == 5, ]
  expect_equal(ligne$nb_retraites, ligne$population3112 * 0.6)
  expect_equal(ligne$tx_nouveaux_retraites, 0.2)
  expect_equal(avec$tx_nouveaux_retraites[avec$age3112 == 0 &
                                            avec$annee == 2005], c(0, 0))
  expect_false(is.null(attr(avec, "parametres")))
})
