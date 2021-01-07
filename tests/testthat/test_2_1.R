context("Test v2.1.0")

set.seed(1313)
v <- FALSE

model <- glm(survived ~., data = DALEX::titanic_imputed, family = "binomial")

explainer <- DALEX::explain(model,
                            data = DALEX::titanic_imputed,
                            y = DALEX::titanic_imputed$survived,
                            label = "Titanic GLM",
                            verbose=v)

testthat::test_that("ms_options parameters", {
  ms1 <- testthat::expect_silent(
    modelStudio::modelStudio(explainer,
                             N = 10, B = 2,
                             options = modelStudio::ms_options(
                               ms_subtitle = "Nice model",
                               ms_margin_top = 80,
                               ms_margin_bottom = 80
                             ),
                             show_info = v)
    )
  testthat::expect_is(ms1, "r2d3")
})

testthat::test_that("N_fi, B_fi parameters", {
  ms2 <- testthat::expect_silent(
    modelStudio::modelStudio(explainer,
                             N_fi = 200, B_fi = 3,
                             show_info = v)
  )
  testthat::expect_is(ms2, "r2d3")
})

testthat::test_that("N = NULL", {
  ms3 <- testthat::expect_silent(
    modelStudio::modelStudio(explainer,
                             N_fi = NULL, B = 2,
                             show_info = v)
  )
  testthat::expect_is(ms3, "r2d3")
})
