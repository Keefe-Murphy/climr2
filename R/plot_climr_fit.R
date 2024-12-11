#' Plot climr output
#'
#' Plots different types of fitted models for global or hemispheric data from NASA at different intervals.
#'
#' @param x An object of class \code{"climr_fit"} outputted from the \code{link{fit}} function.
#' @param time_grid An optional time grid over which to produce fitted values of the model.
#' @param ... Catches unused arguments to \code{plot} (not currently implemented).
#'
#' @return Nothing, just a nice ggplot returned invisibly to enable further modification (seee examples).
#'
#' @export
#' @importFrom ggplot2 "ggplot" "aes" "geom_point" "theme_bw" "xlab" "ylab" "ggtitle" "geom_line" "theme" "scale_color_viridis_c"
#' @importFrom tidyr "tibble"
#' @author Keefe Murphy - <\email{keefe.murphy@@mu.ie}>
#' @seealso \code{\link{fit}}, \code{\link{load_climr}}
#' @examples
#' dat <- load_climr(type = "SH")
#' mod1 <- fit(dat)
#' mod2 <- fit(dat, data_type="monthly", fit_type="smooth.spline")
#' mod3 <- fit(dat, data_type="quarterly", fit_type="loess")
#' plot(mod1)
#' plot(mod2)
#' plot(mod3)
#'
#' # Invisible returning
#' \dontrun{
#' library(ggplot2)
#' p <- plot(mod3)
#' p +
#'   ylab("Temperature Anomaly (Celsius)") +
#'   theme_minimal() +
#'   labs(colour="Temperature Difference")
#' }
plot.climr_fit <- function(x, time_grid = pretty(x$data$x, n=100), ...) {

  ## Create a nice plot from the output of fit.climr()

  ## First, get the data set
  df <- x$data

  ## Get some predicted values based on the time grid and fit_type
  fits <- switch(x$fit_type,
                 lm = {
                   tidyr::tibble(time_grid, pred=stats::predict(x$model,
                                                  newdata=tidyr::tibble(x=time_grid)))
                 },
                 loess = {
                   tidyr::tibble(time_grid, pred=stats::predict(x$model,
                                                  newdata=tidyr::tibble(x=time_grid))) |> stats::na.omit()
                 },
                 smooth.spline = {
                   tidyr::tibble(time_grid, pred=stats::predict(x$model, tidyr::tibble(time_grid))$y[,1L])
                 })

  ## Finally, create the plot
  p <- ggplot2::ggplot(df, ggplot2::aes(x=x, y=temp)) +
    ggplot2::geom_point(ggplot2::aes(colour=temp)) +
    ggplot2::theme_bw() +
    ggplot2::xlab("Year") +
    ggplot2::ylab("Temperature Anomaly") +
    ggplot2::ggtitle(paste(x$fit_type, "based on", x$data_type, attr(x, "source"), "data")) +
    ggplot2::geom_line(data = fits, ggplot2::aes(x = time_grid, y = pred, colour = pred), linewidth = 1.5) +
    ggplot2::theme(legend.position = "None") +
    ggplot2::scale_color_viridis_c()
  print(p)
  invisible(p)
}
