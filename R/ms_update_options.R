#' @title Update the options of a modelStudio object
#'
#' @description
#' This function updates the options of a \code{\link{modelStudio}} object.
#' \strong{WARNING: Editing default options may cause unintended behavior.}
#'
#' @param object A \code{modelStudio} created with \code{modelStudio()}.
#' @param ... Options to change in the form \code{option_name = value},
#'  e.g. \code{time = 0}, \code{facet_dim = c(1,2)}.
#'
#' @return An object of the \code{r2d3, htmlwidget, modelStudio} class.
#'
#' @inheritSection ms_options Options
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
#' # update the options
#' new_ms <- ms_update_options(ms,
#'                             time = 0,
#'                             facet_dim = c(1,2),
#'                             margin_left = 150)
#' new_ms
#'
#' @export
#' @rdname ms_update_options
ms_update_options <- function(object, ...) {

  stopifnot("modelStudio" %in% class(object))

  # extract old options
  old_options <- object$x$options
  # input new options
  old_options[names(list(...))] <- list(...)
  new_options <- old_options

  # update footer text
  new_options$footer_text <- paste0("Site built with modelStudio v", packageVersion("modelStudio"),
                                    " on ", format(Sys.time(), usetz = FALSE))

  options("r2d3.shadow" = FALSE) # set this option to avoid using shadow-root

  model_studio <- r2d3::r2d3(
    data = object$x$data,
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
    elementId = object$elementId,
    width = new_options$facet_dim[2]*(new_options$w + new_options$margin_left + new_options$margin_right),
    height = 100 + new_options$facet_dim[1]*(new_options$h + new_options$margin_top + new_options$margin_bottom)
  )

  model_studio$x$script <- remove_file_paths(model_studio$x$script, "js")
  model_studio$x$style <- remove_file_paths(model_studio$x$style, "css")

  class(model_studio) <- c(class(model_studio), "modelStudio")

  model_studio
}
