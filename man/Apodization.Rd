\name{Apodization}
\alias{Apodization}
\title{Apodization of the FID}
\description{The function multiplies the FID by a defined factor to increase the sensibility and/or resolution of the spectra.}
\usage{
Apodization(Fid_data, Fid_info = NULL, DT = NULL, type.apod = c("exp","cos2", 
            "blockexp","blockcos2","gauss","hanning","hamming"), phase = 0,
            rectRatio = 1/2, gaussLB = 1, expLB = 0.3, plotWindow = F, 
            returnFactor = F)
}
\arguments{
  \item{Fid_data}{Matrix containing the FIDs, one row per signal, as outputted by \code{\link{ReadFids}}.}
  \item{Fid_info}{Matrix containing the info about the FIDs, one row per signal, as outputted by \code{\link{ReadFids}}.}
  \item{DT}{If given, used instead of \code{Fid_info} to give the Dwell Time, the time between 2 points of the FID.}
  \item{type.apod}{Type of apodization, see details.}
  \item{phase}{Phase at which the apodization window is maximum for \code{cos2}, \code{hanning} and \code{hamming} types. For example, if phase is 0.2, the maximum is at 20\% of the signal.}
  \item{rectRatio}{If there is a rectangular window, ratio between the width of the window and the width of the signal.}
  \item{gaussLB}{Line Broadening for the gaussian window, see details.}
  \item{expLB}{Line Broadening for the exponential window, see details.}
  \item{plotWindow}{If \code{TRUE}, a plot of the signal applied to the FID is displayed.}
    \item{returnFactor}{If \code{TRUE}, returns a list with the final FIDs and the apodization function.}
}
\details{

The apodization is usually performed in order to increase the sensitivity, \emph{i.e.} the Signal-to-Noise Ratio (SNR) of the spectra. This is based on the fact that the signal intensity is decreasing over time unlike the noise that keeps a constant amplitude, leaving a noisy tail at the end of the FID. Multiplying the FID with a decaying signal will then increase the SNR. 
Since the area under the spectral peak remains unchanged, a faster decay will also result in a reduced peak height in spectra, lowering the spectral resolution. Optimal trade-off parameters for the apodization signal are thus needed to prevent high losses in sensitivity/resolution.


A FID of the form \eqn{s_0\exp(i2\pi\nu t)\exp(-t/T)}{s0 exp(i*2*pi*nu*t) exp(-t/T)} has a peak
in its spectrum at the frequency \eqn{\nu}{nu} of width that is inversely proportional to \eqn{T}{T}.
This peak is called a \emph{spectral line} and its width a \emph{spectral width}.

In the case of the exponential multiplication (\code{"exp"}), which is the default apodization, the decaying exponential becomes:
\deqn{\exp(-t(1/T + LB))}{exp(-t(1/T + LB))}
The new decay \eqn{T^*}{T*} which satisfies \eqn{1/T^* = 1/T + LB}{1/T* = 1/T  + LB} is therefore smaller so the spectral line is \emph{broader}.
That is why we call this parameter the Line Broadening.

If \emph{LB} increases, the SNR increases but at the expense of the spectral resolution. Usual values in proton NMR for “LB” found in the literature are 0.3 for the NOESY presat pulse sequence and -0.01 for the CMPG presat pulse sequence. It should not exceed the value of 1 to avoid information loss.

The different types of apodization are:
\describe{
  \item{exp}{The signal is multiplied by a decreasing exponential \eqn{\exp(-t/\textsf{expLB)}}{exp(-t/expLB)}.}
  \item{cos2}{The signal is multiplied by the value of a \eqn{\cos^2}{cosinus squared} from 0 (where its value is 1) until \eqn{\pi/2}{pi/2} (where its value is 0).}
  \item{blockexp}{The first part of the signal (defined by \code{rectRatio}) is left unchanged and the second is multiplied by \eqn{\exp(-t/\textsf{expLB)}}{exp(-t/expLB)} starting at value 1.}
  \item{blockcos2}{the first part is left unchanged as with \code{blockexp} and the second part is multiplied by a \eqn{\cos^2}{cosinus squared} where its value starts at 1 at the end of the block and ends at 0 at the end of the signal.}
  \item{gauss}{The signal is multiplied by a gaussian window centered at the beginning of the FID and with \eqn{\sigma = 1/\textsf{gaussLB}}{sigma=1/gaussLB}.}
  \item{hanning}{The signal is multiplied by a hanning window : \eqn{0.5 + 0.5\cos}{0.5 + 0.5} cos.}
  \item{hamming}{The signal is multiplied by a hamming window : \eqn{0.54 + 0.46\cos}{0.54 + 0.46} cos.}
}


}
\value{
If \code{returnFactor} is \code{TRUE}, will return a list with the following elements: \code{Fid_data} and \code{Factor}. Otherwise, the function will just return \code{Fid_data}. 
  \item{Fid_data}{The apodized FIDs.}
  \item{Factor}{The apodization signal.}
}
\references{
  Inspired from the matNMR library.

  Martin, M., Legat, B., Leenders, J., Vanwinsberghe, J., Rousseau, R., Boulanger, B., & Govaerts, B. (2018). PepsNMR for 1H NMR metabolomic data pre-processing. \emph{Analytica chimica acta}, 1019, 1-13.

  Rousseau, R. (2011). \emph{Statistical contribution to the analysis of metabonomics data in 1H NMR spectroscopy}
  (Doctoral dissertation, PhD thesis. Institut de statistique, biostatistique et sciences actuarielles, Université catholique de Louvain, Belgium).
}
\author{
Benoît Legat & Manon Martin
}

\examples{
require(PepsNMRData)
Apod_res <- Apodization(Data_HS_sp$FidData_HS_2, 
                          FidInfo_HS, plotWindow=FALSE)

#or
Apod_res <- Apodization(Data_HS_sp$FidData_HS_2, 
                          FidInfo_HS, plotWindow=FALSE, returnFactor=TRUE)
Apod_fid = Apod_res[["Fid_data"]]
plot(Apod_res[["Factor"]], type="l")
}
\keyword{ manip }
