context("Check ms_update_observations() function")

source("test_objects.R")

ms <- modelStudio::modelStudio(explain_rf, apartments[1:2,], N = 5, B = 2, show_info = v)

testthat::test_that("modelStudio class", {
  testthat::expect_is(ms, "modelStudio")
  testthat::expect_silent(ms)
})

new_ms1 <- modelStudio::ms_update_observations(ms, explain_rf, B = 2, show_info = v)
new_ms2 <- modelStudio::ms_update_observations(ms, explain_rf, B = 2, show_info = v,
                                               new_observation = apartments[100:101,],
                                               overwrite = FALSE)
new_ms3 <- modelStudio::ms_update_observations(ms, explain_rf, B = 2, show_info = v,
                                               new_observation = apartments[1:2,],
                                               overwrite = TRUE)

testthat::test_that("ms_update_observations", {
  testthat::expect_is(new_ms1, "modelStudio")
  testthat::expect_silent(modelStudio::ms_update_observations(ms, explain_rf, B = 2, show_info = v))
  testthat::expect_is(new_ms2, "modelStudio")
  testthat::expect_silent(modelStudio::ms_update_observations(ms, explain_rf, B = 2, show_info = v,
                                                              new_observation = apartments[100:101,],
                                                              overwrite = FALSE))
  testthat::expect_is(new_ms3, "modelStudio")
  testthat::expect_silent(modelStudio::ms_update_observations(ms, explain_rf, B = 2, show_info = v,
                                                              new_observation = apartments[1:2,],
                                                              overwrite = TRUE))
})
