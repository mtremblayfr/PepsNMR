\name{SolventSuppression}
\alias{SolventSuppression}
\title{
Suppress the Solvent signal present in each FID.
}
\description{
Signal smooting for water residuals resonance removal.

}
\usage{
SolventSuppression(Fid_data, lambda.ss = 1e6, ptw.ss = TRUE,
                               returnSolvent = F)
}
\arguments{
  \item{Fid_data}{Matrix containing the FIDs, one row per signal, as outputted by \code{\link{ReadFids}}.}
  \item{lambda.ss}{Penalty on roughness used to calculate the smoothed version of the FID.
  The higher lambda is, the smoother the estimated solvent signal will be.}
  \item{ptw.ss}{If \code{TRUE}, calculates the solvent signal in C using the \code{ptw} package which is a lot faster.
  The R version is only kept in case of problems with the installation of \code{ptw}.}
    \item{returnSolvent}{If \code{TRUE}, returns a list with the resulting FIDs, the real and imaginary parts of the estimated solvent signal, see the examples.}
}
\details{
FIDs usually present a wavy shape. Under the assumption that water is the main compound of the analyzed samples, its signal can be modelled by the smoothing of the FIDs.
We then subtract this wave, \emph{i.e.} the solvent residuals resonance signal, from the original FIDs.


The smoothing is done with a Whittaker smoother which is obtained by the minimization of
\deqn{V + \lambda R}{V + \lambda R}
where
\itemize{
  \item \eqn{V} is the sum of the squared differences between the original and the smoothed signal.
  \item \eqn{R} measures the roughness of the estimated signal.
}

The larger \eqn{\lambda} is, the smoother the solvent residuals resonance signal.
Eilers (2003) and Frasso & Eilers (2015) suggest different ways to tune \eqn{\lambda} in order to optimise the smoothing: either visually, by cross-validation or using the V-curve procedure.
 


}
\value{
If \code{returnSolvent = TRUE}, will return a list with the following elements: \code{Fid_data}, \code{SolventRe} and \code{SolventIm}. Otherwise, the function will just return \code{Fid_data}.

\item{Fid_data}{The matrix of FIDs with the solvent residuals signal removed.}
\item{SolventRe}{The real part of the solvent signal.}
\item{SolventIm}{The imaginary part of the solvent signal.}
}
\references{

  Martin, M., Legat, B., Leenders, J., Vanwinsberghe, J., Rousseau, R., Boulanger, B., & Govaerts, B. (2018). PepsNMR for 1H NMR metabolomic data pre-processing. \emph{Analytica chimica acta}, 1019, 1-13.
  

  Frasso, G., & Eilers, P.H.C. (2015). L-and V-curves for optimal smoothing. \emph{Statistical Modelling}, 15(1), 91-111.
  
   Rousseau, R. (2011). Statistical contribution to the analysis of metabonomics data in 1H NMR spectroscopy. PhD thesis. Institut de statistique, biostatistique et sciences actuarielles, Université catholique de Louvain, Belgium.

  Eilers, P.H.C. (2003). A perfect smoother. \emph{Analytical Chemistry},  75(14), 3631-3636.
  
}
\author{
Benoît Legat & Manon Martin
}


\seealso{
See also \code{\link{BaselineCorrection}} which also uses the Whittaker smoother.
}
\examples{
require(PepsNMRData)
Ss.fid <- SolventSuppression(Data_HS_sp$FidData_HS_1, returnSolvent=FALSE)

#or
Ss.res <- SolventSuppression(Data_HS_sp$FidData_HS_1, returnSolvent=TRUE)
Ss.fid = Ss.res[["Fid_data"]]
SolventRe = Ss.res[["SolventRe"]]
plot(SolventRe[1,], type="l")

}
\keyword{ manip }
