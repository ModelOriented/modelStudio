context("Check ms_update_observations() function")

source("test_objects.R")

ms <- modelStudio::modelStudio(explain_rf, apartments[1:2,], N = 5, B = 2)

testthat::test_that("modelStudio class", {
  testthat::expect_is(ms, "modelStudio")
  testthat::expect_silent(ms)
})

new_ms1 <- modelStudio::ms_update_options(ms, explain_rf, B = 3)
new_ms2 <- modelStudio::ms_update_options(ms, explain_rf,
                                          new_observation = apartments[100:101,],
                                          B = 3, overwrite = FALSE)
new_ms3 <- modelStudio::ms_update_options(ms, explain_rf,
                                          new_observation = apartments[1:2,],
                                          B = 3, overwrite = TRUE)
new_ms4 <- modelStudio::ms_update_options(ms, explain_rf,
                                          new_observation = apartments[1,],
                                          new_observation_y = apartments$m2.price[1])

testthat::test_that("ms_update_observations", {
  testthat::expect_is(new_ms1, "modelStudio")
  testthat::expect_silent(new_ms1)
  testthat::expect_is(new_ms2, "modelStudio")
  testthat::expect_silent(new_ms2)
  testthat::expect_is(new_ms3, "modelStudio")
  testthat::expect_silent(new_ms3)
  testthat::expect_is(new_ms4, "modelStudio")
  testthat::expect_warning(new_ms4)
})
