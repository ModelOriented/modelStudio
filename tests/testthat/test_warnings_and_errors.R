context("Check functions for warnings and errors")

source("test_objects.R")

testthat::test_that("new_observation as list", {
  testthat::expect_warning(
    modelStudio::modelStudio(explain_glm,
                             new_observation = as.list(titanic_test[1,-9]),
                             show_info = v)
  )
})

testthat::test_that("check_single_prediction error", {
  testthat::expect_error(
    modelStudio::modelStudio(explainer_xgb,
                             new_observation = model_matrix_train[1,],
                             show_info = v)
  )
})

testthat::test_that("deprecated modelStudioOptions", {
  testthat::expect_warning(
    modelStudio::modelStudioOptions()
  )
})

ms <- modelStudio::modelStudio(explain_rf, apartments[1:2,], N = 5, B = 2, show_info = v)
new_ms <- modelStudio::ms_update_options(ms, explain_rf, B = 2, show_info = v,
                                         new_observation = apartments[1,],
                                         new_observation_y = apartments$m2.price[1])

testthat::test_that("duplicated ids", {
  testthat::expect_is(new_ms, "modelStudio")
  testthat::expect_warning(
    modelStudio::ms_update_options(ms, explain_rf, B = 2, show_info = v,
                                   new_observation = apartments[1,],
                                   new_observation_y = apartments$m2.price[1])
  )
})
