fichier <- creer_fichier_pop_champs()

test_that("lire_pop_champs_insee lit les deux champs et \u00e9carte le groupe ouvert", {
  pop <- lire_pop_champs_insee(fichier)
  expect_setequal(unique(pop$champ),
                  c("metropole", "france_hors_mayotte", "france"))
  expect_equal(range(pop$age3112), c(1, 10))
  expect_equal(unique(pop$generation[pop$annee == 1995 & pop$age3112 == 1]),
               1994)
  expect_silent(valider_grille(pop, cles = c("annee", "champ", "sexe",
                                            "age3112")))
})

test_that("calculer_coef_champ retrouve les coefficients des deux ruptures", {
  coefs <- calculer_coef_champ(lire_pop_champs_insee(fichier))
  expect_equal(sort(unique(coefs$rupture)), c(1995, 2014))
  expect_true(all(abs(coefs$coef[coefs$rupture == 1995] - 1.03) < 1e-3))
  expect_true(all(abs(coefs$coef[coefs$rupture == 2014] - 1.01) < 1e-3))
  # g\u00e9n\u00e9ration n\u00e9e en 2013 : coefficient repris de la g\u00e9n\u00e9ration voisine
  nee_2013 <- coefs[coefs$rupture == 2014 & coefs$generation == 2013, ]
  expect_false(any(nee_2013$estime))
  expect_true(all(coefs$coef >= 1))
})

test_that("calculer_coef_champ exige les ann\u00e9es 1995, 2013 et 2014", {
  pop <- lire_pop_champs_insee(fichier, annees = c(1995, 2014))
  expect_error(calculer_coef_champ(pop), "2013")
})

test_that("prolonger_projpop utilise les coefficients fournis", {
  fichiers <- creer_fichiers_insee()
  projpop <- lire_projpop_insee(fichiers$scenario, fichiers$mortalite)
  coefs <- calculer_coef_champ(lire_pop_champs_insee(fichier))
  # ruptures (et g\u00e9n\u00e9rations) d\u00e9cal\u00e9es dans la p\u00e9riode des donn\u00e9es de test
  decalage <- c("1995" = 7, "2014" = -10)[as.character(coefs$rupture)]
  coefs$rupture <- coefs$rupture + decalage
  coefs$generation <- coefs$generation + decalage
  pop <- prolonger_projpop(projpop, horizon = 2010, age_max = 10,
                           coef_champ = coefs)
  expect_equal(attr(pop, "parametres")$methode_champ, "publications Insee")
  expect_equal(attr(pop, "parametres")$ruptures_champ, c(2002, 2004))
  # avant 2002 : produit des deux coefficients ; de 2002 \u00e0 2003 : 1,01 seul
  expect_true(all(abs(pop$coef_champ[pop$annee < 2002] - 1.03 * 1.01) < 1e-3))
  entre <- pop$coef_champ[pop$annee %in% 2002:2003 & pop$generation < 2002]
  expect_true(all(abs(entre - 1.01) < 1e-3))
  expect_true(all(pop$coef_champ[pop$annee >= 2004] == 1))
})
