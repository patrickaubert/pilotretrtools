test_that("interpoler_generations compl\u00e8te lin\u00e9airement entre g\u00e9n\u00e9rations", {
  x <- data.frame(sexe = "F", age3112 = c(60, 60, 61, 61),
                  generation = c(1940, 1944, 1940, 1944),
                  annee = c(2000, 2004, 2001, 2005),
                  tx = c(0.2, 0.6, 0.3, 0.7))
  y <- interpoler_generations(x, "tx")
  expect_equal(nrow(y), 10)
  expect_equal(y$tx[y$age3112 == 60], c(0.2, 0.3, 0.4, 0.5, 0.6))
  expect_equal(y$annee, y$generation + y$age3112)
  expect_equal(sum(y$interpole), 6)
})

test_that("lisser_par_age respecte les moyennes par tranche", {
  poids <- c(rep(100, 10), rep(80, 10))
  lisse <- lisser_par_age(c(0.3, 0.7), debuts_tranches = c(20, 30),
                          age_min = 20, age_max = 39, poids = poids)
  expect_length(lisse, 20)
  expect_equal(weighted.mean(lisse[1:10], poids[1:10]), 0.3)
  expect_equal(weighted.mean(lisse[11:20], poids[11:20]), 0.7)
  expect_true(all(diff(lisse) > 0))
})

test_that("lisser_par_age reproduit exactement un profil lin\u00e9aire", {
  ages <- 20:39
  lineaire <- 0.01 * (ages - 20) + 0.1
  moyennes <- tapply(lineaire, rep(1:4, each = 5), mean)
  lisse <- lisser_par_age(as.vector(moyennes), c(20, 25, 30, 35), 20, 39)
  expect_equal(lisse, lineaire)
})

test_that("lisser_par_age borne les taux", {
  lisse <- lisser_par_age(c(0.01, 0.5, 0.99, 0.999), c(15, 20, 25, 30), 15, 34)
  expect_true(all(lisse >= 0 & lisse <= 1))
  expect_error(lisser_par_age(c(0.1, 0.2), c(20, 30), 15, 39), "age_min")
})
