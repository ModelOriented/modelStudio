#' @title Interactive Studio for Explanatory Model Analysis
#'
#' @description
#' This function computes various (instance and dataset level) model explanations and
#' produces a customisable dashboard, which consists of multiple panels for plots with their
#' short descriptions. Easily save the dashboard and share it with others. Tools for
#' \href{https://ema.drwhy.ai/}{Explanatory Model Analysis} unite with tools for
#' Exploratory Data Analysis to give a broad overview of the model behavior.
#'
#' The extensive documentation covers:
#'
#' \itemize{
#'   \item Function parameters description -
#'  \href{https://modelstudio.drwhy.ai/articles/ms-perks-features.html}{\bold{perks and features}}
#'   \item Framework and model compatibility -
#'  \href{https://modelstudio.drwhy.ai/articles/ms-r-python-examples.html}{\bold{R & Python examples}}
#'   \item Theoretical introduction to the plots -
#'  \href{https://ema.drwhy.ai/}{Explanatory Model Analysis: Explore, Explain, and Examine Predictive Models}
#' }
#'
#' Displayed variable can be changed by clicking on the bars of plots or with the first dropdown list,
#'  and observation can be changed with the second dropdown list.
#' The dashboard gathers useful, but not sensitive, information about how it is being used (e.g. computation length,
#'  package version, dashboard dimensions). This is for the development purposes only and can be blocked
#'  by setting \code{telemetry} to \code{FALSE}.
#'
#' @param explainer An \code{explainer} created with \code{DALEX::explain()}.
#' @param new_observation New observations with columns that correspond to variables used in the model.
#' @param new_observation_y True label for \code{new_observation} (optional).
#' @param new_observation_n Number of observations to be taken from the \code{explainer$data} if \code{new_observation = NULL}.
#'  See \href{https://modelstudio.drwhy.ai/articles/ms-perks-features.html#instance-explanations}{\bold{vignette}}
#' @param facet_dim Dimensions of the grid. Default is \code{c(2,2)}.
#' @param time Time in ms. Set the animation length. Default is \code{500}.
#' @param max_features Maximum number of features to be included in BD, SV, and FI plots.
#'  Default is \code{10}.
#' @param max_features_fi Maximum number of features to be included in FI plot. Default is \code{max_features}.
#' @param max_vars An alias for \code{max_features}. If provided, it will override the value.
#' @param N Number of observations used for the calculation of PD and AD. Default is \code{300}.
#'  See \href{https://modelstudio.drwhy.ai/articles/ms-perks-features.html#more-calculations-means-more-time}{\bold{vignette}}
#' @param N_fi Number of observations used for the calculation of FI. Default is \code{10*N}.
#' @param N_sv Number of observations used for the calculation of SV. Default is \code{3*N}.
#' @param B Number of permutation rounds used for calculation of SV. Default is \code{10}.
#'  See \href{https://modelstudio.drwhy.ai/articles/ms-perks-features.html#more-calculations-means-more-time}{\bold{vignette}}
#' @param B_fi Number of permutation rounds used for calculation of FI. Default is \code{B}.
#' @param open_plots A vector listing plots to be initially opened (and on which positions). Default is \code{c("fi")}.
#' @param eda Compute EDA plots and Residuals vs Feature plot, which adds the data to the dashboard. Default is \code{TRUE}.
#' @param show_info Verbose a progress on the console. Default is \code{TRUE}.
#' @param verbose An alias for \code{show_info}. If provided, it will override the value.
#' @param parallel Speed up the computation using \code{parallelMap::parallelMap()}.
#'  See \href{https://modelstudio.drwhy.ai/articles/ms-perks-features.html#parallel-computation}{\bold{vignette}}.
#'  This might interfere with showing progress using \code{show_info}.
#' @param options Customize \code{modelStudio}. See \code{\link{ms_options}} and
#'  \href{https://modelstudio.drwhy.ai/articles/ms-perks-features.html#additional-options-1}{\bold{vignette}}.
#' @param viewer Default is \code{external} to display in an external RStudio window.
#'  Use \code{browser} to display in an external browser or
#'  \code{internal} to use the RStudio internal viewer pane for output.
#' @param widget_id Use an explicit element ID for the widget (rather than an automatically generated one).
#'  Useful e.g. when using \code{modelStudio} with Shiny.
#'  See \href{https://modelstudio.drwhy.ai/articles/ms-perks-features.html#shiny-1}{\bold{vignette}}.
#' @param license Path to the file containing the license (\code{con} parameter passed to \code{readLines()}).
#'  It can be used e.g. to include the license for \code{explainer$data} as a comment in the source of \code{.html} output file.
#' @param telemetry The dashboard gathers useful, but not sensitive, information about how it is being used (e.g. computation length,
#'  package version, dashboard dimensions). This is for the development purposes only and can be blocked by setting \code{telemetry} to \code{FALSE}.
#' @param ... Other parameters.
#'
#' @return An object of the \code{r2d3, htmlwidget, modelStudio} class.
#'
#' @importFrom utils head tail packageVersion
#' @importFrom stats aggregate predict quantile IQR na.omit median
#' @importFrom grDevices nclass.Sturges
#' @import progress
#'
#' @references
#'
#' \itemize{
#'   \item The input object is implemented in \href{https://modeloriented.github.io/DALEX/}{\bold{DALEX}}
#'   \item Feature Importance, Ceteris Paribus, Partial Dependence and Accumulated Dependence explanations
#'    are implemented in \href{https://modeloriented.github.io/ingredients/}{\bold{ingredients}}
#'   \item Break Down and Shapley Values explanations are implemented in
#'    \href{https://modeloriented.github.io/iBreakDown/}{\bold{iBreakDown}}
#' }
#'
#' @seealso
#' Vignettes: \href{https://modelstudio.drwhy.ai/articles/ms-r-python-examples.html}{\bold{modelStudio - R & Python examples}}
#' and \href{https://modelstudio.drwhy.ai/articles/ms-perks-features.html}{\bold{modelStudio - perks and features}}
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
#'             new_observations,
#'             N = 200,  B = 5) # faster example
#'
#' \donttest{
#'
#' #:# ex2 regression on 'apartments' data
#' if (requireNamespace("ranger", quietly=TRUE)) {
#'   library("ranger")
#'   model_apartments <- ranger(m2.price ~. ,data = apartments)
#'
#'   explainer_apartments <- explain(model_apartments,
#'                                   data = apartments,
#'                                   y = apartments$m2.price)
#'
#'   new_apartments <- apartments[1:2,]
#'   rownames(new_apartments) <- c("ap1","ap2")
#'
#'   # change dashboard dimensions and animation length
#'   modelStudio(explainer_apartments,
#'               new_apartments,
#'               facet_dim = c(2, 3),
#'               time = 800)
#'
#'   # add information about true labels
#'   modelStudio(explainer_apartments,
#'               new_apartments,
#'               new_observation_y = new_apartments$m2.price)
#'
#'   # don't compute EDA plots
#'   modelStudio(explainer_apartments,
#'               eda = FALSE)
#' }
#'
#' #:# ex3 xgboost model on 'HR' dataset
#' if (requireNamespace("xgboost", quietly=TRUE)) {
#'   library("xgboost")
#'   HR_matrix <- model.matrix(status == "fired" ~ . -1, HR)
#'
#'   # fit a model
#'   xgb_matrix <- xgb.DMatrix(HR_matrix, label = HR$status == "fired")
#'   params <- list(max_depth = 3, objective = "binary:logistic", eval_metric = "auc")
#'   model_HR <- xgb.train(params, xgb_matrix, nrounds = 300)
#'
#'   # create an explainer for the model
#'   explainer_HR <- explain(model_HR,
#'                           data = HR_matrix,
#'                           y = HR$status == "fired",
#'                           type = "classification",
#'                           label = "xgboost")
#'
#'   # pick observations
#'   new_observation <- HR_matrix[1:2, , drop=FALSE]
#'   rownames(new_observation) <- c("id1", "id2")
#'
#'   # make a studio for the model
#'   modelStudio(explainer_HR,
#'               new_observation)
#' }
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
                                  new_observation_n = 3,
                                  facet_dim = c(2,2),
                                  time = 500,
                                  max_features = 10,
                                  max_features_fi = NULL,
                                  N = 300,
                                  N_fi = N*10,
                                  N_sv = N*3,
                                  B = 10,
                                  B_fi = B,
                                  eda = TRUE,
                                  open_plots = c("fi"),
                                  show_info = TRUE,
                                  parallel = FALSE,
                                  options = ms_options(),
                                  viewer = "external",
                                  widget_id = NULL,
                                  license = NULL,
                                  telemetry = TRUE,
                                  max_vars = NULL,
                                  verbose = NULL,
                                  ...) {

  start_time <- Sys.time()

  #:# checks
  explainer <- check_explainer(explainer)

  model <- explainer$model
  data <- explainer$data
  y <- explainer$y
  predict_function <- explainer$predict_function
  label <- explainer$label
  model_type <- explainer$model_info$type

  if (!is.null(max_vars)) max_features <- max_vars
  if (is.null(max_features_fi)) max_features_fi <- max_features
  if (!is.null(verbose)) show_info <- verbose
  if (is.null(N)) stop("`N` argument must be an integer")
  if (length(open_plots) > prod(facet_dim)) 
    stop(paste0("`open_plots` is of length larger than defined by `facet_dim` dimensions.",
                "Increase `facet_dim` or shorten `open_plots`."))
  available_plots <- c('bd', 'sv', 'cp', 'fi', 'pd', 'ad', 'rv', 'fd', 'tv', 'at')
  if (!all(open_plots %in% c(available_plots, toupper(available_plots))))
    stop(paste0("`open_plots` must be a vector with the following values: 'bd',",
                " 'sv', 'cp', 'fi', 'pd', 'ad', 'rv', 'fd', 'tv', 'at'."))
  open_plots <- toupper(open_plots)
  #if (identical(N_fi, numeric(0))) N_fi <- NULL

  if (is.null(new_observation)) {
    if (show_info) message(paste0("`new_observation` argument is NULL. ",
                                  "`new_observation_n` observations needed to ",
                                  "calculate local explanations are taken from the data.\n"))
    ret <- sample_new_observation(explainer, new_observation_n)
    new_observation <- ret[['no']]
    new_observation_y <- ret[['no_y']]

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

  #:# keyword arguments

  kwargs <- list(...)
  kwargs_names <- names(list(...))

  if ('loss_function' %in% kwargs_names) {
    loss_function <- kwargs[['loss_function']]
  } else if (is.null(explainer$model_info$type)) {
    if (is_binary(y)) {
      loss_function <- DALEX::loss_one_minus_auc
    } else {
      loss_function <- DALEX::loss_root_mean_square
    }
  } else {
    # suppress a warning coming from DALEX v2.5.0
    loss_function <- suppressWarnings(DALEX::loss_default(explainer$model_info$type))
  }

  variable_splits_type <- ifelse('variable_splits_type' %in% kwargs_names,
                                 kwargs[['variable_splits_type']],
                                 'uniform')
  variable_splits_with_obs <- ifelse('variable_splits_with_obs' %in% kwargs_names,
                                     kwargs[['variable_splits_with_obs']],
                                     TRUE)
  #:#

  ## get proper names of features that aren't target
  is_y <- is_y_in_data(data, y)
  potential_variable_names <- names(is_y[!is_y])
  variable_names <- intersect(potential_variable_names, colnames(new_observation))
  ## get rid of target in data
  data <- data[, !is_y, drop = FALSE]

  obs_count <- dim(new_observation)[1]
  obs_data <- new_observation
  obs_list <- list()
  
  if (!is.null(N_sv) && N_sv < nrow(data)) {
    data_sv <- data[sample(1:nrow(data), N_sv),, drop = FALSE]
  } else {
    data_sv <- data
  }

  ## later update progress bar after all explanation functions
  if (show_info) {
    increment <- ifelse(eda, 1, 0)

    pb <- progress_bar$new(
      format = "  Calculating :what \n    Elapsed time: :elapsedfull ETA::eta ", # :percent  [:bar]
      total = 1 + increment + (3*B + 2 + 1)*obs_count + (2*B_fi + N/30 + N/10) + 2,
      show_after = 0,
      width = 110
    )
    pb$tick(0, tokens = list(what = "..."))
  }

  ## count only once
  fi <- calculate(
    ingredients::feature_importance(
        model, data, y, predict_function, variables = variable_names, B = B_fi, N = N_fi,
        loss_function = loss_function
        ),
    "ingredients::feature_importance", show_info, pb, 2*B_fi)

  which_numerical <- which_variables_are_numeric(data)

  ## because aggregate_profiles calculates numerical OR categorical
  if (all(which_numerical)) {
    pd_n <- calculate(
      ingredients::partial_dependence(
          model, data, predict_function, variable_type = "numerical", N = N,
          variable_splits_type=variable_splits_type),
      "ingredients::partial_dependence (numerical)", show_info, pb, N/30)
    pd_c <- NULL
    ad_n <- calculate(
      ingredients::accumulated_dependence(
          model, data, predict_function, variable_type = "numerical", N = N,
          variable_splits_type=variable_splits_type),
      "ingredients::accumulated_dependence (numerical)", show_info, pb, N/10)
    ad_c <- NULL
  } else if (all(!which_numerical)) {
    pd_n <- NULL
    pd_c <- calculate(
      ingredients::partial_dependence(
          model, data, predict_function, variable_type = "categorical", N = N,
          variable_splits_type=variable_splits_type),
      "ingredients::partial_dependence (categorical)", show_info, pb, N/30)
    ad_n <- NULL
    ad_c <- calculate(
      ingredients::accumulated_dependence(
          model, data, predict_function, variable_type = "categorical", N = N,
          variable_splits_type=variable_splits_type),
      "ingredients::accumulated_dependence (categorical)", show_info, pb, N/10)
  } else {
    pd_n <- calculate(
      ingredients::partial_dependence(
        model, data, predict_function, variable_type = "numerical", N = N,
        variable_splits_type=variable_splits_type),
      "ingredients::partial_dependence (numerical)", show_info, pb, N/60)
    pd_c <- calculate(
      ingredients::partial_dependence(
        model, data, predict_function, variable_type = "categorical", N = N,
        variable_splits_type=variable_splits_type),
      "ingredients::partial_dependence (categorical)", show_info, pb, N/60)
    ad_n <- calculate(
      ingredients::accumulated_dependence(
        model, data, predict_function, variable_type = "numerical", N = N,
        variable_splits_type=variable_splits_type),
      "ingredients::accumulated_dependence (numerical)", show_info, pb, 2*N/30)
    ad_c <- calculate(
      ingredients::accumulated_dependence(
        model, data, predict_function, variable_type = "categorical", N = N,
        variable_splits_type=variable_splits_type),
      "ingredients::accumulated_dependence (categorical)", show_info, pb, N/30)
  }
  
  fi_data <- prepare_feature_importance(fi, max_features_fi, options$show_boxplot, ...)
  pd_data <- prepare_partial_dependence(pd_n, pd_c, variables = variable_names)
  ad_data <- prepare_accumulated_dependence(ad_n, ad_c, variables = variable_names)
  mp_ret <- calculate(
    DALEX::model_performance(explainer),
    "DALEX::model_performance", show_info, pb, 1)
  mp_data <- mp_ret$measures

  if (eda) {
    #:# fd_data is used by targetVs and residualsVs plots
    md_ret <- calculate(
      DALEX::model_diagnostics(explainer),
      "DALEX::model_diagnostics", show_info, pb, 1)
    residuals <- md_ret$residuals
    fd_data <- prepare_feature_distribution(data, y, variables = variable_names,
                                            residuals = residuals)
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
        paste0("iBreakDown::local_attributions (", i, ")      "), show_info, pb, 2)
      sv <- calculate(
        iBreakDown::shap(
          model, data_sv, predict_function, new_observation, label = label, B = B),
        paste0("iBreakDown::shap (", i, ")                    "), show_info, pb, 3*B)
      cp <- calculate(
        ingredients::ceteris_paribus(
          model, data, predict_function, new_observation, label = label,
          variable_splits_type=variable_splits_type,
          variable_splits_with_obs=variable_splits_with_obs),
        paste0("ingredients::ceteris_paribus (", i, ")        "), show_info, pb, 1)

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
        paste0("iBreakDown::local_attributions (", i, ")      "), show_info, pb, 2)
      sv <- calculate(
        iBreakDown::shap(
          model, data_sv, predict_function, new_observation, label = label, B = B),
        paste0("iBreakDown::shap (", i, ")                    "), show_info, pb, 3*B)
      cp <- calculate(
        ingredients::ceteris_paribus(
          model, data, predict_function, new_observation, label = label,
          variable_splits_type=variable_splits_type,
          variable_splits_with_obs=variable_splits_with_obs),
        paste0("ingredients::ceteris_paribus (", i, ")        "), show_info, pb, 1)

      bd_data <- prepare_break_down(bd, max_features, ...)
      sv_data <- prepare_shapley_values(sv, max_features, options$show_boxplot, ...)
      cp_data <- prepare_ceteris_paribus(cp, variables = variable_names)

      obs_list[[i]] <- list(bd_data, cp_data, sv_data)
    }
  }

  # pack explanation data to json and make hash for htmlwidget
  names(obs_list) <- rownames(obs_data)
  temp <- jsonlite::toJSON(list(obs_list, fi_data, pd_data, ad_data, fd_data, at_data), auto_unbox = TRUE)
  widget_id <- ifelse(!is.null(widget_id),
                      widget_id,
                      paste0("widget-", digest::digest(temp)))

  # prepare observation data for drop down
  str_between <- " | y: "
  str_before <- "id: "
  if (is.null(new_observation_y)) new_observation_y <- str_between <- str_before <- ""
  drop_down_data <- as.data.frame(
    cbind(rownames(obs_data),
    paste0(str_before, rownames(obs_data), str_between, new_observation_y)),
    stringsAsFactors=TRUE)
  colnames(drop_down_data) <- c("id", "text")

  # prepare footer text and ms title
  ms_package_version <- as.character(packageVersion("modelStudio"))
  ms_creation_date <- Sys.time()
  version_text <- paste0("Site built with modelStudio v",
                         ms_package_version,
                         " on ",
                         format(ms_creation_date, usetz = FALSE))
  measure_text <- paste(names(mp_data),
                        round(unlist(mp_data), 3),
                        sep = ": ", collapse=" | ")

  if (telemetry) {
    creation_time <- as.character(as.integer(as.numeric(ms_creation_date - start_time)*60))
    options$telemetry <- list(date = format(ms_creation_date, usetz = FALSE),
                              version = ms_package_version,
                              showcaseName = options$showcase_name,
                              creationTime = creation_time,
                              facetRow = facet_dim[1],
                              facetCol = facet_dim[2],
                              width = options$w,
                              height = options$h,
                              animationTime = time,
                              parallel = parallel,
                              N = N,
                              B = B,
                              model = class(model)[1],
                              dataSize = nrow(data),
                              varCount = length(variable_names),
                              obsCount = obs_count)
  }

  if (!is.null(license)) options$license <- paste(readLines(license), collapse=" ")
  if (is.null(options$ms_title)) options$ms_title <- paste0("Interactive Studio for ", label, " Model")
  if (!is.null(options$ms_subtitle)) options$ms_margin_top <- options$ms_margin_top + 40
  if (is.null(options$margin_left)) options$margin_left <- max(105, 7*max(nchar(variable_names)))
  if (is.null(options$fi_axis_title)) options$fi_axis_title <- 
    ifelse(is.null(attr(loss_function, "loss_name")), "drop-out loss", attr(loss_function, "loss_name"))
  
  options <- c(list(time = time,
                    model_name = label,
                    variable_names = as.list(variable_names),
                    facet_dim = facet_dim,
                    version_text = version_text,
                    measure_text = measure_text,
                    drop_down_data = jsonlite::toJSON(drop_down_data),
                    open_plots = as.list(open_plots),
                    eda = eda,
                    widget_id = widget_id,
                    is_target_binary = is_binary(y)
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
                    d3_version = "4",  # v4 is important
                    viewer = viewer,
                    sizing = sizing_policy,
                    elementId = widget_id,
                    width = facet_dim[2]*(options$w + options$margin_left + options$margin_right),
                    height = options$ms_margin_top + options$ms_margin_bottom +
                             facet_dim[1]*(options$h + options$margin_top + options$margin_bottom)
                  )

  model_studio$x$script <- remove_file_paths(model_studio$x$script, "js")
  model_studio$x$style <- remove_file_paths(model_studio$x$style, "css")

  class(model_studio) <- c(class(model_studio), "modelStudio")

  if (show_info) pb$tick(1, tokens = list(what = "..."))

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
  if (is.matrix(data)) {
    apply(data[,, drop = FALSE], 2, identical, y)
  } else {
    sapply(data[,, drop = FALSE], identical, y)
  }
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

# check for binary target
is_binary <- function(y) {
  is.numeric(y) & length(unique(y)) == 2
}

# safety check for explainer
check_explainer <- function(explainer) {

  if (is.null(explainer$data))
    stop('explainer$data is NULL - pass the `data` argument to the explain() function')
  if (is.null(explainer$y))
    stop('explainer$y is NULL - pass the `y` argument to the explain() function')
  if (!is.null(explainer$model_info$type) && explainer$model_info$type == 'multiclass')
    stop('explainer$model_info$type is multiclass - modelStudio supports regression and classification',
         ' use predict_function that returns one value per observation')
  if (is.null(rownames(explainer$data)))
    rownames(explainer$data) <- 1:nrow(explainer$data)
  if (is.null(colnames(explainer$data)))
    colnames(explainer$data) <- 1:ncol(explainer$data)

  # this check is to be removed with DALEX>=2.0.1 dependency
  if ("dalex._explainer.object.Explainer" %in% class(explainer)) {
    if (is.null(explainer$y_hat) || is.null(explainer$residuals))
      stop('For Python support, use precalculate=True in Explainer init')
    class(explainer) <- c('explainer', class(explainer))
  }
  if ("array" %in% class(explainer$y_hat) && length(dim(explainer$y_hat)) == 1)
    explainer$y_hat <- as.vector(explainer$y_hat)
  if ("array" %in% class(explainer$residuals) && length(dim(explainer$residuals)) == 1)
    explainer$residuals <- as.vector(explainer$residuals)

  explainer
}

# choose observations
sample_new_observation <- function(explainer, new_observation_n = 3) {
  if (is.null(explainer$y_hat)) {
    y_hat <- try(predict(explainer), silent = TRUE)
    if (class(y_hat)[1] == "try-error")
      stop('`predict(explainer)` returns an error')
  } else {
    y_hat <- explainer$y_hat
  }

  if (new_observation_n >= dim(explainer$data)[1]) {
    new_observation_n <- dim(explainer$data)[1]
  }

  ids <- unique(round(seq(1, length(y_hat), length.out = new_observation_n)))
  new_observation_ids <- order(y_hat)[ids]

  list(no = explainer$data[new_observation_ids,], no_y = explainer$y[new_observation_ids])
}
