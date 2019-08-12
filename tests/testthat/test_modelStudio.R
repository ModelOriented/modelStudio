context("Check modelStudio() function")
source("test_objects.R")

ms1 <- modelStudio(explain_glm,
                   new_observation = titanic_test[1,-9])

ms2 <- modelStudio(model_glm,
                   max_features = 5,
                   data = titanic_test[,-9],
                   y = titanic_test$survived == "yes",
                   label = NULL,
                   new_observation = titanic_test[1:2,-9],
                   N = 50, B = 10)

ms3 <- modelStudio(model_glm,
                   max_features = 5,
                   facet_dim = c(2,3),
                   N = 150,
                   B = 10,
                   time = 900,
                   data = titanic_test[,-9],
                   y = titanic_test$survived == "yes",
                   label = "xxx",
                   new_observation = titanic_test[1:10,-9])

ms4 <- modelStudio(explain_glm_numerical,
                   new_observation = titanic_test[1:2, c(2,6,7,8)],
                   N = 50, B = 10)

ms5 <- modelStudio(explain_glm_not_numerical,
                   new_observation = titanic_test[1:2, c(1,3,4,5)],
                   N = 50, B = 10)

ms6 <- modelStudio(explain_model_small,
                   new_observation = titanic_test[1:2, c(1,2)],
                   N = 50, B = 10)

ms_readme <-  modelStudio(explain_titanic_glm,
                          new_observations,
                          facet_dim = c(2,2), N = 200, B = 20, time = 0)

ms_rf_apartments <- modelStudio(explain_rf,
                                new_observation = apartments[1:2,-1],
                                N = 50, B = 10, facet_dim = c(3,3),
                                time = 50, max_features = 4)

both_without_target <- modelStudio(model_titanic_glm,
                                   new_observation = nx,
                                   N = 10,
                                   B = 2,
                                   data = x,
                                   y = y)

both_full <- modelStudio(model_titanic_glm,
                         new_observation = nz,
                         N = 10,
                         B = 2,
                         data = z,
                         y = y)

obs_without_target_data_full <- modelStudio(model_titanic_glm,
                                            new_observation = nx,
                                            N = 10,
                                            B = 2,
                                            data = z,
                                            y = y)

obs_full_data_without_target <- modelStudio(model_titanic_glm,
                                            new_observation = nz,
                                            N = 10,
                                            B = 2,
                                            data = x,
                                            y = y)

ms_big <- modelStudio(explain_artifficial,
                      new_observation = artifficial[1:2,], N = 5, B = 2,
                      facet_dim = c(3,3))

ms_parallel <- modelStudio(explain_glm, new_observation = titanic_test[1:2,-9],
                           N = 5, B = 2, parallel = TRUE)

# tests

test_that("explainer/model test", {
  expect_is(ms1, "r2d3")
  expect_is(ms2, "r2d3")
  expect_is(ms3, "r2d3")
})

test_that("only_numerical", {
  expect_is(ms4, "r2d3")
})

test_that("only_not_numerical", {
  expect_is(ms5, "r2d3")
})

test_that("description test, 2 features", {
  expect_is(ms6, "r2d3")
})

test_that("README DEMO", {
  expect_is(ms_readme, "r2d3")
})

test_that("randomForest apartments", {
  expect_is(ms_rf_apartments, "r2d3")
})

test_that("test various possibilities of data and new obs", {
  expect_is(both_full, "r2d3")
  expect_is(both_without_target, "r2d3")
  expect_is(obs_without_target_data_full, "r2d3")
  expect_is(obs_full_data_without_target, "r2d3")
})

test_that("more than 10 features", {
  expect_is(ms_big, "r2d3")
})

test_that("parallel", {
  expect_is(ms_parallel, "r2d3")
})
