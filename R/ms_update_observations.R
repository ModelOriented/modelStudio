#' @title Update the observations of a modelStudio object
#'
#' @description
#' This function calculates local explanations on new observations and adds them
#' to the \code{modelStudio} object.
#'
#' @param object A \code{modelStudio} created with \code{modelStudio()}.
#' @param explainer An \code{explainer} created with \code{DALEX::explain()}.
#' @param new_observation New observations with columns that correspond to variables used in the model.
#' @param new_observation_y True label for \code{new_observation} (optional).
#' @param max_features Maximum number of features to be included in BD and SV plots.
#'  Default is \code{10}.
#' @param B Number of permutation rounds used for calculation of SV and FI.
#'  Default is \code{10}.
#'  See \href{https://modelstudio.drwhy.ai/articles/ms-perks-features.html#more-calculations-means-more-time}{\bold{vignette}}
#' @param show_info Verbose a progress on the console. Default is \code{TRUE}.
#' @param parallel Speed up the computation using \code{parallelMap::parallelMap()}.
#'  See \href{https://modelstudio.drwhy.ai/articles/ms-perks-features.html#parallel-computation}{\bold{vignette}}.
#'  This might interfere with showing progress using \code{show_info}.
#' @param widget_id Use an explicit element ID for the widget (rather than an automatically generated one).
#'  Useful e.g. when using \code{modelStudio} with Shiny.
#'  See \href{https://modelstudio.drwhy.ai/articles/ms-perks-features.html#shiny-1}{\bold{vignette}}.
#' @param overwrite Overwrite existing observations and their explanations.
#'  Default is \code{FALSE} which means add new observations to the existing ones.
#' @param ... Other parameters.
#'
#' @return An object of the \code{r2d3, htmlwidget, modelStudio} class.
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
#' # fit a model
#' model_titanic <- glm(survived ~., data = titanic_imputed, family = "binomial")
#'
#' # create an explainer for the model
#' explainer_titanic <- explain(model_titanic,
#'                              data = titanic_imputed,
#'                              y = titanic_imputed$survived)
#'
#' # make a studio for the model
#' ms <- modelStudio(explainer_titanic,
#'                   N = 200,  B = 5) # faster example
#'
#' \donttest{
#'
#' # add new observations
#' ms <- ms_update_observations(ms,
#'                              explainer_titanic,
#'                              new_observation = titanic_imputed[100:101,],
#'                              new_observation_y = titanic_imputed$survived[100:101])
#' ms
#'
#'
#'
#' # overwrite the observations with new ones
#' ms <- ms_update_observations(ms,
#'                              explainer_titanic,
#'                              new_observation = titanic_imputed[100:101,],
#'                              overwrite = TRUE)
#' ms
#'
#' }
#'
#' @export
#' @rdname ms_update_observations
ms_update_observations <- function(object,
                                   explainer,
                                   new_observation = NULL,
                                   new_observation_y = NULL,
                                   max_features = 10,
                                   B = 10,
                                   show_info = TRUE,
                                   parallel = FALSE,
                                   widget_id = NULL,
                                   overwrite = FALSE,
                                   ...) {

  stopifnot("modelStudio" %in% class(object))
  stopifnot("explainer" %in% class(explainer))

  model <- explainer$model
  data <- explainer$data
  y <- explainer$y
  predict_function <- explainer$predict_function
  label <- explainer$label

  # extract old options
  options <- object$x$options

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
      total = (3*B + 2 + 1)*obs_count,
      show_after = 0
    )
    pb$tick(0, tokens = list(what = "..."))
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

  names(obs_list) <- rownames(obs_data)

  #:# prepare new observation data for drop down
  between <- " - "
  if (is.null(new_observation_y)) new_observation_y <- between <- ""
  drop_down_data <- as.data.frame(cbind(rownames(obs_data),
                                        paste0(rownames(obs_data), between, new_observation_y)))
  colnames(drop_down_data) <- c("id", "text")

  #:# extract old data
  old_data <- jsonlite::fromJSON(object$x$data, simplifyVector = FALSE)

  if (!overwrite) {
    #:# extract old drop down and merge with new one
    old_drop_down_data <- jsonlite::fromJSON(options$drop_down_data,
                                             simplifyVector = FALSE, simplifyDataFrame = TRUE)
    drop_down_data <- rbind(old_drop_down_data, drop_down_data)

    #:# update new data
    obs_list <- c(old_data[[1]], obs_list)
    if (length(unique(names(obs_list))) != length(obs_list)) {
      warning("new_observation ids overlap with existing data, using unique ids")
      obs_list <- obs_list[unique(names(obs_list))]
      drop_down_data <- drop_down_data[!duplicated(drop_down_data$id),]
    }
  }

  #:# input new data
  temp <- jsonlite::toJSON(list(obs_list, old_data[[2]], old_data[[3]],
                                old_data[[4]], old_data[[5]], old_data[[6]]),
                           auto_unbox = TRUE)
  widget_id <- ifelse(!is.null(widget_id),
                      widget_id,
                      paste0("widget-", digest::digest(temp)))

  #:# extract old options and update them
  new_options <- options
  new_options$widget_id <- widget_id
  new_options$variable_names <- variable_names
  new_options$footer_text <- paste0("Site built with modelStudio v",
                                    as.character(packageVersion("modelStudio")),
                                    " on ",
                                    format(Sys.time(), usetz = FALSE))
  new_options$drop_down_data <-  jsonlite::toJSON(drop_down_data)

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
    options = new_options,
    d3_version = "4",
    sizing = object$sizingPolicy,
    elementId = widget_id,
    width = new_options$facet_dim[2]*(new_options$w + new_options$margin_left + new_options$margin_right),
    height = 100 + new_options$facet_dim[1]*(new_options$h + new_options$margin_top + new_options$margin_bottom)
  )

  model_studio$x$script <- remove_file_paths(model_studio$x$script, "js")
  model_studio$x$style <- remove_file_paths(model_studio$x$style, "css")

  class(model_studio) <- c(class(model_studio), "modelStudio")

  model_studio
}
