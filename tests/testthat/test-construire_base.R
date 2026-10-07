# Utilise les tables embarqu\u00e9es (sc\u00e9nario central), sans acc\u00e8s \u00e0 internet.
projpop <- donnees_package("projpop_central")
url_centrale <- unname(attr(projpop, "sources")[["scenario"]])
horizon <- max(projpop$annee)

test_that("construire_base assemble la base centrale hors ligne", {
  expect_no_message(
    base <- construire_base(url_scenario = url_centrale, horizon = horizon))
  colonnes <- c("population3112", "tx_retraites", "nb_retraites",
                "tx_emploi", "nb_actifs_occupes", "nb_actifs", "champ")
  expect_true(all(colonnes %in% names(base)))
  expect_equal(nrow(base), nrow(projpop))
  expect_true(attr(base, "champ_corrige"))
  expect_true(attr(base, "options_base")$tables_embarquees)
  expect_silent(valider_grille(base))
})

test_that("construire_base peut omettre la s\u00e9rie historique et la correction", {
  base <- construire_base(url_scenario = url_centrale, horizon = horizon,
                          serie_historique = FALSE, corriger_champ = FALSE)
  historiques <- attr(projpop, "parametres")$annees_historiques
  expect_false(any(base$annee %in% historiques))
  expect_null(attr(base, "champ_corrige"))
  expect_false(is.null(attr(base, "parametres")))
})
