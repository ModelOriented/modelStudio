#' @title Generates interactive studio to explain your predictive model
#'
#' @description
#' This tool uses your model, data and new observations, to provide local
#' and global explanations. It generates plots and descriptions in the form
#' of HTML site, that supports animations and interactivity made with D3.js.
#'
#' @param x an explainer created with function \code{DALEX::explain()} or a model to be explained.
#' @param new_observation a new observation with columns that correspond to variables used in the model.
#' @param facet_dim dimensions of the grid. Default is 2x2.
#' @param max_features maximal number of features to be included in BreakDown and FeatureImportance plot.
#' @param N number of observations used for calculation of partial dependency profiles. Default is 500.
#' @param B number of random paths used for calculation of shapley values. Default is 25.
#' @param time in ms. Set animation length. Default is 1000.
#' @param ... other parameters.
#' @param data validation dataset, will be extracted from \code{x} if it's an explainer.
#' @param y true labels for \code{data}, will be extracted from \code{x} if it's an explainer.
#' @param predict_function predict function, will be extracted from \code{x} if it's an explainer.
#' @param label a name of the model, will be extracted from \code{x} if it's an explainer.
#'
#' @return an object of the \code{r2d3} class.
#'
#' @importFrom utils head tail setTxtProgressBar txtProgressBar
#' @importFrom stats aggregate predict
#'
#' @references \bold{ingredients} \url{https://modeloriented.github.io/ingredients/}
#' \bold{iBreakDown} \url{https://modeloriented.github.io/iBreakDown/}
#'
#' @examples
#' invisible(capture.output({
#'
#' library("dime")
#' library("DALEX")
#'
#' titanic <- na.omit(titanic)
#' set.seed(1313)
#' titanic_small <- titanic[sample(1:nrow(titanic), 500), c(1,2,3,6,7,9)]
#'
#' model_titanic_glm <- glm(survived == "yes" ~ gender + age + fare + class + sibsp,
#'                          data = titanic_small, family = "binomial")
#'
#' explain_titanic_glm <- explain(model_titanic_glm,
#'                                data = titanic_small[,-6],
#'                                y = titanic_small$survived == "yes",
#'                                label = "glm")
#'
#' new_observation <- titanic_small[1:10,-6]
#'
#' modelStudio(explain_titanic_glm, new_observation[1:2,],
#'             N = 200, facet_dim = c(2,3), time = 0)
#'
#' }))
#' @export
#' @rdname modelStudio
modelStudio <- function(x, ...)
  UseMethod("modelStudio")

#' @export
#' @rdname modelStudio
modelStudio.explainer <- function(x,
                                  new_observation,
                                  facet_dim = c(2,2),
                                  max_features = 10,
                                  N = 500,
                                  B = 25,
                                  time = 1000,
                                  ...) {

  modelStudio.default(x = x$model,
                      new_observation = new_observation,
                      facet_dim = facet_dim,
                      max_features = max_features,
                      N = N,
                      B = B,
                      time = time,
                      data = x$data,
                      y = x$y,
                      predict_function = x$predict_function,
                      label = x$label,
                      ...)
}

#' @export
#' @rdname modelStudio
modelStudio.default <- function(x,
                                new_observation,
                                facet_dim = c(2,2),
                                max_features = 10,
                                N = 500,
                                B = 25,
                                time = 1000,
                                data,
                                y,
                                predict_function = predict,
                                label = NULL,
                                ...) {

  ## safeguard
  new_observation <- as.data.frame(new_observation)
  data <- as.data.frame(data)
  all_numerical <- sapply(data[,, drop = FALSE], is.numeric)

  obs_count <- dim(new_observation)[1]

  if (obs_count > 10) stop("There are more than 10 observations.")

  if (is.null(label)) label <- class(x)[1]

  variable_names <- colnames(new_observation)
  obs_data <- new_observation
  obs_list <- list()

  ## update progress bar after all functions
  pb <- txtProgressBar(0, obs_count+5, style=3)

  ## count only once
  fi <- ingredients::feature_importance(x, data, y, predict_function, ...)
  setTxtProgressBar(pb, 1)

  ## because only_numerical throws errors if used incorectly
  if (all(all_numerical==TRUE)) {
    pd_n <- ingredients::partial_dependency(x, data, predict_function, only_numerical = TRUE, N = N)
    setTxtProgressBar(pb, 2)
    pd_c <- NULL
    ad_n <- ingredients::accumulated_dependency(x, data, predict_function, only_numerical = TRUE, N = N)
    setTxtProgressBar(pb, 4)
    ad_c <- NULL
  } else if (all(all_numerical==FALSE)) {
    pd_n <- NULL
    pd_c <- ingredients::partial_dependency(x, data, predict_function, only_numerical = FALSE, N = N)
    setTxtProgressBar(pb, 3)
    ad_n <- NULL
    ad_c <- ingredients::accumulated_dependency(x, data, predict_function, only_numerical = FALSE, N = N)
    setTxtProgressBar(pb, 5)
  } else {
    pd_n <- ingredients::partial_dependency(x, data, predict_function, only_numerical = TRUE, N = N)
    setTxtProgressBar(pb, 2)
    pd_c <- ingredients::partial_dependency(x, data, predict_function, only_numerical = FALSE, N = N)
    setTxtProgressBar(pb, 3)
    ad_n <- ingredients::accumulated_dependency(x, data, predict_function, only_numerical = TRUE, N = N)
    setTxtProgressBar(pb, 4)
    ad_c <- ingredients::accumulated_dependency(x, data, predict_function, only_numerical = FALSE, N = N)
    setTxtProgressBar(pb, 5)
  }

  fi_data <- prepareFeatureImportance(fi, max_features)
  pd_data <- preparePartialDependency(pd_n, pd_c, variables = variable_names)
  ad_data <- prepareAccumulatedDependency(ad_n, ad_c, variables = variable_names)
  fd_data <- prepareFeatureDistribution(data, variables = variable_names)

  ## count once per observation
  for(i in 1:obs_count){
    new_observation <- obs_data[i,]

    bd <- iBreakDown::local_attributions(x, data, predict_function, new_observation, label=label)
    sv <- iBreakDown::shap(x, data, predict_function, new_observation, label=label, B = B)
    cp <- ingredients::ceteris_paribus(x, data, predict_function, new_observation, label=label)
    setTxtProgressBar(pb, i+5)

    bd_data <- prepareBreakDown(bd, max_features)
    sv_data <- prepareShapleyValues(sv, max_features)
    cp_data <- prepareCeterisParibus(cp, variables = variable_names)

    obs_list[[i]] <- list(bd_data, cp_data, sv_data)
  }

  names(obs_list) <- rownames(obs_data)

  ## later for user to define options
  options <- list(time = time,
                  size = 2, alpha = 1, bar_width = 16,
                  bd_title = "Break Down", sv_title = "Shapley Values",
                  cp_title = "Ceteris Paribus", fi_title = "Feature Importance",
                  pd_title = "Partial Dependency", ad_title = "Accumulated Dependency",
                  fd_title = "Feature Distribution",
                  model_name = label, variable_names = variable_names,
                  show_rugs = TRUE, facet_dim = facet_dim)

  temp <- jsonlite::toJSON(list(obs_list, fi_data, pd_data, ad_data, fd_data))

  sizing_policy <- r2d3::sizingPolicy(padding = 10, browser.fill = TRUE)

  ret <- r2d3::r2d3(
          data = temp,
          script = system.file("d3js/modelStudio.js", package = "dime"),
          dependencies = list(
            "d3-jetpack",
            system.file("d3js/myTools.js", package = "dime"),
            system.file("d3js/tooltipD3.js", package = "dime"),
            system.file("d3js/sliderD3.js", package = "dime"),
            system.file("d3js/generatePlots.js", package = "dime"),
            system.file("d3js/generateTooltipHtml.js", package = "dime")
          ),
          css = system.file("d3js/modelStudio.css", package = "dime"),
          options = options,
          d3_version = "4",
          viewer = "external",
          sizing = sizing_policy
        )
  ret$dependencies <- rev(ret$dependencies)
  ret
}
