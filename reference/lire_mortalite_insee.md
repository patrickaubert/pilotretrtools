# Lire une hypothèse de mortalité prolongée de l'Insee

Lire une hypothèse de mortalité prolongée de l'Insee

## Usage

``` r
lire_mortalite_insee(url = url_source("projmort"), hyp_mortalite = "central")
```

## Arguments

- url:

  Adresse (ou chemin local) du fichier des quotients de mortalité.

- hyp_mortalite:

  Hypothèse à lire (onglets `paste0(hyp_mortalite, c("F", "H"))`).

## Value

Un tibble par `sexe`, `annee` et `age3112`, avec la colonne
`qx_prolonge` (probabilité de décès).
