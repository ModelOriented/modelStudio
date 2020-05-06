context("Check options parameter and ms_options() function")

source("test_objects.R")

op <- modelStudio::ms_options()

testthat::test_that("ms_options()", {
  testthat::expect_is(op, "list")
  testthat::expect_true(length(op) > 30)
})

new_options <- modelStudio::ms_options(
  scale_plot = FALSE,
  show_subtitle = TRUE,
  subtitle = "hello",
  margin_top = 51,
  margin_right = 21,
  margin_bottom = 71,
  margin_left = 106,
  margin_inner = 410,
  margin_small = 6,
  margin_big = 11,
  w = 421,
  h = 281,
  bar_width = 17,
  line_size = 3,
  point_size = 4,
  bar_color = "red",
  line_color = "orange",
  point_color = "red",
  positive_color = "yellow",
  negative_color = "black",
  default_color = "green",
  bd_title = "Break Down2",
  bd_subtitle = "Break Down3",
  bd_bar_width = 6,
  bd_positive_color = NULL,
  bd_negative_color = NULL,
  bd_default_color = NULL,
  sv_title = "Shapley Values2",
  sv_subtitle = "Shapley Values3",
  sv_bar_width = 6,
  sv_positive_color = NULL,
  sv_negative_color = NULL,
  sv_default_color = NULL,
  cp_title = "Ceteris Paribus2",
  cp_subtitle = "Ceteris Paribus3",
  cp_bar_width = NULL,
  cp_line_size = NULL,
  cp_point_size = NULL,
  cp_bar_color = "black",
  cp_line_color = "black",
  cp_point_color = "black",
  fi_title = "Feature Importance2",
  fi_subtitle = "Feature Importance3",
  fi_bar_width = 6,
  fi_bar_color = NULL,
  pd_title = "Partial Dependency2",
  pd_subtitle = "Partial Dependency3",
  pd_bar_width = 6,
  pd_line_size = 8,
  pd_bar_color = NULL,
  pd_line_color = NULL,
  ad_title = "Accumulated Dependency2",
  ad_subtitle = "Accumulated Dependency3",
  ad_bar_width = 6,
  ad_line_size = 8,
  ad_bar_color = NULL,
  ad_line_color = NULL,
  fd_title = "Feature Distribution2",
  fd_subtitle = "Feature Distribution3",
  fd_bar_width = 6,
  fd_bar_color = NULL
)

ms <- modelStudio::modelStudio(explain_rf, apartments[1:2,],
                  facet_dim = c(2,3), N = 5, B = 2, show_info = v,
                  options = new_options)

testthat::test_that("options parameter", {
  testthat::expect_is(ms, "r2d3")
})
