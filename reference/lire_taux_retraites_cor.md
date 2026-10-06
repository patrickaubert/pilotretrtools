# Lire les taux de retraités projetés par le COR

Lit les taux de retraités par sexe, âge et année des données
complémentaires du rapport annuel du Conseil d'orientation des
retraites. L'onglet comporte plusieurs tableaux (ensemble, femmes,
hommes), chacun avec sa propre ligne d'années ; ils sont repérés par
leur contenu, et seuls les tableaux des femmes et des hommes sont
conservés. Dans chaque tableau, l'âge est lu dans la colonne située
juste à gauche de la première année, et le sexe dans les colonnes
précédentes.

## Usage

``` r
lire_taux_retraites_cor(url = url_source("txretr"), onglet = "Tx_retraités_an")
```

## Arguments

- url:

  Adresse (ou chemin local) du fichier.

- onglet:

  Nom de l'onglet.

## Value

Un tibble par `sexe`, `annee` et `age3112`, avec `tx_retraites` (part de
retraités au 31 décembre, entre 0 et 1).

## Examples

``` r
if (FALSE) { # \dontrun{
lire_taux_retraites_cor()
} # }
```
