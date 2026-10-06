# Construire les taux de retraités par sexe, âge et année

Assemble les taux de retraités au 31 décembre sur une grille complète de
sexes, d'années et d'âges :

## Usage

``` r
construire_taux_retraites(
  taux_cor,
  taux_retro = donnees_package("taux_retraites_eir"),
  annees = 1962:2180,
  age_max = 120,
  age_min_retraite = 50,
  age_max_retraite = 70,
  annee_debut_retro = NULL
)
```

## Arguments

- taux_cor:

  Taux du COR, tels que produits par
  [`lire_taux_retraites_cor()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_taux_retraites_cor.md).

- taux_retro:

  Taux rétrospectifs (colonnes `sexe`, `annee`, `age3112`,
  `tx_retraites`) ; par défaut la table
  [taux_retraites_eir](https://patrickaubert.github.io/pilotretrtools/reference/taux_retraites_eir.md).
  `NULL` pour n'utiliser que les taux du COR.

- annees:

  Années de la grille.

- age_max:

  Âge maximal de la grille.

- age_min_retraite, age_max_retraite:

  Âges en deçà desquels le taux est nul et au-delà desquels il vaut 1.

- annee_debut_retro:

  Première année retenue pour les taux rétrospectifs ; par défaut,
  première année où ils couvrent tous les âges de `age_min_retraite` à
  `age_max_retraite`.

## Value

Un tibble par `sexe`, `annee` et `age3112`, avec `tx_retraites` et
`source_tx_retraites` (`"COR"`, `"EIR"`, `"convention"` ou
`"prolongation"`).

## Details

- taux projetés par le COR
  ([`lire_taux_retraites_cor()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_taux_retraites_cor.md))
  pour les années qu'ils couvrent ;

- taux rétrospectifs construits à partir des EIR (par défaut la table
  [taux_retraites_eir](https://patrickaubert.github.io/pilotretrtools/reference/taux_retraites_eir.md))
  pour les années antérieures, à partir de la première année où ils
  couvrent tous les âges de `age_min_retraite` à `age_max_retraite` ;

- par convention, taux nul avant `age_min_retraite` et égal à 1 après
  `age_max_retraite` ;

- au-delà de la dernière année du COR, à chaque âge, dernier taux connu
  reconduit.

Les années antérieures au début des données rétrospectives restent
manquantes (`NA`).
