# Télécharger un fichier source, avec mise en cache

Télécharge un fichier diffusé en ligne (Insee, COR...) et le conserve
dans un répertoire de cache, pour éviter de le retélécharger à chaque
appel. Un en-tête « User-Agent » est envoyé, certains sites (dont celui
du COR) refusant les requêtes qui n'en ont pas.

## Usage

``` r
telecharger_source(url, cache = TRUE, forcer = FALSE)
```

## Arguments

- url:

  Adresse du fichier. Un chemin local vers un fichier existant est aussi
  accepté : il est alors renvoyé tel quel.

- cache:

  Si `TRUE` (défaut), le fichier est conservé dans le répertoire de
  cache du package (voir
  [`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html)) ; sinon
  dans un répertoire temporaire.

- forcer:

  Si `TRUE`, retélécharge le fichier même s'il est en cache (utile
  lorsqu'un organisme republie un fichier à la même adresse).

## Value

Le chemin local du fichier.
