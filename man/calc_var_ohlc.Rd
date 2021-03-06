% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R
\name{calc_var_ohlc}
\alias{calc_var_ohlc}
\title{Calculate the variance of an \emph{OHLC time series}, using different range
estimators and \code{RcppArmadillo}.}
\usage{
calc_var_ohlc(
  oh_lc,
  calc_method = "yang_zhang",
  lag_close = 0L,
  scal_e = TRUE,
  in_dex = 0L
)
}
\arguments{
\item{\code{oh_lc}}{An \emph{OHLC time series} or a \emph{numeric matrix} of
prices.}

\item{\code{calc_method}}{A \emph{character} string representing the range
estimator for calculating the variance.  The estimators include:
\itemize{
  \item "close" close-to-close estimator,
  \item "rogers_satchell" Rogers-Satchell estimator,
  \item "garman_klass" Garman-Klass estimator,
  \item "garman_klass_yz" Garman-Klass with account for close-to-open price jumps,
  \item "yang_zhang" Yang-Zhang estimator,
 }
 (The default is the \code{calc_method = "yang_zhang"}.)}

\item{\code{lag_close}}{A \emph{vector} with the lagged \emph{close} prices
of the \emph{OHLC time series}.  This is an optional argument. (The
default is \code{lag_close = 0}.)}

\item{\code{scal_e}}{\emph{Boolean} argument: Should the returns be divided
by the time index, the number of seconds in each period? (The default is
\code{scal_e = TRUE}.)}

\item{\code{in_dex}}{A \emph{vector} with the time index of the \emph{time
series}.  This is an optional argument. (The default is \code{in_dex = 0}.)}
}
\value{
A single \emph{numeric} value equal to the variance of the
  \emph{OHLC time series}.
}
\description{
Calculate the variance of an \emph{OHLC time series}, using different range
estimators and \code{RcppArmadillo}.
}
\details{
The function \code{calc_var_ohlc()} calculates the variance
  from all the different intra-day and day-over-day returns (defined as the
  differences of \emph{OHLC} prices), using several different variance
  estimation methods.

  The default \code{calc_method} is \emph{"yang_zhang"}, which theoretically
  has the lowest standard error among unbiased estimators.
  The methods \emph{"close"}, \emph{"garman_klass_yz"}, and
  \emph{"yang_zhang"} do account for \emph{close-to-open} price jumps, while
  the methods \emph{"garman_klass"} and \emph{"rogers_satchell"} do not
  account for \emph{close-to-open} price jumps.

  If \code{scal_e} is \code{TRUE} (the default), then the returns are
  divided by the differences of the time index (which scales the variance to
  the units of variance per second squared.) This is useful when calculating
  the variance from minutely bar data, because dividing returns by the
  number of seconds decreases the effect of overnight price jumps. If the
  time index is in days, then the variance is equal to the variance per day
  squared.
  
  The optional argument \code{in_dex} is the time index of the \emph{time
  series} \code{oh_lc}. If the time index is in seconds, then the
  differences of the index are equal to the number of seconds in each time
  period.  If the time index is in days, then the differences are equal to
  the number of days in each time period.
  
  The optional argument \code{lag_close} are the lagged \emph{close} prices
  of the \emph{OHLC time series}.  Passing in the lagged \emph{close} prices
  speeds up the calculation, so it's useful for rolling calculations.
  
  The function \code{calc_var_ohlc()} is implemented in \code{RcppArmadillo}
  \code{C++} code, and it's over \code{10} times faster than
  \code{calc_var_ohlc_r()}, which is implemented in \code{R} code.
}
\examples{
\dontrun{
# Extract time index of SPY returns
in_dex <- c(1, diff(xts::.index(HighFreq::SPY)))
# Calculate the variance of SPY returns, with scaling of the returns
HighFreq::calc_var_ohlc(HighFreq::SPY, 
 calc_method="yang_zhang", scal_e=TRUE, in_dex=in_dex)
# Calculate variance without accounting for overnight jumps
HighFreq::calc_var_ohlc(HighFreq::SPY, 
 calc_method="rogers_satchell", scal_e=TRUE, in_dex=in_dex)
# Calculate the variance without scaling the returns
HighFreq::calc_var_ohlc(HighFreq::SPY, scal_e=FALSE)
# Calculate the variance by passing in the lagged close prices
lag_close <- HighFreq::lag_it(HighFreq::SPY[, 4])
all.equal(HighFreq::calc_var_ohlc(HighFreq::SPY), 
  HighFreq::calc_var_ohlc(HighFreq::SPY, lag_close=lag_close))
# Compare with HighFreq::calc_var_ohlc_r()
all.equal(HighFreq::calc_var_ohlc(HighFreq::SPY, in_dex=in_dex), 
  HighFreq::calc_var_ohlc_r(HighFreq::SPY))
# Compare the speed of Rcpp with R code
library(microbenchmark)
summary(microbenchmark(
  Rcpp=HighFreq::calc_var_ohlc(HighFreq::SPY),
  Rcode=HighFreq::calc_var_ohlc_r(HighFreq::SPY),
  times=10))[, c(1, 4, 5)]  # end microbenchmark summary
}
}
