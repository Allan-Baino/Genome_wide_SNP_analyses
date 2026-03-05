#'---
#'author: Allan Baino
#'date: 5th Mar, 2026
#'title: Sample size analysis for genomics project submission Wellcome Trust 
#'---

#'Background
#'Analysis assumes stochastic non-linear relationship between sample size and n# 
#'loci discovered. This assumption reflect a bit more reality for power analysis
#'in genomics projects. 

#'set priors based on principal applicants PhD pouched rat genomics work
obs_samps <- 108
obs_vars <- 626004
#'assume asymptotic maximum number of loci in population
Vmax <- 2000000
#'calc. rate of variant discovery 
k <- -log(1 - obs_vars / Vmax) / obs_samps
#'create a power simulation function 
sim_power <- function(n, Vmax, k, target = 1000000,
                      sd_fraction = 0.05, nsim = 1000) {
  
  successes <- 0
  
  for (i in 1:nsim) {
    
    #'expected variants at sample size n
    expected <- Vmax * (1 - exp(-k * n))
    
    #'add stochastic variability (0.05 default variation)
    observed <- rnorm(1,
                      mean = expected,
                      sd = sd_fraction * expected)
    #'set condition
    if (observed >= target) {
      successes <- successes + 1
    }
  }
  #'calc. power
  power <- successes / nsim
  return(power)
}
#'evaluate power across generated sample sizes
sample_sizes <- seq(110, 250, by = 5)
#'use sapply function to collate power values @each sample size
power_values <- sapply(sample_sizes,sim_power,Vmax = Vmax,k = k)
#'put results in a data.frame
results <- data.frame(sample_size = sample_sizes,power = power_values)
#'find required sample size for 80% power
req_n <- min(results$sample_size[results$power >= 0.80])
#'req_n = 215 pouched rats are required to discover 1M loci at power of 80%

#################################END####################################### 
