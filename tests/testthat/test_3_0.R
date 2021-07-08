context("Test v3.0.0")

set.seed(1313)
v <- FALSE

model <- glm(survived ~., data = DALEX::titanic_imputed, family = "binomial")

explainer <- DALEX::explain(model,
                            data = DALEX::titanic_imputed,
                            y = DALEX::titanic_imputed$survived,
                            verbose = v)

testthat::test_that("N_sv, verbose parameters", {
  ms1 <- testthat::expect_silent(
    modelStudio::modelStudio(explainer,
                             N_sv = 200, B = 2,
                             verbose = v)
  )
  testthat::expect_is(ms1, "r2d3")
})
