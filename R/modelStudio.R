#' @title Interactive Studio for Explanatory Model Analysis
#'
#' @description
#' This function computes various (instance and dataset level) model explanations and produces an interactive,
#' customisable dashboard. It consists of multiple panels for plots with their short descriptions.
#' Easily save and share the HTML dashboard with others. Tools for model exploration unite with tools for
#' Exploratory Data Analysis to give a broad overview of the model behavior.
#'
#' Theoretical introduction to the plots:
#' \href{https://pbiecek.github.io/ema/}{Explanatory Model Analysis: Explore, Explain and Examine Predictive Models}
#'
#' Displayed variable can be changed by clicking on the bars of plots or with the first dropdown list,
#'  and observation can be changed with the second dropdown list.
#'
#' @param explainer An \code{explainer} created with \code{DALEX::explain()}.
#' @param new_observation New observations with columns that correspond to variables used in the model.
#' @param new_observation_y True label for \code{new_observation} (optional).
#' @param facet_dim Dimensions of the grid. Default is \code{c(2,2)}.
#' @param time Time in ms. Set the animation length. Default is \code{500}.
#' @param max_features Maximum number of features to be included in BD and SV plots.
#'  Default is \code{10}.
#' @param N Number of observations used for the calculation of PD and AD.
#'  \code{10*N} is a number of observations used for the calculation of FI.
#'  Default \code{N} is \code{300}.
#'  See \href{https://modelstudio.drwhy.ai/articles/ms-perks-features.html#more-calculations-means-more-time}{\bold{vignette}}
#' @param B Number of permutation rounds used for calculation of SV and FI.
#'  Default is \code{10}.
#'  See \href{https://modelstudio.drwhy.ai/articles/ms-perks-features.html#more-calculations-means-more-time}{\bold{vignette}}
#' @param eda Compute EDA plots. Default is \code{TRUE}.
#' @param show_info Verbose a progress on the console. Default is \code{TRUE}.
#' @param parallel Speed up the computation using \code{parallelMap::parallelMap()}.
#'  See \href{https://modeloriented.github.io/modelStudio/articles/ms-perks-features.html#parallel-computation}{\bold{vignette}}.
#'  This might interfere with showing progress using \code{show_info}.
#' @param options Customize \code{modelStudio}. See \code{\link{ms_options}} and
#'  \href{https://modeloriented.github.io/modelStudio/articles/ms-perks-features.html#plot-options}{\bold{vignette}}.
#' @param viewer Default is \code{external} to display in an external RStudio window.
#'  Use \code{browser} to display in an external browser or
#'  \code{internal} to use the RStudio internal viewer pane for output.
#' @param ... Other parameters.
#'
#' @return An object of the \code{r2d3, htmlwidget, modelStudio} class.
#'
#' @importFrom utils head tail packageVersion
#' @importFrom stats aggregate predict quantile IQR
#' @importFrom grDevices nclass.Sturges
#' @import progress
#'
#' @references
#'
#' \itemize{
#'   \item The input object is implemented in \href{https://modeloriented.github.io/DALEX/}{\bold{DALEX}}
#'   \item Feature Importance, Ceteris Paribus, Partial Dependence and Accumulated Dependence plots
#'    are implemented in \href{https://modeloriented.github.io/ingredients/}{\bold{ingredients}}
#'   \item Break Down and Shapley Values plots are implemented in
#'    \href{https://modeloriented.github.io/iBreakDown/}{\bold{iBreakDown}}
#' }
#'
#' @seealso
#' Vignettes: \href{https://modeloriented.github.io/modelStudio/articles/ms-r-python-examples.html}{\bold{modelStudio - R & Python examples}}
#' and \href{https://modeloriented.github.io/modelStudio/articles/ms-perks-features.html}{\bold{modelStudio - perks and features}}
#'
#' @examples
#' library("DALEX")
#' library("modelStudio")
#'
#' #:# ex1 classification on 'titanic' data
#'
#' # fit a model
#' model_titanic <- glm(survived ~., data = titanic_imputed, family = "binomial")
#'
#' # create an explainer for the model
#' explainer_titanic <- explain(model_titanic,
#'                              data = titanic_imputed,
#'                              y = titanic_imputed$survived,
#'                              label = "Titanic GLM")
#'
#' # pick observations
#' new_observations <- titanic_imputed[1:2,]
#' rownames(new_observations) <- c("Lucas","James")
#'
#' # make a studio for the model
#' modelStudio(explainer_titanic,
#'             new_observations)
#'
#' \donttest{
#'
#' #:# ex2 regression on 'apartments' data
#' library("ranger")
#'
#' model_apartments <- ranger(m2.price ~. ,data = apartments)
#'
#' explainer_apartments <- explain(model_apartments,
#'                                 data = apartments,
#'                                 y = apartments$m2.price)
#'
#' new_apartments <- apartments[1:2,]
#' rownames(new_apartments) <- c("ap1","ap2")
#'
#' # change dashboard dimensions and animation length
#' modelStudio(explainer_apartments,
#'             new_apartments,
#'             facet_dim = c(2, 3),
#'             time = 800)
#'
#' # add information about true labels
#' modelStudio(explainer_apartments,
#'             new_apartments,
#'             new_observation_y = new_apartments$m2.price)
#'
#' # don't compute EDA plots
#' modelStudio(explainer_apartments,
#'             eda = FALSE)
#'
#'
#' #:# ex3 xgboost model on 'HR' dataset
#' library("xgboost")
#'
#' HR_matrix <- model.matrix(status == "fired" ~ . -1, HR)
#'
#' # fit a model
#' xgb_matrix <- xgb.DMatrix(HR_matrix, label = HR$status == "fired")
#' params <- list(max_depth = 3, objective = "binary:logistic", eval_metric = "auc")
#' model_HR <- xgb.train(params, xgb_matrix, nrounds = 300)
#'
#' # create an explainer for the model
#' explainer_HR <- explain(model_HR,
#'                         data = HR_matrix,
#'                         y = HR$status == "fired",
#'                         label = "xgboost")
#'
#' # pick observations
#' new_observation <- HR_matrix[1:2, , drop=FALSE]
#' rownames(new_observation) <- c("id1", "id2")

#' # make a studio for the model
#' modelStudio(explainer_HR,
#'             new_observation)
#'
#' }
#'
#' @export
#' @rdname modelStudio
modelStudio <- function(explainer, ...) {
  UseMethod("modelStudio")
}

#' @export
#' @rdname modelStudio
modelStudio.explainer <- function(explainer,
                                  new_observation = NULL,
                                  new_observation_y = NULL,
                                  facet_dim = c(2,2),
                                  time = 500,
                                  max_features = 10,
                                  N = 300,
                                  B = 10,
                                  eda = TRUE,
                                  show_info = TRUE,
                                  parallel = FALSE,
                                  options = ms_options(),
                                  viewer = "external",
                                  ...) {

  model <- explainer$model
  data <- explainer$data
  y <- explainer$y
  predict_function <- explainer$predict_function
  label <- explainer$label

  #:# checks
  if (is.null(rownames(data))) {
    rownames(data) <- 1:nrow(data)
  }

  if (is.null(new_observation)) {
    if (show_info) message("`new_observation` argument is NULL.\n",
                           "Observations needed to calculate local explanations are taken at random from the data.\n")
    new_observation <- ingredients::select_sample(data, 3)

  } else if (is.null(dim(new_observation))) {
    warning("`new_observation` argument is not a data.frame nor a matrix, coerced to data.frame\n")
    new_observation <- as.data.frame(new_observation, stringsAsFactors=TRUE)

  } else if (is.null(rownames(new_observation))) {
    rownames(new_observation) <- 1:nrow(new_observation)
  }

  check_single_prediction <- try(predict_function(model, new_observation[1,, drop = FALSE]), silent = TRUE)
  if ("try-error" %in% class(check_single_prediction)) {
    stop("`explainer$predict_function` returns an error when executed on `new_observation[1,, drop = FALSE]` \n")
  }
  #:#

  ## get proper names of features that arent target
  is_y <- is_y_in_data(data, y)
  potential_variable_names <- names(is_y[!is_y])
  variable_names <- intersect(potential_variable_names, colnames(new_observation))
  ## get rid of target in data
  data <- data[,!is_y]

  obs_count <- dim(new_observation)[1]
  obs_data <- new_observation
  obs_list <- list()

  ## later update progress bar after all explanation functions
  if (show_info) {
    pb <- progress_bar$new(
      format = "  Calculating :what \n    Elapsed time: :elapsedfull ETA::eta", # :percent  [:bar]
      total = (3*B + 2 + 1)*obs_count + (2*B + 3*B + B) + 1,
      show_after = 0
    )
    pb$tick(0, tokens = list(what = "..."))
  }

  ## count only once
  fi <- calculate(
    ingredients::feature_importance(
        model, data, y, predict_function, variables = variable_names, B = B, N = 10*N),
    "ingredients::feature_importance", show_info, pb, 2*B)

  which_numerical <- which_variables_are_numeric(data)

  ## because aggregate_profiles calculates numerical OR categorical
  if (all(which_numerical)) {
    pd_n <- calculate(
      ingredients::partial_dependence(
          model, data, predict_function, variable_type = "numerical", N = N),
      "ingredients::partial_dependence (numerical)", show_info, pb, B)
    pd_c <- NULL
    ad_n <- calculate(
      ingredients::accumulated_dependence(
          model, data, predict_function, variable_type = "numerical", N = N),
      "ingredients::accumulated_dependence (numerical)", show_info, pb, 3*B)
    ad_c <- NULL
  } else if (all(!which_numerical)) {
    pd_n <- NULL
    pd_c <- calculate(
      ingredients::partial_dependence(
          model, data, predict_function, variable_type = "categorical", N = N),
      "ingredients::partial_dependence (categorical)", show_info, pb, B)
    ad_n <- NULL
    ad_c <- calculate(
      ingredients::accumulated_dependence(
          model, data, predict_function, variable_type = "categorical", N = N),
      "ingredients::accumulated_dependence (categorical)", show_info, pb, 3*B)
  } else {
    pd_n <- calculate(
      ingredients::partial_dependence(
        model, data, predict_function, variable_type = "numerical", N = N),
      "ingredients::partial_dependence (numerical)", show_info, pb, B/2)
    pd_c <- calculate(
      ingredients::partial_dependence(
        model, data, predict_function, variable_type = "categorical", N = N),
      "ingredients::partial_dependence (categorical)", show_info, pb, B/2)
    ad_n <- calculate(
      ingredients::accumulated_dependence(
        model, data, predict_function, variable_type = "numerical", N = N),
      "ingredients::accumulated_dependence (numerical)", show_info, pb, 2*B)
    ad_c <- calculate(
      ingredients::accumulated_dependence(
        model, data, predict_function, variable_type = "categorical", N = N),
      "ingredients::accumulated_dependence (categorical)", show_info, pb, B)
  }

  fi_data <- prepare_feature_importance(fi, max_features, options$show_boxplot, ...)
  pd_data <- prepare_partial_dependence(pd_n, pd_c, variables = variable_names)
  ad_data <- prepare_accumulated_dependence(ad_n, ad_c, variables = variable_names)

  if (eda) {
    fd_data <- prepare_feature_distribution(data, y, variables = variable_names)
    at_data <- prepare_average_target(data, y, variables = variable_names)
  } else {
    fd_data <- at_data <- NULL
  }

  if (parallel) {
    parallelMap::parallelStart()
    parallelMap::parallelLibrary(packages = loadedNamespaces())

    f <- function(i, model, data, predict_function, label, B, show_boxplot, ...) {
      new_observation <- obs_data[i,, drop = FALSE]

      bd <- calculate(
        iBreakDown::local_attributions(
          model, data, predict_function, new_observation, label = label),
        paste0("iBreakDown::local_attributions (", i, ")"), show_info, pb, 2)
      sv <- calculate(
        iBreakDown::shap(
          model, data, predict_function, new_observation, label = label, B = B),
        paste0("iBreakDown::shap (", i, ")"), show_info, pb, 3*B)
      cp <- calculate(
        ingredients::ceteris_paribus(
          model, data, predict_function, new_observation, label = label),
        paste0("ingredients::ceteris_paribus (", i, ")"), show_info, pb, 1)

      bd_data <- prepare_break_down(bd, max_features, ...)
      sv_data <- prepare_shapley_values(sv, max_features, show_boxplot, ...)
      cp_data <- prepare_ceteris_paribus(cp, variables = variable_names)

      list(bd_data, cp_data, sv_data)
    }

    obs_list <- parallelMap::parallelMap(f, 1:obs_count,
                                         more.args = list(
                                           model = model,
                                           data = data,
                                           predict_function = predict_function,
                                           label = label,
                                           B = B,
                                           show_boxplot = options$show_boxplot,
                                           ...
                                         ))

    parallelMap::parallelStop()

  } else {
    ## count once per observation
    for(i in 1:obs_count) {
      new_observation <- obs_data[i,, drop = FALSE]

      bd <- calculate(
        iBreakDown::local_attributions(
          model, data, predict_function, new_observation, label = label),
        paste0("iBreakDown::local_attributions (", i, ")"), show_info, pb, 2)
      sv <- calculate(
        iBreakDown::shap(
          model, data, predict_function, new_observation, label = label, B = B),
        paste0("iBreakDown::shap (", i, ")"), show_info, pb, 3*B)
      cp <- calculate(
        ingredients::ceteris_paribus(
          model, data, predict_function, new_observation, label = label),
        paste0("ingredients::ceteris_paribus (", i, ")"), show_info, pb, 1)

      bd_data <- prepare_break_down(bd, max_features, ...)
      sv_data <- prepare_shapley_values(sv, max_features, options$show_boxplot, ...)
      cp_data <- prepare_ceteris_paribus(cp, variables = variable_names)

      obs_list[[i]] <- list(bd_data, cp_data, sv_data)
    }
  }

  # pack explanation data to json and make hash for htmlwidget
  names(obs_list) <- rownames(obs_data)
  temp <- jsonlite::toJSON(list(obs_list, fi_data, pd_data, ad_data, fd_data, at_data), auto_unbox = TRUE)
  widget_id <- paste0("widget-", digest::digest(temp))

  # prepare observation data for drop down
  between <- " - "
  if (is.null(new_observation_y)) new_observation_y <- between <- ""
  drop_down_data <- as.data.frame(cbind(rownames(obs_data),
                                        paste0(rownames(obs_data), between, new_observation_y)),
                                  stringsAsFactors=TRUE)
  colnames(drop_down_data) <- c("id", "text")

  # prepare footer text and ms title
  footer_text <- paste0("Site built with modelStudio v", packageVersion("modelStudio"),
                        " on ", format(Sys.time(), usetz = FALSE))

  if (is.null(options$ms_title)) options$ms_title <- paste0("Interactive Studio for ", label, " Model")

  options <- c(list(time = time,
                    model_name = label,
                    variable_names = variable_names,
                    facet_dim = facet_dim,
                    footer_text = footer_text,
                    drop_down_data = jsonlite::toJSON(drop_down_data),
                    eda = eda,
                    widget_id = widget_id
                    ), options)

  sizing_policy <- r2d3::sizingPolicy(padding = 10, browser.fill = TRUE)

  options("r2d3.shadow" = FALSE) # set this option to avoid using shadow-root

  model_studio <- r2d3::r2d3(
                    data = temp,
                    script = system.file("d3js/modelStudio.js", package = "modelStudio"),
                    dependencies = list(
                      system.file("d3js/hackHead.js", package = "modelStudio"),
                      system.file("d3js/myTools.js", package = "modelStudio"),
                      system.file("d3js/d3-tip.js", package = "modelStudio"),
                      system.file("d3js/d3-simple-slider.min.js", package = "modelStudio"),
                      system.file("d3js/d3-interpolate-path.min.js", package = "modelStudio"),
                      system.file("d3js/generatePlots.js", package = "modelStudio"),
                      system.file("d3js/generateTooltipHtml.js", package = "modelStudio")
                    ),
                    css = system.file("d3js/modelStudio.css", package = "modelStudio"),
                    options = options,
                    d3_version = "4",
                    viewer = viewer,
                    sizing = sizing_policy,
                    elementId = widget_id,
                    width = facet_dim[2]*(options$w + options$margin_left + options$margin_right),
                    height = 100 + facet_dim[1]*(options$h + options$margin_top + options$margin_bottom)
                  )

  model_studio$x$script <- remove_file_paths(model_studio$x$script, "js")
  model_studio$x$style <- remove_file_paths(model_studio$x$style, "css")

  class(model_studio) <- c(class(model_studio), "modelStudio")

  model_studio
}

#:# alias for reticulate pickle/dalex Explainer
#' @noRd
#' @export
modelStudio.python.builtin.object <- modelStudio.explainer

#' @noRd
#' @export
modelStudio.dalex._explainer.object.Explainer <- modelStudio.explainer

#' @noRd
#' @title remove_file_paths
#'
#' @description \code{r2d3} adds comments in html file with direct file paths to dependencies.
#' This function removes them.
#'
#' @param text string
#' @param type js or css to remove other paths

remove_file_paths <- function(text, type = NULL) {

  if (is.null(type)) stop("error in remove_file_paths")

  if (type == "js") {
    text <- gsub(system.file("d3js/modelStudio.js", package = "modelStudio"), "", text, fixed = TRUE)
    text <- gsub(system.file("d3js/hackHead.js", package = "modelStudio"), "", text, fixed = TRUE)
    text <- gsub(system.file("d3js/myTools.js", package = "modelStudio"), "", text, fixed = TRUE)
    text <- gsub(system.file("d3js/d3-tip.js", package = "modelStudio"), "", text, fixed = TRUE)
    text <- gsub(system.file("d3js/d3-simple-slider.min.js", package = "modelStudio"), "", text, fixed = TRUE)
    text <- gsub(system.file("d3js/d3-interpolate-path.min.js", package = "modelStudio"), "", text, fixed = TRUE)
    text <- gsub(system.file("d3js/generatePlots.js", package = "modelStudio"), "", text, fixed = TRUE)
    text <- gsub(system.file("d3js/generateTooltipHtml.js", package = "modelStudio"), "", text, fixed = TRUE)
  } else if (type == "css") {
    text <- gsub(system.file("d3js/modelStudio.css", package = "modelStudio"), "", text, fixed = TRUE)
  }

  text
}

#' @noRd
#' @title calculate
#'
#' @description This function evaluates expression and returns its value.
#' It returns \code{NULL} and prints \code{warning} if an error occurred.
#' It also updates the \code{progress_bar} from the \code{progress} package.
#'
#' @param expr function
#' @param function_name string
#' @param show_info show message about what is calculated
#' @param pb progress_bar
#' @param ticks number of ticks
#'
#' @return Valid object or \code{NULL}

calculate <- function(expr, function_name, show_info = FALSE, pb = NULL, ticks = NULL) {

  if (show_info) pb$tick(ticks, tokens = list(what = function_name))

  tryCatch({
    expr
    },
    error = function(e) {
      warning(paste0("\nError occurred in ", function_name, " function: ", e$message))
      NULL
  })
}

# returns the vector of logical: TRUE for variables identical with the target
is_y_in_data <- function(data, y) {
  apply(data, 2, function(x) {
    all(as.character(x) == as.character(y))
  })
}

# check for numeric columns (works for data.frame AND matrix)
# sapply, lapply doesnt work for matrix and apply doesnt work for data.frame
which_variables_are_numeric <- function(data) {
  if (is.matrix(data)) {
    apply(data[,, drop = FALSE], 2, is.numeric)
  } else {
    sapply(data[,, drop = FALSE], is.numeric)
  }
}
