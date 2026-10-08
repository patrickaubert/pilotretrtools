# Projeter la population avec une mortalité de référence

Calcule, pour chaque génération, la population qu'elle aurait eue si sa
mortalité était restée celle de la référence (voir
[reference_mortalite](https://patrickaubert.github.io/pilotretrtools/reference/reference_mortalite.md))
à partir de l'âge `age_debut`, toutes choses égales par ailleurs (mêmes
soldes migratoires et ajustements).

## Usage

``` r
projeter_mortalite_reference(
  population,
  reference = mortalite_annee(1982),
  age_debut = 60
)
```

## Arguments

- population:

  Table de population (par exemple
  [`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md)),
  de préférence corrigée des ruptures de champ
  ([`corriger_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/corriger_champ.md)).

- reference:

  Mortalité de référence (voir
  [reference_mortalite](https://patrickaubert.github.io/pilotretrtools/reference/reference_mortalite.md)).

- age_debut:

  Âge (atteint dans l'année) à partir duquel la mortalité de référence
  s'applique.

## Value

La table de population avec les colonnes `gain_mortalite` (population
supplémentaire au 31 décembre due aux gains de mortalité par rapport à
la référence) et `population3112_ref` (population au 31 décembre avec la
mortalité de référence : `population3112 - gain_mortalite`). La
référence est stockée dans l'attribut `reference_mortalite`.

## Details

Le gain de population dû aux gains de mortalité est mesuré comme l'écart
entre deux projections menées de la même façon, à partir du même point
de départ : l'une avec les quotients de mortalité effectifs, l'autre
avec ceux de la référence. Comparer directement la population observée à
la projection de référence mêlerait aux gains de mortalité l'écart entre
les décès observés et ceux que donne la formule à partir des quotients.

La projection de référence part, pour chaque génération, de la première
cellule où la mortalité de référence s'applique (âge `age_debut`, ou
première année postérieure à l'année de référence, ou première année où
les quotients de mortalité sont connus), avec la population effective au
1er janvier. Les années de la série historique, sans quotients de
mortalité, ne sont donc pas couvertes : le gain y est nul. Lorsque
l'année des quotients de référence sort de la période couverte par les
quotients (par exemple l'année des 60 ans des générations nées avant
1902), elle est ramenée à la première ou à la dernière année disponible,
avec un message.
