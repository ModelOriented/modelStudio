prepareBreakDown <- function(x, baseline = NA, max_features = 10, digits = 3, rounding_function = round, margin = 0.2, min_max = NA){
  ### This function returns object needed to plot BreakDown in D3 ###

  m <- ifelse(nrow(x) - 2 <= max_features, nrow(x), max_features + 3)

  new_x <- prepareBreakDownDF(x, baseline, max_features, digits, rounding_function)

  # later count longest label width in d3
  label_list <- as.character(new_x[,'variable'])

  variables <- setdiff(unique(as.character(new_x[,'variable_name'])), c("prediction","intercept","other"))

  if (any(is.na(min_max))) {
    min_max <- range(new_x[,'cummulative'])
  }

  # count margins
  min_max_margin <- abs(min_max[2]-min_max[1])*margin
  min_max[1] <- min_max[1] - min_max_margin
  min_max[2] <- min_max[2] + min_max_margin

  ret <- NULL
  ret$x <- new_x
  ret$m <- m
  ret$labelList <- label_list
  ret$variables <- variables
  ret$x_min_max <- min_max

  ret
}

prepareBreakDownDF <- function(x, baseline = NA, max_features = 10, digits = 3, rounding_function = round) {
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

prepareCeterisParibus <- function(x, variables = NULL) {
  ### This function returns object needed to plot CeterisParibus in D3 ###

  # which variable is numeric?
  is_numeric <- sapply(x[, variables, drop = FALSE], is.numeric)

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

  all_profiles_list <- split(all_profiles, all_profiles$`_vname_`)
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

      new_x[[i]] <- temp[order(temp$xhat),]
      x_min_max_list[[i]] <- list(min(temp$xhat), max(temp$xhat))

    } else {
      if (dim(attr(x, "observations"))[1] > 1) stop("Please pick one observation.")

      name <- as.character(head(temp$`_vname_`,1))
      temp <- temp[, c(name, "_yhat_", "_vname_")]
      colnames(temp) <- c("xhat", "yhat", "vname")
      temp$yhat <- as.numeric(temp$yhat)

      new_x[[i]] <- temp
    }
  }

  ret <- NULL
  ret$observation <- all_observations
  ret$x <- new_x
  ret$y_min_max <- y_min_max
  ret$x_min_max_list <- x_min_max_list
  ret
}
