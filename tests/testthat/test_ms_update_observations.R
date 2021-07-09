context("Check ms_update_observations() function")

source("test_objects.R")

if (requireNamespace("ranger", quietly=TRUE)) {
  ms <- modelStudio::modelStudio(explain_rf, apartments[1:2,], N = 5, B = 2, show_info = v)

  testthat::test_that("modelStudio class", {
    testthat::expect_is(ms, "modelStudio")
    testthat::expect_silent(ms)
  })

  testthat::test_that("ms_update_observations", {
    testthat::expect_silent(new_ms1 <- modelStudio::ms_update_observations(ms, explain_rf, B = 2,
                                                                           show_info = v))
    testthat::expect_is(new_ms1, "modelStudio")
    
    testthat::expect_silent(new_ms2 <- modelStudio::ms_update_observations(ms, explain_rf, B = 2,
                                                                           show_info = v,
                                                                new_observation = apartments[100:101,],
                                                                overwrite = FALSE))
    testthat::expect_is(new_ms2, "modelStudio")

    testthat::expect_silent(new_ms3 <- modelStudio::ms_update_observations(ms, explain_rf, B = 2,
                                                                           show_info = v,
                                                                new_observation = apartments[1:2,],
                                                                overwrite = TRUE))
    testthat::expect_is(new_ms3, "modelStudio")
    
    testthat::test_that("ms_merge_observations", {
      testthat::expect_silent(merged_ms <- ms_merge_observations(new_ms1, new_ms2, new_ms3))
      testthat::expect_is(merged_ms, "modelStudio")
    })
  })
}
