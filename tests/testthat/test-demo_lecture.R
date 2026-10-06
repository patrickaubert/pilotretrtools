fichiers <- creer_fichiers_insee()

test_that("l'\u00e2ge au 1er janvier est converti en \u00e2ge atteint dans l'ann\u00e9e", {
  pop <- lire_onglet_insee(fichiers$scenario, "populationF", "population")
  expect_equal(range(pop$age3112), c(1, 10))
  expect_equal(sort(unique(pop$annee)), 2000:2005)
  expect_true(all(pop$population == 100))

  deces <- lire_onglet_insee(fichiers$scenario, "decesF", "deces")
  expect_equal(range(deces$age3112), c(0, 10))
})

test_that("lire_projpop_insee assemble sexes, mortalit\u00e9 prolong\u00e9e et f\u00e9condit\u00e9", {
  projpop <- lire_projpop_insee(fichiers$scenario, fichiers$mortalite)
  expect_s3_class(projpop, "projpop_insee")
  expect_setequal(unique(projpop$population$sexe), c("F", "H"))
  # quotients convertis en probabilit\u00e9s et prolong\u00e9s jusqu'en 2010
  expect_equal(max(projpop$population$qx, na.rm = TRUE), 1)
  expect_equal(max(projpop$population$annee), 2010)
  expect_equal(sum(projpop$fecondite$naissances[projpop$fecondite$annee == 2000]),
               205)
  expect_silent(valider_grille(projpop$population))
})

test_that("une ligne d'en-t\u00eate introuvable produit une erreur claire", {
  classeur <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(classeur, "vide")
  openxlsx::writeData(classeur, "vide", data.frame(a = 1:3, b = 4:6))
  fichier <- tempfile(fileext = ".xlsx")
  openxlsx::saveWorkbook(classeur, fichier)
  expect_error(lire_onglet_insee(fichier, "vide"), "introuvable")
})
