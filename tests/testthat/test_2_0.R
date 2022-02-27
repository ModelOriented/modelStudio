context("Test v2.0.0")

set.seed(1313)
v <- FALSE

if (requireNamespace("ranger", quietly=TRUE)) {
  data_multiclass <- DALEX::HR[1:100,]
  model_multiclass <- ranger::ranger(status ~. ,
                                     data = data_multiclass,
                                     probability = TRUE)
  exp_multiclass <- DALEX::explain(model_multiclass,
                                   data = data_multiclass,
                                   y = data_multiclass$status,
                                   verbose = v)

  data_fifa <- DALEX::fifa[1:100, 1:10]
  model_fifa <- ranger::ranger(value_eur ~. ,
                               data_fifa)
  exp_fifa <- DALEX::explain(model_fifa,
                             data = data_fifa,
                             y = data_fifa$value_eur,
                             verbose = v)

  #:# errors #:#
  exp_nodata <- DALEX::explain(model_fifa, verbose = v)
  exp_noy <- DALEX::explain(model_fifa, data = data_fifa, verbose = v)

  testthat::expect_error(modelStudio::modelStudio(exp_multiclass))
  testthat::expect_error(modelStudio::modelStudio(exp_nodata))
  testthat::expect_error(modelStudio::modelStudio(exp_noy))

  #:# new functionalities #:#
  case1 <- testthat::expect_silent(
    modelStudio::modelStudio(exp_fifa, data_fifa[1,],
                             widget_id = "MS", telemetry = F,
                             N = 5, B = 2, show_info = v))

  testthat::expect_true(case1$elementId == 'MS')
  testthat::expect_true(!isTRUE(case1$x$options$telemetry))

  case2 <- testthat::expect_silent(
    modelStudio::modelStudio(exp_fifa, data_fifa[1:2,],
                             max_vars = 5, rounding_funtion = signif,
                             digits = 3,
                             N = 5, B = 2, show_info = v))
  testthat::expect_true(
    all(c("mse:", "rmse:", "r2:", "mad:") %in%
          strsplit(case2$x$options$measure_text, split=" ")[[1]]))

  #:# test NA #:#

  data_na <- DALEX::fifa[1:100, 2:10]
  model_na <- ranger::ranger(value_eur~., data_na)
  data_na[1:10,] <- NA

  pf <- function(model, data) {
    data <- impute(data)
    predict(model, data)$predictions
  }

  impute <- function(x, val = 0) {
    for (i in 1:dim(x)[1]) {
      for (j in 1:dim(x)[2]) {
        if (is.na(x[i, j])) x[i, j] <- val
      }
    }
    x
  }

  exp_na <- DALEX::explain(model_na,
                           data = data_na,
                           y = data_na$value_eur,
                           predict_function = pf,
                           verbose = v)

  case3 <- testthat::expect_silent(
    modelStudio::modelStudio(exp_na, data_na[11,],
                             N=5, B=2, show_info = v)
  )

  testthat::expect_true(!case3$x$options$is_target_binary)
}

#:# other #:#

model_bin <- glm(survived ~., data = DALEX::titanic_imputed, family = "binomial")
exp_bin <- DALEX::explain(model_bin,
                          data = DALEX::titanic_imputed,
                          y = DALEX::titanic_imputed$survived,
                          verbose=v)
case4 <- testthat::expect_silent(
  modelStudio::modelStudio(exp_bin, DALEX::titanic_imputed[3:4, ],
  loss_function = DALEX::loss_sum_of_squares,
  variable_splits_with_obs = FALSE, variable_splits_type='quantiles',
  N = 5, B = 2, show_info = v)
)

testthat::expect_true(case4$x$options$is_target_binary)