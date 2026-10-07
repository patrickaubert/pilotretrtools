# Corriger les ruptures de champ géographique

Ramène tous les effectifs au champ géographique le plus récent (France
entière), en multipliant les effectifs des années antérieures aux
ruptures par la colonne `coef_champ` (voir
[`estimer_coef_champ()`](https://patrickaubert.github.io/pilotretrtools/reference/estimer_coef_champ.md)).
Sont corrigés la population au 1er janvier, les naissances, les décès et
l'ajustement. Pour les années antérieures à la dernière rupture, la
population au 31 décembre est prise égale à la population corrigée de la
même génération au 1er janvier suivant, et le solde migratoire est
recalculé comme résidu, ce qui supprime les sauts liés au changement de
champ. Les quotients de mortalité et les taux ne sont pas modifiés. La
colonne `champ`, si elle existe, est mise à jour : `"france"`, ou
`"france_hors_alsace_moselle"` (et `"france_hors_alsace_moselle_corse"`
en 1944) pour les années historiques où l'Alsace-Moselle est exclue,
cette rupture n'étant pas corrigée.

## Usage

``` r
corriger_champ(population)
```

## Arguments

- population:

  Table produite par
  [`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md).

## Value

La même table, effectifs corrigés et `coef_champ` égal à 1.

## Examples

``` r
if (FALSE) { # \dontrun{
projpop_central |> corriger_champ()
} # }
```
