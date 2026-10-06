# Vérifier qu'une table respecte la grille commune du package

Toutes les tables « longues » du package partagent les mêmes clés et les
mêmes conventions d'âge :

## Usage

``` r
valider_grille(x, cles = NULL)
```

## Arguments

- x:

  Une table (data.frame ou tibble).

- cles:

  Colonnes identifiant une ligne. Par défaut, `sexe` (si présent),
  `annee` et `age3112`.

## Value

`x`, de manière invisible. Une erreur est levée si une convention n'est
pas respectée.

## Details

- `annee` : année civile ;

- `age3112` : âge atteint au cours de l'année (âge révolu au 31
  décembre) ;

- `age0101` : âge révolu au 1er janvier, égal à `age3112 - 1` ;

- `generation` : année de naissance, égale à `annee - age3112` ;

- `sexe` (optionnel) : `"F"` ou `"H"`.

La fonction vérifie la présence des clés, la cohérence des colonnes
dérivées lorsqu'elles sont présentes et l'absence de doublons.

## Examples

``` r
grille <- data.frame(sexe = "F", annee = 2030, age3112 = 60:62)
grille$generation <- grille$annee - grille$age3112
valider_grille(grille)
```
