---
title: Oravecz & Muth (2017). Fitting growth curve models in the Bayesian framework.
  Psychonomic Bulletin and Review
author: "Tobias Busch"
date: "July 19 2017"
output:
  html_notebook:
    fig_width: 10
    highlight: pygments
    theme: journal
    toc: yes
  html_document:
    fig_width: 10
    toc: yes
subtitle: ExpORL Journal Club
---

## Introduction

This is a Bayesian Growth Curve analysis, following the tutorial by [Oravecz & Muth (2017)](https://doi.org/10.3758/s13423-017-1281-0). The paper's accompanying git repository can be found [here](https://git.psu.edu/zzo1/FittingGCMBayesian). In some places the code has been adapted to be more concise.

**Note:** This analysis requires a working installation of the Bayesian sampling engine [JAGS](http://mcmc-jags.sourceforge.net/).


```r
library(tidyverse)  
library(stringr)    
library(rjags)

knitr::opts_chunk$set(results = "hold")

# Set ggplot theme for the this notebook
theme_set(theme_grey() + 
          theme(panel.grid.major.y = element_blank(), 
                panel.grid.minor.y = element_blank(),
                panel.grid.minor.x = element_blank()
                )
          )
```

## load and clean marital love data set
We investigate changes in father’s (n=106) feeling of marital love during transition into parenthood (a "marital love" score between 0-100). There were 4 measurement moments (-3, 3, 9, 36 months after birth of their first child). Fathers are divided into 3 groups, depending on "positivity" of life experiences within the time they were married, but before child is born (low, medium, high positivity). Examples of positive/negative evants are job promotion, death of family member etc.

We load the data and change it into long format (more convenient), add subject id, and use less cryptic column and factor level names.


```r
loveData <- read.csv("lovedata.csv")

loveData <- loveData %>% 
  rename(posFactor = PosFactor,     # father's positivity group
         lowPos = X1,               # the 2 dummy coding variables for 3-level positivity factor
         highPos = X2) %>%
  mutate(subject = as.factor(row_number()),  
         posFactor = recode_factor(posFactor, "1"="Low", "2"="Medium", "3"="High") %>% 
           C(base=2)) %>% 
  select(subject, everything())     # reorder columns

# make long format
loveData <- loveData %>% 
  gather(key = month, value = score, M1:M4) %>%
  mutate(month = recode(month, "M1"=-3, "M2"=3, "M3"=9, "M4"=36)) # measurement moment (mo. after birth)

contrasts(loveData$posFactor)   # Check: is 'Medium' reference level?
loveData
```

```
##        1 3
## Low    1 0
## Medium 0 0
## High   0 1
##     subject posFactor lowPos highPos month score
## 1         1      High      0       1    -3    79
## 2         2      High      0       1    -3    80
## 3         3      High      0       1    -3    81
## 4         4       Low      1       0    -3    78
## 5         5       Low      1       0    -3    78
## 6         6    Medium      0       0    -3    79
## 7         7       Low      1       0    -3    65
## 8         8      High      0       1    -3    77
## 9         9    Medium      0       0    -3    69
## 10       10    Medium      0       0    -3    74
## 11       11       Low      1       0    -3    74
## 12       12       Low      1       0    -3    46
## 13       13      High      0       1    -3    88
## 14       14    Medium      0       0    -3    67
## 15       15      High      0       1    -3    61
## 16       16       Low      1       0    -3    76
## 17       17    Medium      0       0    -3    87
## 18       18       Low      1       0    -3    66
## 19       19       Low      1       0    -3    79
## 20       20    Medium      0       0    -3    81
## 21       21    Medium      0       0    -3    79
## 22       22       Low      1       0    -3    52
## 23       23       Low      1       0    -3    79
## 24       24    Medium      0       0    -3    74
## 25       25    Medium      0       0    -3    77
## 26       26       Low      1       0    -3    80
## 27       27      High      0       1    -3    80
## 28       28    Medium      0       0    -3    86
## 29       29    Medium      0       0    -3    86
## 30       30       Low      1       0    -3    85
## 31       31    Medium      0       0    -3    76
## 32       32      High      0       1    -3    78
## 33       33       Low      1       0    -3    86
## 34       34      High      0       1    -3    77
## 35       35    Medium      0       0    -3    81
## 36       36       Low      1       0    -3    72
## 37       37    Medium      0       0    -3    82
## 38       38      High      0       1    -3    77
## 39       39    Medium      0       0    -3    73
## 40       40       Low      1       0    -3    77
## 41       41      High      0       1    -3    79
## 42       42      High      0       1    -3    87
## 43       43       Low      1       0    -3    66
## 44       44      High      0       1    -3    84
## 45       45       Low      1       0    -3    76
## 46       46    Medium      0       0    -3    68
## 47       47      High      0       1    -3    74
## 48       48      High      0       1    -3    73
## 49       49      High      0       1    -3    79
## 50       50    Medium      0       0    -3    80
## 51       51      High      0       1    -3    79
## 52       52       Low      1       0    -3    76
## 53       53      High      0       1    -3    77
## 54       54       Low      1       0    -3    55
## 55       55      High      0       1    -3    78
## 56       56    Medium      0       0    -3    69
## 57       57    Medium      0       0    -3    89
## 58       58    Medium      0       0    -3    62
## 59       59    Medium      0       0    -3    83
## 60       60      High      0       1    -3    79
## 61       61       Low      1       0    -3    87
## 62       62       Low      1       0    -3    84
## 63       63      High      0       1    -3    80
## 64       64    Medium      0       0    -3    84
## 65       65    Medium      0       0    -3    84
## 66       66       Low      1       0    -3    88
## 67       67       Low      1       0    -3    65
## 68       68      High      0       1    -3    56
## 69       69    Medium      0       0    -3    83
## 70       70    Medium      0       0    -3    82
## 71       71       Low      1       0    -3    79
## 72       72      High      0       1    -3    74
## 73       73    Medium      0       0    -3    83
## 74       74    Medium      0       0    -3    72
## 75       75    Medium      0       0    -3    52
## 76       76    Medium      0       0    -3    82
## 77       77    Medium      0       0    -3    86
## 78       78       Low      1       0    -3    88
## 79       79      High      0       1    -3    89
## 80       80      High      0       1    -3    70
## 81       81    Medium      0       0    -3    70
## 82       82    Medium      0       0    -3    77
## 83       83      High      0       1    -3    87
## 84       84       Low      1       0    -3    71
## 85       85      High      0       1    -3    71
## 86       86      High      0       1    -3    82
## 87       87       Low      1       0    -3    49
## 88       88      High      0       1    -3    88
## 89       89    Medium      0       0    -3    75
## 90       90      High      0       1    -3    75
## 91       91       Low      1       0    -3    73
## 92       92    Medium      0       0    -3    77
## 93       93    Medium      0       0    -3    68
## 94       94       Low      1       0    -3    66
## 95       95    Medium      0       0    -3    78
## 96       96       Low      1       0    -3    78
## 97       97       Low      1       0    -3    79
## 98       98      High      0       1    -3    80
## 99       99       Low      1       0    -3    72
## 100     100       Low      1       0    -3    77
## 101     101       Low      1       0    -3    73
## 102     102      High      0       1    -3    86
## 103     103      High      0       1    -3    85
## 104     104    Medium      0       0    -3    67
## 105     105       Low      1       0    -3    56
## 106     106    Medium      0       0    -3    86
## 107     107       Low      1       0    -3    84
## 108     108      High      0       1    -3    79
## 109       1      High      0       1     3    83
## 110       2      High      0       1     3    81
## 111       3      High      0       1     3    73
## 112       4       Low      1       0     3    80
## 113       5       Low      1       0     3    83
## 114       6    Medium      0       0     3    67
## 115       7       Low      1       0     3    67
## 116       8      High      0       1     3    74
## 117       9    Medium      0       0     3    59
## 118      10    Medium      0       0     3    74
## 119      11       Low      1       0     3    61
## 120      12       Low      1       0     3    37
## 121      13      High      0       1     3    88
## 122      14    Medium      0       0     3    70
## 123      15      High      0       1     3    79
## 124      16       Low      1       0     3    63
## 125      17    Medium      0       0     3    85
## 126      18       Low      1       0     3    66
## 127      19       Low      1       0     3    72
## 128      20    Medium      0       0     3    82
## 129      21    Medium      0       0     3    72
## 130      22       Low      1       0     3    57
## 131      23       Low      1       0     3    75
## 132      24    Medium      0       0     3    72
## 133      25    Medium      0       0     3    80
## 134      26       Low      1       0     3    72
## 135      27      High      0       1     3    80
## 136      28    Medium      0       0     3    84
## 137      29    Medium      0       0     3    88
## 138      30       Low      1       0     3    85
## 139      31    Medium      0       0     3    80
## 140      32      High      0       1     3    69
## 141      33       Low      1       0     3    85
## 142      34      High      0       1     3    80
## 143      35    Medium      0       0     3    83
## 144      36       Low      1       0     3    73
## 145      37    Medium      0       0     3    84
## 146      38      High      0       1     3    72
## 147      39    Medium      0       0     3    62
## 148      40       Low      1       0     3    74
## 149      41      High      0       1     3    77
## 150      42      High      0       1     3    76
## 151      43       Low      1       0     3    56
## 152      44      High      0       1     3    86
## 153      45       Low      1       0     3    81
## 154      46    Medium      0       0     3    75
## 155      47      High      0       1     3    76
## 156      48      High      0       1     3    72
## 157      49      High      0       1     3    76
## 158      50    Medium      0       0     3    78
## 159      51      High      0       1     3    78
## 160      52       Low      1       0     3    69
## 161      53      High      0       1     3    75
## 162      54       Low      1       0     3    69
## 163      55      High      0       1     3    76
## 164      56    Medium      0       0     3    71
## 165      57    Medium      0       0     3    82
## 166      58    Medium      0       0     3    73
##  [ reached getOption("max.print") -- omitted 266 rows ]
```

## Plot observed data


```r
loveData %>%
  ggplot(aes(month, score, group = subject)) + 
    geom_line(aes(col = subject), show.legend = F, lty="solid") +
    facet_grid(~posFactor) +
    scale_x_continuous(name = "Months After Baby was Born", breaks = c(-3, 0, 3, 9, 36)) +
    scale_y_continuous(name = "Father's Marital Love Score", limits = c(10,100))
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3-1.png)

```r

ggsave("out/observed.png", width = 10, height = 4)
```

## Prepare data for JAGS
For JAGS all data that the model should use needs to be in the form of a named list.


```r

jagsData <- list(
  "nObservations" = nrow(loveData),               # number of observations
  "nSubjects" = length(unique(loveData$subject)), # number of subjects (fathers)
  "subject" = loveData$subject,                   # subject id of observation
  "time" = loveData$month,                        # month of observation
  "lowPos" = loveData$lowPos,                     # dummy var.s for positivity factor
  "highPos" = loveData$highPos,
  "score" = loveData$score                        # dv: father's marital love score
)

glimpse(jagsData)
```

```
## List of 7
##  $ nObservations: int 432
##  $ nSubjects    : int 108
##  $ subject      : Factor w/ 108 levels "1","2","3","4",..: 1 2 3 4 5 6 7 8 9 10 ...
##  $ time         : num [1:432] -3 -3 -3 -3 -3 -3 -3 -3 -3 -3 ...
##  $ lowPos       : int [1:432] 0 0 0 1 1 0 1 0 0 0 ...
##  $ highPos      : int [1:432] 1 1 1 0 0 0 0 1 0 0 ...
##  $ score        : int [1:432] 79 80 81 78 78 79 65 77 69 74 ...
```

## Specify model in BUGS modeling language
JAGS uses the BUGS modeling language to specify models. (Win)BUGS is a software similar to JAGS. Martyn Plummer, the author of JAGS used to work on BUGS before. Note that for JAGS uses precision instead of variance to parameterize distributions. Precision is simply the inverse of the variance (1/s^2).


```r
GCM <- "
model {
# Loop over observations
for (i in 1:nObservations) {
  # Likelihood Function (assumed data generating distribution), Eq. 1
  score[i] ~ dnorm(betas[subject[i],1] + betas[subject[i],2]*time[i], 1/pow(sdLevel1Error,2))
}

# Loop over subjects
for (j in 1:nSubjects) {
  level2MeanVector[j,1] <- medPInt + betaLowPInt*lowPos[j] + betaHighPInt*highPos[j]
  level2MeanVector[j,2] <- medPSlope + betaLowPSlope*lowPos[j] + betaHighPSlope*highPos[j]

  # Level 2 bivariate distribution of intercepts and slopes, Eq. 6
  betas[j,1:2] ~ dmnorm(level2MeanVector[j,1:2], interpersonPrecisionMatrix[1:2,1:2])
}

# Prior distributions
medPInt ~ dnorm(0,0.01)
medPSlope ~ dnorm(0,0.01)

betaLowPInt ~ dnorm(0,0.01)
betaLowPSlope ~ dnorm(0,0.01)
betaHighPInt ~ dnorm(0,0.01)
betaHighPSlope ~ dnorm(0,0.01)

sdLevel1Error ~ dunif(0,100)
sdIntercept ~ dunif(0,100)
sdSlope ~ dunif(0,100)
corrIntSlope ~ dunif(-1,1)

# Transforming model parameters
interpersonCovMatrix[1,1] = pow(sdIntercept,2)
interpersonCovMatrix[2,2] = pow(sdSlope,2)
interpersonCovMatrix[1,2] = corrIntSlope * sdIntercept * sdSlope
interpersonCovMatrix[2,1] = interpersonCovMatrix[1,2]
interpersonPrecisionMatrix <- inverse(interpersonCovMatrix)

# We also keep track of other parameters of interest
# (not obligatory for the model to run, but useful for us)

# High and low positivity slopes and intercepts
lowPInt <- medPInt + betaLowPInt
highPInt <- medPInt + betaHighPInt
lowPSlope <- medPSlope + betaLowPSlope
highPSlope <- medPSlope + betaHighPSlope

# planned comparisons - contrasts between low, mid, and high intercepts and slopes
c_highLowPInt <- betaHighPInt - betaLowPInt
c_medLowPInt <- - betaLowPInt
c_highMedPInt <- betaHighPInt
c_highLowPSlope <- betaHighPSlope - betaLowPSlope
c_medLowPSlope <- - betaLowPSlope
c_highMedPSlope <- betaHighPSlope
}
"
# the model code needs to be saved in a file that is then read by the jags function
cat(GCM, file = "loveModel.bugs") 
```

## Specify the modeling and sampling parameters


```r

# the parameters we want to monitor
parameters <- c("lowPInt", "medPInt", "highPInt", 
                "lowPSlope", "medPSlope", "highPSlope",  
                "betaLowPInt", "betaHighPInt", "betaLowPSlope", "betaHighPSlope",
                "sdIntercept", "sdSlope", "corrIntSlope", "sdLevel1Error",
                "c_highLowPInt", "c_highMedPInt", "c_medLowPInt",
                "c_highLowPSlope", "c_highMedPSlope", "c_medLowPSlope",
                "betas")

# set random number generators and seeds (optional, for reproducibility)
inits <- list(
  list(.RNG.seed=5,.RNG.name="base::Mersenne-Twister"),
  list(.RNG.seed=6,.RNG.name="base::Mersenne-Twister"),
  list(.RNG.seed=7,.RNG.name="base::Mersenne-Twister"),
  list(.RNG.seed=8,.RNG.name="base::Mersenne-Twister"),
  list(.RNG.seed=9,.RNG.name="base::Mersenne-Twister"),
  list(.RNG.seed=10,.RNG.name="base::Mersenne-Twister"))

# other parameters for the model / sampling
nAdapt <- 2000              # n iterations for algorithm to adapt to data/model
nBurnIn <- 1000             # n burn-in iterations
postSamples <- 30000        # how many samples we want in total
thinning <- 5               # thinning interval
nChains <- 6                # how many sampling chains

nIter <- ceiling((postSamples * thinning)/nChains)

# initialize the model
mdl <- jags.model("loveModel.bugs", jagsData, n.chains = nChains, n.adapt = nAdapt, inits = inits, quiet = T)
```

## Get the samples
We sample from our parameters posterior distribution via the MCMC algorithm implemented in JAGS.


```r
t <- Sys.time()

# run run burn-in iterations
update(mdl, n.iter = nBurnIn, progress.bar = "gui")

# sample from the posterior distribution
codaSamples <- coda.samples(mdl,
                            variable.names = parameters,
                            n.iter = nIter,
                            thin = thinning,
                            seed = 5,
                            progress.bar = "gui")

Sys.time() - t # How long did it take to get the samples?
```

```
## Time difference of 7.676422 mins
```

## Save samples for later use
If needed, save and load samples from previous run of the model to save time.


```r
save(codaSamples, file = "out/loveModelSamples.save", compress = T)
load("loveModelSamples.save")
```

## Check convergence of chains
For each parameter we ran 6 chains with different starting values. Have all chanins converged to the same area, i.e. do all chains find similar likely values for the parameter?


```r

# Graphical convergance check. Here only done for one parameter. Normally it should be done for all parameters. 
traceplot(codaSamples[,"lowPInt"] , main="" , xlab = "Samples", ylab="Low Positivity Intercept") 
```

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9-1.png)

```r
traceplot(codaSamples[,"lowPSlope"] , main="" , xlab = "Samples", ylab="Low Positivity Slope") 
```

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9-2.png)

```r

chains = length(codaSamples)
xax = NULL
yax = NULL
for ( cc in 1:chains ) {
  calcdens = density(codaSamples[,"lowPInt"][[cc]]) 
  xax = cbind(xax,calcdens$x)
  yax = cbind(yax,calcdens$y)
}
matplot( xax , yax , type="l", xlab="Low Positivity Intercept" , ylab="Probability Density" )
```

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9-3.png)

```r

# Numerical check: Gelman Rubin (R hat) diagnostic. Should be > 1.1 for all parameters. 
# Indicates the ratio of between and within chain variances. 
gelman.diag(codaSamples, multivariate = FALSE)

# The coda package provides more diagnostic and summary functions for MCMC chains
# e.g. use plot(codaSamples) to plot all chains for all variables (takes a while).
# see also: gelman.plot(codaSamples), effectiveSize(codaSamples)
```

```
## Potential scale reduction factors:
## 
##                 Point est. Upper C.I.
## betaHighPInt          1.00       1.00
## betaHighPSlope        1.00       1.00
## betaLowPInt           1.00       1.00
## betaLowPSlope         1.00       1.00
## betas[1,1]            1.00       1.00
## betas[2,1]            1.00       1.00
## betas[3,1]            1.00       1.00
## betas[4,1]            1.00       1.00
## betas[5,1]            1.00       1.00
## betas[6,1]            1.00       1.00
## betas[7,1]            1.00       1.00
## betas[8,1]            1.00       1.00
## betas[9,1]            1.00       1.00
## betas[10,1]           1.00       1.00
## betas[11,1]           1.00       1.00
## betas[12,1]           1.00       1.00
## betas[13,1]           1.00       1.00
## betas[14,1]           1.00       1.00
## betas[15,1]           1.00       1.00
## betas[16,1]           1.00       1.00
## betas[17,1]           1.00       1.00
## betas[18,1]           1.00       1.00
## betas[19,1]           1.00       1.00
## betas[20,1]           1.00       1.00
## betas[21,1]           1.00       1.00
## betas[22,1]           1.00       1.00
## betas[23,1]           1.00       1.00
## betas[24,1]           1.00       1.00
## betas[25,1]           1.00       1.00
## betas[26,1]           1.00       1.00
## betas[27,1]           1.00       1.00
## betas[28,1]           1.00       1.00
## betas[29,1]           1.00       1.00
## betas[30,1]           1.00       1.00
## betas[31,1]           1.00       1.00
## betas[32,1]           1.00       1.00
## betas[33,1]           1.00       1.00
## betas[34,1]           1.00       1.00
## betas[35,1]           1.00       1.00
## betas[36,1]           1.00       1.00
## betas[37,1]           1.00       1.00
## betas[38,1]           1.00       1.00
## betas[39,1]           1.00       1.00
## betas[40,1]           1.00       1.00
## betas[41,1]           1.00       1.00
## betas[42,1]           1.00       1.00
## betas[43,1]           1.00       1.00
## betas[44,1]           1.00       1.00
## betas[45,1]           1.00       1.00
## betas[46,1]           1.00       1.00
## betas[47,1]           1.00       1.00
## betas[48,1]           1.00       1.00
## betas[49,1]           1.00       1.00
## betas[50,1]           1.00       1.00
## betas[51,1]           1.00       1.00
## betas[52,1]           1.00       1.00
## betas[53,1]           1.00       1.00
## betas[54,1]           1.00       1.00
## betas[55,1]           1.00       1.00
## betas[56,1]           1.00       1.00
## betas[57,1]           1.00       1.00
## betas[58,1]           1.00       1.00
## betas[59,1]           1.00       1.00
## betas[60,1]           1.00       1.00
## betas[61,1]           1.00       1.00
## betas[62,1]           1.00       1.00
## betas[63,1]           1.00       1.00
## betas[64,1]           1.00       1.00
## betas[65,1]           1.00       1.00
## betas[66,1]           1.00       1.00
## betas[67,1]           1.00       1.00
## betas[68,1]           1.00       1.00
## betas[69,1]           1.00       1.00
## betas[70,1]           1.00       1.00
## betas[71,1]           1.00       1.00
## betas[72,1]           1.00       1.00
## betas[73,1]           1.00       1.00
## betas[74,1]           1.00       1.00
## betas[75,1]           1.00       1.00
## betas[76,1]           1.00       1.00
## betas[77,1]           1.00       1.00
## betas[78,1]           1.00       1.00
## betas[79,1]           1.00       1.00
## betas[80,1]           1.00       1.00
## betas[81,1]           1.00       1.00
## betas[82,1]           1.00       1.00
## betas[83,1]           1.00       1.00
## betas[84,1]           1.00       1.00
## betas[85,1]           1.00       1.00
## betas[86,1]           1.00       1.00
## betas[87,1]           1.00       1.00
## betas[88,1]           1.00       1.00
## betas[89,1]           1.00       1.00
## betas[90,1]           1.00       1.00
## betas[91,1]           1.00       1.00
## betas[92,1]           1.00       1.00
## betas[93,1]           1.00       1.00
## betas[94,1]           1.00       1.00
## betas[95,1]           1.00       1.00
## betas[96,1]           1.00       1.00
## betas[97,1]           1.00       1.00
## betas[98,1]           1.00       1.00
## betas[99,1]           1.00       1.00
## betas[100,1]          1.00       1.00
## betas[101,1]          1.00       1.00
## betas[102,1]          1.00       1.00
## betas[103,1]          1.00       1.00
## betas[104,1]          1.00       1.00
## betas[105,1]          1.00       1.00
## betas[106,1]          1.00       1.00
## betas[107,1]          1.00       1.00
## betas[108,1]          1.00       1.00
## betas[1,2]            1.00       1.00
## betas[2,2]            1.00       1.00
## betas[3,2]            1.00       1.00
## betas[4,2]            1.00       1.00
## betas[5,2]            1.00       1.00
## betas[6,2]            1.00       1.00
## betas[7,2]            1.00       1.01
## betas[8,2]            1.00       1.00
## betas[9,2]            1.00       1.01
## betas[10,2]           1.00       1.00
## betas[11,2]           1.00       1.00
## betas[12,2]           1.00       1.00
## betas[13,2]           1.00       1.00
## betas[14,2]           1.00       1.00
## betas[15,2]           1.00       1.00
## betas[16,2]           1.00       1.00
## betas[17,2]           1.00       1.00
## betas[18,2]           1.00       1.00
## betas[19,2]           1.00       1.00
## betas[20,2]           1.00       1.00
## betas[21,2]           1.00       1.00
## betas[22,2]           1.00       1.00
## betas[23,2]           1.00       1.00
## betas[24,2]           1.00       1.00
## betas[25,2]           1.00       1.00
## betas[26,2]           1.00       1.00
## betas[27,2]           1.00       1.00
## betas[28,2]           1.00       1.00
## betas[29,2]           1.00       1.00
## betas[30,2]           1.00       1.00
## betas[31,2]           1.00       1.00
## betas[32,2]           1.00       1.00
## betas[33,2]           1.00       1.00
## betas[34,2]           1.00       1.00
## betas[35,2]           1.00       1.00
## betas[36,2]           1.00       1.00
## betas[37,2]           1.00       1.00
## betas[38,2]           1.00       1.00
## betas[39,2]           1.00       1.01
## betas[40,2]           1.00       1.00
## betas[41,2]           1.00       1.00
## betas[42,2]           1.00       1.00
## betas[43,2]           1.00       1.00
## betas[44,2]           1.00       1.00
## betas[45,2]           1.00       1.00
## betas[46,2]           1.00       1.00
## betas[47,2]           1.00       1.00
## betas[48,2]           1.00       1.00
## betas[49,2]           1.00       1.00
## betas[50,2]           1.00       1.00
## betas[51,2]           1.00       1.00
## betas[52,2]           1.00       1.00
## betas[53,2]           1.00       1.00
## betas[54,2]           1.00       1.00
## betas[55,2]           1.00       1.00
## betas[56,2]           1.00       1.00
## betas[57,2]           1.00       1.00
## betas[58,2]           1.00       1.00
## betas[59,2]           1.00       1.00
## betas[60,2]           1.00       1.00
## betas[61,2]           1.00       1.00
## betas[62,2]           1.00       1.00
## betas[63,2]           1.00       1.00
## betas[64,2]           1.00       1.00
## betas[65,2]           1.00       1.00
## betas[66,2]           1.00       1.00
## betas[67,2]           1.00       1.00
## betas[68,2]           1.00       1.00
## betas[69,2]           1.00       1.00
## betas[70,2]           1.00       1.00
## betas[71,2]           1.00       1.00
## betas[72,2]           1.00       1.01
## betas[73,2]           1.00       1.00
## betas[74,2]           1.00       1.00
## betas[75,2]           1.00       1.00
## betas[76,2]           1.00       1.00
## betas[77,2]           1.00       1.00
## betas[78,2]           1.00       1.00
## betas[79,2]           1.00       1.00
## betas[80,2]           1.00       1.00
## betas[81,2]           1.00       1.00
## betas[82,2]           1.00       1.00
## betas[83,2]           1.00       1.00
## betas[84,2]           1.00       1.00
## betas[85,2]           1.00       1.00
## betas[86,2]           1.00       1.00
## betas[87,2]           1.00       1.00
## betas[88,2]           1.00       1.00
## betas[89,2]           1.00       1.00
## betas[90,2]           1.00       1.00
## betas[91,2]           1.00       1.00
## betas[92,2]           1.00       1.00
## betas[93,2]           1.00       1.00
## betas[94,2]           1.01       1.01
## betas[95,2]           1.00       1.00
## betas[96,2]           1.00       1.00
## betas[97,2]           1.00       1.00
## betas[98,2]           1.00       1.00
## betas[99,2]           1.00       1.00
## betas[100,2]          1.00       1.00
## betas[101,2]          1.00       1.01
## betas[102,2]          1.00       1.00
## betas[103,2]          1.00       1.00
## betas[104,2]          1.00       1.00
## betas[105,2]          1.00       1.00
## betas[106,2]          1.00       1.00
## betas[107,2]          1.00       1.00
## betas[108,2]          1.00       1.00
## c_highLowPInt         1.00       1.00
## c_highLowPSlope       1.00       1.00
## c_highMedPInt         1.00       1.00
## c_highMedPSlope       1.00       1.00
## c_medLowPInt          1.00       1.00
## c_medLowPSlope        1.00       1.00
## corrIntSlope          1.00       1.01
## highPInt              1.00       1.00
## highPSlope            1.00       1.00
## lowPInt               1.00       1.00
## lowPSlope             1.00       1.00
## medPInt               1.00       1.00
## medPSlope             1.00       1.00
## sdIntercept           1.00       1.00
## sdLevel1Error         1.00       1.01
## sdSlope               1.01       1.03
```

## Create Summary Table of posterior distributions
We use the functions provided in the papers git repository to create a summary of the posterior distribution.

  - mean
  - posterior standard deviation (PSD), uncertainty around the mean (similar to SE)
  - posterior credibility interval (PCI), central 95% of posterior distribution
  - Highest density interval (HDI), 95% range of the distribution with highest probability density
  - Percentage of post. distr. below, in, or above region of practical equivalence (ROPE), here: ROPE=[-0.05,0.05], i.e. practically equivalent to zero


```r
source("posteriorSummaryStats.R") 

resultTable <- summarizePost(codaSamples) %>%
  as.data.frame() %>% 
  rownames_to_column("parameter")

# finds non-converged chains
resultTable %>% filter(RHAT > 1.1)

# Display summary statistics for selected parameters 
resultTable %>% filter(!str_detect(parameter, "^betas"))
```

```
##  [1] parameter     mean          PSD           PCI 2.50%     PCI 97.50%   
##  [6] 95% HDI_Low   95% HDI_High  st -0.05       (-0.05,0.05) lt 0.05      
## [11] ESS           RHAT         
## <0 rows> (or 0-length row.names)
##          parameter    mean    PSD PCI 2.50% PCI 97.50% 95% HDI_Low
## 1     betaHighPInt  2.0676 1.7663   -1.4169     5.5237     -1.5061
## 2   betaHighPSlope  0.0514 0.0536   -0.0549     0.1568     -0.0529
## 3      betaLowPInt -2.9379 1.7525   -6.3169     0.5253     -6.3496
## 4    betaLowPSlope -0.1198 0.0530   -0.2243    -0.0156     -0.2243
## 5    c_highLowPInt  5.0055 1.8139    1.4500     8.5413      1.5392
## 6  c_highLowPSlope  0.1711 0.0551    0.0630     0.2791      0.0586
## 7    c_highMedPInt  2.0676 1.7663   -1.4169     5.5237     -1.5061
## 8  c_highMedPSlope  0.0514 0.0536   -0.0549     0.1568     -0.0529
## 9     c_medLowPInt  2.9379 1.7525   -0.5253     6.3169     -0.4853
## 10  c_medLowPSlope  0.1198 0.0530    0.0156     0.2243      0.0156
## 11    corrIntSlope  0.2402 0.2594   -0.1955     0.8408     -0.2150
## 12        highPInt 77.3463 1.2939   74.8003    79.8572     74.7778
## 13      highPSlope -0.0316 0.0391   -0.1096     0.0454     -0.1079
## 14         lowPInt 72.3408 1.2708   69.8413    74.8174     69.8107
## 15       lowPSlope -0.2027 0.0383   -0.2782    -0.1276     -0.2787
## 16         medPInt 75.2786 1.2232   72.8333    77.6562     72.9378
## 17       medPSlope -0.0830 0.0371   -0.1557    -0.0098     -0.1564
## 18     sdIntercept  6.7102 0.6179    5.5895     8.0006      5.5418
## 19   sdLevel1Error  5.7015 0.2842    5.1768     6.2796      5.1688
## 20         sdSlope  0.1213 0.0373    0.0403     0.1871      0.0406
##    95% HDI_High st -0.05  (-0.05,0.05) lt 0.05   ESS   RHAT
## 1        5.4193   0.1148        0.0120  0.8732 16670 1.0001
## 2        0.1587   0.0310        0.4559  0.5131  7112 1.0008
## 3        0.4853   0.9495        0.0056  0.0449 14142 1.0002
## 4       -0.0156   0.9055        0.0936  0.0009  6659 1.0003
## 5        8.6225   0.0035        0.0006  0.9959 25826 1.0001
## 6        0.2742   0.0001        0.0131  0.9868 10315 1.0005
## 7        5.4193   0.1148        0.0120  0.8732 16670 1.0001
## 8        0.1587   0.0310        0.4559  0.5131  7112 1.0008
## 9        6.3496   0.0449        0.0056  0.9495 14142 1.0002
## 10       0.2243   0.0009        0.0936  0.9055  6659 1.0003
## 11       0.8076   0.1168        0.1245  0.7587  1268 1.0019
## 12      79.8292   0.0000        0.0000  1.0000 25458 1.0001
## 13       0.0469   0.3179        0.6630  0.0192 12682 1.0005
## 14      74.7828   0.0000        0.0000  1.0000 22252 1.0000
## 15      -0.1285   1.0000        0.0000  0.0000 11204 1.0002
## 16      77.7429   0.0000        0.0000  1.0000 15229 1.0002
## 17      -0.0105   0.8155        0.1842  0.0003  6103 1.0005
## 18       7.9420   0.0000        0.0000  1.0000 17164 1.0003
## 19       6.2689   0.0000        0.0000  1.0000  3873 1.0003
## 20       0.1873   0.0000        0.0433  0.9567  1047 1.0011
```

## Make pretty output table for presentation (Optional) 
*Note:* requires the stargazer package


```r
resultTable %>% 
  filter(!str_detect(parameter, "^betas")) %>%
  select(-ESS, -RHAT) %>%
  rename(stROPE = `st -0.05`,
         inROPE = ` (-0.05,0.05)`,
         ltROPE = `lt 0.05`) %>%
  stargazer::stargazer(type = "text", summary = F, rownames=F)
```

```
## 
## ===============================================================================================
## parameter        mean   PSD  PCI 2.50% PCI 97.50% 95% HDI_Low 95% HDI_High stROPE inROPE ltROPE
## -----------------------------------------------------------------------------------------------
## betaHighPInt    2.068  1.766  -1.417     5.524      -1.506       5.419     0.115  0.012  0.873 
## betaHighPSlope  0.051  0.054  -0.055     0.157      -0.053       0.159     0.031  0.456  0.513 
## betaLowPInt     -2.938 1.752  -6.317     0.525      -6.350       0.485     0.950  0.006  0.045 
## betaLowPSlope   -0.120 0.053  -0.224     -0.016     -0.224       -0.016    0.906  0.094  0.001 
## c_highLowPInt   5.005  1.814   1.450     8.541       1.539       8.623     0.004  0.001  0.996 
## c_highLowPSlope 0.171  0.055   0.063     0.279       0.059       0.274     0.0001 0.013  0.987 
## c_highMedPInt   2.068  1.766  -1.417     5.524      -1.506       5.419     0.115  0.012  0.873 
## c_highMedPSlope 0.051  0.054  -0.055     0.157      -0.053       0.159     0.031  0.456  0.513 
## c_medLowPInt    2.938  1.752  -0.525     6.317      -0.485       6.350     0.045  0.006  0.950 
## c_medLowPSlope  0.120  0.053   0.016     0.224       0.016       0.224     0.001  0.094  0.906 
## corrIntSlope    0.240  0.259  -0.196     0.841      -0.215       0.808     0.117  0.124  0.759 
## highPInt        77.346 1.294  74.800     79.857     74.778       79.829      0      0      1   
## highPSlope      -0.032 0.039  -0.110     0.045      -0.108       0.047     0.318  0.663  0.019 
## lowPInt         72.341 1.271  69.841     74.817     69.811       74.783      0      0      1   
## lowPSlope       -0.203 0.038  -0.278     -0.128     -0.279       -0.128      1      0      0   
## medPInt         75.279 1.223  72.833     77.656     72.938       77.743      0      0      1   
## medPSlope       -0.083 0.037  -0.156     -0.010     -0.156       -0.010    0.816  0.184  0.0003
## sdIntercept     6.710  0.618   5.590     8.001       5.542       7.942       0      0      1   
## sdLevel1Error   5.702  0.284   5.177     6.280       5.169       6.269       0      0      1   
## sdSlope         0.121  0.037   0.040     0.187       0.041       0.187       0    0.043  0.957 
## -----------------------------------------------------------------------------------------------
```

## Alternative solution to get posterior summary
The paper uses a pretty complex script to produce the summary table. 
It's probably possible to create the same table with less code. I've tried but couldn't figure out (yet) how to get the same values for ESS and RHAT, and how to get ROPE-related statistics. 

*Not functional*


```r
to_df <- function(x) rownames_to_column(as.data.frame(x), "parameter")

s <-summary(codaSamples, quantiles=c(0.025, 0.975))  # quantiles = Credible intervals (here 95% interval)
s1 <- to_df(s[[1]])
s2 <- to_df(s[[2]])
s3 <- to_df(HDInterval::hdi(codaSamples, credMass = 0.95) %>% t())   # produces 0.95 HDI
s4 <- to_df(effectiveSize(codaSamples)) %>% rename(ESS = x) # Effective Sample Size (ESS)
s5 <- to_df(gelman.diag(codaSamples, multivariate = F)$psrf) # R hat convergence diagnostic

myResultTable <- full_join(s1, s2, by = "parameter") %>%
                 full_join(s3, by = "parameter") %>%
                 full_join(s4, by = "parameter") %>%
                 full_join(s5, by = "parameter") %>%
                 select(-`Naive SE`, -`Time-series SE`, -`Upper C.I.`) %>%
                 rename(mean = Mean,
                       PSD = SD,
                       PCI_low = `2.5%`,
                       PCI_high = `97.5%`,
                       HDI_low = lower,
                       HDI_high = upper,
                       RHAT = `Point est.`)

myResultTable %>% filter(!str_detect(parameter, "^betas"))
```

## Model Summary


```r

# Get individual intercepts and slopes
betas <- resultTable %>% 
  filter(str_detect(parameter, "betas")) %>%
  extract(parameter, c("subject", "coef"), "betas\\[([0-9]+),([0-9]+)\\]") %>%
  mutate(subject = as.factor(subject),
         coef = recode(coef, "1" = "intercept", "2" = "slope")) %>%
  select(subject, coef, mean) %>%
  spread(key = coef, value = mean) 

betas
```

```
##     subject intercept   slope
## 1         1   77.3587 -0.0580
## 2        10   75.4100 -0.0546
## 3       100   75.2399 -0.1508
## 4       101   70.1863 -0.3891
## 5       102   82.1547 -0.0305
## 6       103   74.5566 -0.0781
## 7       104   70.9505 -0.0770
## 8       105   59.4978 -0.2567
## 9       106   83.5585  0.0024
## 10      107   80.4842 -0.1509
## 11      108   79.4256  0.0243
## 12       11   68.4311 -0.2749
## 13       12   50.9240 -0.2567
## 14       13   85.1757 -0.0106
## 15       14   71.0423 -0.0315
## 16       15   71.0127 -0.0227
## 17       16   73.1619 -0.1258
## 18       17   81.8791 -0.0829
## 19       18   67.1435 -0.2410
## 20       19   75.2013 -0.2264
## 21        2   78.4663 -0.1500
## 22       20   79.0968 -0.1575
## 23       21   74.1519 -0.1100
## 24       22   61.2158 -0.2360
## 25       23   75.5959 -0.2243
## 26       24   73.5113 -0.1097
## 27       25   80.2863 -0.0338
## 28       26   76.7965 -0.1640
## 29       27   80.0991 -0.0348
## 30       28   83.3977 -0.0033
## 31       29   82.0148 -0.0683
## 32        3   78.0909 -0.0202
## 33       30   82.4616 -0.1076
## 34       31   74.4350 -0.1458
## 35       32   73.9572 -0.0826
## 36       33   84.3220 -0.1061
## 37       34   79.0967  0.0382
## 38       35   79.6496 -0.0625
## 39       36   73.4506 -0.1361
## 40       37   81.2098 -0.0496
## 41       38   75.4782 -0.0337
## 42       39   68.8457 -0.1845
## 43        4   78.5271 -0.1112
## 44       40   75.1887 -0.1441
## 45       41   77.3368 -0.0545
## 46       42   81.4083  0.0389
## 47       43   60.7700 -0.2043
## 48       44   82.7943 -0.0297
## 49       45   76.4155 -0.1669
## 50       46   75.8476 -0.0334
## 51       47   74.7065 -0.0397
## 52       48   75.4915 -0.0049
## 53       49   75.3451 -0.0715
## 54        5   77.2572 -0.2547
## 55       50   73.9224 -0.1652
## 56       51   76.2764 -0.0813
## 57       52   74.8173 -0.1242
## 58       53   75.2781 -0.0868
## 59       54   65.6753 -0.2426
## 60       55   74.8638 -0.0941
## 61       56   72.2707 -0.1086
## 62       57   80.3560 -0.0959
## 63       58   70.7545 -0.0514
## 64       59   83.0957  0.0101
## 65        6   75.5416 -0.0430
## 66       60   82.4768  0.0395
## 67       61   81.7127 -0.1748
## 68       62   81.1054 -0.1257
## 69       63   77.7828 -0.0031
## 70       64   79.7057 -0.0984
## 71       65   78.4813 -0.0743
## 72       66   81.1216 -0.2033
## 73       67   71.5541 -0.1082
## 74       68   62.0471 -0.1085
## 75       69   81.1274 -0.0651
## 76        7   61.8798 -0.4559
## 77       70   80.5470 -0.0123
## 78       71   78.7977 -0.1514
## 79       72   70.5858 -0.1338
## 80       73   77.5042 -0.1113
## 81       74   72.8267 -0.0434
## 82       75   69.4966  0.0349
## 83       76   79.6091 -0.0861
## 84       77   82.6803 -0.1002
## 85       78   82.1326 -0.1167
## 86       79   86.0144  0.0417
## 87        8   76.9592  0.0211
## 88       80   73.0343 -0.0133
## 89       81   70.9671 -0.1574
## 90       82   73.9834 -0.0084
## 91       83   81.3238 -0.0285
## 92       84   66.7213 -0.2650
## 93       85   75.0082  0.0022
## 94       86   81.1118  0.0264
## 95       87   61.3220 -0.1679
## 96       88   81.5615 -0.0062
## 97       89   76.8256 -0.0472
## 98        9   65.8898 -0.2896
## 99       90   77.1177 -0.0002
## 100      91   72.9290 -0.2045
## 101      92   68.5237 -0.0597
## 102      93   71.4289 -0.0826
## 103      94   60.6200 -0.5370
## 104      95   73.8165 -0.1820
## 105      96   72.8857 -0.1935
## 106      97   75.7585 -0.1358
## 107      98   77.7185 -0.0234
## 108      99   71.6179 -0.1674
```


```r

# make predictions for individuals
predictions <- loveData %>% 
  left_join(betas, by = "subject") %>%
  mutate(predicted = intercept + month*slope)
```

```
## Warning: Column `subject` joining factors with different levels, coercing
## to character vector
```

```r

# select subsample of subjects for plot
s <- sample(unique(loveData$subject), 54)

predictions %>% 
  filter(subject %in% s) %>%
  ggplot(aes(month, score, group = subject)) + 
    geom_line(aes(), show.legend = F) +   # Observed
    geom_line(aes(y = predicted), col = "dodgerblue", show.legend = F) +  # Predicted
    facet_wrap(~subject, nrow=6) + 
    scale_x_continuous(name = "Months After Baby was Born", breaks = c(-3, 0, 3, 9, 36)) +
    scale_y_continuous(name = "Father's Marital Love Score") +
    theme(strip.background = element_blank(),
          strip.text.x = element_blank())
```

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14-1.png)

```r

ggsave("out/observed_predicted_individual.png", width=12, height=5)
```


```r

predictions %>% 
  ggplot(aes(month, predicted, group = subject)) + 
    geom_line(aes(col = subject), show.legend = F) +
    facet_grid(~posFactor) + 
    scale_x_continuous(name = "Months After Baby was Born", breaks = c(-3, 0, 3, 9, 39)) +
    scale_y_continuous(name = "Father's Marital Love Score", limits = c(10,100))
```

![plot of chunk unnamed-chunk-15](figure/unnamed-chunk-15-1.png)

```r

ggsave("out/predicted.png", width = 10, height = 4)
```


```r
# get a subset of the parameter samples 
low <- data.frame(int = unlist(codaSamples[,"lowPInt"])[seq(1,30000,50)],
                  slope = unlist(codaSamples[,"lowPSlope"])[seq(1,30000,50)])

med <- data.frame(int = unlist(codaSamples[,"medPInt"])[seq(1,30000,50)],
                  slope = unlist(codaSamples[,"medPSlope"])[seq(1,30000,50)])

high <- data.frame(int = unlist(codaSamples[,"highPInt"])[seq(1,30000,50)],
                   slope = unlist(codaSamples[,"highPSlope"])[seq(1,30000,50)])

samplesFromChains <- bind_rows("Low" = low, "Medium" = med, "High" = high, .id = "posFactor")

samplesFromChains <- samplesFromChains %>%
  mutate(id = row_number(),
         t1 = int - 3 * slope,
         t2 = int + 36 * slope,
         posFactor = ordered(posFactor, levels = c("Low", "Medium", "High"))) %>%
  gather(month, score, t1:t2) %>%
  mutate(month = recode(month, "t1"=-3, "t2"=36))

# get the mean intercept and slope for each postitivity group
means <- resultTable %>% 
  filter(str_detect(parameter, "^(high|med|low)P(Int|Slope)")) %>%
  transmute(posFactor = str_extract(parameter, "(low|med|high)"),
            parameter = str_extract(parameter, "(Int|Slope)") %>% str_to_lower(),
            mean = mean) %>%
  spread(parameter, mean) %>%
  mutate(id = row_number(),
         t1 = int - 3 * slope,
         t2 = int + 36 * slope,
         posFactor = recode_factor(posFactor, 
           low = "Low", med = "Medium", high = "High", .ordered = T)) %>%
  gather(month, score, t1:t2) %>%
  mutate(month = recode(month, "t1"=-3, "t2"=36))

# plot 
samplesFromChains %>%
  ggplot(aes(x = month, y = score, group = id, color = posFactor)) +
  geom_line(alpha = .01) +
  geom_line(data = means, size = 1) +
  facet_wrap(~ posFactor) +
  scale_x_continuous(name = "Months After Baby was Born", breaks = c(-3, 0, 3, 9, 39)) +
  scale_y_continuous(name = "Father's Marital Love Score", limits = c(10,100))
```

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-16-1.png)

```r

ggsave("out/predicted_mean.png", width = 10, height = 4)
```

## Calculate DIC
Deviance Information Criterion quantifies how well the model reduces uncertainty in future predictions and can be used to compare models in terms of their relative goodness of fit. It accounts for model complexity and model fit. 
Lower DIC = better model performance in predicting future values. 

  - DIC>5: some difference, 
  - DIC>10: considerable difference.


```r
dicSamples <- dic.samples(mdl, nIter, thin = thinning, "pD", progress.bar = "gui")
show(dicSamples)
```

```
## Mean deviance:  2727 
## penalty 129.2 
## Penalized deviance: 2856
```

## Fit the same (?) model with stan + brms
There are some packages that try to make fitting bayesian models easier. One of them is brms. 
Note that this uses [Stan](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started) instead of jags, so you will have to install Stan first.


```r
library(brms)   # requires rstan 
```

```
## Loading required package: Rcpp
```

```
## Loading 'brms' package (version 1.7.0). Useful instructions 
## can be found by typing help('brms'). A more detailed introduction 
## to the package is available through vignette('brms_overview').
```

```r

fit <- brm(score ~ posFactor*month + (1 + month|subject), 
           data = loveData,
           prior = c(
             set_prior("normal(0,100)", class = "Intercept"),
             set_prior("normal(0,100)", class = "b"),
             set_prior("uniform(0,100)", class = "sd"),
             set_prior("uniform(0,100)", class = "sd", group = "subject")
           ),
           warmup = 1000, iter = nIter, chains = 6, thin = thinning)
```

```
## Warning: It appears as if you have specified an upper bounded prior on a parameter that has no natural upper bound.
## If this is really what you want, please specify argument 'ub' of 'set_prior' appropriately.
## Warning occurred for prior 
## sd ~ uniform(0,100)
## sd_subject ~ uniform(0,100)
```

```
## Compiling the C++ model
```

```
## Start sampling
```

```r

# Note: There is a warning message about the boundaries for the uniform priors not being set. 
# However, setting them, via set_prior("uniform(0,100)", lb = 0, ub = 100, class = "sd"), creates
# an Error, indicating that setting boundaries is not possible in this case. The model seems to 
# run fine without the boundaries, sespite the error message.
```

```
## 
## SAMPLING FOR MODEL 'gaussian(identity) brms-model' NOW (CHAIN 1).
## 
## Gradient evaluation took 0 seconds
## 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
## Adjust your expectations accordingly!
## 
## 
## Iteration:     1 / 25000 [  0%]  (Warmup)
## Iteration:  1001 / 25000 [  4%]  (Sampling)
## Iteration:  3500 / 25000 [ 14%]  (Sampling)
## Iteration:  6000 / 25000 [ 24%]  (Sampling)
## Iteration:  8500 / 25000 [ 34%]  (Sampling)
## Iteration: 11000 / 25000 [ 44%]  (Sampling)
## Iteration: 13500 / 25000 [ 54%]  (Sampling)
## Iteration: 16000 / 25000 [ 64%]  (Sampling)
## Iteration: 18500 / 25000 [ 74%]  (Sampling)
## Iteration: 21000 / 25000 [ 84%]  (Sampling)
## Iteration: 23500 / 25000 [ 94%]  (Sampling)
## Iteration: 25000 / 25000 [100%]  (Sampling)
## 
##  Elapsed Time: 2.99 seconds (Warm-up)
##                23.959 seconds (Sampling)
##                26.949 seconds (Total)
## 
## 
## SAMPLING FOR MODEL 'gaussian(identity) brms-model' NOW (CHAIN 2).
## 
## Gradient evaluation took 0 seconds
## 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
## Adjust your expectations accordingly!
## 
## 
## Iteration:     1 / 25000 [  0%]  (Warmup)
## Iteration:  1001 / 25000 [  4%]  (Sampling)
## Iteration:  3500 / 25000 [ 14%]  (Sampling)
## Iteration:  6000 / 25000 [ 24%]  (Sampling)
## Iteration:  8500 / 25000 [ 34%]  (Sampling)
## Iteration: 11000 / 25000 [ 44%]  (Sampling)
## Iteration: 13500 / 25000 [ 54%]  (Sampling)
## Iteration: 16000 / 25000 [ 64%]  (Sampling)
## Iteration: 18500 / 25000 [ 74%]  (Sampling)
## Iteration: 21000 / 25000 [ 84%]  (Sampling)
## Iteration: 23500 / 25000 [ 94%]  (Sampling)
## Iteration: 25000 / 25000 [100%]  (Sampling)
## 
##  Elapsed Time: 2.692 seconds (Warm-up)
##                38.536 seconds (Sampling)
##                41.228 seconds (Total)
## 
## 
## SAMPLING FOR MODEL 'gaussian(identity) brms-model' NOW (CHAIN 3).
## 
## Gradient evaluation took 0 seconds
## 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
## Adjust your expectations accordingly!
## 
## 
## Iteration:     1 / 25000 [  0%]  (Warmup)
## Iteration:  1001 / 25000 [  4%]  (Sampling)
## Iteration:  3500 / 25000 [ 14%]  (Sampling)
## Iteration:  6000 / 25000 [ 24%]  (Sampling)
## Iteration:  8500 / 25000 [ 34%]  (Sampling)
## Iteration: 11000 / 25000 [ 44%]  (Sampling)
## Iteration: 13500 / 25000 [ 54%]  (Sampling)
## Iteration: 16000 / 25000 [ 64%]  (Sampling)
## Iteration: 18500 / 25000 [ 74%]  (Sampling)
## Iteration: 21000 / 25000 [ 84%]  (Sampling)
## Iteration: 23500 / 25000 [ 94%]  (Sampling)
## Iteration: 25000 / 25000 [100%]  (Sampling)
## 
##  Elapsed Time: 2.975 seconds (Warm-up)
##                35.005 seconds (Sampling)
##                37.98 seconds (Total)
## 
## 
## SAMPLING FOR MODEL 'gaussian(identity) brms-model' NOW (CHAIN 4).
## 
## Gradient evaluation took 0 seconds
## 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
## Adjust your expectations accordingly!
## 
## 
## Iteration:     1 / 25000 [  0%]  (Warmup)
## Iteration:  1001 / 25000 [  4%]  (Sampling)
## Iteration:  3500 / 25000 [ 14%]  (Sampling)
## Iteration:  6000 / 25000 [ 24%]  (Sampling)
## Iteration:  8500 / 25000 [ 34%]  (Sampling)
## Iteration: 11000 / 25000 [ 44%]  (Sampling)
## Iteration: 13500 / 25000 [ 54%]  (Sampling)
## Iteration: 16000 / 25000 [ 64%]  (Sampling)
## Iteration: 18500 / 25000 [ 74%]  (Sampling)
## Iteration: 21000 / 25000 [ 84%]  (Sampling)
## Iteration: 23500 / 25000 [ 94%]  (Sampling)
## Iteration: 25000 / 25000 [100%]  (Sampling)
## 
##  Elapsed Time: 3.044 seconds (Warm-up)
##                25.058 seconds (Sampling)
##                28.102 seconds (Total)
## 
## 
## SAMPLING FOR MODEL 'gaussian(identity) brms-model' NOW (CHAIN 5).
## 
## Gradient evaluation took 0 seconds
## 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
## Adjust your expectations accordingly!
## 
## 
## Iteration:     1 / 25000 [  0%]  (Warmup)
## Iteration:  1001 / 25000 [  4%]  (Sampling)
## Iteration:  3500 / 25000 [ 14%]  (Sampling)
## Iteration:  6000 / 25000 [ 24%]  (Sampling)
## Iteration:  8500 / 25000 [ 34%]  (Sampling)
## Iteration: 11000 / 25000 [ 44%]  (Sampling)
## Iteration: 13500 / 25000 [ 54%]  (Sampling)
## Iteration: 16000 / 25000 [ 64%]  (Sampling)
## Iteration: 18500 / 25000 [ 74%]  (Sampling)
## Iteration: 21000 / 25000 [ 84%]  (Sampling)
## Iteration: 23500 / 25000 [ 94%]  (Sampling)
## Iteration: 25000 / 25000 [100%]  (Sampling)
## 
##  Elapsed Time: 2.688 seconds (Warm-up)
##                44.559 seconds (Sampling)
##                47.247 seconds (Total)
## 
## 
## SAMPLING FOR MODEL 'gaussian(identity) brms-model' NOW (CHAIN 6).
## 
## Gradient evaluation took 0 seconds
## 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
## Adjust your expectations accordingly!
## 
## 
## Iteration:     1 / 25000 [  0%]  (Warmup)
## Iteration:  1001 / 25000 [  4%]  (Sampling)
## Iteration:  3500 / 25000 [ 14%]  (Sampling)
## Iteration:  6000 / 25000 [ 24%]  (Sampling)
## Iteration:  8500 / 25000 [ 34%]  (Sampling)
## Iteration: 11000 / 25000 [ 44%]  (Sampling)
## Iteration: 13500 / 25000 [ 54%]  (Sampling)
## Iteration: 16000 / 25000 [ 64%]  (Sampling)
## Iteration: 18500 / 25000 [ 74%]  (Sampling)
## Iteration: 21000 / 25000 [ 84%]  (Sampling)
## Iteration: 23500 / 25000 [ 94%]  (Sampling)
## Iteration: 25000 / 25000 [100%]  (Sampling)
## 
##  Elapsed Time: 2.773 seconds (Warm-up)
##                23.644 seconds (Sampling)
##                26.417 seconds (Total)
```


```r
summary(fit) 

# use plot() for graphical convergence diagnostics
# plot(fit)
# use launch_shiny() for an interactive app for model exploration
# launch_shiny(fit) 

predictions <- loveData %>% 
  mutate(predicted = predict(fit)[,"Estimate"])
```

```
##  Family: gaussian(identity) 
## Formula: score ~ posFactor * month + (1 + month | subject) 
##    Data: loveData (Number of observations: 432) 
## Samples: 6 chains, each with iter = 25000; warmup = 1000; thin = 5; 
##          total post-warmup samples = 28800
##     ICs: LOO = Not computed; WAIC = Not computed
##  
## Group-Level Effects: 
## ~subject (Number of levels: 108) 
##                      Estimate Est.Error l-95% CI u-95% CI Eff.Sample Rhat
## sd(Intercept)            6.68      0.61     5.56     7.94      22416    1
## sd(month)                0.12      0.04     0.04     0.19      11878    1
## cor(Intercept,month)     0.23      0.25    -0.20     0.82      16768    1
## 
## Population-Level Effects: 
##                  Estimate Est.Error l-95% CI u-95% CI Eff.Sample Rhat
## Intercept           76.44      1.23    74.04    78.87      21241    1
## posFactor1          -4.14      1.75    -7.57    -0.69      21099    1
## posFactor3           0.96      1.79    -2.53     4.44      21372    1
## month               -0.09      0.04    -0.16    -0.02      27497    1
## posFactor1:month    -0.11      0.05    -0.22    -0.01      28111    1
## posFactor3:month     0.06      0.05    -0.05     0.17      28164    1
## 
## Family Specific Parameters: 
##       Estimate Est.Error l-95% CI u-95% CI Eff.Sample Rhat
## sigma     5.69      0.28     5.16     6.27      17107    1
## 
## Samples were drawn using sampling(NUTS). For each parameter, Eff.Sample 
## is a crude measure of effective sample size, and Rhat is the potential 
## scale reduction factor on split chains (at convergence, Rhat = 1).
```


```r
# plot subsample of subjects
# (commentet out, so same sample as above is used)
# s <- sample(unique(loveData$subject), 49)

filter(predictions, subject %in% s) %>%
  ggplot(aes(month, score, group = subject)) + 
    geom_line(aes(), show.legend = F) +   # Observed
    geom_line(aes(y = predicted), col = "dodgerblue", show.legend = F) +
    facet_wrap(~subject, nrow=6) + 
    scale_x_continuous(name = "Months After Baby was Born", breaks = c(-3, 0, 3, 9, 36)) +
    scale_y_continuous(name = "Father's Marital Love Score") +
    theme(strip.background = element_blank(),
          strip.text.x = element_blank())
```

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20-1.png)


```r
predictions %>%
  ggplot(aes(month, predicted, group = subject)) + 
    geom_line(aes(col = subject), show.legend = F) +
    facet_grid(~posFactor) +
    scale_x_continuous(name = "Months After Baby was Born", breaks = c(-3, 0, 3, 9, 36)) +
    scale_y_continuous(name = "Father's Marital Love Score", limits = c(10,100))
```

![plot of chunk unnamed-chunk-21](figure/unnamed-chunk-21-1.png)


```r
marginal_effects(fit)
```

![plot of chunk unnamed-chunk-22](figure/unnamed-chunk-22-1.png)![plot of chunk unnamed-chunk-22](figure/unnamed-chunk-22-2.png)![plot of chunk unnamed-chunk-22](figure/unnamed-chunk-22-3.png)

## As a comparison, run the same (?) model with lme4 (i.e. non-Bayesian)


```r
library(lme4)
```

```
## Loading required package: Matrix
```

```
## 
## Attaching package: 'Matrix'
```

```
## The following object is masked from 'package:tidyr':
## 
##     expand
```

```
## 
## Attaching package: 'lme4'
```

```
## The following object is masked from 'package:brms':
## 
##     ngrps
```

```r

lmerfit <- lmer(score ~ posFactor*month + (1 + month|subject), data = loveData)
summary(lmerfit)
```

```
## Linear mixed model fit by REML ['lmerMod']
## Formula: score ~ posFactor * month + (1 + month | subject)
##    Data: loveData
## 
## REML criterion at convergence: 2969.4
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -4.8044 -0.3856  0.1232  0.5085  2.8923 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev. Corr
##  subject  (Intercept) 43.52072 6.5970       
##           month        0.01813 0.1346   0.16
##  Residual             31.28396 5.5932       
## Number of obs: 432, groups:  subject, 108
## 
## Fixed effects:
##                  Estimate Std. Error t value
## (Intercept)      76.44237    1.21175   63.08
## posFactor1       -4.14842    1.73731   -2.39
## posFactor3        0.95264    1.76335    0.54
## month            -0.08903    0.03746   -2.38
## posFactor1:month -0.11364    0.05371   -2.12
## posFactor3:month  0.05719    0.05452    1.05
## 
## Correlation of Fixed Effects:
##             (Intr) psFct1 psFct3 month  psFc1:
## posFactor1  -0.697                            
## posFactor3  -0.687  0.479                     
## month       -0.147  0.103  0.101              
## psFctr1:mnt  0.103 -0.147 -0.070 -0.697       
## psFctr3:mnt  0.101 -0.070 -0.147 -0.687  0.479
```
