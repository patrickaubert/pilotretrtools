# Lire un onglet d'un fichier de projections de l'Insee

Lit un onglet au format habituel des fichiers de projections de l'Insee
: une ligne d'en-tête contenant les années en colonnes, une première
colonne contenant l'âge (avec un éventuel groupe ouvert du type « 105+
»).

## Usage

``` r
lire_onglet_insee(fichier, onglet, nom_valeur = onglet)
```

## Arguments

- fichier:

  Chemin local ou adresse du fichier xlsx.

- onglet:

  Nom de l'onglet.

- nom_valeur:

  Nom de la colonne de valeurs en sortie.

## Value

Un tibble avec les colonnes `annee`, `age3112` et `nom_valeur`.

## Details

La ligne d'en-tête est repérée par son contenu (première ligne
comportant plusieurs années) et non par un numéro de ligne fixe, pour
résister aux changements de mise en page d'un millésime à l'autre. Si le
libellé de la colonne d'âge mentionne le 1er janvier, l'âge est converti
en âge atteint dans l'année (`age3112 = age + 1`) ; sinon il est supposé
déjà exprimé ainsi.
