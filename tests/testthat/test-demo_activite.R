eec <- lire_taux_emploi_eec(creer_fichier_eec())
ppa <- lire_taux_activite_ppa(creer_fichier_ppa())
cor <- suppressMessages(lire_hypotheses_cor(creer_fichier_hypotheses_cor()))

test_that("lire_taux_emploi_eec ne garde que les tranches quinquennales", {
  expect_setequal(unique(eec$sexe), c("F", "H"))
  expect_equal(sort(unique(eec$age_debut)), c(tranches_test, 75))
  expect_true(is.na(unique(eec$age_fin[eec$age_debut == 75])))
  expect_equal(eec$tx_emploi[eec$sexe == "F" & eec$annee == 2010 &
                               eec$age_debut == 25], 0.8)
})

test_that("lire_taux_activite_ppa lit les blocs des femmes et des hommes", {
  expect_setequal(unique(ppa$sexe), c("F", "H"))
  expect_equal(range(ppa$annee), c(2010, 2016))
  expect_true(is.na(unique(ppa$age_fin[ppa$age_debut == 70])))
  expect_equal(ppa$tx_activite[ppa$sexe == "H" & ppa$annee == 2012 &
                                 ppa$age_debut == 25], 0.8 / 0.9)
})

test_that("lire_hypotheses_cor corrige les ann\u00e9es et d\u00e9duit l'activit\u00e9", {
  messages <- capture_messages(
    lire_hypotheses_cor(creer_fichier_hypotheses_cor()))
  expect_length(messages, 2)
  expect_match(messages, "corrig\u00e9e")
  expect_equal(range(cor$annee), c(2014, 2020))
  expect_equal(cor$tx_activite, cor$tx_emploi / 0.9)
  expect_equal(attr(cor, "hypothese_chomage"), 7)
})

test_that("construire_taux_activite raccorde les sources et lisse par \u00e2ge", {
  taux <- construire_taux_activite(eec, ppa, cor, horizon = 2025)
  sources <- unique(taux[c("annee", "source_tx_emploi", "source_tx_activite")][
    taux$age3112 == 40, ])
  expect_equal(sources$source_tx_activite[sources$annee == 2012], "PPA + lissage")
  expect_equal(sources$source_tx_activite[sources$annee == 2015],
               "EEC + COR + lissage")
  expect_equal(sources$source_tx_emploi[sources$annee == 2018], "COR + lissage")
  expect_equal(sources$source_tx_emploi[sources$annee == 2023], "prolongation")
  # moyennes par tranche respect\u00e9es (poids uniformes) et taux nuls hors \u00e2ges
  t2018 <- taux[taux$sexe == "F" & taux$annee == 2018, ]
  expect_equal(mean(t2018$tx_emploi[t2018$age3112 %in% 40:44]), 0.85)
  expect_equal(mean(t2018$tx_activite[t2018$age3112 %in% 40:44]), 0.85 / 0.9)
  expect_true(all(taux$tx_emploi[taux$age3112 >= 80 | taux$age3112 < 15] == 0))
  # coh\u00e9rence des trois taux
  ok <- taux$tx_activite > 0
  expect_equal(taux$tx_chomage[ok],
               1 - taux$tx_emploi[ok] / taux$tx_activite[ok])
  expect_true(all(taux$tx_activite >= taux$tx_emploi))
  expect_true(all(taux$tx_chomage >= 0 & taux$tx_chomage < 1))
  expect_equal(attr(taux, "hypothese_chomage"), 7)
})

test_that("ajouter_actifs calcule actifs et actifs occup\u00e9s au 31 d\u00e9cembre", {
  fichiers <- creer_fichiers_insee()
  pop <- prolonger_projpop(lire_projpop_insee(fichiers$scenario,
                                              fichiers$mortalite),
                           horizon = 2010, age_max = 10)
  taux <- tidyr::expand_grid(sexe = c("F", "H"), annee = 2000:2010,
                             age3112 = 0:10) |>
    dplyr::mutate(tx_emploi = 0.5, tx_activite = 0.6,
                  tx_chomage = 1 - 0.5 / 0.6)
  avec <- ajouter_actifs(pop, taux)
  expect_equal(avec$nb_actifs, avec$population3112 * 0.6)
  expect_equal(avec$nb_actifs_occupes, avec$population3112 * 0.5)
  expect_false(is.null(attr(avec, "parametres")))
})

test_that("lire_taux_activite_publies rassemble les taux sans lissage", {
  fichier_cor <- creer_fichier_hypotheses_cor()
  publies <- lire_taux_activite_publies(eec, ppa, chomage = 7,
                                        url_cor = fichier_cor)
  expect_setequal(unique(publies$source), c("EEC", "PPA", "COR"))
  expect_equal(unique(publies$hypothese_chomage[publies$source == "COR"]), 7)
  expect_true(all(is.na(publies$tx_activite[publies$source == "EEC"])))
  expect_equal(publies$tx_emploi[publies$source == "EEC" & publies$sexe == "F" &
                                   publies$annee == 2010 &
                                   publies$age_debut == 25], 0.8)
})
