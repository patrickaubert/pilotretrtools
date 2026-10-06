# Estimer les coefficients de correction des ruptures de champ géographique

Les séries historiques de l'Insee changent de champ géographique :
France métropolitaine jusqu'en 1994, France hors Mayotte de 1995 à 2013,
France entière à partir de 2014. Ces ruptures sont réelles, mais elles
introduisent des sauts dans les séries longues. Cette fonction estime,
pour chaque rupture, un coefficient par génération et par sexe qui
ramène les effectifs de l'ancien champ au nouveau.

## Usage

``` r
estimer_coef_champ(population, ruptures = c(1995, 2014), annees_voisines = 2)
```

## Arguments

- population:

  Table produite par
  [`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md).

- ruptures:

  Années de rupture (première année dans le nouveau champ).

- annees_voisines:

  Nombre d'années de part et d'autre de la rupture utilisées pour
  neutraliser les migrations.

## Value

Un tibble par `rupture`, `sexe` et `generation`, avec le rapport de
l'année de rupture (`ratio_rupture`), la moyenne des rapports voisins
(`ratio_voisins`), le coefficient (`coef`) et `estime` (`FALSE` lorsque
le coefficient est repris d'une génération voisine).

## Details

Pour une génération et un sexe, on calcule chaque année le rapport
\$\$R(t) = \frac{P(t+1)}{P(t) + N(t) - D(t)}\$\$ entre la population au
1er janvier suivant et la population de l'année (augmentée des
naissances \\N\\ pour l'âge 0) diminuée des décès. En dehors des
ruptures, ce rapport ne reflète que les migrations ; l'année de rupture,
il reflète aussi le changement de champ. Le coefficient est le rapport
de l'année de rupture divisé par la moyenne des rapports des
`annees_voisines` années de part et d'autre, ce qui neutralise la
migration « normale ».

Le coefficient n'est pas estimé lorsque l'effectif concerné a été
reconstitué par
[`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md)
(grands âges), lorsque le dénominateur est nul, ou pour les générations
qui ont quitté la table (au-delà de l'âge maximal) avant la rupture : il
est alors repris de la génération la plus proche pour laquelle il l'est.
Les générations nées à partir de l'année de rupture n'ont pas de
coefficient (elles sont nées dans le nouveau champ).

Hypothèse sous-jacente : la part de l'ancien champ dans chaque
génération est supposée constante avant la rupture, ce qui ignore les
migrations passées entre territoires (par exemple entre les DROM et la
métropole). Les coefficients sont bornés à 1.

Cette méthode indirecte est imprécise lorsque l'effet de la rupture est
du même ordre que les migrations annuelles (cas de Mayotte en 2014).
Elle ne sert que de repli : lorsque l'Insee publie les deux champs pour
l'année de rupture,
[`calculer_coef_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/calculer_coef_champ.md)
est préférable.
