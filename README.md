# Interactive Studio with Explanations for ML Predictive Models <img src="man/figures/logo.png" align="right" width="150"/>

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/modelStudio)](https://cran.r-project.org/package=modelStudio)
[![Build Status](https://travis-ci.org/ModelOriented/modelStudio.svg?branch=master)](https://travis-ci.org/ModelOriented/modelStudio)
[![Coverage Status](https://codecov.io/gh/ModelOriented/modelStudio/branch/master/graph/badge.svg)](https://codecov.io/github/ModelOriented/modelStudio?branch=master)
[![DrWhy-eXtrAI](https://img.shields.io/badge/DrWhy-AutoMat-ae2c87)](http://drwhy.ai/#AutoMat)
[![JOSS-status](https://joss.theoj.org/papers/9eec8c9d1969fbd44b3ea438a74af911/status.svg)](https://joss.theoj.org/papers/9eec8c9d1969fbd44b3ea438a74af911)

## Overview

The `modelStudio` package automates the explanation of machine learning predictive models. This package generates advanced interactive and animated model explanations in the form of a serverless HTML site.

It combines **R** with **D3.js** to produce plots and descriptions
for various local and global explanations. Tools for model exploration unite with
tools for EDA (Exploratory Data Analysis) to give a broad overview of the model behavior. 
`modelStudio` is a fast and condensed way to get all the answers without much effort. Break down your model and look into its ingredients with only a few lines of code.

[See a demo](https://modeloriented.github.io/modelStudio/demo.html) &emsp; [explainFIFA19](https://pbiecek.github.io/explainFIFA19/) &emsp;
[explain Lung Cancer](https://github.com/hbaniecki/transparent_xai/) &emsp;
[More](https://github.com/ModelOriented/modelStudio#more)

![](images/gif3.gif)

The `modelStudio` package is a part of the [DrWhy.AI](http://drwhy.ai) universe.

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
library("modelStudio")

# Create a model
model <- glm(survived ~.,
             data = DALEX::titanic_imputed,
             family = "binomial")
                 
# Wrap it into an explainer        
explainer <- DALEX::explain(model,
                            data = DALEX::titanic_imputed[,-8],
                            y = DALEX::titanic_imputed[,8],
                            label = "glm")
                   
# Pick some data points
new_observations <- DALEX::titanic_imputed[1:4,]
rownames(new_observations) <- c("Lucas", "James", "Thomas", "Nancy")

# Make a studio for the model
modelStudio(explainer, new_observations)
```

More examples [here](https://modeloriented.github.io/modelStudio/articles/vignette_modelStudio.html).

![](images/gif4.gif)

## More

  - [Conference Poster about modelStudio](misc/MLinPL2019_modelStudio_poster.pdf)

  - [Article about modelStudio](https://joss.theoj.org/papers/10.21105/joss.01798)
  
  - [News](NEWS.md)
  
  - [Read the vignette: modelStudio - perks and features](https://modeloriented.github.io/modelStudio/articles/vignette_modelStudio.html)  
    
  - [Cheatsheet](images/cheatsheet.png)

## Save

Save `modelStudio` as a HTML file using buttons on the top of the RStudio Viewer
or with the [`r2d3::save_d3_html()`](https://rstudio.github.io/r2d3/articles/publishing.html#save-as-html) function.

<p align="center">
  <img src="images/controls.png">
</p>

## Acknowledgments

Work on this package was financially supported by the `NCN Opus grant 2016/21/B/ST6/02176`.
