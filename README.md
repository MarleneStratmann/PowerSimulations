# Description
This package makes it easy to calculate power for sampling study participants. This package is made specifically for a project where the gestational age is important, as well as if the pregnancy was geriatric and you can also change the autism prevalence.

# Example
This is an easy example how you can modify the code:
run_simulations(n_obs = 500, n_simulations = 100, n_parallel_cores = 3,
                p_preterm = list(very = 0.01, moderate = 0.1, late = 0.3),
                p_autism = 0.05,
                p_geriatric_preg = 1/6)

# Installation
For installing the package from GitHub please use

```
remotes::install_github("MarleneStratmann/PowerSimulations")
library(PowerSimulations)
```

# Bugs
If you find any bugs or have any suggestion please don't hesitate to file an issue on GitHub.
