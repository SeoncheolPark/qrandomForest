#' Method of Moments Estimator for gamma dist.
#'
#' mom_gamma function will calculate mom estimate for the shape parameter "k" and the scale parameter "theta" by using given sample.
#'
#' @return A 2 by 1 vector containing estimate of parameters k and theta: c(k, theta)
#' @examples
#' hello()
#' @useDynLib qrandomForest, .registration = TRUE
#' @importFrom Rcpp evalCpp sourceCpp
#' @exportPattern ^[[:alpha:]]+



# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Build and Reload Package:  'Cmd + Shift + B'
#   Check Package:             'Cmd + Shift + E'
#   Test Package:              'Cmd + Shift + T'

hello <- function() {
  print("Hello, world!")
}
