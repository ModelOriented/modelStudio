#' @title Modify default options and pass them to modelStudio
#'
#' @description
#' This function returns default options for \code{\link{modelStudio}}.
#' It is possible to modify values of this list and pass it to the \code{options}
#' parameter in the main function. \strong{WARNING: Editing default options may cause
#' unintended behavior.}
#'
#' @param ... Options to change in the form \code{option_name = value}.
#'
#' @return \code{list} of options for \code{modelStudio}.
#'
#' @section Options:
#' \subsection{Main options:}{
#' \describe{
#' \item{scale_plot}{\code{TRUE} Makes every plot the same height, ignores \code{bar_width}.}
#' \item{show_boxplot}{\code{TRUE} Display boxplots in Feature Importance and Shapley Values plots.}
#' \item{show_subtitle}{\code{TRUE} Should the subtitle be displayed?}
#' \item{subtitle}{\code{label} parameter from \code{explainer}.}
#' \item{ms_title}{Title of the dashboard.}
#' \item{ms_subtitle}{Subtitle of the dashboard (makes space between the title and line).}
#' \item{ms_margin_*}{Dashboard margins. Change \code{margin_top} for more \code{ms_subtitle} space.}
#' \item{margin_*}{Plot margins. Change \code{margin_left} for longer/shorter axis labels.}
#' \item{w}{\code{420} in px. Inner plot width.}
#' \item{h}{\code{280} in px. Inner plot height.}
#' \item{bar_width}{\code{16} in px. Default width of bars for all plots,
#' ignored when \code{scale_plot = TRUE}.}
#' \item{line_size}{\code{2} in px. Default width of lines for all plots.}
#' \item{point_size}{\code{3} in px. Default point radius for all plots.}
#' \item{[bar,line,point]_color}{\code{[#46bac2,#46bac2,#371ea3]}}
#' \item{positive_color}{\code{#8bdcbe} for Break Down and Shapley Values bars.}
#' \item{negative_color}{\code{#f05a71} for Break Down and Shapley Values bars.}
#' \item{default_color}{\code{#371ea3} for Break Down bar and highlighted line.}
#' }
#' }
#' \subsection{Plot-specific options:}{
#' \code{**} is a two letter code unique to each plot, might be
#' one of \code{[bd,sv,cp,fi,pd,ad,rv,fd,tv,at]}.\cr
#'
#' \describe{
#' \item{**_title}{Plot-specific title. Default varies.}
#' \item{**_subtitle}{Plot-specific subtitle. Default is \code{subtitle}.}
#' \item{**_axis_title}{Plot-specific axis title. Default varies.}
#' \item{**_bar_width}{Plot-specific width of bars. Default is \code{bar_width},
#' ignored when \code{scale_plot = TRUE}.}
#' \item{**_line_size}{Plot-specific width of lines. Default is \code{line_size}.}
#' \item{**_point_size}{Plot-specific point radius. Default is \code{point_size}.}
#' \item{**_*_color}{Plot-specific \code{[bar,line,point]} color. Default is \code{[bar,line,point]_color}.}
#' }
#' }
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
#' model_apartments <- glm(m2.price ~. , data = apartments)
#'
#' # create an explainer for the model
#' explainer_apartments <- explain(model_apartments,
#'                                 data = apartments,
#'                                 y = apartments$m2.price)
#'
#' # pick observations
#' new_observation <- apartments[1:2,]
#' rownames(new_observation) <- c("ap1","ap2")
#'
#' # modify default options
#' new_options <- ms_options(
#'   show_subtitle = TRUE,
#'   bd_subtitle = "Hello World",
#'   line_size = 5,
#'   point_size = 9,
#'   line_color = "pink",
#'   point_color = "purple",
#'   bd_positive_color = "yellow",
#'   bd_negative_color = "orange"
#' )
#'
#' # make a studio for the model
#' modelStudio(explainer_apartments,
#'             new_observation,
#'             options = new_options,
#'             N = 200,  B = 5) # faster example
#'
#' @export
#' @rdname ms_options
ms_options <- function(...) {

  # prepare default options
  default_options <- list(
    scale_plot = TRUE,
    show_boxplot = TRUE,
    show_subtitle = FALSE,
    subtitle = NULL,
    ms_title = NULL,
    ms_subtitle = NULL,
    ms_margin_top = 50,
    ms_margin_bottom = 50,
    margin_top = 50,
    margin_right = 20,
    margin_bottom = 70,
    margin_left = NULL, # 105,
    margin_inner = 40,
    margin_small = 5,
    margin_big = 10,
    margin_ytitle = 40,
    w = 420,
    h = 280,
    bar_width = 16,
    line_size = 2,
    point_size = 2,
    bar_color = "#46bac2",
    line_color = "#46bac2",
    point_color = "#46bac2",
    positive_color = "#8bdcbe",
    negative_color = "#f05a71",
    default_color = "#371ea3",
    bd_title = "Break Down",
    bd_subtitle = NULL,
    bd_axis_title = "contribution",
    bd_bar_width = NULL,
    bd_positive_color = NULL,
    bd_negative_color = NULL,
    bd_default_color = NULL,
    sv_title = "Shapley Values",
    sv_subtitle = NULL,
    sv_axis_title = "contribution",
    sv_bar_width = NULL,
    sv_positive_color = NULL,
    sv_negative_color = NULL,
    sv_default_color = NULL,
    cp_title = "Ceteris Paribus",
    cp_subtitle = NULL,
    cp_axis_title = "prediction",
    cp_bar_width = NULL,
    cp_line_size = NULL,
    cp_point_size = 3,
    cp_bar_color = NULL,
    cp_line_color = NULL,
    cp_point_color = "#371ea3",
    fi_title = "Feature Importance",
    fi_subtitle = NULL,
    fi_axis_title = NULL,
    fi_bar_width = NULL,
    fi_bar_color = NULL,
    pd_title = "Partial Dependence",
    pd_subtitle = NULL,
    pd_axis_title = "average prediction",
    pd_bar_width = NULL,
    pd_line_size = NULL,
    pd_bar_color = NULL,
    pd_line_color = NULL,
    ad_title = "Accumulated Dependence",
    ad_subtitle = NULL,
    ad_axis_title = "accumulated prediction",
    ad_bar_width = NULL,
    ad_line_size = NULL,
    ad_bar_color = NULL,
    ad_line_color = NULL,
    rv_title = "Residuals vs Feature",
    rv_subtitle = NULL,
    rv_axis_title = "residuals",
    rv_point_size = NULL,
    rv_point_color = NULL,
    fd_title = "Feature Distribution",
    fd_subtitle = NULL,
    fd_axis_title = "count",
    fd_bar_width = NULL,
    fd_bar_color = NULL,
    tv_title = "Target vs Feature",
    tv_subtitle = NULL,
    tv_axis_title = "target",
    tv_point_size = NULL,
    tv_point_color = NULL,
    at_title = "Average Target vs Feature",
    at_subtitle = NULL,
    at_axis_title = "average target",
    at_bar_width = NULL,
    at_line_size = NULL,
    at_point_size = 3,
    at_bar_color = NULL,
    at_line_color = NULL,
    at_point_color = "#371ea3",
    showcase_name = NULL
  )

  # input new options
  default_options[names(list(...))] <- list(...)

  default_options
}

#' deprecated since v1.1 (May 2020)
#' removed in v2.2 (July 2021)
#' @export
#' @rdname ms_options
# modelStudioOptions <- function(...) {
#   warning("The 'modelStudioOptions()' function is deprecated; use 'ms_options()' instead.")
#   ret <- ms_options(...)
#   ret
# }
