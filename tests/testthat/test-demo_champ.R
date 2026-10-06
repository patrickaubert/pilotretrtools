# Rupture de champ simul\u00e9e : \u00e0 partir de 2003, toutes les populations, tous les
# d\u00e9c\u00e8s et toutes les naissances publi\u00e9s sont major\u00e9s de 10 %.
fichiers <- creer_fichiers_insee()
projpop <- lire_projpop_insee(fichiers$scenario, fichiers$mortalite)
rupture <- projpop
apres <- rupture$population$annee >= 2003
rupture$population$population[apres] <- rupture$population$population[apres] * 1.1
rupture$population$deces[apres] <- rupture$population$deces[apres] * 1.1
apres_n <- rupture$fecondite$annee >= 2003
rupture$fecondite$naissances[apres_n] <- rupture$fecondite$naissances[apres_n] * 1.1

pop <- prolonger_projpop(rupture, horizon = 2010, age_max = 10,
                         ruptures_champ = 2003, annees_voisines = 1)

test_that("le coefficient de champ retrouve l'\u00e9cart simul\u00e9", {
  coefs <- estimer_coef_champ(pop, ruptures = 2003, annees_voisines = 1)
  expect_equal(unique(coefs$rupture), 2003)
  expect_true(all(abs(coefs$coef - 1.1) < 0.01))
  # g\u00e9n\u00e9rations n\u00e9es apr\u00e8s la rupture : pas de coefficient
  expect_true(all(coefs$generation < 2003))
  # coefficient non estim\u00e9 aux \u00e2ges reconstitu\u00e9s ou sans survivant
  expect_true(any(!coefs$estime))
})

test_that("coef_champ ne concerne que les ann\u00e9es et g\u00e9n\u00e9rations ant\u00e9rieures", {
  expect_true(all(pop$coef_champ[pop$annee >= 2003] == 1))
  avant <- pop[pop$annee < 2003 & pop$age3112 >= 1, ]
  expect_true(all(abs(avant$coef_champ - 1.1) < 0.01))
  expect_false(is.null(attr(pop, "coef_champ")))
})

test_that("corriger_champ supprime le saut de population et de solde migratoire", {
  corrige <- corriger_champ(pop)
  f <- function(x, annee, age) {
    x$population[x$sexe == "F" & x$annee == annee & x$age3112 == age]
  }
  expect_equal(f(pop, 2002, 5), 100)
  expect_equal(f(corrige, 2002, 5), f(corrige, 2003, 6), tolerance = 0.01)
  # le solde migratoire r\u00e9siduel de l'ann\u00e9e 2002 n'enregistre plus la rupture
  m <- corrige$solde_migratoire[corrige$annee == 2002 & corrige$age3112 %in% 1:8]
  expect_true(all(abs(m) < 1))
  expect_true(all(corrige$coef_champ == 1))
  expect_true(attr(corrige, "champ_corrige"))
  expect_warning(corriger_champ(corrige), "d\u00e9j\u00e0")
})

test_that("sans rupture d\u00e9clar\u00e9e, aucune correction n'est estim\u00e9e", {
  sans <- prolonger_projpop(projpop, horizon = 2010, age_max = 10,
                            ruptures_champ = NULL)
  expect_true(all(sans$coef_champ == 1))
  expect_null(attr(sans, "coef_champ"))
})
