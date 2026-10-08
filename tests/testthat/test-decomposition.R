# Population synth\u00e9tique stationnaire, puis baisse de la mortalit\u00e9 \u00e0 8 et
# 9 ans \u00e0 partir de 2004 ; taux de retrait\u00e9s et d'emploi fictifs.
fichiers <- creer_fichiers_insee()
projpop <- lire_projpop_insee(fichiers$scenario, fichiers$mortalite)
baisse <- projpop
cible <- baisse$population$age3112 %in% 8:9
baisse$population$qx[cible] <- ifelse(baisse$population$annee[cible] >= 2004,
                                       0.1, 0.3)
pop <- prolonger_projpop(baisse, horizon = 2015, age_max = 10,
                         ruptures_champ = NULL)
taux <- tidyr::expand_grid(sexe = c("F", "H"), annee = 2000:2015,
                           age3112 = 0:10) |>
  dplyr::mutate(
    tx_retraites = dplyr::case_when(age3112 >= 8 ~ 1, age3112 == 7 ~ 0.5,
                                    TRUE ~ 0),
    tx_retraites = dplyr::if_else(annee >= 2010 & age3112 == 7, 0.2,
                                  tx_retraites),
    tx_emploi = dplyr::if_else(age3112 %in% 2:7, 0.8, 0),
    tx_activite = tx_emploi, tx_chomage = 0)
pop <- pop |> ajouter_retraites(taux) |> ajouter_actifs(taux)

test_that("les r\u00e9f\u00e9rences de mortalit\u00e9 se construisent et s'affichent", {
  expect_s3_class(mortalite_annee(1982), "reference_mortalite")
  expect_match(format(mortalite_generation(1950)), "g\u00e9n\u00e9ration 1950")
  expect_error(projeter_mortalite_reference(pop, reference = 1982), "cr\u00e9\u00e9e")
})

test_that("le gain de mortalit\u00e9 est nul avant la r\u00e9f\u00e9rence et sans baisse", {
  avec <- projeter_mortalite_reference(pop, mortalite_annee(2003),
                                       age_debut = 8)
  expect_true(all(avec$gain_mortalite[avec$annee <= 2003] == 0))
  expect_true(all(avec$gain_mortalite[avec$age3112 < 8] == 0))
  expect_true(any(avec$gain_mortalite[avec$annee > 2004] > 0))
  # r\u00e9f\u00e9rence post\u00e9rieure \u00e0 la baisse : aucun gain apr\u00e8s 2004
  apres <- projeter_mortalite_reference(pop, mortalite_annee(2005),
                                        age_debut = 8)
  expect_true(all(abs(apres$gain_mortalite) < 1e-9))
  expect_equal(avec$population3112_ref,
               avec$population3112 - avec$gain_mortalite)
})

test_that("la d\u00e9composition est exacte et additive dans le temps", {
  dec <- decomposer_evolutions(pop, mortalite_annee(2003),
                               age_debut_mortalite = 8, age_seuil_emploi = 5)
  dec <- dec[!is.na(dec$d_nb_retraites), ]
  expect_equal(dec$d_nb_retraites,
               dec$d_nb_retraites_taux + dec$d_nb_retraites_mortalite +
                 dec$d_nb_retraites_taille)
  expect_equal(dec$d_nb_actifs_occupes,
               dec$d_nb_actifs_occupes_taux_avant +
                 dec$d_nb_actifs_occupes_taux_apres +
                 dec$d_nb_actifs_occupes_mortalite +
                 dec$d_nb_actifs_occupes_taille)
  expect_equal(dec$d_rapport_demo,
               dec$d_rapport_demo_taux_retraites +
                 dec$d_rapport_demo_taux_emploi_avant +
                 dec$d_rapport_demo_taux_emploi_apres +
                 dec$d_rapport_demo_mortalite + dec$d_rapport_demo_taille)
  # somme des effets mortalit\u00e9 = variation du surplus de retrait\u00e9s
  surplus <- dec$nb_retraites - dec$nb_retraites_ref
  expect_equal(sum(dec$d_nb_retraites_mortalite[dec$annee > 2001]),
               surplus[dec$annee == 2015] - surplus[dec$annee == 2001])
  # baisse du taux de retrait\u00e9s \u00e0 7 ans en 2010 : effet taux n\u00e9gatif
  expect_lt(dec$d_nb_retraites_taux[dec$annee == 2010], 0)
  expect_equal(dec$d_nb_retraites_taux[dec$annee == 2012], 0)
  # gains de mortalit\u00e9 \u00e0 partir de 2004 : effet positif sur les retrait\u00e9s
  expect_gt(dec$d_nb_retraites_mortalite[dec$annee == 2004], 0)
})

test_that("decomposer_evolutions avertit sans correction de champ", {
  avec_rupture <- pop
  avec_rupture$coef_champ[avec_rupture$annee < 2003] <- 1.1
  expect_warning(decomposer_evolutions(avec_rupture), "champ")
  expect_error(decomposer_evolutions(pop[c("sexe", "annee", "age3112")]),
               "absentes")
})

test_that("donnees_graph_decomposition met en forme les effets", {
  dec <- decomposer_evolutions(pop, mortalite_annee(2003),
                               age_debut_mortalite = 8, age_seuil_emploi = 5)
  g <- donnees_graph_decomposition(dec, "actifs_occupes")
  expect_equal(levels(g$effet)[1:2], c("Taux d'emploi avant 5 ans",
                                       "Taux d'emploi apr\u00e8s 5 ans"))
  somme <- tapply(g$valeur, g$annee, sum)
  variation <- tapply(g$variation, g$annee, unique)
  expect_equal(as.vector(somme), as.vector(variation))
  expect_equal(nlevels(donnees_graph_decomposition(dec, "rapport_demo")$effet), 5)
  expect_true(all(donnees_graph_decomposition(dec, annees = 2010)$annee == 2010))
})

test_that("les r\u00e9f\u00e9rences hors p\u00e9riode et les ann\u00e9es sans quotients sont g\u00e9r\u00e9es", {
  # ann\u00e9es 2000 et 2001 sans quotients, comme la s\u00e9rie historique
  sans_qx <- pop
  sans_qx$qx[sans_qx$annee <= 2001] <- NA
  expect_message(
    avec <- projeter_mortalite_reference(sans_qx, mortalite_annee_age(8),
                                         age_debut = 8),
    "ramen")
  expect_true(all(avec$gain_mortalite[avec$annee <= 2001] == 0))
  expect_false(anyNA(avec$gain_mortalite))
  expect_true(any(avec$gain_mortalite != 0))
  expect_no_error(projeter_mortalite_reference(pop, mortalite_annee(1950),
                                               age_debut = 8) |>
                    suppressMessages())
})
