# modelStudio (development)
* ...

# modelStudio 3.1.2
* added new parameter to `modelStudio()`: `open_plots = c("fi")`, which is a vector listing plots to be initially opened (and on which positions) [(#112)](https://github.com/ModelOriented/modelStudio/issues/112)
* fixed future warning with `DALEX::loss_default()` since `DALEX >=2.5.0`

# modelStudio 3.1.0
* changed y-axis variable labels in `SV` to the same as in `BD`
* added new parameter to `modelStudio()`: `max_features_fi = max_features`, which allows displaying a distinctive number of features in `FI` plot (other than in `BD` and `SV`)
* added new options to `ms_options()`: `**_axis_title`, which allow changing plot-specific axis title (default varies)

# modelStudio 3.0.0
* **BREAKING CHANGES**: 
  * this version requires `R >=3.6`, `DALEX >=2.2.1`, `ingredients >=2.2.0` and `iBreakDown >=2.0.1`
  * the deprecated alias `modelStudioOptions()` is removed from this version of the package; after being deprecated for over a year since **v1.1.0**. Use the recommended `ms_options()` instead.
  * added new parameter to `modelStudio()`: `N_sv = 3*N`, which by default decreases the number of observations used for the calculation of `Shapley Values` (rows in `data`)
  * `margin_left = NULL` by default and it is adjusted based on the length of variable names 
  * the first plot opened in the dashboard is now `FI` instead of `BD` by default
* added the `verbose` parameter to `modelStudio()` as an alias to `show_info` [(#101)](https://github.com/ModelOriented/modelStudio/issues/101)
* added new `ms_merge_observations()` function that merges local explanation of observations from multiple `modelStudio` objects [(#102)](https://github.com/ModelOriented/modelStudio/issues/102)

# modelStudio 2.1.2
* fixed an error in `modelStudio()` when data had only one variable [(#99)](https://github.com/ModelOriented/modelStudio/issues/99)

# modelStudio 2.1.1
* fix CRAN checks

# modelStudio 2.1.0
* **DEFAULTS CHANGES**: if `new_observation = NULL` then choose `new_observation_n = 3` observations, evenly spread by the order of `y_hat`. This shall always include the observations, which ids are `which.min(y_hat)` and `which.max(y_hat)`. Additionally, improve the observation dropdown text in dashboard. [(#94)](https://github.com/ModelOriented/modelStudio/issues/94)
* updated the progress printing
* this version requires `DALEX v2.0.1`
* added new options to `ms_options`: `ms_subtitle`, `ms_margin_top` and `ms_margin_bottom`
* added new parameters to `modelStudio()`: `N_fi = 10*N` and `B_fi = B`
* added new `license` parameter to `modelStudio()` which allows to specify the connection for `readLines()` (e.g. `'LICENSE'`) which will add file contents into the HTML output as a comment

# modelStudio 2.0.0
* this version requires `DALEX v2.0`, `ingredients v2.0` and `iBreakDown v1.3.1`
* The dashboard gathers useful, but not sensitive, information about how it is being used (e.g. computation length, package version, dashboard dimensions). This is for the development purposes only and can be blocked by setting `telemetry` to `FALSE`.
* add support for `modelStudio` in Shiny [(#77)](https://github.com/ModelOriented/modelStudio/issues/77)
using new `widget_id` argument
* modelStudio now works with `NA` in `data` [(#71)](https://github.com/ModelOriented/modelStudio/issues/71)
* CP, PD and AD plots are now calculated with `variable_splits_type='uniform'` and CP plots are now calculated with `variable_splits_with_obs=TRUE` [(#74)](https://github.com/ModelOriented/modelStudio/issues/74)
* By default the `loss_function` in FI is now different for each `explainer$model_info$type` [(#73)](https://github.com/ModelOriented/modelStudio/issues/73)
* fixed a bug where passing additional parameters in `...` would cause an error
* added a `max_vars` alias for the `max_features` parameter
* added median line to the boxplots in FI and SV plots, added boxplots to TV categorical plots (regression)
* TV plot uses boxplots and barplot when the target `y` has only two unique
values (classification) [(#76)](https://github.com/ModelOriented/modelStudio/issues/76)
* added more checks for input
* added the Residuals vs Feature plot (RV) [(#84)](https://github.com/ModelOriented/modelStudio/issues/84)
* added model performance measures to the footnote [#(85)](https://github.com/ModelOriented/modelStudio/issues/85)

# modelStudio 1.2.0
* remove redundant documentation resources so that the package weights less
* add a second dropdown list for variable change
* fix check class warning
* add `stringsAsFactors=TRUE` where `data.frame` is used

# modelStudio 1.1.0
* rename `modelStudioOptions()` to `ms_options()`
* add new `ms_update_options()` function that updates the options of a `modelStudio` object
* add new `ms_update_observations()` function that updates the observations of a `modelStudio` object
* lower `B` default value from `15` to `10` and `N` default value from `400` to `300`
* `feature_importance` is now calculated on `10*N` sampled rows from the data
* use `ranger` instead of `randomForest` everywhere
* remove unnecessary imports, update the documentation
* added `auto_unbox = TRUE` to `jsonlite::toJSON` and changed the `.js` code to comply
* add new class `"modelStudio"` to the `modelStudio()` output

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
* lower `B` default value from `25` to `15`, `N` default value from `500` to `400`

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
