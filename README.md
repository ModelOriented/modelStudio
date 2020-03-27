# Interactive Studio for Explanatory Model Analysis <img src="man/figures/logo.png" align="right" width="150"/>

[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/modelStudio)](https://cran.r-project.org/package=modelStudio)
[![R build status](https://github.com/ModelOriented/modelStudio/workflows/R-CMD-check/badge.svg)](https://github.com/ModelOriented/modelStudio/actions?query=workflow%3AR-CMD-check)
[![Coverage Status](https://codecov.io/gh/ModelOriented/modelStudio/branch/master/graph/badge.svg)](https://codecov.io/github/ModelOriented/modelStudio?branch=master)
[![DrWhy-eXtrAI](https://img.shields.io/badge/DrWhy-AutoMat-ae2c87)](http://drwhy.ai/#AutoMat)
[![JOSS-status](https://joss.theoj.org/papers/9eec8c9d1969fbd44b3ea438a74af911/status.svg)](https://joss.theoj.org/papers/9eec8c9d1969fbd44b3ea438a74af911)

## Overview

The `modelStudio` package **automates the Explanatory Analysis of Machine Learning predictive models**. Generate advanced interactive and animated model explanations in the form of a **serverless HTML site** with only one line of code. This tool is compatibile with most of the black box predictive models and frameworks (e.g. `xgboost`, `caret`, `mlr/mlr3`, `h2o`, `scikit-learn`, `lightGBM`, `tensorflow`).

The main `modelStudio()` function computes various (instance and dataset level) model explanations and produces an **interactive, customisable dashboard made with D3.js**. It consists of multiple panels for plots with their short descriptions. Easily **save and share** the dashboard with others. Tools for model exploration unite with tools for EDA (Exploratory Data Analysis) to give a broad overview of the model behavior.

<!--- [explain FIFA19](https://pbiecek.github.io/explainFIFA19/) &emsp; --->
[**explain FIFA20**](https://pbiecek.github.io/explainFIFA20/) &emsp;
[explain Lung Cancer](https://github.com/hbaniecki/transparent_xai/) &emsp;
[**explain Python model**](https://modeloriented.github.io/modelStudio/articles/vignette_modelStudio.html#python-scikit-learn-model) &emsp;
[More Resources](https://modeloriented.github.io/modelStudio/#more) &emsp;
[**FAQ & Troubleshooting**](https://github.com/ModelOriented/modelStudio/issues/54)

![](man/figures/short.gif)

The `modelStudio` package is a part of the [**DrWhy.AI**](http://drwhy.ai) universe.

## Installation

```r
# Install from CRAN: 
install.packages("modelStudio")

# Install the development version from GitHub:
devtools::install_github("ModelOriented/modelStudio")
```

## Demo

This package bases on `DALEX` explainers created with `DALEX::explain()`.

```r
library("DALEX")
library("modelStudio")

# Create a model
model <- glm(survived ~.,
             data = titanic_imputed,
             family = "binomial")

# Wrap it into an explainer        
explainer <- explain(model,
                     data = titanic_imputed,
                     y = titanic_imputed$survived,
                     label = "Titanic GLM")

# Pick some data points
new_observations <- titanic_imputed[1:4,]
rownames(new_observations) <- c("Lucas", "James", "Thomas", "Nancy")

# Make a studio for the model
modelStudio(explainer, new_observations)
```

Saved output in the form of a HTML file - [**Demo Dashboard**](https://modeloriented.github.io/modelStudio/demo.html).

![](man/figures/long.gif)

## Examples

```{r}
# update main dependencies
install.packages("ingredients")
install.packages("iBreakDown")

# packages for explainer objects
install.packages("DALEX")
devtools::install_github("ModelOriented/DALEXtra")
```

### xgboost

```{r}
# load packages and data
library(xgboost)
library(DALEX)
library(modelStudio)

data <- DALEX::titanic_imputed

# split the data
index <- sample(1:nrow(data), 0.8*nrow(data))
train <- data[index, ]
test <- data[-index, ]

train_matrix <- model.matrix(survived ~.-1, train)
test_matrix <- model.matrix(survived ~.-1, test)

# prepare the model
xgb_matrix <- xgb.DMatrix(train_matrix, label = train$survived)
params <- list(eta = 0.01, subsample = 0.6, max_depth = 7, min_child_weight = 3,
               objective = "binary:logistic", eval_metric = "auc")
model <- xgb.train(params, xgb_matrix, nrounds = 1000)

# create an explainer for the model
explainer <- explain(model,
                     data = test_matrix,
                     y = test$survived,
                     label = "xgboost")

# pick observations
new_observation <- test_matrix[1:2,,drop=FALSE]
rownames(new_observation) <- c("id1", "id2")

# make a studio for the model
modelStudio(explainer,
            new_observation,
            options = modelStudioOptions(margin_left = 140))
```

[xgboost dashboard](https://modeloriented.github.io/modelStudio/xgboost.html)

### caret

```{r}
# load packages and data
library(caret)
library(DALEX)
library(modelStudio)

data <- DALEX::titanic_imputed

# split the data
index <- sample(1:nrow(data), 0.8*nrow(data))
train <- data[index, ]
test <- data[-index, ]

# caret train takes target as factor
train$survived <- as.factor(train$survived)

# prepare the model
cv <- trainControl(method = "repeatedcv",
                   number = 3,
                   repeats = 10)

model <- train(survived ~ ., data = train,
               method = "gbm",
               trControl = cv,
               verbose = FALSE)

# create an explainer for the model
explainer <- explain(model,
                     data = test,
                     y = test$survived,
                     label = "caret")

# pick observations
new_observation <- test[1:2,]
rownames(new_observation) <- c("id1", "id2")

# make a studio for the model
modelStudio(explainer,
            new_observation)
```

### mlr/mlr3

```{r}
# load packages and data
library(mlr)
library(DALEXtra)
library(modelStudio)

data <- DALEX::titanic_imputed

# split the data
index <- sample(1:nrow(data), 0.8*nrow(data))
train <- data[index, ]
test <- data[-index, ]

# mlr ClassifTask takes target as factor
train$survived <- as.factor(train$survived)

# prepare the model
task <- makeClassifTask(id = "titanic",
                        data = train,
                        target = "survived")

learner <- makeLearner("classif.ranger",
                       predict.type = "prob")

model <- train(learner, task)

# create an explainer for the model
explainer <- explain_mlr(model,
                         data = test,
                         y = test$survived,
                         label = "mlr")

# pick observations
new_observation <- test[1:2, ]
rownames(new_observation) <- c("id1", "id2")

# make a studio for the model
modelStudio(explainer,
            new_observation)
```

```{r}
# load packages and data
library(mlr3)
library(mlr3learners)
library(DALEXtra)
library(modelStudio)

data <- DALEX::titanic_imputed

# split the data
index <- sample(1:nrow(data), 0.8*nrow(data))
train <- data[index, ]
test <- data[-index, ]

# mlr3 TaskClassif takes target as factor
train$survived <- as.factor(train$survived)

# prepare the model
task <- TaskClassif$new(id = "titanic",
                        backend = train,
                        target = "survived")

learner <- lrn("classif.ranger",
               predict_type = "prob")

learner$train(task)

# create an explainer for the model
explainer <- explain_mlr3(learner,
                          data = test,
                          y = test$survived,
                          label = "mlr3")

# pick observations
new_observation <- test[1:2, ]
rownames(new_observation) <- c("id1", "id2")

# make a studio for the model
modelStudio(explainer,
            new_observation)
```

### h2o

```{r}
library(DALEXtra)

explain_h2o()

```

### scikit-learn

```{r}
library(DALEXtra)

explain_scikit()

```

### lightGBM

```{r}
library(DALEXtra)

explain_scikit()

```

### tensorflow

```{r}
library(DALEXtra)

explain_keras()

```


## More Resources
  
  - [Explanatory Model Analysis. Explore, Explain and Examine Predictive Models.](https://pbiecek.github.io/ema)
  
  - [Read the vignette: modelStudio - perks and features](https://modeloriented.github.io/modelStudio/articles/vignette_modelStudio.html)  
  
  - [Conference Poster about modelStudio](misc/MLinPL2019_modelStudio_poster.pdf)

<!--  - [Article about modelStudio](https://joss.theoj.org/papers/10.21105/joss.01798) -->
  
  - [News](NEWS.md)
  
    
  
## Save and Share

Save `modelStudio` as a HTML file using buttons on the top of the RStudio Viewer
or with [`r2d3::save_d3_html()`](https://rstudio.github.io/r2d3/articles/publishing.html#save-as-html).

<p align="center">
  <img src="man/figures/controls.png">
</p>

## Acknowledgments

Work on this package was financially supported by the `NCN Opus grant 2016/21/B/ST6/02176`.
