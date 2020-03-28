#' @title Generate Interactive Studio for Explanatory Model Analysis
#'
#' @description
#' This function computes various (instance and dataset level) model explanations and produces an interactive,
#' customisable dashboard made with D3.js. It consists of multiple panels for plots with their short descriptions.
#' Easily save and share the dashboard with others. Tools for model exploration unite with tools for EDA
#' (Exploratory Data Analysis) to give a broad overview of the model behavior.
#'
#' Find more details about the plots in \href{https://github.com/pbiecek/ema}{Explanatory Model Analysis: Explore, Explain and Examine Predictive Models}
#'
#' @param explainer An \code{explainer} created with function \code{DALEX::explain()}.
#' @param new_observation A new observation with columns that correspond to variables used in the model.
#' @param new_observation_y True label for \code{new_observation} (optional).
#' @param facet_dim Dimensions of the grid. Default is \code{c(2,2)}.
#' @param time Time in ms. Set animation length. Default is \code{500}.
#' @param max_features Maximum number of features to be included in Break Down and Shapley Values plots. Default is \code{10}.
#' @param N Number of observations used for calculation of partial dependence profiles. Default is \code{400}.
#' @param B Number of random paths used for calculation of Shapley values. Default is \code{15}.
#' @param eda Compute EDA plots. Default is \code{TRUE}.
#' @param show_info Verbose progress on the console. Default is \code{TRUE}.
#' @param parallel Speed up the computation using \code{parallelMap::parallelMap()}.
#' See \href{https://modeloriented.github.io/modelStudio/articles/vignette_modelStudio.html#parallel-computation}{\bold{vignette}}.
#' This might interfere with showing progress using \code{show_info}.
#' @param options Customize \code{modelStudio}. See \code{\link{modelStudioOptions}} and
#' \href{https://modeloriented.github.io/modelStudio/articles/vignette_modelStudio.html#plot-options}{\bold{vignette}}.
#' @param viewer Default is \code{external} to display in an external RStudio window.
#' Use \code{browser} to display in an external browser or
#' \code{internal} to use the RStudio internal viewer pane for output.
#' @param ... Other parameters.
#'
#' @return An object of the \code{r2d3} class.
#'
#' @importFrom utils head tail setTxtProgressBar txtProgressBar packageVersion
#' @importFrom stats aggregate predict quantile IQR
#' @importFrom grDevices nclass.Sturges
#' @import progress
#'
#' @references
#'
#' \itemize{
#'   \item Wrapper for the function is implemented in \href{https://modeloriented.github.io/DALEX/}{\bold{DALEX}}
#'   \item Feature Importance, Ceteris Paribus, Partial Dependence and Accumulated Dependence plots
#' are implemented in \href{https://modeloriented.github.io/ingredients/}{\bold{ingredients}}
#'   \item Break Down and Shapley Values plots are implemented in \href{https://modeloriented.github.io/iBreakDown/}{\bold{iBreakDown}}
#' }
#'
#' @seealso
#' Python wrappers and more can be found in \href{https://modeloriented.github.io/DALEXtra/}{\bold{DALEXtra}}
#'
#' @examples
#' library("DALEX")
#' library("modelStudio")
#'
#' #:# ex1 classification on 'titanic_imputed' dataset
#'
#' # Create a model
#' model_titanic <- glm(survived ~.,
#'                      data = titanic_imputed,
#'                      family = "binomial")
#'
#' # Wrap it into an explainer
#' explainer_titanic <- explain(model_titanic,
#'                              data = titanic_imputed[,-8],
#'                              y = titanic_imputed[,8],
#'                              label = "glm",
#'                              verbose = FALSE)
#'
#' # Pick some data points
#' new_observations <- titanic_imputed[1:2,]
#' rownames(new_observations) <- c("Lucas","James")
#'
#' # Make a studio for the model
#' modelStudio(explainer_titanic, new_observations,
#'             N = 100, B = 10, show_info = FALSE)
#'
#' \donttest{
#'
#' #:# ex2 regression on 'apartments' dataset
#' library("randomForest")
#'
#' model_apartments <- randomForest(m2.price ~. ,data = apartments)
#'
#' explainer_apartments <- explain(model_apartments,
#'                                 data = apartments[,-1],
#'                                 y = apartments[,1],
#'                                 verbose = FALSE)
#'
#' new_apartments <- apartments[1:2,]
#' rownames(new_apartments) <- c("ap1","ap2")
#'
#' # change dashboard dimensions and animation length
#' modelStudio(explainer_apartments, new_apartments,
#'             facet_dim = c(2, 3), time = 800,
#'             show_info = FALSE)
#'
#' # add information about true labels
#' modelStudio(explainer_apartments, new_apartments,
#'                                 new_observation_y = apartments[1:2, 1],
#'                                 show_info = FALSE)
#'
#' # don't compute EDA plots
#' modelStudio(explainer_apartments, eda = FALSE,
#'             show_info = FALSE)
#'
#'
#' #:# ex3 xgboost model on 'HR' dataset
#' library("xgboost")
#'
#' model_matrix <- model.matrix(status == "fired" ~ . -1, HR)
#' data <- xgb.DMatrix(model_matrix, label = HR$status == "fired")
#'
#' params <- list(max_depth = 2, eta = 1, silent = 1, nthread = 2,
#'                objective = "binary:logistic", eval_metric = "auc")
#'
#' model_HR <- xgb.train(params, data, nrounds = 50)
#'
#' explainer_HR <- explain(model_HR,
#'                         data = model_matrix,
#'                         y = HR$status == "fired",
#'                         verbose = FALSE)
#'
#' modelStudio(explainer_HR, show_info = FALSE)
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
                                  N = 400,
                                  B = 15,
                                  eda = TRUE,
                                  show_info = TRUE,
                                  parallel = FALSE,
                                  options = modelStudioOptions(),
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
    new_observation <- as.data.frame(new_observation)

  } else if (is.null(rownames(new_observation))) {
    rownames(new_observation) <- 1:nrow(new_observation)
  }

  check_single_prediction <- try(predict_function(model, new_observation[1,, drop = FALSE]), silent = TRUE)
  if (class(check_single_prediction)[1] == "try-error") {
    stop("`predict_function` returns an error when executed on `new_observation[1,, drop = FALSE]` \n")
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
      total = (2*B + 8 + 1)*obs_count + (4*B + 3*B + B) + 1,
      show_after = 0
    )
    pb$tick(0, tokens = list(what = "..."))
  }

  ## count only once
  fi <- calculate(
    ingredients::feature_importance(
        model, data, y, predict_function, variables = variable_names, B = B),
    "ingredients::feature_importance", show_info, pb, 4*B)

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
        paste0("iBreakDown::local_attributions (", i, ")"), show_info, pb, 8)
      sv <- calculate(
        iBreakDown::shap(
          model, data, predict_function, new_observation, label = label, B = B),
        paste0("iBreakDown::shap (", i, ")"), show_info, pb, 2*B)
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
        paste0("iBreakDown::local_attributions (", i, ")"), show_info, pb, 8)
      sv <- calculate(
        iBreakDown::shap(
          model, data, predict_function, new_observation, label = label, B = B),
        paste0("iBreakDown::shap (", i, ")"), show_info, pb, 2*B)
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
  temp <- jsonlite::toJSON(list(obs_list, fi_data, pd_data, ad_data, fd_data, at_data))
  widget_id <- paste0("widget-", digest::digest(temp))

  # prepare observation data for drop down
  between <- " - "
  if (is.null(new_observation_y)) new_observation_y <- between <- ""
  drop_down_data <- as.data.frame(cbind(rownames(obs_data),
                                        paste0(rownames(obs_data), between, new_observation_y)))
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

  model_studio
}

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
      warning(paste0("Error occurred in ", function_name, " function: ", e$message))
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
