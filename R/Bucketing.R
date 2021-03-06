#' @export Bucketing
Bucketing <- function(Spectrum_data, width = FALSE, mb = 500, boundary = NULL, 
                      intmeth = c("r", "t"), tolbuck = 10^-4) {
  
  # Data initialisation and checks ---------------------------------------------- 
  begin_info <- beginTreatment("Bucketing", Spectrum_data)
  Spectrum_data <- begin_info[["Signal_data"]]
  checkArg(mb, c("num", "pos"))
  checkArg(width, "bool", can.be.null = FALSE)
  checkArg(boundary, "num", can.be.null = TRUE)
  checkArg(tolbuck, "num", can.be.null = TRUE)
  
  intmeth <- match.arg(intmeth)
  
  if(length(boundary)>2) {
    warning("boundary has a length > 2, only the first two elements are taken into account.")
  }
  
  if (mb == 1 & width == FALSE) {
    stop("A minimum of 2 buckets is required")
  }
  
  ppm <- as.numeric(colnames(Spectrum_data))
  old_width <- abs(ppm[2] - ppm[1])
  n <- nrow(Spectrum_data)
  old_m <- ncol(Spectrum_data)
  
  
  
  # calculates the limits of the old buckets
  old_buckets <- c((ppm[1] - (ppm[2] - ppm[1])/2), (ppm[2:old_m] + ppm[1:(old_m - 
                 1)])/2, ppm[old_m] + (ppm[old_m] - ppm[old_m - 1])/2)
 
  if (is.null(boundary)) {

    boundary <- c(ppm[1], ppm[length(ppm)])

  } else if ((boundary[2] - boundary[1]) == 0){
    stop("the boundaries are identical")
  }
  
  if (n == 0) {
    stop("Empty ppm scale")
  }
  
  decreasing <- (ppm[old_m] <= ppm[1])
  
  if (width == TRUE) {
    
    if (mb <= old_width) {
      stop("mb is <= old_width")
    }
    boundary <- sort(boundary, decreasing=FALSE)
    new_width <- mb
    
    if (decreasing){
      buckets <- seq(from = boundary[2], to = boundary[1], by = - new_width)# new limits of the buckets intervals
      mb <- length(buckets)-1
      ppmleft <- buckets[1]
      ppmright <- buckets[mb+1]
      
    } else{
      buckets <- seq(from = boundary[1], to = boundary[2], by = new_width)# new limits of the buckets intervals
      mb <- length(buckets)-1
      ppmleft <- buckets[1]
      ppmright <- buckets[mb+1]
    }
    
    
    if (length(buckets) == 1 | is.null(buckets)) {
      stop("modify width, mb or boundary to create at leat 2 buckets")
    }    
    
  } else { # width == FALSE
      checkArg(mb, c("int", "pos"), can.be.null = FALSE)
      
      if (mb == 1 ) {
        stop("A minimum of 2 buckets is required")
      }
  
      # values of ppmleft and ppmright 
      if(decreasing & ((boundary[2] - boundary[1])>0)){
            boundary <- rev(boundary)
      }
    
      ppmleft = boundary[1]
      ppmright = boundary[2]
      
      # Verifies if the new ppm interval is effective and in the right direction
      if (!decreasing) {
        if ((ppmright - ppmleft) <= 0) 
          stop("Your new ppm interval is not coherent with the old spectral matrix")
      }
      if (decreasing) {
        if ((ppmright - ppmleft) >= 0) 
          stop("Your new ppm interval is not coherent with the old spectral matrix")
      }
      
      # Check for values of ppmleft and ppmright when manually imputed
      # Verifies if the new ppm interval is included in the old one
      if (decreasing == F) {
        if ((ppmleft < old_buckets[1]) | (ppmright > old_buckets[old_m + 
          1]))
          {
          stop("new ppm limits not included in original ppm limits")
        }
      } else {
        if ((ppmleft > old_buckets[1]) | (ppmright < old_buckets[old_m + 1]))  {
          stop("new ppm limits not included in original ppm limits")
        }
      }
      
      # Calculates the limits of the buckets intervals and centers for the
      # new spectral matrix
      buckets <- seq(ppmleft, ppmright, length.out = mb + 1)  # new limits of the buckets intervals
      
      
  }
  
  # Bucketting ----------------------------------------------
  
  # Verifies if buckets are of constant length,test if the old buckets
  # are decreasing or not
  old_buckets_lengths <- abs(ppm[1:(mb - 1)] - ppm[2:mb])  #vector of length of old buckets
  mbl_old <- mean(old_buckets_lengths)  # mean length of old buckets
  
  if (sum(abs(old_buckets_lengths - mbl_old) > tolbuck * old_buckets_lengths) > 0) {
    warning("The buckets of your original spectra are not of constant length")
  }
  # calculation 
  centers <- (buckets[1:mb] + buckets[2:(mb + 1)])/2  # new centers of the buckets intervals
  bl_new <- abs(ppmright - ppmleft)/(mb)
  
  # verifies if data reduction is effective
  if (bl_new < mbl_old) {
    stop("Bucketing (data reduction) is not effective: the size of new buckets is smaller than the size of old buckets.")
  }
  
  # creates the matrix for the bucketed data
  bucketed <- matrix(0, nrow = n, ncol = mb, dimnames = list(rownames(Spectrum_data), 
                      centers))
  
  # Loop on the ppms of the new matrix - Integrates original spectra on
  # each new bucket
  for (i in 1:mb) {
    # locates the window of the original spectra to be used to integrate
    # old_buckets[from] is at the left of buckets[i] and old_buckets[to] is
    # at the right of buckets[i+1] if ppm it is decreasing, that means we
    # want it higher e.g. ppm[from] >= buckets[i]
    
    from <- binarySearch(ppm, buckets[i], !decreasing)
    to <- binarySearch(ppm, buckets[i + 1], decreasing)
    # Now that old_buckets[from] is on the left and old_buckets[to] is on
    # the right, we can intergrate the intensity in the interval
    # (bucket[i],bucket[i+1]) by rectangular or trapezoidal method
    
    # RECTANGULAR METHOD  ======================
    if (intmeth == "r") {
      # Integration on the old buckets that are completely inside the new
      # bucket
      if ((from + 1) < (to - 1))  {
        # calculates the sum of intensities x the bucket length
        int_inside <- base::apply(as.matrix(Spectrum_data[, as.vector((from + 
          1):(to - 2))], nrows = n, ncol = to - from - 2), 1, sum) * 
          mbl_old
      } else {
        # else the integral is just 0
        int_inside <- 0
      }
      
      # Integrates on the last old bucket which is on the left of the new
      # bucket
      int_left <- Spectrum_data[, from] * abs(buckets[i] - old_buckets[from + 1])
      # Integrates on the last old bucket which is on the right of the new
      # bucket (if it is not the same than the last one...)
      if (to > (from + 1))  {
        int_right <- Spectrum_data[, to - 1] * abs(buckets[i + 
          1] - old_buckets[to - 1])
      } else {
        int_right <- 0
      }
      # Calculates intensity for bucket i and Normalizes the bucketed
      # intensities to the same integral than the previous ones
      bucketed[, i] <- (int_inside + int_left + int_right)/bl_new 
      }
    
    
    # TRAPEZOIDAL METHOD  ====================== 
    if (intmeth == "t") {
      left_part_trapz <- function(x1, x2, xmid, y1, y2)  {
        # Integral from x1 to xmid of the trapezium defined by (x1,y1) and
        # (x1,y2) /| y2 / | / | # : Integral /# | y1 /## | |## | |## | x1 | x2
        # xmid
        if (x1 == x2) {
          # Integral is 0 but should be of the form of y1 and y2
          return(y1 * 0)
        } else  {
          ymid <- y1 + (y2 - y1) * (xmid - x1)/(x2 - x1)
          half_interval <- abs(xmid - x1)/2
          return((y1 + ymid) * half_interval)
        }
      }
      # Now that ppm[from] is on the left and ppm[to] is on the right, we can
      # take the trapezium over this interval and remove * the integral from
      # ppm[from] to buckets[i] and * the integral from buckets[i+1¯ to
      # ppm[to].  else the integral is just 0 Trapezium from ppm[from] to
      # ppm[to]] (we will need to remove some at the extremities)
      
      if (from < to && buckets[i] != buckets[i + 1]) {
        half_intervals_length <- abs(ppm[(from + 1):to] - ppm[from:(to - 1)])/2
        # The contribution of the points to half the area of the trapezium on
        # their right
        trapz_right <- base::rowSums(sweep(Spectrum_data[, from:(to - 1), drop = F], 
                                           MARGIN = 2, half_intervals_length, `*`))
        
        # The contribution of the points to half the area of the trapezium on
        # their left
        trapz_left <- base::rowSums(sweep(Spectrum_data[, (from + 1):to, drop = F], 
                                          MARGIN = 2, half_intervals_length, `*`))
        
        # Integral of the part of the integral of the leftmost trapezium that
        # is after buckets[i]
        left_part <- left_part_trapz(ppm[from], ppm[from + 1], buckets[i], 
                                     Spectrum_data[, from], Spectrum_data[, from + 1])
        
        right_part <- left_part_trapz(ppm[to], ppm[to - 1], buckets[i + 1], 
                                      Spectrum_data[, to], Spectrum_data[, to - 1])
        
        bucketed[, i] <- (trapz_right + trapz_left - left_part - right_part)/bl_new

      }
    }
    
    
  }
  # Data finalisation ----------------------------------------------

  cat("PPM range of the bucketted spectral matrix:",  
      sprintf("%.5f",c(as.numeric(colnames(bucketed)[1])+bl_new/2,
         as.numeric(colnames(bucketed)[mb])+bl_new/2)), "\n")
  
  cat("PPM width between 2 buckets:", 
      sprintf("%.5f",abs(as.numeric(colnames(bucketed)[1]) -
            as.numeric(colnames(bucketed)[2]))), "\n") 
        
  return(endTreatment("Bucketing", begin_info, bucketed))
}
