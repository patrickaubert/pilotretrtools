# Lisser par âge fin des taux connus par tranche d'âge

Estime des taux par âge fin à partir de taux moyens par tranche d'âge
(par exemple les taux d'activité par tranche quinquennale de l'Insee).
La méthode, reprise de la fonction `prevalenceApprox()` du package
`healthexpectancies`, minimise la somme des carrés des différences
secondes des taux selon l'âge, sous la contrainte que la moyenne des
taux de chaque tranche, pondérée par les effectifs par âge (`poids`),
soit égale au taux observé de la tranche. Les taux obtenus sont ensuite
ramenés dans l'intervalle `bornes` : lorsque cette borne joue (taux très
proches de 0 ou de 1 aux âges extrêmes), la moyenne de la tranche
concernée n'est plus exactement respectée.

## Usage

``` r
lisser_par_age(
  taux,
  debuts_tranches,
  age_min,
  age_max,
  poids = rep(1, age_max - age_min + 1),
  bornes = c(0, 1)
)
```

## Arguments

- taux:

  Taux observés, un par tranche d'âge.

- debuts_tranches:

  Âge de début de chaque tranche (même longueur que `taux`, ordre
  croissant). La dernière tranche va jusqu'à `age_max`.

- age_min, age_max:

  Âges extrêmes en sortie ; `age_min` doit être égal au début de la
  première tranche.

- poids:

  Effectifs par âge, de `age_min` à `age_max` (par défaut uniformes).

- bornes:

  Valeurs minimale et maximale des taux en sortie (`NULL` pour ne pas
  borner).

## Value

Un vecteur de taux, un par âge de `age_min` à `age_max`.

## Examples

``` r
lisser_par_age(c(0.2, 0.6, 0.9, 0.8), debuts_tranches = c(15, 20, 25, 30),
               age_min = 15, age_max = 34)
#>  [1] 0.04680587 0.12303738 0.19944296 0.27637077 0.35434302 0.43405601
#>  [7] 0.51638012 0.60062915 0.68456034 0.76437438 0.83471540 0.88867094
#> [13] 0.92191947 0.93273035 0.92196385 0.89307113 0.85209427 0.80386693
#> [19] 0.75201434 0.69895334
```
