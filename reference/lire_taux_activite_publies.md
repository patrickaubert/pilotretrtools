# Rassembler les taux d'activité, d'emploi et de chômage publiés

Rassemble, dans une même table et sans lissage, les taux par sexe et
tranche d'âge tels que publiés par l'Insee (enquête Emploi, projections
de population active) et par le COR (hypothèses d'emploi et de chômage,
pour chaque hypothèse de chômage de long terme). C'est à partir de ces
taux que
[`construire_taux_activite()`](https://patrickaubert.github.io/pilotretrtools/reference/construire_taux_activite.md)
construit les taux par âge fin.

## Usage

``` r
lire_taux_activite_publies(
  eec = lire_taux_emploi_eec(),
  ppa = lire_taux_activite_ppa(),
  chomage = c(5, 7, 10),
  url_cor = url_source("txempl_proj")
)
```

## Arguments

- eec:

  Taux d'emploi observés
  ([`lire_taux_emploi_eec()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_taux_emploi_eec.md)).

- ppa:

  Taux d'activité de la PPA
  ([`lire_taux_activite_ppa()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_taux_activite_ppa.md)).

- chomage:

  Hypothèses de chômage du COR à lire, en %.

- url_cor:

  Adresse (ou chemin local) du fichier d'hypothèses du COR.

## Value

Un tibble avec `source` (`"EEC"`, `"PPA"`, `"COR"`), `hypothese_chomage`
(pour le COR), `sexe`, `annee`, `age_debut`, `age_fin` (`NA` pour la
tranche ouverte), `tx_emploi`, `tx_activite` et `tx_chomage` (manquants
lorsque la source ne les publie pas).

## Examples

``` r
if (FALSE) { # \dontrun{
lire_taux_activite_publies()
} # }
```
