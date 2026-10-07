# Taux de retraités et taux d'activité et d'emploi du scénario central,
# embarqués dans le package pour permettre un usage hors ligne.
#
# À relancer après data-raw/projpop_central.R et data-raw/taux_retraites_eir.R,
# ou lorsque l'Insee ou le COR publient de nouvelles données (mettre d'abord à
# jour le registre inst/extdata/sources.csv).

devtools::load_all()

taux_retraites_central <- construire_taux_retraites(lire_taux_retraites_cor())
dplyr::count(taux_retraites_central, source_tx_retraites)

eec <- lire_taux_emploi_eec()
ppa <- lire_taux_activite_ppa()

taux_activite_central <- construire_taux_activite(
  eec, ppa, lire_hypotheses_cor(chomage = 7), population = projpop_central
)
dplyr::count(taux_activite_central, source_tx_emploi, source_tx_activite)

# taux publiés, non lissés (Insee et COR, trois hypothèses de chômage)
taux_activite_publies <- lire_taux_activite_publies(eec, ppa)
dplyr::count(taux_activite_publies, source, hypothese_chomage)

usethis::use_data(taux_retraites_central, taux_activite_central,
                  taux_activite_publies, overwrite = TRUE, compress = "xz")
