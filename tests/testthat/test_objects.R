titanic <- na.omit(DALEX::titanic)
apartments <- DALEX::apartments
set.seed(1313)
v <- FALSE

### README DEMO

titanic_small <- titanic[sample(1:nrow(titanic), 500), c(1,2,3,6,7,9)]

model_titanic_glm <- glm(survived == "yes" ~ gender + age + fare + class + sibsp,
                         data = titanic_small, family = "binomial")

explain_titanic_glm <- DALEX::explain(model_titanic_glm,
                               data = titanic_small[,-6],
                               y = titanic_small$survived == "yes",
                               label = "glm",
                               verbose = v)

new_observations <- titanic_small[1:4,-6]
rownames(new_observations) <- c("Lucas", "James", "Thomas", "Nancy")


### glm + titanic

titanic_test <- titanic[sample(1:nrow(titanic), 500),]

model_glm <- glm(survived == "yes" ~.,
                 data = titanic_test, family = "binomial")

explain_glm <- DALEX::explain(model_glm,
                       data = titanic_test[,-9],
                       y = titanic_test$survived == "yes",
                       label = "glm",
                       verbose = v)

glm_numerical <- glm(survived == "yes" ~ age + fare + sibsp + parch,
                       data = titanic_test[, c(2,6,7,8,9)],
                       family = "binomial")

explain_glm_numerical <- DALEX::explain(glm_numerical,
                                   data = titanic_test[, c(2,6,7,8)],
                                   y = titanic_test$survived == "yes",
                                   verbose = v)

glm_not_numerical <- glm(survived == "yes" ~ gender + class + embarked + country,
                           data = titanic_test[, c(1,3,4,5,9)],
                           family = "binomial")

explain_glm_not_numerical <- DALEX::explain(glm_not_numerical,
                                       data = titanic_test[, c(1,3,4,5)],
                                       y = titanic_test$survived == "yes",
                                       verbose = v)

model_small <- glm(survived == "yes" ~ age + gender,
                   data = titanic_test[, c(1,2,9)],
                   family = "binomial")

explain_model_small <- DALEX::explain(model_small,
                               data = titanic_test[, c(1,2)],
                               y = titanic_test$survived == "yes",
                               verbose = v)


### randomForest + apartments

model_rf <- randomForest::randomForest(m2.price ~. , data = apartments)
explain_rf <- DALEX::explain(model_rf,
                      data = apartments,
                      y = apartments$m2.price,
                      verbose = v)


### data/new_observation permutations

x <- titanic_small[,-6]
nx <- titanic_small[1,-6]

z <- titanic_small[,]
nz <- titanic_small[1,]

w <- titanic_small[,1:3]
nw <- titanic_small[1,1:3]

y <- titanic_small[,6]== "yes"

explain_both_without_target <- DALEX::explain(model_titanic_glm,
                                              data = x,
                                              y = y)

explain_both_full <- DALEX::explain(model_titanic_glm,
                                    data = z,
                                    y = y)

explain_obs_without_target_data_full <- DALEX::explain(model_titanic_glm,
                                               data = z,
                                               y = y)

explain_obs_full_data_without_target <- DALEX::explain(model_titanic_glm,
                                                       data = x,
                                                       y = y)
### more than 10 features

n <- 50
artifficial <- data.frame(x1 = rnorm(n),
                          x2 =  rnorm(n),
                          x3 =  rnorm(n),
                          x4  = rnorm(n),
                          x5  = rnorm(n),
                          x6  = rnorm(n),
                          x7 = rnorm(n),
                          x8  = rnorm(n),
                          x9 = runif(n),
                          x10 = runif(n),
                          x11 = runif(n),
                          y = rbinom(n, 1, prob = 0.4))

model_artifficial <- glm(y ~.,
                         data = artifficial,
                         family = "binomial")

explain_artifficial <- DALEX::explain(model_artifficial,
                               data = artifficial[,-12],
                               y = artifficial[,12],
                               verbose = v)

