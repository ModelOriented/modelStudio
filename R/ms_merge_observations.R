#' @title Merge the observations of modelStudio objects
#'
#' @description
#' This function merges local explanations from multiple \code{modelStudio} objects into one.
#'
#' @param ... \code{modelStudio} objects created with \code{modelStudio()}.
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
#' \donttest{
#' library("DALEX")
#' library("modelStudio")
#' 
#' # fit a model
#' model_happiness <- glm(score ~., data = happiness_train)
#' 
#' # create an explainer for the model
#' explainer_happiness <- explain(model_happiness,
#'                                data = happiness_test,
#'                                y = happiness_test$score)
#' 
#' # make studios for the model
#' ms1 <- modelStudio(explainer_happiness,
#'                    N = 200,  B = 5)
#' 
#' ms2 <- modelStudio(explainer_happiness,
#'                    new_observation = head(happiness_test, 3),
#'                    N = 200,  B = 5)
#' 
#' # merge 
#' ms <- ms_merge_observations(ms1, ms2)
#' ms
#' }
#'
#' @export
#' @rdname ms_merge_observations
ms_merge_observations <- function(...) {
  
  #:# extract data
  obs_list <- list()
  var_list <- list()
  dropdown_df <- list()
  for (object in list(...)) {
    stopifnot("modelStudio" %in% class(object))
    temp <- jsonlite::fromJSON(object$x$data, simplifyVector = FALSE)
    obs_list <- c(obs_list, temp[[1]])
    var_list <- c(var_list, object$x$options$variable_names)
    dropdown_df <- rbind(
      dropdown_df,
      jsonlite::fromJSON(object$x$options$drop_down_data,
                         simplifyVector = FALSE,
                         simplifyDataFrame = TRUE)
    )
  }
  
  #:# create new data
  temp <- jsonlite::toJSON(list(obs_list, temp[[2]], temp[[3]],
                                temp[[4]], temp[[5]], temp[[6]]),
                           auto_unbox = TRUE)
  widget_id <- paste0("widget-", digest::digest(temp))
  
  #:# extract old options and update them
  new_options <- object$x$options
  new_options$widget_id <- widget_id
  new_options$variable_names <- unique(var_list)
  new_options$footer_text <- paste0("Site built with modelStudio v",
                                    as.character(packageVersion("modelStudio")),
                                    " on ",
                                    format(Sys.time(), usetz = FALSE))
  new_options$drop_down_data <- jsonlite::toJSON(dropdown_df)
  
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
