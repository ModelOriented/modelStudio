library("dime")
library("DALEX")

### EXAMPLES
# ex1 classification

titanic <- na.omit(titanic)
set.seed(1313)
titanic_small <- titanic[sample(1:nrow(titanic), 500), c(1,2,3,6,7,9)]

model_titanic_glm <- glm(survived == "yes" ~ gender + age + fare + class + sibsp,
                         data = titanic_small, family = "binomial")

explain_titanic_glm <- explain(model_titanic_glm,
                               data = titanic_small[,-6],
                               y = titanic_small$survived == "yes",
                               label = "glm")

new_observations <- titanic_small[1:4,-6]
rownames(new_observations) <- c("Lucas","James", "Thomas", "Nancy")

modelStudio(explain_titanic_glm, new_observations,
            facet_dim = c(2,3), N = 100, B = 15, time = 0)

# ex2 regression

model_apartments <- glm(m2.price ~. ,
                        data = apartments)

explain_apartments <- explain(model_apartments,
                              data = apartments[,-1],
                              y = apartments[,1])

new_apartments <- apartments[1:2, -1]
rownames(new_apartments) <- c("ap1","ap2")

modelStudio(explain_apartments, new_apartments, N = 100, B = 15)


### README

titanic_small <- na.omit(titanic[, c(1,2,3,6,7,9)])
titanic_small$survived <- titanic_small$survived == "yes"

model_titanic_glm <- glm(survived ~ gender + age + fare + class + sibsp,
                         data = titanic_small, family = "binomial")
explain_titanic_glm <- explain(model_titanic_glm,
                               data = titanic_small[, -6],
                               y = titanic_small[, 6],
                               label = "glm")

new_observations <- titanic_small[1:4, -6]
rownames(new_observations) <- c("Lucas", "James", "Thomas", "Nancy")

modelStudio(explain_titanic_glm, new_observations)

### SOME TESTS
### randomForest + apartments

library("randomForest")

model_rf <- randomForest(m2.price ~. , data = apartments)
explain_rf <- explain(model_rf,
                      data = apartments,
                      y = apartments$m2.price)

modelStudio(explain_rf,
            new_observation = apartments[1:2,-1],
            N = 50, B = 10, facet_dim = c(3,3),
            time = 50, max_features = 4)


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

explain_artifficial <- explain(model_artifficial,
                               data = artifficial[,-12],
                               y = artifficial[,12])

modelStudio(explain_artifficial,
            new_observation = artifficial[1:2,], N = 5, B = 2,
            facet_dim = c(3,3))
