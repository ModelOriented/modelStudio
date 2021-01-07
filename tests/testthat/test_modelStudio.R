context("Check modelStudio() function")

source("test_objects.R")

N = 10
B = 2

ms1 <- testthat::expect_silent(modelStudio::modelStudio(explain_glm,
                                                        new_observation = titanic_test[1,-9],
                                                        show_info = v))

ms4 <- testthat::expect_silent(modelStudio::modelStudio(explain_glm_numerical,
                                                        new_observation = titanic_test[1:2, c(2,6,7,8)],
                                                        N = N, B = B,
                                                        show_info = v))

ms5 <- testthat::expect_silent(modelStudio::modelStudio(explain_glm_not_numerical,
                                                        new_observation = titanic_test[1:2, c(1,3,4,5)],
                                                        N = N, B = B,
                                                        show_info = v))

ms6 <- testthat::expect_silent(modelStudio::modelStudio(explain_model_small,
                                                        new_observation = titanic_test[1:2, c(1,2)],
                                                        N = N, B = B,
                                                        show_info = v))

ms_readme <-  testthat::expect_silent(modelStudio::modelStudio(explain_titanic_glm,
                                                               new_observations,
                                                               facet_dim = c(2,2),
                                                               N = N, B = B, time = 0,
                                                               show_info = v))

ms_rf_apartments <- testthat::expect_silent(modelStudio::modelStudio(explain_rf,
                                                                     new_observation = apartments[1:2,-1],
                                                                     N = N, B = B, facet_dim = c(3,3),
                                                                     time = 50, max_features = 4,
                                                                     show_info = v))

both_without_target <- testthat::expect_silent(modelStudio::modelStudio(explain_both_without_target,
                                                                        new_observation = nx,
                                                                        N = N,
                                                                        B = B,
                                                                        show_info = v))

both_full <- testthat::expect_silent(modelStudio::modelStudio(explain_both_full,
                                                              new_observation = nz,
                                                              N = N,
                                                              B = B,
                                                              show_info = v))

obs_without_target_data_full <- testthat::expect_silent(modelStudio::modelStudio(explain_obs_without_target_data_full,
                                                                                 new_observation = nx,
                                                                                 N = N,
                                                                                 B = B,
                                                                                 show_info = v))

obs_full_data_without_target <- testthat::expect_silent(modelStudio::modelStudio(explain_obs_full_data_without_target,
                                                                                 new_observation = nz,
                                                                                 N = N,
                                                                                 B = B,
                                                                                 show_info = v))

ms_big <- testthat::expect_silent(modelStudio::modelStudio(explain_artifficial,
                                                           new_observation = artifficial[1:2,],
                                                           N = N, B = B,
                                                           facet_dim = c(3,3),
                                                           show_info = v))

ms_parallel <- modelStudio::modelStudio(explain_glm, new_observation = titanic_test[1:2,-9],
                                        N = N, B = B, parallel = TRUE,
                                        show_info = v)

ms_parallel_rf <- modelStudio::modelStudio(explain_rf, new_observation = apartments[1:5,-1],
                                           N = N, B = B, parallel = TRUE,
                                           show_info = v)

# tests

testthat::test_that("explainer test", {
  testthat::expect_is(ms1, "r2d3")
})

testthat::test_that("only_numerical", {
  testthat::expect_is(ms4, "r2d3")
})

testthat::test_that("only_not_numerical", {
  testthat::expect_is(ms5, "r2d3")
})

testthat::test_that("description test, 2 features", {
  testthat::expect_is(ms6, "r2d3")
})

testthat::test_that("README DEMO", {
  testthat::expect_is(ms_readme, "r2d3")
})

testthat::test_that("ranger apartments", {
  testthat::expect_is(ms_rf_apartments, "r2d3")
})

testthat::test_that("test various possibilities of data and new obs", {
  testthat::expect_is(both_full, "r2d3")
  testthat::expect_is(both_without_target, "r2d3")
  testthat::expect_is(obs_without_target_data_full, "r2d3")
  testthat::expect_is(obs_full_data_without_target, "r2d3")
})

testthat::test_that("more than 10 features", {
  testthat::expect_is(ms_big, "r2d3")
})

testthat::test_that("parallel", {
  testthat::expect_is(ms_parallel, "r2d3")
})

if (requireNamespace("ranger", quietly=TRUE)) {
  testthat::test_that("parallel rf", {
    testthat::expect_is(ms_parallel_rf, "r2d3")
  })
}

testthat::test_that("show_info_and_new_observation_y", {
  testthat::expect_is(modelStudio::modelStudio(explain_glm,
                                               titanic_test[1:2,-9],
                                               titanic_test[1:2, 9],
                                               N = N, B = B, show_info = TRUE), "r2d3")
})

testthat::test_that("eda = FALSE", {
  testthat::expect_is(modelStudio::modelStudio(explain_glm, eda = FALSE,
                                               N = N, B = B, show_info = v), "r2d3")
})

if (requireNamespace("xgboost", quietly=TRUE)) {
  testthat::test_that("xgboost matrix", {
    testthat::expect_is(modelStudio::modelStudio(explainer_xgb,
                                                 N = N, B = B, show_info = v), "r2d3")
  })
}
