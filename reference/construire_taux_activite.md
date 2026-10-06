# Construire les taux d'activité et d'emploi par âge fin

Assemble les taux d'emploi et d'activité par sexe et tranche d'âge
quinquennale, les lisse par âge fin
([`lisser_par_age()`](https://patrickaubert.github.io/pilotretrtools/reference/lisser_par_age.md))
pour chaque sexe et chaque année, puis en déduit les taux de chômage.

## Usage

``` r
construire_taux_activite(
  eec,
  ppa,
  cor,
  population = NULL,
  age_min = 15,
  age_max = 79,
  seuil_activite = 0.01,
  horizon = 2180
)
```

## Arguments

- eec:

  Taux d'emploi observés
  ([`lire_taux_emploi_eec()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_taux_emploi_eec.md)).

- ppa:

  Taux d'activité de la PPA
  ([`lire_taux_activite_ppa()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_taux_activite_ppa.md)).

- cor:

  Hypothèses du COR
  ([`lire_hypotheses_cor()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_hypotheses_cor.md)).

- population:

  Table de population servant de pondération pour le lissage (colonnes
  `sexe`, `annee`, `age3112`, `population3112`), par exemple
  `projpop_central`. `NULL` pour des poids uniformes.

- age_min, age_max:

  Âges extrêmes du lissage.

- seuil_activite:

  Taux d'activité en deçà duquel actifs et actifs occupés sont
  confondus.

- horizon:

  Dernière année en sortie.

## Value

Un tibble par `sexe`, `annee` et `age3112`, avec `tx_activite`,
`tx_emploi`, `tx_chomage`, et la source des taux d'emploi et d'activité
(`source_tx_emploi`, `source_tx_activite`). L'hypothèse de chômage du
COR est stockée dans l'attribut `hypothese_chomage`.

## Details

Sources selon les années :

- jusqu'à l'année précédant la première année du COR : emploi observé de
  l'enquête Emploi, activité des projections de population active (PPA)
  de l'Insee (années observées) ;

- de la première année du COR à la dernière année observée de l'enquête
  Emploi : emploi observé, activité déduite de l'emploi observé et du
  chômage du COR (taux d'activité = taux d'emploi / (1 - taux de
  chômage)) ;

- au-delà : emploi et activité du COR, selon l'hypothèse de chômage
  retenue dans `cor` ;

- après la dernière année du COR : taux reconduits à chaque âge.

Le raccordement entre l'emploi observé et l'emploi projeté par le COR
présente un saut de niveau (point ouvert).

Les taux d'emploi et d'activité sont lissés séparément, ce qui respecte
les moyennes par tranche des deux taux (sauf lorsque la borne à 0 joue,
aux âges extrêmes). Le lissage est fait de `age_min` à `age_max` ; la
tranche ouverte des âges élevés est lissée comme si elle s'arrêtait à
`age_max`, et les taux sont nuls en dehors de cet intervalle. Le taux
d'activité est porté au niveau du taux d'emploi s'il lui est inférieur.
Le taux de chômage est déduit des deux taux lissés. Aux âges où le taux
d'activité est inférieur à `seuil_activite` ou le taux d'emploi nul
(âges extrêmes, où les deux lissages indépendants donnent des rapports
sans signification), actifs et actifs occupés sont confondus : le taux
d'activité est pris égal au taux d'emploi et le chômage est nul. Lorsque
les sources ne découpent pas les âges élevés de la même façon (tranche «
70 ans et plus » de la PPA et du COR, tranches « 70-74 ans » et « 75 ans
et plus » de l'enquête Emploi), les tranches de l'enquête Emploi sont
regroupées, en moyenne pondérée par la population, avant le lissage,
pour que les profils par âge des deux taux soient comparables.
