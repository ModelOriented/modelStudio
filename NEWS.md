# modelStudio 0.1.8
* change `Shapley Values` to `SHAP Values`
* Lower `B` default value from 25 to 15, `N` default value from 500 to 400
* This version requires `DALEX 0.4.9` and `ingredients 0.4.0`

# modelStudio 0.1.7
* fix tests for CRAN

# modelStudio 0.1.6
Many minor changes stated in #20, most notably:
* rename `x` parameter to `object` in `modelStudio()`
* rename `getOptions()` to `modelStudioOptions()`
* add `viewer` parameter to `modelStudio()`
* add suppressWarnings(ingredients::describe)
* upgrade documentation, examples and vignette

# modelStudio 0.1.5
* add description to all plots besides AD and FD
* add footer to `modelStudio`
* change `only_numerical` to `variable_type` in `ingredients` functions

# modelStudio 0.1.4
* add support for parallel computation with `parallelMap`
* more `modelStudio` customization with `options` parameter
* add `getOptions()` function
* remove plot subtitles by default

# modelStudio 0.1.3
* remove file paths of dependencies from html file
* add animations to line plots
* change .js dependencies to min.js

# modelStudio 0.1.2
* major .js code refactoring
* add proper exit plot buttons
* import Fira Sans font
* `modelStudio` does not reload on resize
* rewrite d3-tip code, fix placement, add pointer

# modelStudio 0.1.1
* add demo, cheatsheet, animated instructions, more tests and examples
* `description` won't show if there are less than 4 features in the model

# modelStudio 0.1.0
* first stable version of the `modelStudio` package
* `modelStudio()` function implemented
