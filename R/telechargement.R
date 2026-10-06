#' Télécharger un fichier source, avec mise en cache
#'
#' Télécharge un fichier diffusé en ligne (Insee, COR...) et le conserve dans
#' un répertoire de cache, pour éviter de le retélécharger à chaque appel.
#' Un en-tête « User-Agent » est envoyé, certains sites (dont celui du COR)
#' refusant les requêtes qui n'en ont pas.
#'
#' @param url Adresse du fichier. Un chemin local vers un fichier existant est
#'   aussi accepté : il est alors renvoyé tel quel.
#' @param cache Si `TRUE` (défaut), le fichier est conservé dans le répertoire
#'   de cache du package (voir [tools::R_user_dir()]) ; sinon dans un
#'   répertoire temporaire.
#' @param forcer Si `TRUE`, retélécharge le fichier même s'il est en cache
#'   (utile lorsqu'un organisme republie un fichier à la même adresse).
#'
#' @return Le chemin local du fichier.
#' @export
telecharger_source <- function(url, cache = TRUE, forcer = FALSE) {
  if (file.exists(url)) {
    return(url)
  }
  repertoire <- if (cache) repertoire_cache() else tempdir()
  dir.create(repertoire, recursive = TRUE, showWarnings = FALSE)
  destination <- file.path(repertoire, nom_fichier_cache(url))
  if (forcer || !file.exists(destination)) {
    utils::download.file(
      url, destination, mode = "wb", quiet = TRUE, method = "libcurl",
      headers = c("User-Agent" = "Mozilla/5.0 (R package pilotretrtools)")
    )
  }
  destination
}

#' Vider le cache des fichiers téléchargés
#'
#' @return `TRUE` de manière invisible.
#' @export
vider_cache <- function() {
  unlink(repertoire_cache(), recursive = TRUE)
  invisible(TRUE)
}

repertoire_cache <- function() {
  tools::R_user_dir("pilotretrtools", which = "cache")
}

# Nom de fichier lisible et unique construit à partir de l'URL.
nom_fichier_cache <- function(url) {
  sans_requete <- sub("\\?.*$", "", url)
  extension <- tools::file_ext(sans_requete)
  nom <- gsub("[^A-Za-z0-9]+", "_", sub("^https?://", "", sans_requete))
  nom <- substr(nom, max(1, nchar(nom) - 150), nchar(nom))
  if (nzchar(extension)) nom <- paste0(nom, ".", extension)
  nom
}
