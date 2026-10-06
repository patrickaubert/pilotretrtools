# Prolonger les projections de population de l'Insee

Prolonge un scénario des projections de population de l'Insee au-delà de
son horizon de publication, en reproduisant la méthode des composantes :
chaque année, la population de chaque génération est obtenue à partir de
celle de l'année précédente, diminuée des décès et augmentée du solde
migratoire et de l'ajustement ; les naissances sont calculées à partir
de la population féminine et des taux de fécondité par âge (les
naissances publiées par l'Insee sont utilisées lorsqu'elles existent).

## Usage

``` r
prolonger_projpop(
  projpop,
  horizon = 2180,
  age_max = NULL,
  annee_agregation = 2023,
  age_ouvert = 105,
  rapport_masculinite = 1.05,
  arrondir = TRUE
)
```

## Arguments

- projpop:

  Objet renvoyé par
  [`lire_projpop_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_projpop_insee.md).

- horizon:

  Dernière année de la projection prolongée.

- age_max:

  Âge maximal (en âge atteint dans l'année). Par défaut, le plus grand
  âge présent dans les données.

- annee_agregation:

  Première année pour laquelle les fichiers de l'Insee agrègent les âges
  élevés en un groupe ouvert ; `NA` si aucune agrégation.

- age_ouvert:

  Premier âge (atteint dans l'année) du groupe ouvert.

- rapport_masculinite:

  Nombre de naissances de garçons pour une naissance de fille.

- arrondir:

  Si `TRUE` (défaut), les décès et les naissances sont arrondis à
  l'unité, comme dans les projections de l'Insee.

## Value

Une liste de classe `projpop_prolongee` contenant :

- `population` : tibble par `sexe`, `generation`, `annee`, `age0101`,
  `age3112`, avec `population` (au 1er janvier), `deces`, `qx`,
  `solde_migratoire`, `ajustement`, `population3112` (au 31 décembre) et
  `prolonge` (`TRUE` pour les valeurs calculées par la fonction) ;

- `naissances` : tibble par `annee` des naissances utilisées pour les
  générations non diffusées (`calculees = TRUE` lorsqu'elles sont
  calculées à partir de la fécondité, `FALSE` lorsqu'elles sont reprises
  des naissances publiées) ;

- `parametres` et `sources` : les paramètres de prolongation et les
  sources lues.

## Details

Le calcul est mené année par année, de manière vectorisée sur les âges.
Seules les cellules sans population diffusée sont calculées, ainsi que
les âges du groupe ouvert (voir `age_ouvert`) : les valeurs publiées par
l'Insee sont conservées partout ailleurs.

Hypothèses de prolongation :

- quotients de mortalité, soldes migratoires, ajustements et taux de
  fécondité : à chaque âge, dernière valeur connue reconduite ;

- quotients de mortalité aux âges non couverts : valeur de l'âge
  inférieur ;

- groupe ouvert : à partir de l'année suivant `annee_agregation`, la
  population aux âges `age_ouvert` et plus est recalculée par génération
  ; le groupe ouvert agrégé de l'année `annee_agregation` n'est pas
  propagé (simplification : les générations correspondantes sont
  considérées comme éteintes).

Pour les années observées, le solde migratoire (non diffusé par l'Insee)
est calculé comme résidu de l'équation comptable.

## Examples

``` r
if (FALSE) { # \dontrun{
projpop <- prolonger_projpop(lire_projpop_insee(), horizon = 2180)
} # }
```
