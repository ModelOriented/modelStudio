prepareBreakDown <- function(x, max_features = 10, baseline = NA, digits = 3,
                             rounding_function = round, margin = 0.2, min_max = NA) {
  ### This function returns object needed to plot BreakDown in D3 ###

  m <- ifelse(nrow(x) - 2 <= max_features, nrow(x), max_features + 3)

  new_x <- prepareBreakDownDF(x, max_features, baseline, digits, rounding_function)

  #variables <- setdiff(unique(as.character(new_x[,'variable_name'])), c("prediction","intercept","other"))

  if (any(is.na(min_max))) {
    if (is.na(baseline)) {
      min_max <- range(new_x[,'cummulative'])
    } else {
      min_max <- range(new_x[,'cummulative'], baseline)
    }
  }

  # count margins
  min_max_margin <- abs(min_max[2]-min_max[1])*margin
  min_max[1] <- min_max[1] - min_max_margin
  min_max[2] <- min_max[2] + min_max_margin

  desc <- NULL
  # because apparently describe doesnt work for less than 4 features
  if (nrow(x) > 5) {
    desc <- iBreakDown::describe(x, display_values =  TRUE,
                                 display_numbers = TRUE)
  } else {
    desc <- "Description for less than 4 features model not available."
  }

  ret <- NULL
  ret$x <- new_x
  ret$m <- m
  #ret$variables <- variables
  ret$x_min_max <- min_max
  ret$desc <- data.frame(type = "desc",
                         text = gsub("\n","</br>", desc))

  ret
}

prepareBreakDownDF <- function(x, max_features = 10, baseline = NA, digits = 3,
                               rounding_function = round) {
  ### This function returns data as DF needed to plot BreakDown in D3 ###

  # fix df
  x[,'variable'] <- as.character(x[,'variable'])
  x[,'variable_name'] <- as.character(x[,'variable_name'])

  x[x[,'variable_name']=="",'variable_name'] <- "prediction"

  temp <- data.frame(x[c(1,nrow(x)),])
  x <- data.frame(x[-c(1,nrow(x)),])

  if (nrow(x) > max_features) {
    last_row <- max_features + 1
    new_x <- x[1:last_row,]
    new_x[last_row,'variable'] <- "+ all other factors"
    new_x[last_row,'contribution'] <- sum(x[last_row:nrow(x),'contribution'])
    new_x[last_row,'cummulative'] <- x[nrow(x),'cummulative']
    new_x[last_row,'sign'] <- ifelse(new_x[last_row,'contribution'] > 0,1,-1)
    new_x[last_row,'variable_name'] <- "other"

    x <- new_x
  }

  x <- rbind(temp[1,], x, temp[2,])

  if (is.na(baseline)) {
    baseline <- x[1,"cummulative"]
  }

  # fix contribution and sign
  x[c(1,nrow(x)),"contribution"] <- x[c(1,nrow(x)),"contribution"] - baseline

  x[c(1,nrow(x)),"sign"] <- ifelse(x[c(1,nrow(x)),"contribution"] > 0,1,ifelse(x[c(1,nrow(x)),"contribution"] < 0,-1,0))

  # use for bars
  x[,'barStart'] <- ifelse(x[,'sign'] == "1", x[,'cummulative'] - x[,'contribution'], x[,'cummulative'])
  x[,'barSupport'] <- ifelse(x[,'sign'] == "1", x[,'cummulative'], x[,'cummulative'] - x[,'contribution'])

  # use for text label and tooltip
  x[,'contribution'] <- rounding_function(x['contribution'], digits)
  x[,'cummulative'] <- rounding_function(x['cummulative'], digits)

  # use for color
  x[c(1,nrow(x)),"sign"] <- "X"

  x[,'tooltipText'] <- ifelse(x[,'sign'] == "X", paste0("Average response: ",x[1,'cummulative'],
                                                        "<br>", "Prediction: ",
                                                        x[nrow(x),'cummulative']),
                              paste0(substr(x[,'variable'], 1, 25),
                                     "<br>", ifelse(x[,'contribution'] > 0, "increases", "decreases"),
                                     " average response <br>by ", abs(x[,'contribution'])))

  x
}

prepareShapleyValues <- function(x, max_features = 10, baseline = NA, digits = 3,
                                 rounding_function = round, margin = 0.2, min_max = NA) {
  ### This function returns object needed to plot Shap in D3 ###

  x <- x[x$B == 0,]
  if (is.na(baseline)) baseline <- attr(x, "intercept")[[1]]
  prediction <- attr(x, "prediction")[[1]]

  m <- ifelse(nrow(x) <= max_features, nrow(x), max_features + 1)

  new_x <- prepareShapleyValuesDF(x, max_features, baseline, prediction, digits, rounding_function)

  if (any(is.na(min_max))) {
    min_max <- range(new_x[,"barStart"], new_x[,"barSupport"])
  }

  # count margins
  min_max_margin <- abs(min_max[2]-min_max[1])*margin
  min_max[1] <- min_max[1] - min_max_margin
  min_max[2] <- min_max[2] + min_max_margin

  desc <- NULL
  # because apparently describe doesnt work for less than 4 features
  if (nrow(x) > 3) {
    desc <- iBreakDown::describe(x, display_values = TRUE,
                                 display_numbers = TRUE,
                                 display_shap = TRUE)
  } else {
    desc <- "Description for less than 4 features model not available."
  }

  ret <- NULL
  ret$x <- new_x
  ret$m <- m
  ret$x_min_max <- min_max
  ret$desc <- data.frame(type = "desc",
                         text = gsub("\n","</br>", desc))

  ret
}

prepareShapleyValuesDF <- function(x, max_features = 10, baseline = NA, prediction,
                                   digits = 3, rounding_function = round) {
  ### This function returns data as DF needed to plot ShapleyValues in D3 ###

  x <- as.data.frame(x)
  rownames(x) <- NULL

  # sort rows on contribution for max_features
  x <- x[order(-abs(x$contribution)),]

  # fix df
  x[,'variable'] <- as.character(x[,'variable'])
  x[,'variable_name'] <- as.character(x[,'variable_name'])

  if (nrow(x) > max_features) {
    last_row <- max_features + 1
    new_x <- x[1:last_row,]
    new_x[last_row,'variable'] <- "+ all other factors"
    new_x[last_row,'contribution'] <- sum(x[last_row:nrow(x),'contribution'])
    new_x[last_row,'sign'] <- ifelse(new_x[last_row,'contribution'] > 0,1,-1)

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

prepareCeterisParibus <- function(x, variables = NULL) {
  ### This function returns object needed to plot CeterisParibus in D3 ###

  # which variable is numeric?
  is_numeric <- sapply(x[, variables, drop = FALSE], is.numeric)
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
  all_profiles$`_vname_` <- droplevels(all_profiles$`_vname_`)
  rownames(all_profiles) <- NULL

  y_min_max <- range(all_profiles$`_yhat_`)

  # count margins
  y_min_max_margin <- abs(y_min_max[2]-y_min_max[1])*0.1
  y_min_max[1] <- y_min_max[1] - y_min_max_margin
  y_min_max[2] <- y_min_max[2] + y_min_max_margin

  all_profiles_list <- split(all_profiles, all_profiles$`_vname_`)[variables]

  new_x <- x_min_max_list <- list()

  # line plot or bar plot?
  for (i in 1:length(is_numeric)) {
    temp <- all_profiles_list[[i]]
    if (is_numeric[i]) {

      name <- as.character(head(temp$`_vname_`,1))
      temp <- temp[, c(name, "_yhat_", "_ids_", "_vname_")]
      colnames(temp) <- c("xhat", "yhat", "id", "vname")
      temp$xhat <- as.numeric(temp$xhat)
      temp$yhat <- as.numeric(temp$yhat)

      new_x[[name]] <- temp[order(temp$xhat),]
      x_min_max_list[[name]] <- list(min(temp$xhat), max(temp$xhat))

    } else {
      if (dim(attr(temp, "observations"))[1] > 1) stop("Please pick one observation.")

      name <- as.character(head(temp$`_vname_`,1))
      temp <- temp[, c(name, "_yhat_", "_vname_")]
      colnames(temp) <- c("xhat", "yhat", "vname")
      temp$yhat <- as.numeric(temp$yhat)

      new_x[[name]] <- temp
    }
  }

  ret <- NULL
  ret$observation <- all_observations
  ret$x <- new_x
  ret$y_min_max <- y_min_max
  ret$x_min_max_list <- x_min_max_list
  ret$is_numeric <- as.list(is_numeric)

  ret
}

prepareFeatureImportance <- function(x, max_features = 10, margin = 0.2) {
  ### This function returns object needed to plot FeatureImportance in D3 ###

  m <- dim(x)[1] - 2

  xmin <- min(x$dropout_loss)
  xmax <- max(x[x$variable!="_baseline_",]$dropout_loss)

  ticks_margin <- abs(xmin-xmax)*margin;

  best_fits <- x[x$variable == "_full_model_", ]
  x <- merge(x, best_fits[,c("label", "dropout_loss")], by = "label")

  # remove rows that starts with _
  x <- x[!(substr(x$variable,1,1) == "_"),]

  perm <- aggregate(x$dropout_loss.x, by = list(Category=x$variable), FUN = mean)


  if (!is.null(max_features) && max_features < m) {
    m <- max_features
    x <- x[tail(order(x$dropout_loss.x), max_features), ]
  }

  # sorting bars in groups
  perm <- as.character(perm$Category[order(perm$x)])
  x$variable <- factor(as.character(x$variable), levels = perm)
  x <- x[order(x$variable),]

  colnames(x) <- c("label","variable","dropout_loss", "full_model")

  ret <- NULL
  ret$x <- x[,2:4]
  ret$x_min_max <- c(xmin - ticks_margin, xmax + ticks_margin)

  ret
}

preparePartialDependency <- function(x, y, variables = NULL) {
  ### This function returns object needed to plot PartialDependency in D3 ###

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
  aggregated_profiles$`_vname_` <- droplevels(aggregated_profiles$`_vname_`)
  rownames(aggregated_profiles) <- NULL

  y_min_max <- range(aggregated_profiles$`_yhat_`)

  # count margins
  y_min_max_margin <- abs(y_min_max[2]-y_min_max[1])*0.1
  y_min_max[1] <- y_min_max[1] - y_min_max_margin
  y_min_max[2] <- y_min_max[2] + y_min_max_margin

  aggregated_profiles_list <- split(aggregated_profiles, aggregated_profiles$`_vname_`)[variables]

  new_x <- x_min_max_list <- list()
  y_mean <- NULL

  # line plot or bar plot?
  for (i in 1:length(is_numeric)) {
    temp <- aggregated_profiles_list[[i]]
    if (is_numeric[i]) {

      name <- as.character(head(temp$`_vname_`,1))
      temp <- temp[, c('_x_', "_yhat_", "_vname_", "_label_")]
      colnames(temp) <- c("xhat", "yhat", "vname", "label")
      temp$xhat <- as.numeric(temp$xhat)
      temp$yhat <- as.numeric(temp$yhat)

      new_x[[name]] <- temp[order(temp$xhat),]
      x_min_max_list[[name]] <- list(min(temp$xhat), max(temp$xhat))

    } else {

      name <- as.character(head(temp$`_vname_`,1))
      temp <- temp[, c("_x_", "_yhat_", "_vname_", "_label_")]
      colnames(temp) <- c("xhat", "yhat", "vname", "label")
      temp$yhat <- as.numeric(temp$yhat)

      new_x[[name]] <- temp
    }
  }

  y_mean <- ifelse(is.null(x), round(attr(y, "mean_prediction"),3),
                   round(attr(x, "mean_prediction"),3))

  ret <- NULL
  ret$y_mean <- y_mean
  ret$x <- new_x
  ret$y_min_max <- y_min_max
  ret$x_min_max_list <- x_min_max_list
  ret$is_numeric <- as.list(is_numeric)

  ret
}

prepareAccumulatedDependency <- function(x, y, variables = NULL) {
  ### This function returns object needed to plot AccumulatedDependency in D3 ###

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
  aggregated_profiles$`_vname_` <- droplevels(aggregated_profiles$`_vname_`)
  rownames(aggregated_profiles) <- NULL

  y_min_max <- range(aggregated_profiles$`_yhat_`)

  # count margins
  y_min_max_margin <- abs(y_min_max[2]-y_min_max[1])*0.1
  y_min_max[1] <- y_min_max[1] - y_min_max_margin
  y_min_max[2] <- y_min_max[2] + y_min_max_margin

  aggregated_profiles_list <- split(aggregated_profiles, aggregated_profiles$`_vname_`)[variables]

  # safeguard
  aggregated_profiles_list <-
    aggregated_profiles_list[!unlist(lapply(aggregated_profiles_list, is.null))]

  new_x <- x_min_max_list <- list()
  y_mean <- NULL

  # line plot or bar plot?
  for (i in 1:length(is_numeric)) {
    temp <- aggregated_profiles_list[[i]]
    if (is_numeric[i]) {

      name <- as.character(head(temp$`_vname_`,1))
      temp <- temp[, c('_x_', "_yhat_", "_vname_", "_label_")]
      colnames(temp) <- c("xhat", "yhat", "vname", "label")
      temp$xhat <- as.numeric(temp$xhat)
      temp$yhat <- as.numeric(temp$yhat)

      new_x[[name]] <- temp[order(temp$xhat),]
      x_min_max_list[[name]] <- list(min(temp$xhat), max(temp$xhat))

    } else {

      name <- as.character(head(temp$`_vname_`,1))
      temp <- temp[, c("_x_", "_yhat_", "_vname_", "_label_")]
      colnames(temp) <- c("xhat", "yhat", "vname", "label")
      temp$yhat <- as.numeric(temp$yhat)

      new_x[[name]] <- temp
    }
  }

  y_mean <- ifelse(is.null(x), round(attr(y, "mean_prediction"),3),
                   round(attr(x, "mean_prediction"),3))

  ret <- NULL
  ret$y_mean <- y_mean
  ret$x <- new_x
  ret$y_min_max <- y_min_max
  ret$x_min_max_list <- x_min_max_list
  ret$is_numeric <- as.list(is_numeric)

  ret
}

prepareFeatureDistribution <- function(x, variables = NULL) {
  ### This function returns object needed to plot FeatureDistribution in D3 ###

  # which variable is numeric?
  is_numeric <- sapply(x[, variables, drop = FALSE], is.numeric)
  names(is_numeric) <- variables

  # safeguard
  is_numeric <- is_numeric[!is.na(is_numeric)]

  x_min_max_list <- x_max_list <- nbin <- list()

  for (i in 1:length(is_numeric)) {
    if (is_numeric[i]) {
      name <- names(is_numeric[i])
      x_min_max_list[[name]] <- range(x[,name])
      nbin[[name]] <- nclass.Sturges(x[,name]) ## FD, scott nbin choice
    } else {
      name <- names(is_numeric[i])
      x_max_list[[name]] <-max(table(x[,name]))
    }
  }

  ret <- NULL
  ret$x <- x[,variables]
  ret$x_min_max_list <- x_min_max_list
  ret$x_max_list <- x_max_list
  ret$nbin <- nbin
  ret$is_numeric <- as.list(is_numeric)

  ret
}
