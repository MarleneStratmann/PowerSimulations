#' Power calculation with Monte Carlo simulation
#'
#' This function helps you calculate power for regressions
#' using Monte Carlo simulation with several variables
#' that potentially have interactions.
#'
#' @param name description
#'
#' @return description
#'
#' @importFrom data.table .N
#' @export run_simulations

run_simulations <- function(n_obs            = 10000,
                            n_simulations    = 1000,
                            n_parallel_cores = 5,
                            p_preterm        = list(very     = 0.002,
                                                    moderate = 0.05,
                                                    late     = 0.1),
                            p_autism         = 0.01,
                            p_geriatric_preg = 1/8) {

  # Defining variables used later by data.table
  power <- p_value <- term <- NULL

  # Set up paralisation
  cl <- parallel::makeCluster(n_parallel_cores)

  parallel::clusterExport(cl, c("simulate", "n_obs", "p_preterm",
                                "p_autism", "p_geriatric_preg"),
                          envir = rlang::current_env())

  # Run simulaiton
  simulations <- parallel::parLapply(cl, 1:n_simulations, function(i) {
    # simulations <- lapply(1:n_simulations, function(i) {
    set.seed(i * 7)

    simulation <- simulate(n_obs, p_preterm, p_autism, p_geriatric_preg)

    model <- stats::glm(autism ~ geriatric_preg
                        + factor(preterm)
                        + I(preterm > 0):geriatric_preg,
                        data = simulation,
                        family = "binomial")

    model_estimates <- broom::tidy(model)

    model_estimates$iteration <- i

    return(model_estimates)

  })

  # Stop cluster
  parallel::stopCluster(cl)

  # Create dataset of simulations
  simulations <- data.table::rbindlist(simulations)

  cat("Simulated", n_simulations, "datasets with", n_obs, "observation\n")
  cat("using the following parameters:\n")
  cat("---------------------------------------------\n")
  cat("Preterm prevalences\n")
  cat("   very:    "                   , p_preterm[["very"]]    , "\n")
  cat("   moderate:"                   , p_preterm[["moderate"]], "\n")
  cat("   late:    "                   , p_preterm[["late"]]    , "\n")
  cat("Autism prevalence:             ", p_autism               , "\n")
  cat("Geriatric pregnancy prevalence:", p_geriatric_preg       , "\n")
  cat("---------------------------------------------\n")

  cat("\nSimulation results:\n")
  # Calculate power
  out <- simulations[, .(power = sum(p.value < 0.05) / .N),
                     by = term]

  return(out)

}
