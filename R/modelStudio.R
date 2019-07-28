#' @title Generate interactive studio to explain your model
#'
#' @description
#' TODO.
#'
#' @param x an explainer created with function `DALEX::explain()` or a model to be explained.
#' @param new_observation a new observation with columns that correspond to variables used in the model.
#' @param facet_dim dimensions of the grid. Default is 2x2.
#' @param max_features maximal number of features to be included in BreakDown and FeatureImportance plot.
#' @param N number of observations used for calculation of partial dependency profiles. Default is 500.
#' @param data validation dataset, will be extracted from `x` if it's an explainer.
#' @param y true labels for `data`, will be extracted from `x` if it's an explainer.
#' @param predict_function predict function, will be extracted from `x` if it's an explainer.
#' @param label a name of the model, will be extracted from `x` if it's an explainer.
#' @param ... other parameters.
#'
#' @return an object of the `r2d3` class.
#'
#' @importFrom utils head tail setTxtProgressBar txtProgressBar
#' @importFrom stats aggregate predict
#'
#' @references ingredients \url{https://modeloriented.github.io/ingredients/} iBreakDown \url{https://modeloriented.github.io/iBreakDown/}
#'
#' @examples
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
#' modelStudio(explain_titanic_glm, new_observation[1,])
#' modelStudio(explain_titanic_glm, new_observation, N = 50)
#'
#'
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
                                  ...) {

  modelStudio.default(x = x$model,
                      new_observation = new_observation,
                      facet_dim = facet_dim,
                      max_features = max_features,
                      N = N,
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
                                data,
                                y,
                                predict_function = predict,
                                label = NULL,
                                ...) {

  ## safeguard
  new_observation <- as.data.frame(new_observation)
  data <- as.data.frame(data)

  obs_count <- dim(new_observation)[1]

  if(obs_count > 10) stop("There are more than 10 observations.")

  if(is.null(label)) label <- class(x)[1]

  variable_names <- colnames(new_observation)
  obs_data <- new_observation
  obs_list <- list()

  pb <- txtProgressBar(0, obs_count, style=3)

  ## count only once
  fi <- ingredients::feature_importance(x, data, y, predict_function, ...)
  pd_n <- ingredients::partial_dependency(x, data, predict_function, only_numerical = TRUE, N = N)
  pd_c <- ingredients::partial_dependency(x, data, predict_function, only_numerical = FALSE, N = N)
  ad_n <- ingredients::accumulated_dependency(x, data, predict_function, only_numerical = TRUE, N = N)
  ad_c <- ingredients::accumulated_dependency(x, data, predict_function, only_numerical = FALSE, N = N)

  fi_data <- prepareFeatureImportance(fi, max_features, ...)
  pd_data <- preparePartialDependency(pd_n, pd_c, variables = variable_names)
  ad_data <- prepareAccumulatedDependency(ad_n, ad_c, variables = variable_names)

  ## count once per observation
  for(i in 1:obs_count){
    setTxtProgressBar(pb, i)

    new_observation <- obs_data[i,]

    bd <- iBreakDown::local_attributions(x, data, predict_function, new_observation, label=label)
    cp <- ingredients::ceteris_paribus(x, data, predict_function, new_observation, label=label)

    bd_data <- prepareBreakDown(bd, max_features, ...)
    cp_data <- prepareCeterisParibus(cp, variables = variable_names)

    obs_list[[i]] <- list(bd_data, cp_data)
  }

  names(obs_list) <- rownames(obs_data)

  options <- list(size = 2, alpha = 1, bar_width = 16,
                  cp_title = "Ceteris Paribus", bd_title = "Break Down",
                  fi_title = "Feature Importance", pd_title = "Partial Dependency",
                  ad_title = "Accumulated Dependency",
                  model_name = label, variable_names = variable_names,
                  show_rugs = TRUE, facet_dim = facet_dim)

  temp <- jsonlite::toJSON(list(obs_list, fi_data, pd_data, ad_data))

  sizing_policy <- r2d3::sizingPolicy(padding = 10, browser.fill = TRUE)

  r2d3::r2d3(
    data = temp,
    script = system.file("d3js/modelStudio.js", package = "dime"),
    dependencies = list(
      system.file("d3js/myTools.js", package = "dime"),
      system.file("d3js/tooltipD3.js", package = "dime"),
      system.file("d3js/generatePlots.js", package = "dime"),
      system.file("d3js/generateTooltipHtml.js", package = "dime")
    ),
    css = system.file("d3js/modelStudio.css", package = "dime"),
    options = options,
    d3_version = "4",
    viewer = "external",
    sizing = sizing_policy
  )
}
