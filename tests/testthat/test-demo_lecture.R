fichiers <- creer_fichiers_insee()

test_that("l'\u00e2ge au 1er janvier est converti en \u00e2ge atteint dans l'ann\u00e9e", {
  pop <- lire_onglet_insee(fichiers$scenario, "populationF", "population")
  expect_equal(range(pop$age3112), c(1, 10))
  expect_equal(sort(unique(pop$annee)), 2000:2005)
  expect_true(all(pop$population[pop$age3112 < 10] == 100))

  deces <- lire_onglet_insee(fichiers$scenario, "decesF", "deces")
  expect_equal(range(deces$age3112), c(0, 10))
})

test_that("seul le premier tableau sous l'en-t\u00eate est lu", {
  # onglets suivis d'une ligne de total, de notes et d'un second tableau
  pop <- lire_onglet_insee(fichiers$scenario, "populationF", "population")
  expect_equal(nrow(pop), 10 * 6)
  expect_false(anyDuplicated(pop[c("annee", "age3112")]) > 0)
  expect_false(any(pop$population == 999, na.rm = TRUE))
  qx <- lire_onglet_insee(fichiers$scenario, "hyp_mortaliteF", "qx")
  expect_equal(nrow(qx), 11 * 6)
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

test_that("les groupes ouverts sont rep\u00e9r\u00e9s et \u00e9cart\u00e9s", {
  pop <- lire_onglet_insee(fichiers$scenario, "populationF", "population")
  ouverts <- pop[pop$groupe_ouvert, ]
  expect_equal(unique(ouverts$age3112), 10)
  expect_true(all(is.na(ouverts$population)))
  gardes <- lire_onglet_insee(fichiers$scenario, "populationF", "population",
                              groupes_ouverts = "garder")
  expect_true(all(gardes$population[gardes$age3112 == 10] == 150))
})

test_that("un d\u00e9tail plus court certaines ann\u00e9es est trait\u00e9 comme groupe ouvert", {
  # en 2000, le d\u00e9tail s'arr\u00eate \u00e0 la ligne \u00ab 8 \u00bb (groupe ouvert sans \u00ab + \u00bb)
  classeur <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(classeur, "decesF")
  tableau <- data.frame(age = c(as.character(0:9), "10+"),
                        `2000` = c(rep(1, 8), 5, NA, NA),
                        `2001` = c(rep(1, 10), 3), check.names = FALSE)
  names(tableau)[1] <- "\u00c2ge atteint dans l'ann\u00e9e"
  openxlsx::writeData(classeur, "decesF", tableau, startRow = 2)
  fichier <- tempfile(fileext = ".xlsx")
  openxlsx::saveWorkbook(classeur, fichier)

  deces <- lire_onglet_insee(fichier, "decesF", "deces")
  ouverts <- deces[deces$groupe_ouvert, c("annee", "age3112")]
  expect_equal(ouverts$annee, c(2000, 2001))
  expect_equal(ouverts$age3112, c(8, 10))
  expect_true(is.na(deces$deces[deces$annee == 2000 & deces$age3112 == 8]))
  expect_equal(deces$deces[deces$annee == 2000 & deces$age3112 == 7], 1)
})

test_that("des z\u00e9ros au-del\u00e0 du groupe ouvert signalent des \u00e2ges non d\u00e9taill\u00e9s", {
  # en 2000, la ligne \u00ab 8 \u00bb est le groupe ouvert et les \u00e2ges sup\u00e9rieurs valent 0,
  # comme la ligne \u00ab 100 \u00bb des fichiers de l'Insee avant 1999
  classeur <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(classeur, "populationF")
  tableau <- data.frame(age = c(as.character(0:9), "10+"),
                        `2000` = c(rep(10, 8), 25, 0, 0),
                        `2001` = c(rep(10, 10), 5), check.names = FALSE)
  names(tableau)[1] <- "\u00c2ge atteint dans l'ann\u00e9e"
  openxlsx::writeData(classeur, "populationF", tableau, startRow = 2)
  fichier <- tempfile(fileext = ".xlsx")
  openxlsx::saveWorkbook(classeur, fichier)

  pop <- lire_onglet_insee(fichier, "populationF", "population",
                           zeros_non_detailles = TRUE)
  en_2000 <- pop[pop$annee == 2000, ]
  expect_true(en_2000$groupe_ouvert[en_2000$age3112 == 8])
  expect_true(all(is.na(en_2000$population[en_2000$age3112 >= 8])))
  expect_equal(en_2000$population[en_2000$age3112 == 7], 10)

  # sans l'option (soldes migratoires, ajustements), les z\u00e9ros sont des valeurs
  brut <- lire_onglet_insee(fichier, "populationF", "valeur")
  expect_true(brut$groupe_ouvert[brut$annee == 2000 & brut$age3112 == 10])
  expect_equal(brut$valeur[brut$annee == 2000 & brut$age3112 == 9], 0)
})
