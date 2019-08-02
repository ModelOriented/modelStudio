context("Check modelStudio() function")

# preparation
library("dime")
library("DALEX")

titanic <- na.omit(titanic)
set.seed(1313)
titanic_small <- titanic[sample(1:nrow(titanic), 500),]

model_titanic_glm <- glm(survived == "yes" ~.,
                         data = titanic_small, family = "binomial")

explain_titanic_glm <- explain(model_titanic_glm,
                               data = titanic_small[,-9],
                               y = titanic_small$survived == "yes",
                               label = "glm")

ms1 <- modelStudio(explain_titanic_glm,
                   new_observation = titanic_small[1,-9])

ms2 <- modelStudio(model_titanic_glm,
                   max_features = 5,
                   data = titanic_small[,-9],
                   y = titanic_small$survived == "yes",
                   label = "xxx",
                   new_observation = titanic_small[1:2,-9],
                   N = 50, B = 10)

ms3 <- modelStudio(model_titanic_glm,
                   max_features = 5,
                   facet_dim = c(2,3),
                   N = 150,
                   B = 10,
                   time = 900,
                   data = titanic_small[,-9],
                   y = titanic_small$survived == "yes",
                   label = "xxx",
                   new_observation = titanic_small[1:10,-9])


model_numerical <- glm(survived == "yes" ~ age + fare + sibsp + parch,
                       data = titanic_small[, c(2,6,7,8,9)],
                       family = "binomial")

explain_model_numerical <- explain(model_numerical,
                                   data = titanic_small[, c(2,6,7,8)],
                                   y = titanic_small$survived == "yes")

ms4 <- modelStudio(explain_model_numerical,
                   new_observation = titanic_small[1:2, c(2,6,7,8)],
                   N = 50, B = 10)


model_not_numerical <- glm(survived == "yes" ~ gender + class + embarked + country,
                           data = titanic_small[, c(1,3,4,5,9)],
                           family = "binomial")

explain_model_not_numerical <- explain(model_not_numerical,
                                       data = titanic_small[, c(1,3,4,5)],
                                       y = titanic_small$survived == "yes")

ms5 <- modelStudio(explain_model_not_numerical,
                   new_observation = titanic_small[1:2, c(1,3,4,5)],
                   N = 50, B = 10)

model_small <- glm(survived == "yes" ~ age + gender,
                   data = titanic_small[, c(1,2,9)],
                   family = "binomial")

explain_model_small <- explain(model_small,
                               data = titanic_small[, c(1,2)],
                               y = titanic_small$survived == "yes")

ms6 <- modelStudio(explain_model_small,
                   new_observation = titanic_small[1:2, c(1,2)],
                   N = 50, B = 10)

# tests

test_that("Output format", {
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

test_that("Without description", {
  expect_is(ms6, "r2d3")
})
