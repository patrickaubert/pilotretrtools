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
