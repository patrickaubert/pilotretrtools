# Lire un onglet d'un fichier de projections de l'Insee

Lit un onglet au format habituel des fichiers de projections de l'Insee
: une ligne d'en-tête contenant les années en colonnes, une première
colonne contenant l'âge.

## Usage

``` r
lire_onglet_insee(
  fichier,
  onglet,
  nom_valeur = onglet,
  groupes_ouverts = c("supprimer", "garder"),
  zeros_non_detailles = FALSE
)
```

## Arguments

- fichier:

  Chemin local ou adresse du fichier xlsx.

- onglet:

  Nom de l'onglet.

- nom_valeur:

  Nom de la colonne de valeurs en sortie.

- groupes_ouverts:

  `"supprimer"` (défaut) pour remplacer les valeurs des groupes ouverts
  et des âges non détaillés par `NA`, `"garder"` pour les conserver.

- zeros_non_detailles:

  Si `TRUE`, des zéros situés au-delà de la dernière valeur non nulle de
  l'année sont considérés comme des âges non détaillés. À réserver aux
  variables qui ne peuvent pas être nulles aux âges détaillés
  (populations, décès, quotients) : un solde migratoire ou un ajustement
  peut valoir zéro.

## Value

Un tibble avec les colonnes `annee`, `age3112`, `nom_valeur` et
`groupe_ouvert` (`TRUE` pour les lignes repérées comme groupe ouvert).

## Details

La ligne d'en-tête est repérée par son contenu (première ligne
comportant plusieurs années) et non par un numéro de ligne fixe, pour
résister aux changements de mise en page d'un millésime à l'autre. Seul
le premier bloc continu de lignes d'âge situé sous l'en-tête est lu :
les lignes de total, les notes de champ et de source et les éventuels
tableaux placés en dessous sont ignorés.

Si le libellé de la colonne d'âge mentionne le 1er janvier, l'âge est
converti en âge atteint dans l'année (`age3112 = age + 1`) ; sinon il
est supposé déjà exprimé ainsi.

**Groupes ouverts.** Pour chaque année, la dernière ligne renseignée est
considérée comme un groupe ouvert (somme des âges supérieurs) lorsque
son libellé se termine par « + » (par exemple « 105+ ») ou lorsque les
lignes d'âges plus élevés sont vides cette année-là (par exemple la
ligne « 100 » des années où le détail s'arrête à 100 ans). Avec
`zeros_non_detailles = TRUE`, des zéros au-delà de la dernière valeur
non nulle sont traités comme des cellules vides : c'est le cas des
populations, des décès et des quotients de mortalité, pour lesquels un
zéro aux grands âges signale un âge non détaillé. Par défaut, les
valeurs agrégées et les âges non détaillés sont remplacés par `NA`, pour
être recalculés ensuite (voir
[`prolonger_projpop()`](https://patrickaubert.github.io/pilotretrtools/reference/prolonger_projpop.md)).
