# Description
This package makes it easy to calculate power for sampling study participants. This package is made specifically for a project where the gestational age is important, as well as if the pregnancy was geriatric and you can also change the autism prevalence.

# Example
This is an easy example how you can modify the code:

```
run_simulations(n_obs = 500, 
                n_simulations = 100, 
                n_parallel_cores = 3,
                p_preterm = list(very = 0.01, moderate = 0.1, late = 0.3),
                p_autism = 0.05,
                p_geriatric_preg = 1/6)
 ```
 
Alternatively, you can use run_simulations_stratified if you are interested in a stratified sample:
```
run_simulations_stratified(strata_sizes = list(very_preterm = 2500, moderate_preterm = 2500,
                           late_preterm = 2500, not_preterm = 2500), 
                           n_simulations = 1000,
                           n_parallel_cores = 5, 
                           p_preterm = list(very = 0.01, moderate = 0.1, late = 0.3),
                           p_autism = 0.05,
                           p_geriatric_preg = 1/6)       
```
The package also includes interactions between autism prevalence and gestational age as well as 
             autism prevalence and geriatric pregnancies. The code for these interactions is as follows:
              
``` 
dta$autism <- stats::rbinom(n_obs, 1, p_autism
                              + dta$geriatric_preg  * 0.04
                              + I(dta$preterm == 1) * 0.10
                              + I(dta$preterm == 2) * 0.05
                              + I(dta$preterm == 3) * 0.025
                              + dta$geriatric_preg * I(dta$preterm > 0) * 0.05)
                              
```
              
The model specifications for the power calculations are:

```
               model <- stats::glm(autism ~ geriatric_preg
                      + factor(preterm)
                      + I(dta$preterm > 0):geriatric_preg,
                      data = dta,
                      family = "binomial")

```
# Installation
For installing the package from GitHub please use

```
remotes::install_github("MarleneStratmann/PowerSimulations")
library(PowerSimulations)
```

# Bugs
If you find any bugs or have any suggestion please don't hesitate to file an issue on GitHub.
