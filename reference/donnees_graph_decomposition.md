# Données d'un graphique de décomposition

Met en forme, pour un graphique, les effets calculés par
[`decomposer_evolutions()`](https://patrickaubert.github.io/pilotretrtools/reference/decomposer_evolutions.md)
pour un indicateur : une ligne par année et par effet, avec un libellé
lisible et un ordre d'affichage. Les données peuvent ensuite être
représentées avec n'importe quel outil graphique (voir
[`vignette("decomposition")`](https://patrickaubert.github.io/pilotretrtools/articles/decomposition.md)
pour un exemple avec `ggplot2`).

## Usage

``` r
donnees_graph_decomposition(
  decomposition,
  indicateur = c("retraites", "actifs_occupes", "rapport_demo"),
  annees = NULL
)
```

## Arguments

- decomposition:

  Table produite par
  [`decomposer_evolutions()`](https://patrickaubert.github.io/pilotretrtools/reference/decomposer_evolutions.md).

- indicateur:

  `"retraites"`, `"actifs_occupes"` ou `"rapport_demo"`.

- annees:

  Années à retenir (par défaut toutes celles où les effets sont
  calculés).

## Value

Un tibble avec `annee`, `effet` (facteur ordonné, libellés en clair),
`valeur` (contribution à la variation annuelle, en nombre de personnes
ou en points de rapport démographique) et `variation` (variation totale
de l'année).

## Examples

``` r
if (FALSE) { # \dontrun{
donnees_graph_decomposition(decomposer_evolutions(construire_base()),
                            "actifs_occupes", annees = 1980:2070)
} # }
```
