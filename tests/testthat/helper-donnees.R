# Fichiers synthétiques reproduisant la mise en page des fichiers de
# projections de l'Insee : population stationnaire (100 femmes et 105 hommes
# à chaque âge de 1 à 10 ans), mortalité nulle sauf à 10 ans (quotient de 1),
# solde migratoire et ajustement nuls, 205 naissances par an.

ecrire_onglet <- function(classeur, nom, ages, annees, valeurs, libelle_age) {
  openxlsx::addWorksheet(classeur, nom)
  openxlsx::writeData(classeur, nom, paste("Titre de l'onglet", nom),
                      startRow = 1)
  tableau <- as.data.frame(matrix(valeurs, nrow = length(ages),
                                  ncol = length(annees)))
  names(tableau) <- annees
  tableau <- cbind(age = ages, tableau)
  names(tableau)[1] <- libelle_age
  openxlsx::writeData(classeur, nom, tableau, startRow = 3)
}

creer_fichiers_insee <- function(repertoire = tempfile("insee")) {
  dir.create(repertoire, showWarnings = FALSE)
  annees <- 2000:2005
  ages_atteints <- as.character(0:10)
  quotients <- c(rep(0, 10), 1e5)

  scenario <- openxlsx::createWorkbook()
  for (sexe in c("F", "H")) {
    effectif <- if (sexe == "F") 100 else 105
    ecrire_onglet(scenario, paste0("population", sexe), as.character(0:9),
                  annees, effectif, "\u00c2ge au 1er janvier")
    ecrire_onglet(scenario, paste0("deces", sexe), ages_atteints, annees,
                  c(rep(0, 10), effectif), "\u00c2ge atteint dans l'ann\u00e9e")
    ecrire_onglet(scenario, paste0("hyp_mortalite", sexe), ages_atteints,
                  annees, quotients, "\u00c2ge atteint dans l'ann\u00e9e")
    ecrire_onglet(scenario, paste0("hyp_soldemig", sexe), ages_atteints,
                  annees, 0, "\u00c2ge atteint dans l'ann\u00e9e")
    ecrire_onglet(scenario, paste0("ajustement", sexe), ages_atteints,
                  annees, 0, "\u00c2ge atteint dans l'ann\u00e9e")
  }
  fecondes <- 0:10 %in% 3:7
  ecrire_onglet(scenario, "naissance", ages_atteints, annees, 41 * fecondes,
                "\u00c2ge")
  ecrire_onglet(scenario, "hyp_fecondite", ages_atteints, annees,
                4100 * fecondes, "\u00c2ge")
  fichier_scenario <- file.path(repertoire, "00_central.xlsx")
  openxlsx::saveWorkbook(scenario, fichier_scenario, overwrite = TRUE)

  mortalite <- openxlsx::createWorkbook()
  for (sexe in c("F", "H")) {
    ecrire_onglet(mortalite, paste0("central", sexe), ages_atteints,
                  2000:2010, quotients, "\u00c2ge atteint dans l'ann\u00e9e")
  }
  fichier_mortalite <- file.path(repertoire, "hyp_mortalite.xlsx")
  openxlsx::saveWorkbook(mortalite, fichier_mortalite, overwrite = TRUE)

  list(scenario = fichier_scenario, mortalite = fichier_mortalite)
}
