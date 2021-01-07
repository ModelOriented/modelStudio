context("Check ms_update_options() function")

source("test_objects.R")

if (requireNamespace("ranger", quietly=TRUE)) {
  ms <- modelStudio::modelStudio(explain_rf, apartments[1:2,],
                                 facet_dim = c(2,3), N = 5, B = 2, show_info = v)

  testthat::test_that("modelStudio class", {
    testthat::expect_is(ms, "modelStudio")
    testthat::expect_silent(modelStudio::modelStudio(explain_rf, apartments[1:2,],
                                                     facet_dim = c(2,3), N = 5, B = 2, show_info = v))
  })

  new_ms <- modelStudio::ms_update_options(ms, facet_dim = c(1,2), time = 0,
                                           margin_left = 100)

  testthat::test_that("ms_update_options", {
    testthat::expect_is(new_ms, "modelStudio")
    testthat::expect_equal(new_ms$x$options$time, 0)
    testthat::expect_equal(new_ms$x$options$margin_left, 100)
    testthat::expect_equal(new_ms$x$options$facet_dim, c(1,2))
  })

  testthat::test_that("ms_update_options run", {
    testthat::expect_silent(modelStudio::ms_update_options(ms, facet_dim = c(1,2), time = 0,
                                                           margin_left = 100, show_info = v))
  })
}
