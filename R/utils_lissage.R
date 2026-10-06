#' Lisser par âge fin des taux connus par tranche d'âge
#'
#' Estime des taux par âge fin à partir de taux moyens par tranche d'âge
#' (par exemple les taux d'activité par tranche quinquennale de l'Insee). La
#' méthode, reprise de la fonction `prevalenceApprox()` du package
#' `healthexpectancies`, minimise la somme des carrés des différences
#' secondes des taux selon l'âge, sous la contrainte que la moyenne des taux
#' de chaque tranche, pondérée par les effectifs par âge (`poids`), soit
#' égale au taux observé de la tranche. Les taux obtenus sont ensuite
#' ramenés dans l'intervalle `bornes` : lorsque cette borne joue (taux très
#' proches de 0 ou de 1 aux âges extrêmes), la moyenne de la tranche
#' concernée n'est plus exactement respectée.
#'
#' @param taux Taux observés, un par tranche d'âge.
#' @param debuts_tranches Âge de début de chaque tranche (même longueur que
#'   `taux`, ordre croissant). La dernière tranche va jusqu'à `age_max`.
#' @param age_min,age_max Âges extrêmes en sortie ; `age_min` doit être égal
#'   au début de la première tranche.
#' @param poids Effectifs par âge, de `age_min` à `age_max` (par défaut
#'   uniformes).
#' @param bornes Valeurs minimale et maximale des taux en sortie (`NULL`
#'   pour ne pas borner).
#'
#' @return Un vecteur de taux, un par âge de `age_min` à `age_max`.
#' @export
#' @examples
#' lisser_par_age(c(0.2, 0.6, 0.9, 0.8), debuts_tranches = c(15, 20, 25, 30),
#'                age_min = 15, age_max = 34)
lisser_par_age <- function(taux, debuts_tranches, age_min, age_max,
                           poids = rep(1, age_max - age_min + 1),
                           bornes = c(0, 1)) {
  ages <- seq(age_min, age_max)
  n <- length(ages)
  k <- length(taux)
  if (length(debuts_tranches) != k) {
    stop("`taux` et `debuts_tranches` doivent avoir la m\u00eame longueur.",
         call. = FALSE)
  }
  if (length(poids) != n) {
    stop("`poids` doit compter une valeur par \u00e2ge de `age_min` \u00e0 ",
         "`age_max`.", call. = FALSE)
  }
  if (debuts_tranches[1] != age_min || is.unsorted(debuts_tranches)) {
    stop("`debuts_tranches` doit \u00eatre croissant et commencer \u00e0 ",
         "`age_min`.", call. = FALSE)
  }
  tranche <- findInterval(ages, debuts_tranches)

  # contraintes : moyenne pondérée de chaque tranche égale au taux observé
  contraintes <- matrix(0, k, n)
  for (j in seq_len(k)) {
    dans <- tranche == j
    contraintes[j, dans] <- poids[dans] / sum(poids[dans])
  }

  if (k == 1 || n < 3) {
    estime <- rep(taux, times = tabulate(tranche, k))
  } else {
    # minimisation de ||D2 x||^2 sous contraintes (conditions de
    # Kuhn-Tucker) : [2 D2'D2  C'] [x]   [0]
    #                [C       0 ] [l] = [p]
    d2 <- diff(diag(n), differences = 2)
    systeme <- rbind(cbind(2 * crossprod(d2), t(contraintes)),
                     cbind(contraintes, matrix(0, k, k)))
    estime <- qr.solve(systeme, c(rep(0, n), taux))[seq_len(n)]
  }
  if (!is.null(bornes)) {
    estime <- pmin(pmax(estime, bornes[1]), bornes[2])
  }
  estime
}
