prepare_break_down <- function(x, max_features = 10, baseline = NA, digits = 3,
                               rounding_function = round, margin = 0.2, ...) {
  ### Return the object for the BreakDown plot ###

  if (is.null(x)) return(NULL)

  m <- ifelse(nrow(x) - 2 <= max_features, nrow(x), max_features + 3)

  new_x <- prepare_break_down_df(x, max_features, baseline, digits, rounding_function)

  if (is.na(baseline)) {
    min_max <- range(new_x[,'cumulative'])
  } else {
    min_max <- range(new_x[,'cumulative'], baseline)
  }

  # count margins
  min_max_margin <- abs(min_max[2]-min_max[1])*margin
  min_max[1] <- min_max[1] - min_max_margin
  min_max[2] <- min_max[2] + min_max_margin

  desc <- calculate(iBreakDown::describe(x, display_values =  TRUE,
                                            display_numbers = TRUE),
                    "iBreakDown::describe.break_down")

  if (is.null(desc)) desc <- "error in iBreakDown::describe.break_down"

  ret <- NULL
  ret$x <- new_x
  ret$m <- m
  ret$x_min_max <- min_max
  ret$desc <- data.frame(type = "desc",
                         text = gsub("\n","</br>", desc))

  ret
}

prepare_break_down_df <- function(x, max_features = 10, baseline = NA, digits = 3,
                                  rounding_function = round) {
  ### This function returns data as DF needed for the BreakDown plot ###

  # fix df
  x[,'variable'] <- as.character(x[,'variable'])
  x[,'variable_name'] <- as.character(x[,'variable_name'])

  x[x[,'variable_name']=="",'variable_name'] <- "prediction"

  temp <- data.frame(x[c(1,nrow(x)),], stringsAsFactors=TRUE)
  x <- data.frame(x[-c(1,nrow(x)),], stringsAsFactors=TRUE)

  if (nrow(x) > max_features) {
    last_row <- max_features + 1
    new_x <- x[1:last_row,]
    new_x[last_row,'variable'] <- "+ all other factors"
    new_x[last_row,'contribution'] <- sum(x[last_row:nrow(x),'contribution'])
    new_x[last_row,'cumulative'] <- x[nrow(x),'cumulative']
    new_x[last_row,'sign'] <- ifelse(new_x[last_row,'contribution'] > 0,1,-1)
    new_x[last_row,'variable_name'] <- "other"

    x <- new_x
  }

  x <- rbind(temp[1,], x, temp[2,])

  if (is.na(baseline)) {
    baseline <- x[1,"cumulative"]
  }

  # fix contribution and sign
  x[c(1,nrow(x)),"contribution"] <- x[c(1,nrow(x)),"contribution"] - baseline

  x[c(1,nrow(x)),"sign"] <- ifelse(x[c(1,nrow(x)),"contribution"] > 0,1,ifelse(x[c(1,nrow(x)),"contribution"] < 0,-1,0))

  # use for bars
  x[,'barStart'] <- ifelse(x[,'sign'] == "1", x[,'cumulative'] - x[,'contribution'], x[,'cumulative'])
  x[,'barSupport'] <- ifelse(x[,'sign'] == "1", x[,'cumulative'], x[,'cumulative'] - x[,'contribution'])

  # use for text label and tooltip
  x[,'contribution'] <- rounding_function(x['contribution'], digits)
  x[,'cumulative'] <- rounding_function(x['cumulative'], digits)

  # use for color
  x[c(1,nrow(x)),"sign"] <- "X"

  x[,'tooltipText'] <- ifelse(x[,'sign'] == "X", paste0("Average response: ",x[1,'cumulative'],
                                                        "<br>", "Prediction: ",
                                                        x[nrow(x),'cumulative']),
                              paste0(substr(x[,'variable'], 1, 25),
                                     "<br>", ifelse(x[,'contribution'] > 0, "increases", "decreases"),
                                     " average response <br>by ", abs(x[,'contribution'])))

  x
}

prepare_shapley_values <- function(x, max_features = 10, show_boxplot = TRUE,
                                   baseline = NA,
                                   digits = 3, rounding_function = round,
                                   margin = 0.15, ...) {
  ### Return the the object for the ShapleyValues plot ###

  if (is.null(x)) return(NULL)
  B <- NULL

  if (is.na(baseline)) baseline <- attr(x, "intercept")[[1]]
  prediction <- attr(x, "prediction")[[1]]

  x_df <- as.data.frame(x, stringsAsFactors=TRUE)

  x_df_short <- subset(x_df[x_df$B == 0, ], select = -B)

  m <- ifelse(nrow(x_df_short) <= max_features, nrow(x_df_short), max_features) # max_features + 1
  new_x <- prepare_shapley_values_df(x_df_short, max_features, baseline, prediction, digits, rounding_function)

  if (show_boxplot) {
    #:# change the input to save boxplot data
    x_stats <- data.frame(
      variable_name = levels(as.factor(x_df$variable_name)),
      min = as.numeric(tapply(x_df$contribution, x_df$variable_name, min, na.rm = TRUE)),
      q1 = as.numeric(tapply(x_df$contribution, x_df$variable_name, quantile, 0.25, na.rm = TRUE)),
      median = as.numeric(tapply(x_df$contribution, x_df$variable_name, median, na.rm = TRUE)),
      q3 = as.numeric(tapply(x_df$contribution, x_df$variable_name, quantile, 0.75, na.rm = TRUE)),
      max = as.numeric(tapply(x_df$contribution, x_df$variable_name, max, na.rm = TRUE)),
      iqr = as.numeric(tapply(x_df$contribution, x_df$variable_name, IQR, na.rm = TRUE)),
      stringsAsFactors=TRUE
    )

    x_stats$min <- pmax(x_stats$min, x_stats$q1 - 1.5*x_stats$iqr)
    x_stats$max <- pmin(x_stats$max, x_stats$q3 + 1.5*x_stats$iqr)
    x_stats$iqr <- NULL
    x_stats[,-1] <- x_stats[,-1] + baseline

    new_x <- merge(new_x, x_stats, by = "variable_name", sort = FALSE)
    #:#

    min_max <- range(new_x[,"q1"], new_x[,"q3"], new_x[,"barStart"], new_x[,"barSupport"])
  } else {
    min_max <- range(new_x[,"barStart"], new_x[,"barSupport"])
    margin <- 0.2
  }

  # count margins
  min_max_margin <- abs(min_max[2]-min_max[1])*margin
  min_max[1] <- min_max[1] - min_max_margin
  min_max[2] <- min_max[2] + min_max_margin

  # describe cuts df to B=0 anyway
  desc <- calculate(iBreakDown::describe(x, display_values = TRUE,
                                            display_numbers = TRUE,
                                            display_shap = TRUE),
                    "iBreakDown::describe.shap")

  if (is.null(desc)) desc <- "error in iBreakDown::describe.shap"

  ret <- NULL
  ret$x <- new_x
  ret$m <- m
  ret$x_min_max <- min_max
  ret$desc <- data.frame(type = "desc",
                         text = gsub("\n","</br>", desc))

  ret
}

prepare_shapley_values_df <- function(x, max_features = 10, baseline = NA, prediction,
                                      digits = 3, rounding_function = round) {
  ### Return the data as DF needed for the ShapleyValues plot ###

  x <- as.data.frame(x, stringsAsFactors=TRUE)
  rownames(x) <- NULL

  # sort rows on contribution for max_features
  x <- x[order(-abs(x$contribution)),]

  # fix df
  x[,'variable'] <- as.character(x[,'variable'])
  x[,'variable_name'] <- as.character(x[,'variable_name'])

  if (nrow(x) > max_features) {
    # last_row <- max_features + 1
    # new_x <- x[1:last_row,]
    # new_x[last_row,'variable'] <- "+ all other factors"
    # new_x[last_row,'contribution'] <- sum(x[last_row:nrow(x),'contribution'])
    # new_x[last_row,'sign'] <- ifelse(new_x[last_row,'contribution'] > 0,1,-1)

    new_x <- x[1:max_features,]
    x <- new_x
  }

  x[,"sign"] <- ifelse(x[,"contribution"] > 0,1,ifelse(x[,"contribution"] < 0,-1,0))

  # use for bars
  x[,'barStart'] <- ifelse(x[,'sign'] == "1", baseline, baseline + x[,'contribution'])
  x[,'barSupport'] <- ifelse(x[,'sign'] == "1", baseline + x[,'contribution'], baseline)

  # use for text label and tooltip
  x[,'contribution'] <- rounding_function(x['contribution'], digits)

  x[,"sign"] <- as.character(x[,"sign"])

  x[,'tooltipText'] <- ifelse(x[,'sign'] == "X", paste0("Average response: ", baseline,
                                                        "<br>", "Prediction: ", prediction),
                              paste0(substr(x[,'variable'], 1, 25),
                                     "<br>", ifelse(x[,'contribution'] > 0, "increases", "decreases"),
                                     " average response <br>by ", abs(x[,'contribution'])))

  x
}

prepare_ceteris_paribus <- function(x, variables = NULL) {
  ### Return the object for the CeterisParibus plot ###

  if (is.null(x)) return(NULL)

  # which variable is numeric?
  is_numeric <- which_variables_are_numeric(x[, variables, drop = FALSE])
  names(is_numeric) <- variables

  # safeguard
  is_numeric <- is_numeric[!is.na(is_numeric)]

  # prepare clean observations data for tooltips
  all_observations <- attr(x, "observations")

  m <- dim(all_observations)[2]
  colnames(all_observations) <- c(colnames(all_observations)[1:(m-3)], "yhat","model","observation.id")
  all_observations <- all_observations[,c(m,m-1,m-2,1:(m-3))]
  all_observations$observation.id <- rownames(all_observations)

  # prepare profiles data
  all_profiles <- x[x$`_vname_` %in% variables, ]
  rownames(all_profiles) <- NULL

  y_min_max <- range(all_profiles$`_yhat_`)

  # count margins
  y_min_max_margin <- abs(y_min_max[2]-y_min_max[1])*0.1
  y_min_max[1] <- y_min_max[1] - y_min_max_margin
  y_min_max[2] <- y_min_max[2] + y_min_max_margin

  all_profiles_list <- split(all_profiles, all_profiles$`_vname_`, drop = TRUE)

  new_x <- x_min_max_list <- desc <- list()

  # line plot or bar plot?
  for (name in names(is_numeric)) {
    temp <- all_profiles_list[[name]]

    if (is_numeric[name]) {
      temp <- temp[, c(name, "_yhat_", "_ids_", "_vname_")]
      colnames(temp) <- c("xhat", "yhat", "id", "vname")
      temp$xhat <- as.numeric(temp$xhat)
      temp$yhat <- as.numeric(temp$yhat)

      new_x[[name]] <- temp[order(temp$xhat),]
      x_min_max_list[[name]] <- list(min(temp$xhat), max(temp$xhat))

    } else {
      temp <- temp[, c(name, "_yhat_", "_vname_")]
      colnames(temp) <- c("xhat", "yhat", "vname")
      temp$yhat <- as.numeric(temp$yhat)

      new_x[[name]] <- temp[order(temp$xhat),]
    }

    text <- calculate(
      suppressWarnings(ingredients::describe(x, display_values = TRUE,
                                                display_numbers = TRUE,
                                                variables = name)),
      "ingredients::describe.ceteris_paribus")

    if (is.null(text)) text <- "error in ingredients::describe.ceteris_paribus"

    desc[[name]] <- data.frame(type = "desc",
                               text = gsub("\n","</br>", text))
  }

  ret <- NULL
  ret$observation <- all_observations
  ret$x <- new_x
  ret$y_min_max <- y_min_max
  ret$x_min_max_list <- x_min_max_list
  ret$is_numeric <- as.list(is_numeric)
  ret$desc <- desc

  ret
}

prepare_feature_importance <- function(x, max_features = 10, show_boxplot = TRUE,
                                       margin = 0.15, digits = 3, rounding_function = round,
                                       ...) {
  ### Return the object for the FeatureImportance plot ###

  if (is.null(x)) return(NULL)
  permutation <- NULL

  x_df <- as.data.frame(x, stringsAsFactors=TRUE)

  x_df_short <- subset(x_df[x_df$permutation == 0,], select = -permutation)
  m <- dim(x_df_short)[1] - 2

  best_fits <- x_df_short[x_df_short$variable %in% "_full_model_", ]
  new_x <- merge(x_df_short, best_fits[,c("label", "dropout_loss")], by = "label", sort = FALSE)

  # remove rows that starts with _
  new_x <- new_x[!new_x$variable %in% c("_full_model_", "_baseline_"), ]

  # order bars
  new_x <- new_x[order(-abs(new_x$dropout_loss.x)),]

  if (max_features < m) {
    m <- max_features
    new_x <- new_x[1:max_features,]
  }

  colnames(new_x)[3:4] <- c("dropout_loss", "full_model")
  new_x$dropout_loss <- rounding_function(new_x$dropout_loss, digits)
  new_x$full_model <- rounding_function(new_x$full_model, digits)

  if (show_boxplot) {
    #:# change the input to save boxplot data
    x_stats <- data.frame(
      variable = levels(as.factor(x_df$variable)),
      min = as.numeric(tapply(x_df$dropout_loss, x_df$variable, min, na.rm = TRUE)),
      q1 = as.numeric(tapply(x_df$dropout_loss, x_df$variable, quantile, 0.25, na.rm = TRUE)),
      median = as.numeric(tapply(x_df$dropout_loss, x_df$variable, median, na.rm = TRUE)),
      q3 = as.numeric(tapply(x_df$dropout_loss, x_df$variable, quantile, 0.75, na.rm = TRUE)),
      max = as.numeric(tapply(x_df$dropout_loss, x_df$variable, max, na.rm = TRUE)),
      iqr = as.numeric(tapply(x_df$dropout_loss, x_df$variable, IQR, na.rm = TRUE)),
      stringsAsFactors=TRUE
    )

    x_stats$min <- pmax(x_stats$min, x_stats$q1 - 1.5*x_stats$iqr)
    x_stats$max <- pmin(x_stats$max, x_stats$q3 + 1.5*x_stats$iqr)
    x_stats$iqr <- NULL

    new_x <- merge(new_x, x_stats, by = "variable", sort = FALSE)
    #:#

    min_max <- range(new_x[,"q1"], new_x[,"q3"], new_x[,"dropout_loss"], new_x[1,"full_model"])
  } else {
    min_max <- range(new_x[,"dropout_loss"], new_x[1,"full_model"])
    margin <- 0.2
  }

  # count margins
  min_max_margin <- abs(min_max[2]-min_max[1])*margin
  min_max[1] <- min_max[1] - min_max_margin
  min_max[2] <- min_max[2] + min_max_margin

  desc <- calculate(ingredients::describe(x),
                    "ingredients::describe.feature_importance")

  if (is.null(desc)) desc <- "error in ingredients::describe.feature_importance"

  ret <- NULL
  ret$x <- new_x
  ret$m <- m
  ret$x_min_max <- min_max
  ret$desc <- data.frame(type = "desc",
                         text = gsub("\n","</br>", desc))

  ret
}

prepare_partial_dependence <- function(x, y, variables = NULL) {
  ### Return the object for the PartialDependence plot ###

  if (is.null(x) & is.null(y)) return(NULL)

  # which variable is numeric?
  num <- as.character(unique(x$`_vname_`))
  cat <- as.character(unique(y$`_vname_`))
  is_numeric <- c(rep(TRUE, length(num)), rep(FALSE, length(cat)))
  names(is_numeric) <- c(num, cat)
  is_numeric <- is_numeric[variables]

  # safeguard
  is_numeric <- is_numeric[!is.na(is_numeric)]

  # prepare aggregated profiles data
  aggregated_profiles <- rbind(x,y)

  aggregated_profiles <- aggregated_profiles[aggregated_profiles$`_vname_` %in% variables, ]
  rownames(aggregated_profiles) <- NULL

  y_min_max <- range(aggregated_profiles$`_yhat_`)

  # count margins
  y_min_max_margin <- abs(y_min_max[2]-y_min_max[1])*0.1
  y_min_max[1] <- y_min_max[1] - y_min_max_margin
  y_min_max[2] <- y_min_max[2] + y_min_max_margin

  aggregated_profiles_list <- split(aggregated_profiles, aggregated_profiles$`_vname_`, drop = TRUE)

  # safeguard
  aggregated_profiles_list <-
    aggregated_profiles_list[!sapply(aggregated_profiles_list, is.null)]

  new_x <- x_min_max_list <- desc <- list()
  y_mean <- NULL

  # line plot or bar plot?
  for (name in names(is_numeric)) {
    temp <- aggregated_profiles_list[[name]]

    if (is_numeric[name]) {
      temp <- temp[, c('_x_', "_yhat_", "_vname_", "_label_")]
      colnames(temp) <- c("xhat", "yhat", "vname", "label")
      temp$xhat <- as.numeric(temp$xhat)
      temp$yhat <- as.numeric(temp$yhat)

      new_x[[name]] <- temp[order(temp$xhat),]
      x_min_max_list[[name]] <- list(min(temp$xhat), max(temp$xhat))

    } else {
      temp <- temp[, c("_x_", "_yhat_", "_vname_", "_label_")]
      colnames(temp) <- c("xhat", "yhat", "vname", "label")
      temp$yhat <- as.numeric(temp$yhat)

      new_x[[name]] <- temp
    }

    text <- calculate(
      suppressWarnings(ingredients::describe(rbind(x,y), display_values = TRUE,
                                                         display_numbers = TRUE,
                                                         variables = name)),
      "ingredients::describe.partial_dependence")

    if (is.null(text)) text <- "error in ingredients::describe.partial_dependence"

    desc[[name]] <- data.frame(type = "desc",
                               text = gsub("\n","</br>", text))
  }

  y_mean <- ifelse(is.null(x), round(attr(y, "mean_prediction"),3),
                   round(attr(x, "mean_prediction"),3))

  ret <- NULL
  ret$y_mean <- y_mean
  ret$x <- new_x
  ret$y_min_max <- y_min_max
  ret$x_min_max_list <- x_min_max_list
  ret$is_numeric <- as.list(is_numeric)
  ret$desc <- desc

  ret
}

prepare_accumulated_dependence <- function(x, y, variables = NULL) {
  ### Return the object for the AccumulatedDependence plot ###

  if (is.null(x) & is.null(y)) return(NULL)

  # which variable is numeric?
  num <- as.character(unique(x$`_vname_`))
  cat <- as.character(unique(y$`_vname_`))
  is_numeric <- c(rep(TRUE, length(num)), rep(FALSE, length(cat)))
  names(is_numeric) <- c(num, cat)
  is_numeric <- is_numeric[variables]

  # safeguard
  is_numeric <- is_numeric[!is.na(is_numeric)]

  # prepare aggregated profiles data
  aggregated_profiles <- rbind(x,y)

  aggregated_profiles <- aggregated_profiles[aggregated_profiles$`_vname_` %in% variables, ]
  rownames(aggregated_profiles) <- NULL

  y_min_max <- range(aggregated_profiles$`_yhat_`)

  # count margins
  y_min_max_margin <- abs(y_min_max[2]-y_min_max[1])*0.1
  y_min_max[1] <- y_min_max[1] - y_min_max_margin
  y_min_max[2] <- y_min_max[2] + y_min_max_margin

  aggregated_profiles_list <- split(aggregated_profiles, aggregated_profiles$`_vname_`, drop = TRUE)

  # safeguard
  aggregated_profiles_list <-
    aggregated_profiles_list[!sapply(aggregated_profiles_list, is.null)]

  new_x <- x_min_max_list <- desc <- list()
  y_mean <- NULL

  # line plot or bar plot?
  for (name in names(is_numeric)) {
    temp <- aggregated_profiles_list[[name]]

    if (is_numeric[name]) {
      temp <- temp[, c('_x_', "_yhat_", "_vname_", "_label_")]
      colnames(temp) <- c("xhat", "yhat", "vname", "label")
      temp$xhat <- as.numeric(temp$xhat)
      temp$yhat <- as.numeric(temp$yhat)

      new_x[[name]] <- temp[order(temp$xhat),]
      x_min_max_list[[name]] <- list(min(temp$xhat), max(temp$xhat))

    } else {
      temp <- temp[, c("_x_", "_yhat_", "_vname_", "_label_")]
      colnames(temp) <- c("xhat", "yhat", "vname", "label")
      temp$yhat <- as.numeric(temp$yhat)

      new_x[[name]] <- temp
    }

    # text <- calculate(
    #   suppressWarnings(
    #   ingredients::describe(rbind(x,y),
    #                         display_values = TRUE,
    #                         display_numbers = TRUE,
    #                         variables = name)),
    #   "ingredients::describe.accumulated_dependence"
    # )
    # if (is.null(text)) text <- "ingredients::describe.accumulated_dependence"

    ## accumulated not still developed
    text <- "Under development"
    desc[[name]] <- data.frame(type = "desc",
                               text = gsub("\n","</br>", text))
  }

  y_mean <- ifelse(is.null(x), round(attr(y, "mean_prediction"),3),
                   round(attr(x, "mean_prediction"),3))

  ret <- NULL
  ret$y_mean <- y_mean
  ret$x <- new_x
  ret$y_min_max <- y_min_max
  ret$x_min_max_list <- x_min_max_list
  ret$is_numeric <- as.list(is_numeric)
  ret$desc <- desc

  ret
}

prepare_feature_distribution <- function(x, y, variables = NULL, residuals = NULL) {
  ### Return the object for the FeatureDistribution plot ###

  if (is.null(x) | is.null(y)) return(NULL)

  # which variable is numeric?
  is_numeric <- which_variables_are_numeric(x[, variables, drop = FALSE])
  names(is_numeric) <- variables

  # safeguard
  is_numeric <- is_numeric[!is.na(is_numeric)]

  x_min_max_list <- x_max_list <- nbin <- list()

  for (name in names(is_numeric)) {
    variable_column_nona <- na.omit(x[,name])
    if (is_numeric[name]) {
      x_min_max_list[[name]] <- range(variable_column_nona)
      nbin[[name]] <- nclass.Sturges(variable_column_nona) ## FD, scott/Sturges nbin choice

    } else {
      x_min_max_list[[name]] <- sort(unique(variable_column_nona))
      x_max_list[[name]] <- max(table(variable_column_nona))
    }
  }

  #:# add residuals
  X <- as.data.frame(cbind(x[,variables, drop = FALSE], y, residuals), stringsAsFactors=TRUE)
  colnames(X) <- c(variables, "_target_", "_residuals_")

  y_max <- max(y, na.rm = TRUE)
  y_min <- min(y, na.rm = TRUE)
  y_margin <- abs(y_max - y_min)*0.1

  residuals_max <- max(residuals, na.rm = TRUE)
  residuals_min <- min(residuals, na.rm = TRUE)
  residuals_margin <- abs(residuals_max - residuals_min)*0.1

  ret <- NULL
  ret$x <- X
  ret$x_min_max_list <- x_min_max_list
  ret$y_min_max <- c(y_min - y_margin, y_max + y_margin)
  ret$residuals_min_max <- c(residuals_min - residuals_margin,
                             residuals_max + residuals_margin)
  ret$x_max_list <- x_max_list
  ret$nbin <- nbin
  ret$is_numeric <- as.list(is_numeric)

  ret
}

prepare_average_target <- function(x, y, variables = NULL) {
  ### Return the object for the TargetAverage plot ###

  if (is.null(x) | is.null(y)) return(NULL)

  # which variable is numeric?
  is_numeric <- which_variables_are_numeric(x[, variables, drop = FALSE])
  names(is_numeric) <- variables

  # safeguard
  is_numeric <- is_numeric[!is.na(is_numeric)]

  x_min_max_list <- y_min_max_list <- X <- list()

  y_mean <- mean(y, na.rm = TRUE)

  for (name in names(is_numeric)) {
    index <- !is.na(x[,name])
    variable_column_nona <- x[,name][index]
    y_nona <- y[index]

    if (length(unique(x[,name])) == 1) is_numeric[name] <- FALSE # issue #45

    if (is_numeric[name]) {
      x_min_max_list[[name]] <- range(variable_column_nona)

      nbins <- nclass.Sturges(variable_column_nona)
      variable_splits <- seq(min(variable_column_nona),
                             max(variable_column_nona),
                             length.out = nbins)

      x_bin <- cut(variable_column_nona,
                   variable_splits,
                   include.lowest = TRUE)
      y_mean_aggr <- aggregate(y_nona, by = list(x_bin), mean, na.rm = TRUE)

      ci <- y_mean_aggr[, 1]
      ci2 <- substr(as.character(ci), 2, nchar(as.character(ci)) - 1)
      lb <- sapply(ci2, function(x) strsplit(x, ",")[[1]][1])
      ub <- sapply(ci2, function(x) strsplit(x, ",")[[1]][2])
      mid_points <- (as.numeric(lb) + as.numeric(ub)) / 2

      p <- length(mid_points)

      temp <- as.data.frame(cbind(mid_points[-p], mid_points[-1],
                                  y_mean_aggr[-p, 2], y_mean_aggr[-1, 2]),
                            stringsAsFactors=TRUE)
      colnames(temp) <- c("x0", "x1", "y0", "y1")

    } else {
      x_min_max_list[[name]] <- sort(unique(variable_column_nona))

      y_mean_aggr <- aggregate(y_nona, by = list(variable_column_nona), mean, na.rm = TRUE)

      temp <- as.data.frame(y_mean_aggr, stringsAsFactors=TRUE)
      colnames(temp) <- c("y", "x0")
      temp$sign <- ifelse(temp$x0 < y_mean, -1, 1)
    }

    y_mean_max <- max(y_mean_aggr[,2])
    y_mean_min <- min(y_mean_aggr[,2])
    y_mean_margin <- abs(y_mean_max - y_mean_min)*0.1
    y_min_max_list[[name]] <- c(y_mean_min - y_mean_margin,
                                y_mean_max + y_mean_margin)

    X[[name]] <- temp
  }

  y_max <- max(y, na.rm = TRUE)
  y_min <- min(y, na.rm = TRUE)
  y_margin <- abs(y_max - y_min)*0.1

  ret <- NULL
  ret$x <- X
  ret$x_min_max_list <- x_min_max_list
  ret$y_min_max_list <- y_min_max_list
  ret$y_mean <- y_mean
  ret$is_numeric <- as.list(is_numeric)

  ret
}
