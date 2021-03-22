library("testthat")
library("modelStudio")
library("DALEX")
requireNamespace("ranger", quietly=TRUE)
requireNamespace("xgboost", quietly=TRUE)

test_check("modelStudio")
