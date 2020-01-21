---
title: 'modelStudio: Interactive Studio with Explanations for ML Predictive Models'
authors:
- affiliation: 1
  name: Hubert Baniecki
  orcid: 0000-0001-6661-5364
- affiliation: 1
  name: Przemyslaw Biecek
  orcid: 0000-0001-8423-1823
date: "22 October 2019"
bibliography: paper.bib
tags:
- automated data analysis
- model visualization 
- explainable artificial intelligence
- predictive modeling
- interpretable machine learning
affiliations:
- index: 1
  name: Faculty of Mathematics and Information Science, Warsaw University of Technology
---

# Introduction

Machine learning predictive models are widely used in many areas of
business and research. Their rising popularity is due to them being
effective but often leads to problems with explaining their prediction.
This has led to development of many Interpretable Machine Learning
tools, e.g., `DALEX` [@DALEX] R package, `lime` [@lime] and
`shap` [@NIPS2017_7062] Python packages and `H2o.ai Driverless AI` [@Gill2017MachineLI].

Nowadays, we can see a huge demand for automation in many areas. This is
how Automated Machine Learning and Automated Exploratory Data Analysis
came to existence. AutoML [@Truong2019TowardsAM] and AutoEDA [@2018arXiv180401955S]
tools not only speed up the model development process
but also often lead to new discoveries or higher quality of models.

Explaining predictive models might be a time consuming and tedious task. 
Libraries for interpretable machine learning [@DALEX; @iml; @tfexplain; @sklearnexplain; @InterpretML] require high programing skills and endless exploration of different aspects of a predictive model.

There are tools for automation of the XAI process like `modelDown` [@Romaszko2019] which produces static HTML site to compare and explain various models. Unfortunately, such tools are focused on global level explanations and deliver monotonous experience.  

# The `modelStudio` package

The `modelStudio` R package automates the process of model exploration. It generates advanced interactive and animated model explanations in the form of a serverless HTML site. It combines **R** [@R] with **D3.js** [@bostock2016d3] to produce plots and descriptions for various local and global explanations. Tools for model exploration unite with tools for EDA to give a broad overview of the model behaviour.

The usage of `modelStudio` is meant to be intuitive and simple. The computation time needed to produce the output might not be short though.
The main goal of this tool is to make model explaining more automated and achieve higher quality explanations by juxtaposition of complementary aspects of a model.

Comparing instance level explanations and model level
explanations side by side adds wider context and allows for deeper understanding. 
`modelStudio` helps to study relations between various methods for model explanation like *Break Down*, *SHAP*, *Partial Dependency Plots*, *Feature Importance*, and others.



# Example

The package `modelStudio` is available on [CRAN](https://CRAN.R-project.org/package=modelStudio). It can be installed
using the `install.packages('modelStudio')` command. This package is based
on `DALEX` explainers created with `DALEX::explain()`. Below there is a basic code
example, which produces [demo](https://modeloriented.github.io/modelStudio/demo.html).

``` r
library("modelStudio")

# Create a model
model <- glm(survived ~., data = DALEX::titanic_imputed, family = "binomial")
                 
# Wrap it into an explainer        
explainer <- DALEX::explain(model, data = DALEX::titanic_imputed[,-8],
                            y = DALEX::titanic_imputed[,8], label = "glm")
                   
# Pick some data points
new_observations <- DALEX::titanic_imputed[1:4,]
rownames(new_observations) <- c("Lucas", "James", "Thomas", "Nancy")

# Make a studio for the model
modelStudio(explainer, new_observations)
```

![Exemplary HTML output layout.](images/demo.png)

# Key Features

The generated HTML site has many interactive features. One can choose
which plots are displayed on the grid and change them at any given
moment by clicking the X symbol. A drop down list may be used to pick the
observation that will be considered for local explanation plots. One may manipulate plots having a variable-based dimension by selecting corresponding bars on the other plots. Mousing over the D symbol displays a description of the plot. Finally, mousing over lines and bars displays the tooltip.

![1. Open in browser or save as HTML document or PNG image 2. Click on bars to choose which feature will be used for other plots 3. Mouse over the D symbol to display a description of the plot and click X to close the plot 4. Choose which observation will be used for local explanations 5. Mouse over lines and bars to display the tooltip 6. Click on the text to choose the plot 7. Interact with other elements like a slider](images/cheatsheetcut.png)

# Explanations

Seven possible plots to choose from are implemented. There are three
local explanation plots, three global explanation plots and a feature density plot.

**Local explanations** are designed to better understand model behaviour
around a single observation.

  - **Break Down** plot and **SHAP Values** [@NIPS2017_7062]
    plot present variable contributions to a model prediction [@gosiewska2019ibreakdown].
    Both of them come from the `iBreakDown` [@iBreakDown] R package.

  - **Ceteris Paribus** plot presents model responses around a single
    point in the feature space [@ceterisParibus].

**Global explanations** are designed to allow for better understanding of how the model
works in general, for some population of interest.

  - **Feature Importance** plot presents permutation based feature
    importance [@fisher2018all].

  - **Partial Dependency** plot presents averages from N number of
    Ceteris Paribus Profiles [@RJ-2017-016].

  - **Accumulated Dependency** plot presents accumulated local changes
    in Ceteris Paribus Profiles [@apley2016visualizing].

Detailed overview of these methods can be found in “Predictive Models:
Explore, Explain, and Debug” [@pmeed]. The last explanations are implemented 
in the `ingredients` [@ingredients] R package.

# Conclusions

The `modelStudio` package is easy to use and its output is intuitive to
explore. Automation is convenient and interactivity adds an another
dimension to visualisations. All of this enhance explanation of machine
learning predictive models. More features and examples can be found in
the vignette: [modelStudio - perks and features](https://modeloriented.github.io/modelStudio/articles/vignette_modelStudio.html)
and on [GitHub](https://github.com/ModelOriented/modelStudio).

# Acknowledgments

Work on this package was financially supported by the ‘NCN Opus grant 2016/21/B/ST6/02176’.

# References
