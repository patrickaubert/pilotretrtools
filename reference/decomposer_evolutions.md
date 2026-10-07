# Décomposer les évolutions du nombre de retraités et du rapport démographique

Décompose, année par année, la variation du nombre de retraités, du
nombre d'actifs occupés et du rapport démographique (actifs occupés /
retraités) en effets des taux (de retraités, d'emploi), de la mortalité
et de la taille des générations.

## Usage

``` r
decomposer_evolutions(
  population,
  reference = mortalite_annee(1982),
  age_debut_mortalite = 60,
  age_seuil_emploi = 55
)
```

## Arguments

- population:

  Table de population comportant les taux de retraités et d'emploi
  ([`ajouter_retraites()`](https://patrickaubert.github.io/pilotretrtools/reference/ajouter_retraites.md),
  [`ajouter_actifs()`](https://patrickaubert.github.io/pilotretrtools/reference/ajouter_actifs.md)),
  corrigée des ruptures de champ
  ([`corriger_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/corriger_champ.md)).

- reference:

  Mortalité de référence (voir
  [reference_mortalite](https://patrickaubert.github.io/pilotretrtools/reference/reference_mortalite.md)).

- age_debut_mortalite:

  Âge à partir duquel les gains de mortalité sont mesurés.

- age_seuil_emploi:

  Âge séparant les effets des taux d'emploi « avant » et « après » cet
  âge.

## Value

Un tibble par `annee`, avec pour les retraités (`nb_retraites`) et les
actifs occupés (`nb_actifs_occupes`) : le niveau, sa variation (préfixe
`d_`), les effets (suffixes `_taux`, `_taux_avant`, `_taux_apres`,
`_mortalite`, `_taille`) et le niveau avec la mortalité de référence
(suffixe `_ref`) ; pour le rapport démographique (`rapport_demo`) : le
niveau, sa variation et les contributions
(`d_rapport_demo_taux_retraites`, `_taux_emploi_avant`,
`_taux_emploi_apres`, `_mortalite`, `_taille`).

## Details

Pour un effectif \\N(t) = \sum_a P(t,a) \tau(t,a)\\ (population au 31
décembre par sexe et âge, multipliée par un taux), la variation annuelle
se décompose exactement, à chaque âge, en :

- effet des taux : \\\Delta\tau(a)\\ multipliée par la moyenne de
  \\P(a)\\ sur les deux années ;

- effet de la mortalité : variation du gain de population dû aux gains
  de mortalité par rapport à la référence
  ([`projeter_mortalite_reference()`](https://patrickaubert.github.io/pilotretrtools/reference/projeter_mortalite_reference.md)),
  multipliée par la moyenne de \\\tau(a)\\ ;

- effet de la taille des générations : le reste de la variation de la
  population, multiplié par la moyenne de \\\tau(a)\\. Il recouvre tous
  les déterminants de la taille des générations à l'âge `age_debut`
  (taille à la naissance, migrations, mortalité avant cet âge), ainsi
  que les migrations après cet âge.

Pondérer par des moyennes des deux années rend la décomposition
indépendante de l'ordre dans lequel les effets sont considérés. Avec une
mortalité de référence fixe, les effets de la mortalité s'additionnent
dans le temps : leur somme sur une période est égale à la variation, sur
cette période, du surplus de retraités dû aux gains de mortalité
(exactement lorsque les taux ne varient pas aux âges où s'appliquent les
gains, approximativement sinon, l'interaction entre gains de mortalité
et évolution des taux étant comptée dans l'effet des taux).

L'effet de la mortalité dépend de la référence retenue : avec une année
de référence, il cumule les gains intervenus depuis cette année et croît
mécaniquement à mesure qu'on s'en éloigne. Il inclut l'application des
gains cumulés à des générations de tailles différentes ; symétriquement,
l'effet de la taille des générations est mesuré avec la mortalité de
référence.

La variation du rapport démographique \\R = E / N\\ est décomposée de
façon exacte par la méthode des moyennes logarithmiques (LMDI) : la
contribution d'un effet est \\L(R) (\Delta E_k / L(E) - \Delta N_k /
L(N))\\, où \\L\\ est la moyenne logarithmique des valeurs des deux
années et \\\Delta E_k\\, \\\Delta N_k\\ les effets sur les actifs
occupés et les retraités.
