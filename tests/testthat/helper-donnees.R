# Fichiers synthétiques reproduisant la mise en page des fichiers de
# projections de l'Insee : population stationnaire (100 femmes et 105 hommes
# à chaque âge de 1 à 10 ans), mortalité nulle sauf à 10 ans (quotient de 1),
# solde migratoire et ajustement nuls, 205 naissances par an. Comme dans les
# fichiers de l'Insee, la dernière ligne de population (« 9+ » au 1er
# janvier) est un groupe ouvert, dont l'effectif (150) dépasse celui de
# l'âge précédent.

# Comme dans les fichiers de l'Insee, chaque tableau est suivi d'une ligne de
# total et de notes ; certains onglets comportent un second tableau en dessous.
ecrire_onglet <- function(classeur, nom, ages, annees, valeurs, libelle_age,
                          second_tableau = FALSE) {
  openxlsx::addWorksheet(classeur, nom)
  openxlsx::writeData(classeur, nom, paste("Titre de l'onglet", nom),
                      startRow = 1)
  tableau <- as.data.frame(matrix(valeurs, nrow = length(ages),
                                  ncol = length(annees)))
  names(tableau) <- annees
  tableau <- cbind(age = ages, tableau)
  names(tableau)[1] <- libelle_age
  openxlsx::writeData(classeur, nom, tableau, startRow = 3)
  ligne <- 4 + length(ages)
  openxlsx::writeData(classeur, nom, data.frame(x = c("Total", "Champ :",
                                                      "1. Note de lecture")),
                      startRow = ligne, colNames = FALSE)
  if (second_tableau) {
    tableau[-1] <- 999
    openxlsx::writeData(classeur, nom, tableau, startRow = ligne + 4)
  }
}

creer_fichiers_insee <- function(repertoire = tempfile("insee")) {
  dir.create(repertoire, showWarnings = FALSE)
  annees <- 2000:2005
  ages_atteints <- as.character(0:10)
  quotients <- c(rep(0, 10), 1e5)

  scenario <- openxlsx::createWorkbook()
  for (sexe in c("F", "H")) {
    effectif <- if (sexe == "F") 100 else 105
    ecrire_onglet(scenario, paste0("population", sexe),
                  c(as.character(0:8), "9+"), annees,
                  c(rep(effectif, 9), 1.5 * effectif),
                  "\u00c2ge au 1er janvier", second_tableau = TRUE)
    ecrire_onglet(scenario, paste0("deces", sexe), ages_atteints, annees,
                  c(rep(0, 10), effectif), "\u00c2ge atteint dans l'ann\u00e9e")
    ecrire_onglet(scenario, paste0("hyp_mortalite", sexe), ages_atteints,
                  annees, quotients, "\u00c2ge atteint dans l'ann\u00e9e",
                  second_tableau = TRUE)
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

# Fichier synthétique au format du tableau POP3 de l'Insee : un onglet par
# année, France métropolitaine puis champ « France » de l'époque, par âge
# révolu au 1er janvier (groupe ouvert « 10 ou plus »).
creer_fichier_pop_champs <- function(fichier = tempfile(fileext = ".xlsx"),
                                     coef_drom = 1.03, coef_mayotte = 1.01) {
  classeur <- openxlsx::createWorkbook()
  ages <- c(as.character(0:9), "10 ou plus")
  champs <- list("1995" = c("France hors Mayotte", coef_drom),
                 "2013" = c("France hors Mayotte", coef_drom),
                 "2014" = c("France", coef_drom * coef_mayotte))
  for (annee in names(champs)) {
    openxlsx::addWorksheet(classeur, annee)
    metro <- rep(1000, length(ages))
    autre <- round(metro * as.numeric(champs[[annee]][2]), 1)
    openxlsx::writeData(classeur, annee, paste("POP3 - Ann\u00e9e", annee),
                        startRow = 1)
    openxlsx::writeData(
      classeur, annee,
      data.frame(a = NA, b = NA, c = "France m\u00e9tropolitaine", d = NA,
                 e = NA, f = champs[[annee]][1]),
      startRow = 4, colNames = FALSE)
    tableau <- data.frame(
      naissance = as.numeric(annee) - 1 - seq_along(ages) + 1,
      age = ages, e1 = 2 * metro, h1 = metro, f1 = metro,
      e2 = 2 * autre, h2 = autre, f2 = autre)
    names(tableau) <- c("Ann\u00e9e de naissance", "\u00c2ge en ann\u00e9es r\u00e9volues",
                        "Ensemble", "Hommes", "Femmes",
                        "Ensemble", "Hommes", "Femmes")
    openxlsx::writeData(classeur, annee, tableau, startRow = 5)
    openxlsx::writeData(classeur, annee, "Population totale",
                        startRow = 5 + length(ages) + 3)
  }
  openxlsx::saveWorkbook(classeur, fichier, overwrite = TRUE)
  fichier
}

# Onglet synthétique au format des données complémentaires du COR : trois
# tableaux (ensemble, femmes, hommes), chacun précédé d'une ligne
# « Sexe / Âge / année » et d'une ligne d'années ; colonne A vide comme dans
# le fichier réel (`colonne_vide = FALSE` pour une variante sans).
creer_fichier_taux_cor <- function(fichier = tempfile(fileext = ".xlsx"),
                                   annees = 2000:2005, ages = 50:70,
                                   colonne_vide = TRUE) {
  classeur <- openxlsx::createWorkbook()
  onglet <- "Tx_retrait\u00e9s_an"
  openxlsx::addWorksheet(classeur, onglet)
  depart <- if (colonne_vide) 2 else 1
  openxlsx::writeData(classeur, onglet, "Taux de retrait\u00e9s par sexe et \u00e2ge",
                      startRow = 1)
  ligne <- 4
  for (sexe in c("Ensemble", "Femmes", "Hommes")) {
    openxlsx::writeData(classeur, onglet,
                        t(c("Sexe", "\u00c2ge", "ann\u00e9e")),
                        startRow = ligne, startCol = depart, colNames = FALSE)
    openxlsx::writeData(classeur, onglet, t(annees), startRow = ligne + 1,
                        startCol = depart + 2, colNames = FALSE)
    taux <- outer((ages - 50) / 20, rep(1, length(annees)))
    if (sexe == "Hommes") taux <- taux * 0.9
    bloc <- data.frame(c(sexe, rep(NA, length(ages) - 1)), ages, taux)
    openxlsx::writeData(classeur, onglet, bloc, startRow = ligne + 2,
                        startCol = depart, colNames = FALSE)
    ligne <- ligne + length(ages) + 3
  }
  openxlsx::saveWorkbook(classeur, fichier, overwrite = TRUE)
  fichier
}

# Fichiers synthétiques reproduisant la mise en page des sources d'emploi et
# d'activité : taux constants dans le temps, profil simple par tranche.
tranches_test <- c(seq(15, 70, 5))
emploi_test <- c(0.2, 0.6, 0.8, 0.85, 0.85, 0.85, 0.85, 0.8, 0.7, 0.3, 0.1, 0.02)

creer_fichier_eec <- function(fichier = tempfile(fileext = ".xlsx"),
                              annees = 2010:2016) {
  classeur <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(classeur, "T207")
  openxlsx::writeData(classeur, "T207", "T207 : Taux d'emploi", startRow = 1)
  openxlsx::writeData(classeur, "T207", t(c(NA, "Annuel", annees)),
                      startRow = 4, colNames = FALSE)
  openxlsx::writeData(classeur, "T207", t(c("Sexe", "\u00c2ge")), startRow = 5,
                      colNames = FALSE)
  libelles <- c("Total", "De 15 \u00e0 64 ans",
                paste0("De ", tranches_test, " \u00e0 ", tranches_test + 4, " ans"),
                "75 ans ou plus")
  valeurs <- c(50, 60, emploi_test * 100, 0.5)
  ligne <- 7
  for (sexe in c("Femme", "Homme", "Total")) {
    bloc <- data.frame(sexe, libelles,
                       matrix(valeurs, nrow = length(valeurs),
                              ncol = length(annees)))
    openxlsx::writeData(classeur, "T207", bloc, startRow = ligne,
                        colNames = FALSE)
    ligne <- ligne + length(libelles)
  }
  openxlsx::writeData(classeur, "T207", "Champ : France", startRow = ligne + 1)
  openxlsx::saveWorkbook(classeur, fichier, overwrite = TRUE)
  fichier
}

creer_fichier_ppa <- function(fichier = tempfile(fileext = ".xlsx"),
                              annees = 2010:2016) {
  classeur <- openxlsx::createWorkbook()
  onglet <- "taux_activit\u00e9"
  openxlsx::addWorksheet(classeur, onglet)
  libelles <- c(paste0(tranches_test[-12], "-", tranches_test[-12] + 4, " ans"),
                "70 ans et plus")
  activite <- emploi_test / 0.9 * 100
  for (k in 0:2) {
    colonne <- 2 + k * length(libelles)
    openxlsx::writeData(classeur, onglet, c("Ensemble", "Femmes", "Hommes")[k + 1],
                        startRow = 1, startCol = colonne)
    openxlsx::writeData(classeur, onglet, t(libelles), startRow = 2,
                        startCol = colonne, colNames = FALSE)
    openxlsx::writeData(classeur, onglet,
                        matrix(activite, nrow = length(annees),
                               ncol = length(libelles), byrow = TRUE),
                        startRow = 3, startCol = colonne, colNames = FALSE)
  }
  openxlsx::writeData(classeur, onglet, "Ann\u00e9e", startRow = 2, startCol = 1)
  openxlsx::writeData(classeur, onglet, annees, startRow = 3, startCol = 1,
                      colNames = FALSE)
  openxlsx::saveWorkbook(classeur, fichier, overwrite = TRUE)
  fichier
}

# Hypothèses du COR : chômage de 10 % à tous les âges, emploi égal à
# `emploi_test` ; la dernière année est mal étiquetée, comme dans le fichier
# de 2025.
creer_fichier_hypotheses_cor <- function(fichier = tempfile(fileext = ".xlsx"),
                                         annees = 2014:2020) {
  classeur <- openxlsx::createWorkbook()
  codes <- c(paste0("F", tranches_test, "S"), paste0("H", tranches_test, "S"))
  etiquettes <- annees
  etiquettes[length(etiquettes)] <- annees[1]
  for (onglet in c("Emploi_7%", "Ch\u00f4mage_7%")) {
    openxlsx::addWorksheet(classeur, onglet)
    openxlsx::writeData(classeur, onglet, paste("Taux -", onglet), startRow = 1)
    openxlsx::writeData(classeur, onglet,
                        t(c("Ann\u00e9e", "Total", "Total_F", "Total_H", codes)),
                        startRow = 4, colNames = FALSE)
    valeurs <- if (grepl("Emploi", onglet)) rep(emploi_test, 2) * 100 else
      rep(10, length(codes))
    openxlsx::writeData(classeur, onglet,
                        cbind(etiquettes, 50, 50, 50,
                              matrix(valeurs, nrow = length(annees),
                                     ncol = length(codes), byrow = TRUE)),
                        startRow = 5, colNames = FALSE)
  }
  openxlsx::saveWorkbook(classeur, fichier, overwrite = TRUE)
  fichier
}
