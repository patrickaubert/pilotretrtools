test_that("le registre des sources est lisible et coh\u00e9rent", {
  registre <- sources_donnees()
  expect_true(all(c("objet", "millesime", "scenario", "url") %in%
                    names(registre)))
  expect_false(anyDuplicated(registre[c("objet", "millesime", "scenario")]) > 0)
  expect_match(url_source("projpop"), "^https://")
  expect_error(url_source("projpop", scenario = "inexistant"), "Aucune source")
})

test_that("les noms de fichiers en cache sont stables et sans caract\u00e8res sp\u00e9ciaux", {
  nom <- pilotretrtools:::nom_fichier_cache(
    "https://www.insee.fr/fr/statistiques/fichier/8990852/00_central.xlsx")
  expect_match(nom, "^[A-Za-z0-9_.]+$")
  expect_match(nom, "\\.xlsx$")
})
