fichiers <- creer_fichiers_insee()
# ruptures fictives en 2003 et 2005, dans la période des données de test
coefs <- tidyr::expand_grid(rupture = c(2003, 2005), sexe = c("F", "H"),
                            generation = 1995) |>
  dplyr::mutate(coef = ifelse(rupture == 2003, 1.03, 1.01), estime = TRUE)
pop <- prolonger_projpop(lire_projpop_insee(fichiers$scenario,
                                            fichiers$mortalite),
                         horizon = 2010, age_max = 10, coef_champ = coefs)
fichier_pop3 <- creer_fichier_pop_champs(annees_historiques = 1997:1999)

test_that("champ_insee d\u00e9crit les champs successifs", {
  expect_equal(champ_insee(c(1905, 1917, 1930, 1944, 1945, 1950, 2000, 2020)),
               c("metropole_hors_alsace_moselle", NA, "metropole",
                 "metropole_hors_alsace_moselle_corse",
                 "metropole_hors_alsace_moselle", "metropole",
                 "france_hors_mayotte", "france"))
})

test_that("ajouter_serie_historique ajoute les ann\u00e9es ant\u00e9rieures", {
  h <- ajouter_serie_historique(pop, url = fichier_pop3, annees = 1997:1999)
  expect_equal(min(h$annee), 1997)
  expect_equal(names(h), c(names(pop)))
  expect_silent(valider_grille(h))
  f1998 <- h[h$sexe == "F" & h$annee == 1998, ]
  # \u00e2ge r\u00e9volu au 1er janvier converti en \u00e2ge atteint ; groupe ouvert \u00e9cart\u00e9
  expect_equal(f1998$population[f1998$age3112 %in% 1:8], rep(100, 8))
  expect_true(all(is.na(f1998$population[f1998$age3112 >= 9])))
  # population au 31/12 = m\u00eame g\u00e9n\u00e9ration au 1er janvier suivant (y c. 2000)
  expect_equal(f1998$population3112[f1998$age3112 == 3], 100)
  f1999 <- h[h$sexe == "F" & h$annee == 1999 & h$age3112 == 3, ]
  expect_equal(f1999$population3112,
               pop$population[pop$sexe == "F" & pop$annee == 2000 &
                                pop$age3112 == 4])
  expect_true(all(is.na(f1998$deces)))
  # champ et coefficients de champ \u00e9tendus aux g\u00e9n\u00e9rations anciennes
  expect_equal(h$champ, champ_insee(h$annee))
  expect_true(all(abs(f1998$coef_champ - 1.03 * 1.01) < 1e-9))
  expect_equal(attr(h, "parametres")$annees_historiques, 1997:1999)
})

test_that("corriger_champ met \u00e0 jour la colonne champ", {
  h <- ajouter_serie_historique(pop, url = fichier_pop3, annees = 1997:1999)
  corrige <- corriger_champ(h)
  expect_false(any(grepl("metropole|mayotte", corrige$champ)))
  expect_equal(corrige$population[corrige$sexe == "F" & corrige$annee == 1998 &
                                    corrige$age3112 == 3], 100 * 1.03 * 1.01)
})

test_that("sans ann\u00e9e ant\u00e9rieure disponible, la table est inchang\u00e9e", {
  expect_message(h <- ajouter_serie_historique(pop, url = fichier_pop3,
                                              annees = 1980),
                 "Aucune")
  expect_identical(h, pop)
})
