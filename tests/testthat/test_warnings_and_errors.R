context("Check modelStudio() function for warnings and errors")

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

