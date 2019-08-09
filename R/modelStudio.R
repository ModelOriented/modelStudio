#' @title Generates interactive studio to explain your predictive model
#'
#' @description
#' This tool uses your model, data and new observations, to provide local
#' and global explanations. It generates plots and descriptions in the form
#' of serverless HTML site, that supports animations and interactivity made with D3.js.
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
#' @return an object of the \code{r2d3} class
#'
#' @importFrom utils head tail setTxtProgressBar txtProgressBar
#' @importFrom stats aggregate predict
#' @importFrom grDevices nclass.Sturges
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
#' # ex1 classification
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
#' new_observations <- titanic_small[1:4,-6]
#' rownames(new_observations) <- c("Lucas","James", "Thomas", "Nancy")
#'
#' modelStudio(explain_titanic_glm, new_observations,
#'             facet_dim = c(2,3), N = 100, B = 15, time = 0)
#'
#'
#' # ex2 regression
#'
#' model_apartments <- glm(m2.price ~. ,
#'                         data = apartments)
#'
#' explain_apartments <- explain(model_apartments,
#'                               data = apartments[,-1],
#'                               y = apartments[,1])
#'
#' new_apartments <- apartments[1:2, -1]
#' rownames(new_apartments) <- c("ap1","ap2")
#'
#' modelStudio(explain_apartments, new_apartments,
#'             N = 100, B = 15)
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

  if (is.null(label)) label <- class(x)[1]

  ## safeguard
  new_observation <- as.data.frame(new_observation)
  data <- as.data.frame(data)

  ## get proper names of features that arent target
  is_y <- sapply(data, function(x) identical(x, y))
  variable_names <- intersect(names(is_y == FALSE), colnames(new_observation))
  ## get rid of target in data
  data <- data[is_y == FALSE]


  obs_count <- dim(new_observation)[1]
  obs_data <- new_observation
  obs_list <- list()

  ## later update progress bar after all explanation functions
  pb <- txtProgressBar(0, obs_count + 5, style = 3)

  ## count only once
  fi <- ingredients::feature_importance(
        x, data, y, predict_function, variables = variable_names)
  setTxtProgressBar(pb, 1)

  which_numerical <- sapply(data[,, drop = FALSE], is.numeric)

  ## because only_numerical throws errors if used incorectly
  if (all(which_numerical==TRUE)) {
    pd_n <- ingredients::partial_dependency(
            x, data, predict_function, only_numerical = TRUE, N = N)
    setTxtProgressBar(pb, 2)
    pd_c <- NULL
    ad_n <- ingredients::accumulated_dependency(
            x, data, predict_function, only_numerical = TRUE, N = N)
    setTxtProgressBar(pb, 4)
    ad_c <- NULL
  } else if (all(which_numerical==FALSE)) {
    pd_n <- NULL
    pd_c <- ingredients::partial_dependency(
            x, data, predict_function, only_numerical = FALSE, N = N)
    setTxtProgressBar(pb, 3)
    ad_n <- NULL
    ad_c <- ingredients::accumulated_dependency(
            x, data, predict_function, only_numerical = FALSE, N = N)
    setTxtProgressBar(pb, 5)
  } else {
    pd_n <- ingredients::partial_dependency(
            x, data, predict_function, only_numerical = TRUE, N = N)
    setTxtProgressBar(pb, 2)
    pd_c <- ingredients::partial_dependency(
            x, data, predict_function, only_numerical = FALSE, N = N)
    setTxtProgressBar(pb, 3)
    ad_n <- ingredients::accumulated_dependency(
            x, data, predict_function, only_numerical = TRUE, N = N)
    setTxtProgressBar(pb, 4)
    ad_c <- ingredients::accumulated_dependency(
            x, data, predict_function, only_numerical = FALSE, N = N)
    setTxtProgressBar(pb, 5)
  }

  fi_data <- prepareFeatureImportance(fi, max_features)
  pd_data <- preparePartialDependency(pd_n, pd_c, variables = variable_names)
  ad_data <- prepareAccumulatedDependency(ad_n, ad_c, variables = variable_names)
  fd_data <- prepareFeatureDistribution(data, variables = variable_names)

  ## count once per observation
  for(i in 1:obs_count){
    new_observation <- obs_data[i,]

    bd <- iBreakDown::local_attributions(
          x, data, predict_function, new_observation, label = label)
    sv <- iBreakDown::shap(
          x, data, predict_function, new_observation, label = label, B = B)
    cp <- ingredients::ceteris_paribus(
          x, data, predict_function, new_observation, label = label)
    setTxtProgressBar(pb, 5+i)

    bd_data <- prepareBreakDown(bd, max_features)
    sv_data <- prepareShapleyValues(sv, max_features)
    cp_data <- prepareCeterisParibus(cp, variables = variable_names)

    obs_list[[i]] <- list(bd_data, cp_data, sv_data)
  }

  names(obs_list) <- rownames(obs_data)

  ## later for user to define options
  options <- list(time = time,
                  size = 2, alpha = 1, bar_width = 16,
                  bd_title = "Break Down",
                  sv_title = "Shapley Values",
                  cp_title = "Ceteris Paribus",
                  fi_title = "Feature Importance",
                  pd_title = "Partial Dependency",
                  ad_title = "Accumulated Dependency",
                  fd_title = "Feature Distribution",
                  model_name = label, variable_names = variable_names,
                  show_rugs = TRUE, facet_dim = facet_dim)

  temp <- jsonlite::toJSON(list(obs_list, fi_data, pd_data, ad_data, fd_data))

  sizing_policy <- r2d3::sizingPolicy(padding = 10, browser.fill = TRUE)

  model_studio <- r2d3::r2d3(
                    data = temp,
                    script = system.file("d3js/modelStudio.js", package = "dime"),
                    dependencies = list(
                      system.file("d3js/hackHead.js", package = "dime"),
                      system.file("d3js/myTools.js", package = "dime"),
                      system.file("d3js/d3-tip.js", package = "dime"),
                      system.file("d3js/d3-slider.js", package = "dime"),
                      system.file("d3js/generatePlots.js", package = "dime"),
                      system.file("d3js/generateTooltipHtml.js", package = "dime")
                    ),
                    css = system.file("d3js/modelStudio.css", package = "dime"),
                    options = options,
                    d3_version = "4",
                    viewer = "external",
                    sizing = sizing_policy
                  )

  model_studio$x$script <- remove_file_paths(model_studio$x$script, "js")
  model_studio$x$style <- remove_file_paths(model_studio$x$style, "css")

  model_studio
}

#' @noRd
#' @title remove_file_paths
#'
#' @description `r2d3`` adds comments in html file with direct file paths to dependencies.
#' This function removes them.
#'
#' @param text string
#' @param type js or css to remove other paths

remove_file_paths <- function(text, type = NULL) {

  if (is.null(type)) stop("error in remove_file_paths")

  if (type == "js") {
    text <- gsub(system.file("d3js/modelStudio.js", package = "dime"), "", text, fixed = TRUE)
    text <- gsub(system.file("d3js/hackHead.js", package = "dime"), "", text, fixed = TRUE)
    text <- gsub(system.file("d3js/myTools.js", package = "dime"), "", text, fixed = TRUE)
    text <- gsub(system.file("d3js/d3-tip.js", package = "dime"), "", text, fixed = TRUE)
    text <- gsub(system.file("d3js/d3-slider.js", package = "dime"), "", text, fixed = TRUE)
    text <- gsub(system.file("d3js/generateTooltipHtml.js", package = "dime"), "", text, fixed = TRUE)
  } else if (type == "css") {
    text <- gsub(system.file("d3js/modelStudio.css", package = "dime"), "", text, fixed = TRUE)
  }

  text
}
