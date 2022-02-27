context("Check functions for warnings and errors")

source("test_objects.R")

testthat::test_that("new_observation as list", {
  testthat::expect_warning(
    ms <- modelStudio::modelStudio(explain_glm,
                             new_observation = as.list(titanic_test[1,-9]),
                             show_info = v, B = 3)
  )
})

if (requireNamespace("xgboost", quietly=TRUE)) {
  testthat::test_that("check_single_prediction error", {
    testthat::expect_warning(
      testthat::expect_error(
        ms <- modelStudio::modelStudio(explainer_xgb,
                                       new_observation = model_matrix_train[1,],
                                       show_info = v, B = 3)
      )
    )
  })
}

# deprecated since v1.1 (May 2020)
# removed in v2.2 (July 2021)
# testthat::test_that("deprecated modelStudioOptions", {
#   testthat::expect_warning(
#     ms <- modelStudio::modelStudioOptions()
#   )
# })
testthat::test_that("removed modelStudioOptions", {
  testthat::expect_error(
    ms <- modelStudio::modelStudioOptions()
  )
})


if (requireNamespace("ranger", quietly=TRUE)) {
  ms <- modelStudio::modelStudio(explain_rf, apartments[1:2,], N = 5, B = 2, show_info = v)
  new_ms <- modelStudio::ms_update_observations(ms, explain_rf, B = 2, show_info = v,
                                                new_observation = apartments[3,],
                                                new_observation_y = apartments$m2.price[3])

  testthat::test_that("duplicated ids", {
    testthat::expect_is(new_ms, "modelStudio")
    testthat::expect_warning(
      ms <- modelStudio::ms_update_observations(ms, explain_rf, B = 2, show_info = v,
                                                new_observation = apartments[1,],
                                                new_observation_y = apartments$m2.price[1])
    )
  })

}
