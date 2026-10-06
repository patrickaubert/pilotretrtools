# Lire un scénario des projections de population de l'Insee

Lit le fichier d'un scénario des projections de population de l'Insee
(populations au 1er janvier, décès, quotients de mortalité, soldes
migratoires, ajustements, naissances et fécondité) et, si elle est
fournie, l'hypothèse de mortalité prolongée diffusée séparément par
l'Insee.

## Usage

``` r
lire_projpop_insee(
  url = url_source("projpop"),
  url_mortalite = url_source("projmort"),
  hyp_mortalite = "central"
)
```

## Arguments

- url:

  Adresse (ou chemin local) du fichier du scénario.

- url_mortalite:

  Adresse (ou chemin local) du fichier des quotients de mortalité
  prolongés, ou `NULL` pour ne pas l'utiliser.

- hyp_mortalite:

  Hypothèse de mortalité à lire dans ce fichier : les onglets lus sont
  `paste0(hyp_mortalite, c("F", "H"))`. L'hypothèse doit être cohérente
  avec le scénario lu.

## Value

Une liste de classe `projpop_insee` contenant :

- `population` : tibble par `sexe`, `annee` et `age3112`, avec les
  colonnes `population` (au 1er janvier), `deces`, `qx`,
  `solde_migratoire` et `ajustement` ;

- `fecondite` : tibble par `annee` et `age3112` (âge de la mère), avec
  les colonnes `naissances` et `fecondite` (naissances pour 10 000
  femmes) ;

- `sources` : les adresses lues.

## Details

Les quotients de mortalité sont convertis en probabilités (l'Insee les
diffuse pour 100 000). Les valeurs des groupes ouverts (« 105+ », ou «
100 » les années où le détail s'arrête à 100 ans) sont remplacées par
`NA` (voir
[`lire_onglet_insee()`](https://patrickaubert.github.io/pilotretrtools/reference/lire_onglet_insee.md))
; elles sont recalculées par
[`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md).
Lorsque le fichier de mortalité prolongée est fourni, ses quotients
remplacent ceux du fichier de scénario pour les années qu'il couvre.

## Examples

``` r
if (FALSE) { # \dontrun{
projpop <- lire_projpop_insee()
} # }
```
