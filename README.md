# dime: Deep Interactive Model Explanation
### Automate Explaining Machine Learning Predictive Models

[![Build Status](https://travis-ci.org/ModelOriented/dime.svg?branch=master)](https://travis-ci.org/ModelOriented/dime)
[![Coverage Status](https://img.shields.io/codecov/c/github/ModelOriented/dime/master.svg)](https://codecov.io/github/ModelOriented/dime?branch=master)

This package generates advanced interactive and animated model explanations in the form
of serverless HTML site. It combines R with D3.js to produce plots and descriptions
for local and global explanations. The whole is greater than the sum of its parts,
so it also supports EDA on top of that. ModelStudio is a fast and condensed way to get
all the answers without much effort. Break down your model and look into its ingredients
with only a few lines of code.  
    
[See an example](https://modeloriented.github.io/dime/demo.html)

------------------------------------------------------

## Installation

Install from GitHub:

``` 
devtools::install_github("ModelOriented/dime")
```

Be sure that all dependencies are up-to-date with GitHub.

-------------------------------------------------------

## Demo

This package bases on `DALEX::explain()`.

```r
 library("dime")
 library("DALEX")
```

Create a model:

```r
 titanic <- na.omit(titanic)
 set.seed(1313)
 titanic_small <- titanic[sample(1:nrow(titanic), 500), c(1,2,3,6,7,9)]

 model_titanic_glm <- glm(survived == "yes" ~ gender + age + fare + class + sibsp,
                          data = titanic_small, family = "binomial")
```

Wrap it into an explainer:

```r
 explain_titanic_glm <- explain(model_titanic_glm,
                                data = titanic_small[,-6],
                                y = titanic_small$survived == "yes",
                                label = "glm")
```

Pick some data points:

```r
 new_observations <- titanic_small[1:4,-6]
 rownames(new_observations) <- c("Lisa", "James", "Thomas", "Nancy")
```

Make a studio for the model:

```r
 modelStudio(explain_titanic_glm,
             new_observations,
             facet_dim = c(2,2), N = 200, B = 20, time = 0)
```

------------------------------------------------------

## Cheat Sheet

![CheatSheet](images/basicCheatSheet.bmp)

