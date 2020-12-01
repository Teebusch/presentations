# Auxilliary R file to summarize the posterior distribution
# written for Fitting growth curve models in the Bayesian framework
# Author: Zita Oravecz
# Credits: parts of this code is taken from the
# Utility program DBDA2E-utilities.R for use with the book
# Kruschke, J. K. (2015). Doing Bayesian Data Analysis, Second Edition:
# A Tutorial with R, JAGS, and Stan. Academic Press / Elsevier

require(rjags)

HDIofMCMC = function( sampleVec , HDImass=0.95 ) {
  # Computes highest density interval from a sample of representative values,
  #   estimated as shortest credible interval.
  # Arguments:
  #   sampleVec
  #     is a vector of representative values from a probability distribution.
  #   HDImass is a scalar between 0 and 1, indicating the mass within the credible
  #     interval that is to be estimated.
  #   HDIlim is a vector containing the limits of the HDI
  sortedPts = sort( sampleVec )
  ciIdxInc = ceiling( HDImass * length( sortedPts ) )
  nCIs = length( sortedPts ) - ciIdxInc
  ciWidth = rep( 0 , nCIs )
  for ( i in 1:nCIs ) {
    ciWidth[ i ] = sortedPts[ i + ciIdxInc ] - sortedPts[ i ]
  }
  HDImin = sortedPts[ which.min( ciWidth ) ]
  HDImax = sortedPts[ which.min( ciWidth ) + ciIdxInc ]
  HDIlim = c( HDImin , HDImax )
  return( HDIlim )
}

summarizePost = function(samples, HDImass = 0.95, CI=c(.025,.975),  ROPE=c(-0.05,0.05), filters=NULL, file=NULL) {
  # Number of models passed to the function
  sampleCount = 1

  # If only one model is passed make a list of it
  if(!is.mcmc.list(samples)) {
    sampleCount = length(samples)
  }else{
    samples = list(samples)
  }

  # Make sure filter is a vector
  if(!is.null(filters) && !is.vector(filters))
  {
    filters = c(filters)
  }

  # Pre Calculate the number of expected rows
  rowCount = 0
  drops = list()
  for(k in 1:sampleCount) {
    drops[[k]] = c(0)
    if(is.null(filters)) {
      rowCount = rowCount + nvar(samples[[k]])
    }else{
      nvar = nvar(samples[[k]])
      varnames = varnames(samples[[k]])
      for(l in 1:nvar) {
        varname = varnames[[l]]
        isOK = FALSE
        for(f in 1:length(filters)) {
          isOK = isOK || regexpr(filters[[f]], varname)[1] > 0
        }
        if(isOK) {
          rowCount = rowCount + 1
        }else{
          drops[[k]] = c(drops[[k]],l)
        }
      }
    }
  }

  columnNames = c()
  # Pre-allocate
  result = data.frame(
    mean=rep(NaN,rowCount),
    PSD=rep(NaN,rowCount),
    quantileLow=rep(NaN,rowCount),
    quantileHigh=rep(NaN,rowCount),
    hdiLow=rep(NaN,rowCount),
    hdiHigh=rep(NaN,rowCount),
    stROPE=rep(NaN,rowCount),
    inROPE=rep(NaN,rowCount),
    ltROPE=rep(NaN,rowCount),
    ESS=rep(NaN,rowCount),
    RHAT=rep(NaN,rowCount),
    stringsAsFactors=FALSE
  )

  # Keeping track of the currently edited row
  currentRow = 0

  # Process the models
  for(k in 1:sampleCount) {
    # Make the name prefix if multiple models are present
    prefix = ""
    if( sampleCount > 1 ) {
      prefix = paste(k,".",sep="")
    }

    # Get the sample
    sample = samples[[k]]

    # Some common values
    variables = nvar(sample)
    varnames = varnames(sample)
    iterations = niter(sample)
    chains = nchain(sample)

    for(j in 1:variables) {
      if(!(j %in% drops[[k]])) {
        currentRow = currentRow + 1

        uvalue = unlist(sample[,j])
        value = sample[,j]

        columnNames = c(columnNames, paste(prefix,varnames[[j]],sep=""))

        result[currentRow,"ESS"] <- as.integer(round(effectiveSize(uvalue),1))
        result[currentRow,"mean"] <- mean(uvalue)

        result[currentRow,"stROPE"] <- mean(unlist(lapply(uvalue, function(x) ifelse(x < ROPE[1], 1, 0) )));
        result[currentRow,"ltROPE"] <- mean(unlist(lapply(uvalue, function(x) ifelse(x > ROPE[2], 1, 0) )));
        result[currentRow,"inROPE"] <- mean(unlist(lapply(uvalue, function(x) ifelse(x <= ROPE[2] && x >= ROPE[1], 1, 0) )));

        HDI = HDIofMCMC( uvalue , HDImass )
        result[currentRow,"hdiLow"] <- HDI[1]
        result[currentRow,"hdiHigh"] <- HDI[2]

        resultCI = quantile(uvalue, CI)

        result[currentRow,"quantileLow"] <- resultCI[1]
        result[currentRow,"quantileHigh"] <- resultCI[2]

        result[currentRow,"PSD"] <- sd(uvalue)

        # RHAT calc

        # Get chain stats
        chainmeans = c()
        chainvars = c()
        for(i in 1:chains) {
            sum = sum(value[[i]])
            var = var(value[[i]])
            mean = sum / iterations

            chainmeans = c(chainmeans,mean)
            chainvars = c(chainvars,var)
        }
        globalmean = sum(chainmeans) / chains;

        #w in gelmanrubin with code === value
        #w = sum(var(coda)) / nchains;
        globalvar = sum(chainvars) / chains;

        # Compute between- and within-variances and MPV
        b = sum((chainmeans - globalmean)^2) * iterations / (chains - 1);

        varplus = (iterations - 1) * globalvar / iterations + b / iterations;

        # Gelman-Rubin statistic
        rhat = sqrt(varplus / globalvar);

        if(is.na(rhat)) {
            rhat = 1;
        }

        result[currentRow,"RHAT"] <- rhat
      }
    }
  }

  # Columns to round
  # cnames = c("ESS","mean","quantileLow","quantileHigh","hdiLow","hdiHigh","PSD","RHAT")
  cnames = c("ESS","mean","quantileLow","quantileHigh","hdiLow","hdiHigh","PSD","RHAT", "inROPE", "stROPE", "ltROPE")

  # Round a bit
  result[cnames] = apply(result[cnames], 2, function(x) round(x,4))

  # Rename columns
  if(length(result) > 0) {
    names(result)[names(result) == 'hdiLow'] <- paste(sprintf("%.0f", round(HDImass*100, digits = 2)),"HDI_Low",sep="% ")
    names(result)[names(result) == 'hdiHigh'] <- paste(sprintf("%.0f", round(HDImass*100, digits = 2)),"HDI_High",sep="% ")
    names(result)[names(result) == 'quantileLow'] <- paste("PCI",sprintf("%.2f%%", round(CI[1]*100, digits = 3)),sep=" ")
    names(result)[names(result) == 'quantileHigh'] <- paste("PCI", sprintf("%.2f%%", round(CI[2]*100, digits = 3)),sep=" ")
    names(result)[names(result) == 'inROPE'] <- paste("", sprintf("(%.2f,%.2f)", round(ROPE[1], digits = 3), round(ROPE[2], digits = 3)))
    names(result)[names(result) == 'stROPE'] <- paste("st", sprintf("%.2f", round(ROPE[1], digits = 3)),sep=" ")
    names(result)[names(result) == 'ltROPE'] <- paste("lt", sprintf("%.2f", round(ROPE[2], digits = 3)),sep=" ")
  }

  # Set the row names
  row.names(result) <- columnNames

  if(!is.null(file)) {
    write.table(result, file = file, append = FALSE, quote = TRUE, sep = ",",
            eol = "\n", na = "NA", dec = ".", row.names = TRUE,
            col.names = NA, qmethod = c("escape", "double"),
            fileEncoding = "utf-8")
  }

  # Return
  result
}
