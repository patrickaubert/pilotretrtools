fichiers <- creer_fichiers_insee()
projpop <- lire_projpop_insee(fichiers$scenario, fichiers$mortalite)

test_that("une population stationnaire reste stationnaire apr\u00e8s prolongation", {
  pop <- prolonger_projpop(projpop, horizon = 2015, age_max = 10)
  expect_equal(max(pop$annee), 2015)
  futur <- pop[pop$annee > 2005 & pop$age3112 >= 1, ]
  expect_true(all(futur$population[futur$sexe == "F"] == 100))
  expect_true(all(futur$population[futur$sexe == "H"] == 105))
  naissances <- pop[pop$age3112 == 0, ]
  total <- tapply(naissances$naissances, naissances$annee, sum)
  expect_true(all(total == 205))
  expect_true(all(naissances$naissances[naissances$sexe == "F"] == 100))
  expect_true(all(is.na(pop$naissances[pop$age3112 > 0])))
  expect_equal(attr(pop, "parametres")$naissances_calculees, 2006:2015)
  expect_s3_class(pop, "tbl_df")
})

test_that("les identit\u00e9s comptables sont respect\u00e9es", {
  pop <- prolonger_projpop(projpop, horizon = 2015, age_max = 10)
  expect_silent(valider_grille(pop))
  calc <- pop[pop$prolonge & pop$age3112 >= 1, ]
  expect_equal(calc$population3112,
               calc$population + calc$solde_migratoire - calc$deces +
                 calc$ajustement)
  # la population au 1er janvier prolonge celle de la m\u00eame g\u00e9n\u00e9ration
  avant <- pop[c("sexe", "generation", "annee", "population3112")]
  avant$annee <- avant$annee + 1
  joint <- merge(calc, avant, by = c("sexe", "generation", "annee"),
                 suffixes = c("", "_avant"))
  expect_equal(joint$population, joint$population3112_avant)
})

test_that("les \u00e2ges du groupe ouvert sont recalcul\u00e9s par g\u00e9n\u00e9ration", {
  pop <- prolonger_projpop(projpop, horizon = 2010, age_max = 10)
  f <- function(annee, age) {
    pop$population[pop$sexe == "F" & pop$annee == annee & pop$age3112 == age]
  }
  # valeur agr\u00e9g\u00e9e (150) \u00e9cart\u00e9e, effectif reconstitu\u00e9 \u00e0 partir de 9 ans
  expect_equal(f(2003, 10), 100)
  # premi\u00e8re ann\u00e9e : pas d'effectif d\u00e9taill\u00e9, g\u00e9n\u00e9ration consid\u00e9r\u00e9e \u00e9teinte
  expect_equal(f(2000, 10), 0)
  expect_false(anyNA(pop$population))
})

test_that("la population ne devient jamais n\u00e9gative et reste nulle une fois \u00e9teinte", {
  negatif <- projpop
  # ajustement tr\u00e8s n\u00e9gatif \u00e0 8 ans, reconduit au-del\u00e0 de 2005
  cible <- negatif$population$age3112 == 8 & negatif$population$annee == 2005
  negatif$population$ajustement[cible] <- -1000
  pop <- prolonger_projpop(negatif, horizon = 2012, age_max = 10)
  expect_true(all(pop$population >= 0))
  expect_true(all(pop$population3112 >= 0, na.rm = TRUE))
  expect_true(all(pop$deces >= 0, na.rm = TRUE))
  # g\u00e9n\u00e9rations pass\u00e9es par 8 ans apr\u00e8s 2005 : \u00e9teintes \u00e0 9 et 10 ans
  futur <- pop[pop$annee >= 2007 & pop$age3112 %in% 9:10, ]
  expect_true(all(futur$population == 0))
})

test_that("les d\u00e9c\u00e8s restent positifs avec un solde migratoire tr\u00e8s n\u00e9gatif", {
  emigration <- projpop
  cible <- emigration$population$age3112 == 10
  emigration$population$solde_migratoire[cible] <- -500
  pop <- prolonger_projpop(emigration, horizon = 2012, age_max = 10)
  expect_true(all(pop$deces >= 0, na.rm = TRUE))
  expect_true(all(pop$population3112 >= 0, na.rm = TRUE))
})

test_that("la mortalit\u00e9 au-del\u00e0 des donn\u00e9es est constante ou suit la tendance", {
  declin <- projpop
  cible <- declin$population$age3112 == 5
  declin$population$qx[cible] <- 0.02 * 0.9^(declin$population$annee[cible] - 2000)
  qx <- function(prol, annee) {
    p <- prol
    p$qx[p$sexe == "F" & p$annee == annee & p$age3112 == 5]
  }
  constante <- prolonger_projpop(declin, horizon = 2015, age_max = 10)
  expect_equal(qx(constante, 2015), qx(constante, 2010))

  tendance <- prolonger_projpop(declin, horizon = 2015, age_max = 10,
                                prolongation_mortalite = "tendance",
                                duree_tendance = 5)
  expect_equal(qx(tendance, 2010), 0.02 * 0.9^10)
  expect_equal(qx(tendance, 2015), 0.02 * 0.9^15)
  # quotient de 1 \u00e0 l'\u00e2ge maximal inchang\u00e9
  p <- tendance
  expect_true(all(p$qx[p$age3112 == 10 & p$annee > 2010] == 1))
  expect_error(prolonger_projpop(declin, prolongation_mortalite = "autre"))
})

test_that("un objet d'entr\u00e9e inadapt\u00e9 est refus\u00e9", {
  expect_error(prolonger_projpop(data.frame()), "lire_projpop_insee")
})
