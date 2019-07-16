context("Check modelStudio() function")

# preparation
library("dime")
library("DALEX")

titanic <- na.omit(titanic)
set.seed(1313)
titanic_small <- titanic[sample(1:nrow(titanic), 500), c(1,2,3,6,7,9)]
model_titanic_glm <- glm(survived == "yes" ~ gender + age + fare + class + sibsp,
                         data = titanic_small, family = "binomial")
explain_titanic_glm <- explain(model_titanic_glm,
                               data = titanic_small[,-6],
                               y = titanic_small$survived == "yes",
                               label = "glm")

ms1 <- modelStudio(explain_titanic_glm, new_observation = titanic_small[1,-6])
ms2 <- modelStudio(model_titanic_glm,
                   max_features = 5,
                   data = titanic_small[,-6],
                   y = titanic_small$survived == "yes",
                   label = "xxx",
                   new_observation = titanic_small[1,-6])

# tests

test_that("Output format", {
  expect_is(ms1, "r2d3")
  expect_is(ms2, "r2d3")
})
