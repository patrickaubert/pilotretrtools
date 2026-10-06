# Conventions et organisation du package

``` r

library(pilotretrtools)
```

Cette vignette décrit les conventions partagées par toutes les fonctions
du package. Elle est la porte d’entrée pour quiconque souhaite
réutiliser ou enrichir les outils.

## La grille génération × âge × année

Toutes les tables « longues » du package sont indexées par l’année
civile et l’âge, et éventuellement par le sexe. Les âges suivent une
convention unique :

| Colonne      | Définition                                            |
|--------------|-------------------------------------------------------|
| `annee`      | année civile                                          |
| `age3112`    | âge atteint au cours de l’année (âge révolu au 31/12) |
| `age0101`    | âge révolu au 1er janvier, égal à `age3112 - 1`       |
| `generation` | année de naissance, égale à `annee - age3112`         |
| `sexe`       | `"F"` ou `"H"`                                        |

Les stocks sont mesurés soit au 1er janvier (`population`), soit au 31
décembre (`population3112`). Les flux de l’année (décès, solde
migratoire) sont rattachés à la ligne de l’année et de l’âge atteint.

La fonction
[`valider_grille()`](https://patrickaubert.github.io/pilotretrtools/reference/valider_grille.md)
vérifie ces conventions ; tout nouveau module devrait l’appeler sur ses
entrées et ses sorties.

``` r

grille <- data.frame(sexe = "F", annee = 2030, age3112 = 60:62)
grille$generation <- grille$annee - grille$age3112
valider_grille(grille)
```

## Familles de fonctions

Les fonctions sont nommées par famille, ce qui permet de les retrouver
par autocomplétion :

- `lire_*()` : lecture des fichiers diffusés (Insee, COR, barèmes IPP) ;
- `prolonger_*()` : prolongation des projections au-delà de leur horizon
  ;
- `construire_*()` : assemblage des tables d’hypothèses ;
- `calculer_*()` et `decomposer_*()` : calculs du modèle ;
- `indic_*()` : indicateurs par génération ou par année ;
- `donnees_graph_*()` et `graph_*()` : données d’un graphique, puis son
  dessin, pour pouvoir reprendre les données avec une autre charte ;
- `app_*()` : applications Shiny.

## Sources de données et actualisation

Les adresses des fichiers sources sont centralisées dans un registre :

``` r

sources_donnees()[c("objet", "organisme", "millesime", "scenario")]
#> # A tibble: 7 × 4
#>   objet       organisme millesime scenario
#>   <chr>       <chr>         <int> <chr>   
#> 1 projpop     Insee          2026 central 
#> 2 projmort    Insee          2026 tous    
#> 3 txretr      COR            2025 central 
#> 4 txact       Insee          2022 central 
#> 5 txempl_obs  Insee          2026 tous    
#> 6 txempl_proj COR            2025 central 
#> 7 eco         COR            2025 tous
```

Les fonctions de lecture prennent l’adresse du fichier en argument ;
leur valeur par défaut est lue dans ce registre. Pour utiliser un autre
scénario des projections de l’Insee, il suffit de passer l’adresse du
fichier correspondant :

``` r

projpop_haut <- lire_projpop_insee(
  url = "https://www.insee.fr/.../XX_scenario.xlsx",
  hyp_mortalite = "central"
)
```

Les fichiers téléchargés sont conservés en cache
([`telecharger_source()`](https://patrickaubert.github.io/pilotretrtools/reference/telecharger_source.md),
[`vider_cache()`](https://patrickaubert.github.io/pilotretrtools/reference/vider_cache.md)).

Lorsqu’un organisme publie une version actualisée :

1.  ajouter une ligne au registre `inst/extdata/sources.csv` (nouveau
    millésime) ;
2.  relancer le script correspondant dans `data-raw/` pour reconstruire
    les tables embarquées ;
3.  vérifier les tests (`devtools::test()`) et noter le changement dans
    `NEWS.md`.

## Prolongation des projections de population

[`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md)
prolonge un scénario de l’Insee jusqu’à l’horizon voulu par la méthode
des composantes. Les hypothèses de prolongation (reconduction à chaque
âge de la dernière valeur connue des quotients de mortalité, soldes
migratoires, ajustements et taux de fécondité ; traitement du groupe
ouvert des âges élevés) sont détaillées dans l’aide de la fonction. Les
valeurs calculées par prolongation sont repérées par la colonne
`prolonge`.
