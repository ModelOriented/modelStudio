context("Test v3.1.1")

set.seed(1313)
v <- FALSE

model <- glm(survived ~., data = DALEX::titanic_imputed, family = "binomial")

explainer <- DALEX::explain(model,
                            data = DALEX::titanic_imputed,
                            y = DALEX::titanic_imputed$survived,
                            verbose = v)

testthat::test_that("max_features_fi, **_axis_title", {
  ms <- testthat::expect_silent(
    modelStudio::modelStudio(explainer,
                             B = 2,
                             max_features_fi = 2, 
                             max_features = 2,
                             options = ms_options(cp_axis_title = "pred",
                                                  bd_axis_title = "attribution"),
                             verbose = v)
  )
  testthat::expect_is(ms, "r2d3")
})

testthat::test_that("open_plots", {
  ms <- testthat::expect_silent(
    modelStudio::modelStudio(explainer,
                             B = 2,
                             open_plots = c("fi", "bd", "rv"),
                             verbose = v)
  )
  testthat::expect_is(ms, "r2d3")
  
  testthat::expect_error(
    modelStudio::modelStudio(explainer, 
                             B = 2,
                             open_plots = c("bd", "test"), 
                             verbose = v)
  )
  testthat::expect_error(
    modelStudio::modelStudio(explainer, 
                             B = 2,
                             facet_dim = c(2, 1),
                             open_plots = c("pd", "ad", "cp"), 
                             verbose = v)
  )
  testthat::expect_silent(
    modelStudio::modelStudio(explainer, 
                             B = 2,
                             facet_dim = c(2, 1),
                             open_plots = c("SV", "FI"), 
                             verbose = v)
  )
})