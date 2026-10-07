# Prolonger les projections de population de l'Insee

Prolonge un scénario des projections de population de l'Insee au-delà de
son horizon de publication et reconstitue les effectifs aux âges élevés
que l'Insee diffuse sous forme agrégée, par la méthode des composantes :
chaque année, la population de chaque génération est obtenue à partir de
celle de l'année précédente, diminuée des décès et augmentée du solde
migratoire et de l'ajustement. Les naissances sont celles publiées par
l'Insee lorsqu'elles existent ; au-delà, elles sont calculées à partir
de la population féminine et des taux de fécondité par âge.

## Usage

``` r
prolonger_projpop(
  projpop,
  horizon = 2180,
  age_max = 120,
  prolongation_mortalite = c("constante", "tendance"),
  duree_tendance = 20,
  rapport_masculinite = 1.05,
  coef_champ = NULL,
  ruptures_champ = c(1995, 2014),
  annees_voisines = 2,
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

  Âge maximal (en âge atteint dans l'année).

- prolongation_mortalite:

  Hypothèse de mortalité au-delà de la dernière année disponible :
  `"constante"` ou `"tendance"`.

- duree_tendance:

  Nombre d'années, en remontant depuis la dernière année disponible, sur
  lequel est mesurée l'évolution des quotients lorsque
  `prolongation_mortalite = "tendance"`.

- rapport_masculinite:

  Nombre de naissances de garçons pour une naissance de fille.

- coef_champ:

  Coefficients de correction des ruptures de champ géographique, tels
  que produits par
  [`calculer_coef_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/calculer_coef_champ.md)
  à partir des publications de l'Insee (méthode recommandée). Si `NULL`,
  ils sont estimés indirectement par
  [`estimer_coef_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/estimer_coef_champ.md)
  pour les années `ruptures_champ`.

- ruptures_champ:

  Années de changement du champ géographique (première année dans le
  nouveau champ), utilisées lorsque `coef_champ` est `NULL`. `NULL` pour
  ne pas corriger les ruptures.

- annees_voisines:

  Nombre d'années de part et d'autre de chaque rupture utilisées par la
  méthode indirecte pour neutraliser les migrations.

- arrondir:

  Si `TRUE` (défaut), les décès et les naissances calculés sont arrondis
  à l'unité, comme dans les projections de l'Insee.

## Value

Un tibble par `sexe`, `generation`, `annee`, `age0101` et `age3112`,
avec les colonnes :

- `population` : population au 1er janvier ;

- `naissances` : naissances de l'année, par sexe, sur les lignes d'âge 0
  (`NA` aux autres âges) ;

- `deces`, `qx`, `solde_migratoire`, `ajustement` : décès, quotient de
  mortalité, solde migratoire et ajustement de l'année ;

- `population3112` : population au 31 décembre ;

- `prolonge` : `TRUE` pour les effectifs calculés par la fonction ;

- `champ` : champ géographique des données de l'année (voir
  [`champ_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/champ_insee.md))
  ;

- `coef_champ` : coefficient multiplicatif ramenant les effectifs au
  champ géographique le plus récent (voir
  [`corriger_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/corriger_champ.md)).

Les effectifs sont ceux du champ publié par l'Insee pour chaque année.
Les paramètres de prolongation, les sources et le détail des
coefficients de correction de champ sont stockés dans les attributs
`parametres`, `sources` et `coef_champ`.

## Details

Les valeurs publiées par l'Insee sont conservées partout où elles
existent. Sont calculées par la fonction :

- toutes les cellules au-delà de l'horizon des projections ;

- les âges couverts par un groupe ouvert dans les fichiers de l'Insee («
  105+ », ou « 100 » les années où le détail s'arrête à 100 ans), que
  [`lire_projpop_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_projpop_insee.md)
  a écartés.

Hypothèses :

- **mortalité** : au-delà de la dernière année disponible (2125 avec le
  fichier de mortalité prolongée de l'Insee), selon
  `prolongation_mortalite` :

  - `"constante"` (défaut) : à chaque âge, les quotients de la dernière
    année sont reconduits à l'identique ;

  - `"tendance"` : à chaque âge, les quotients poursuivent leur
    évolution annuelle moyenne observée sur les `duree_tendance`
    dernières années disponibles (évolution géométrique, quotients
    plafonnés à 1) ;

  aux âges sans quotient détaillé, le quotient du plus grand âge
  détaillé de l'année est reconduit ;

- **solde migratoire, ajustement, fécondité** : à chaque âge, dernière
  valeur connue reconduite ; solde migratoire et ajustement nuls aux
  âges où ils ne sont pas détaillés et sur les années observées (pour
  les âges recalculés) ;

- **première année** : les âges sans effectif détaillé sont mis à zéro
  (générations les plus anciennes, considérées comme éteintes) ;

- les décès calculés sont positifs et ne peuvent excéder l'effectif
  présent, et la population ne peut devenir négative : une génération
  entièrement décédée reste à zéro.

Pour les années observées, le solde migratoire (non diffusé par l'Insee)
est calculé comme résidu de l'équation comptable. Les naissances
publiées, tous sexes confondus, sont réparties par sexe selon
`rapport_masculinite`.

Les écarts avec les données publiées par l'Insee qui en résultent sont
détaillés dans
[`vignette("ecarts-insee", package = "pilotretrtools")`](https://patrickaubert.github.io/pilotretrtools/articles/ecarts-insee.md).

## Examples

``` r
if (FALSE) { # \dontrun{
projpop <- prolonger_projpop(lire_projpop_insee(), horizon = 2180)
} # }
```
