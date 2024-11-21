plot.climr_fit <- function(x, time_grid = pretty(x$data$x, n=100), ...) {

  ## Create a nice plot from the output of fit.climr()

  ## First, get the data set
  df <- x$data

  ## Get some predicted values based on the time grid and fit_type
  fits <- switch(x$fit_type,
                 lm = {
                   tibble(time_grid, pred=predict(x$model,
                                                  newdata=tibble(x=time_grid)))
                 },
                 loess = {
                   tibble(time_grid, pred=predict(x$model,
                                                  newdata=tibble(x=time_grid))) |> stats::na.omit()
                 },
                 smooth.spline = {
                   tibble(time_grid, pred=predict(x$model, tibble(time_grid))$y[,1L])
                 })

  ## Finally, create the plot
  ggplot2::ggplot(df, aes(x=x, y=temp)) +
    ggplot2::geom_point(aes(colour=temp)) +
    ggplot2::theme_bw() +
    ggplot2::xlab("Year") +
    ggplot2::ylab("Temperature Anomaly") +
    ggplot2::ggtitle(paste(x$fit_type, "based on", x$data_type, attr(x, "source"), "data")) +
    ggplot2::geom_line(data = fits, aes(x = time_grid, y = pred, colour = pred)) +
    ggplot2::theme(legend.position = "None") +
    viridis::scale_color_viridis_c()
}
