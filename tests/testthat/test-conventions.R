test_that("valider_grille d\u00e9tecte les incoh\u00e9rences", {
  ok <- data.frame(sexe = "F", annee = 2030, age3112 = 60:61,
                   generation = 1970:1969, age0101 = 59:60)
  expect_silent(valider_grille(ok))
  expect_error(valider_grille(transform(ok, generation = 1970)), "generation")
  expect_error(valider_grille(transform(ok, age0101 = 60)), "age0101")
  expect_error(valider_grille(transform(ok, sexe = "X")), "sexe")
  expect_error(valider_grille(rbind(ok, ok)), "Doublons")
  expect_error(valider_grille(ok[c("annee", "sexe")]), "age3112")
})
