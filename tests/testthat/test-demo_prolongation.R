fichiers <- creer_fichiers_insee()
projpop <- lire_projpop_insee(fichiers$scenario, fichiers$mortalite)

test_that("une population stationnaire reste stationnaire apr\u00e8s prolongation", {
  prol <- prolonger_projpop(projpop, horizon = 2015, annee_agregation = NA)
  pop <- prol$population
  expect_equal(max(pop$annee), 2015)
  futur <- pop[pop$annee > 2005 & pop$age3112 >= 1, ]
  expect_true(all(futur$population[futur$sexe == "F"] == 100))
  expect_true(all(futur$population[futur$sexe == "H"] == 105))
  expect_true(all(prol$naissances$naissances == 205))
  expect_false(any(prol$naissances$calculees[prol$naissances$annee <= 2005]))
  expect_true(all(prol$naissances$calculees[prol$naissances$annee > 2005]))
})

test_that("les identit\u00e9s comptables sont respect\u00e9es", {
  pop <- prolonger_projpop(projpop, horizon = 2015,
                           annee_agregation = NA)$population
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

test_that("le groupe ouvert agr\u00e9g\u00e9 n'est pas propag\u00e9", {
  pop <- prolonger_projpop(projpop, horizon = 2010, annee_agregation = 2003,
                           age_ouvert = 8)$population
  f <- function(annee, age) {
    pop$population[pop$sexe == "F" & pop$annee == annee & pop$age3112 == age]
  }
  expect_equal(f(2004, 8), 100)
  expect_equal(f(2004, 9), 0)
  expect_equal(f(2005, 9), 100)
  expect_equal(f(2005, 10), 0)
})

test_that("un objet d'entr\u00e9e inadapt\u00e9 est refus\u00e9", {
  expect_error(prolonger_projpop(data.frame()), "lire_projpop_insee")
})
