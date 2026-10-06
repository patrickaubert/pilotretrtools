# pilotretrtools : outils pour illustrer le pilotage d'un régime par annuités

Le package est organisé en familles de fonctions, repérables par leur
préfixe :

## Details

- `lire_*()` : lecture des fichiers diffusés (Insee, COR, barèmes IPP) ;

- `prolonger_*()` : prolongation des projections au-delà de leur horizon
  ;

- `construire_*()` : assemblage des tables d'hypothèses ;

- `calculer_*()` et `decomposer_*()` : calculs du modèle ;

- `indic_*()` : indicateurs par génération ou par année ;

- `graph_*()` et `donnees_graph_*()` : graphiques et données
  sous-jacentes ;

- `app_*()` : applications Shiny.

Les conventions communes (grille génération x âge x année, définition
des âges) sont décrites dans
[`vignette("conventions", package = "pilotretrtools")`](https://patrickaubert.github.io/pilotretrtools/articles/conventions.md)
et vérifiées par
[`valider_grille()`](https://patrickaubert.github.io/pilotretrtools/reference/valider_grille.md).

## See also

Useful links:

- <https://github.com/patrickaubert/pilotretrtools>

- Report bugs at
  <https://github.com/patrickaubert/pilotretrtools/issues>

## Author

**Maintainer**: Patrick Aubert <patrick.aubert@ipp.eu>
