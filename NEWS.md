# modelStudio 1.0.2
* fix `FD` plot on matrix-like data 
* center `modelStudio` position in HTML
* `modelStudio` now renders properly from `.Rmd` to `.html`

# modelStudio 1.0.1
* fix `devel-fedora` tests for cran

# modelStudio 1.0.0
* stable release after fixing minor issues
* comply with `R v4.0` changes
* add support for matrix-like `data` with `xgboost` working example
* boxplot whiskers end in `max(min, q1 - 1.5*iqr)` and `min(max, q3 + 1.5*iqr)` 
* upgrade `show_info` with `progress` package

# modelStudio 0.3.0
* **`modelStudio()` now only works on `explainer` class object made with `DALEX::explain()`**
* this version requires `iBreakDown v1.0.0` and `ingredients v1.0.0` 
* change `cummulative` to `cumulative` in code (#49)
* change `dependency` to `dependence` in code (#52)
* update package title and description
* change LICENSE to GPL-3 (#55)
* add boxplots to `SV` plot (#50)
* add `eda` argument to `modelStudio()`
* add `show_boxplot` argument to `modelStudioOptions()`

# modelStudio 0.2.1
* fix `TV` plot (X had columns sorted while y was the same)
* add `ms_title` argument to `modelStudioOptions()` (#46)
* `modelStudio` footer is generated faster 

# modelStudio 0.2.0
* new plot: `Target vs Feature [EDA]` (#38)
* new plot: `Average Target vs Feature [EDA]` (#41)
* add boxplots to `FI` plot [ingredients/72](https://github.com/ModelOriented/ingredients/issues/72)
* add `new_observation_y` argument to `modelStudio()` (#39)
* pass `...` to `prepare_*` functions (e.g. allows to round numbers)
* add `margin_ytitle` argument to `modelStudioOptions()`
* by default: observations to calculate local explanations are taken at random from the `data` (#25)
* by default: first plot is selected as `BD` and second is `clicked` (#37)
* nicer histogram when few unique values
* all categorical plots now have the same bar order [ingredients/82](https://github.com/ModelOriented/ingredients/issues/82)
* `try-catch` blocks added - errors in `ingredients` or `iBreakDown` functions are
now treated as warnings and do not stop the `modelStudio` computation (#35)
* `show_info` adds messages saying what is currently calculated (#40)
* add `spellcheck` to tests (#36)
* Travis-CI now checks OSX

# modelStudio 0.1.9
* this version requires `DALEX v0.4.9` and `ingredients v0.4.0`

# modelStudio 0.1.8
* lower `B` default value from 25 to 15, `N` default value from 500 to 400

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
