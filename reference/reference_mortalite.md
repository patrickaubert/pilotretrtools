# Définir une mortalité de référence

Définit la mortalité de référence utilisée pour mesurer l'effet des
gains de mortalité
([`projeter_mortalite_reference()`](https://patrickaubert.github.io/pilotretrtools/reference/projeter_mortalite_reference.md),
[`decomposer_evolutions()`](https://patrickaubert.github.io/pilotretrtools/reference/decomposer_evolutions.md))
:

## Usage

``` r
mortalite_annee(annee = 1982)

mortalite_generation(generation)

mortalite_annee_age(age = 60)
```

## Arguments

- annee, generation, age:

  Année, génération ou âge de référence.

## Value

Un objet de classe `reference_mortalite`.

## Details

- `mortalite_annee(annee)` : quotients de mortalité par âge d'une année
  donnée, appliqués à toutes les générations pour les années
  postérieures à cette année (gains mesurés depuis l'année de référence)
  ;

- `mortalite_generation(generation)` : quotients de mortalité par âge
  d'une génération donnée, appliqués à toutes les générations (gains
  mesurés par rapport à la génération de référence, négatifs pour les
  générations plus anciennes dont la mortalité était plus forte) ;

- `mortalite_annee_age(age)` : pour chaque génération, quotients de
  l'année où elle atteint l'âge donné (gains mesurés depuis cette année,
  propre à chaque génération).

## Examples

``` r
mortalite_annee(1982)
#> <reference_mortalite> mortalité de l'année 1982 
mortalite_generation(1950)
#> <reference_mortalite> mortalité de la génération 1950 
```
