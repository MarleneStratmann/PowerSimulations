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
#' @export run_simulations_stratified

run_simulations_stratified <- function(strata_sizes     = list(very_preterm     = 2500,
                                                               moderate_preterm = 2500,
                                                               late_preterm     = 2500,
                                                               not_preterm      = 2500),
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

  parallel::clusterExport(cl, c("p_preterm", "p_autism", "p_geriatric_preg",
                                "strata_sizes", "simulate"),
                          envir = rlang::current_env())

  # Run simulation
  simulations <- parallel::parLapply(cl, 1:n_simulations, function(i){

    set.seed(i * 7)

    population <- simulate(n_obs = 1000000, p_preterm, p_autism, p_geriatric_preg)

    study_sample <- rbind(dplyr::slice_sample(subset(population, preterm == 3),
                                              n = strata_sizes$very_preterm),
                          dplyr::slice_sample(subset(population, preterm == 2),
                                              n = strata_sizes$moderate_preterm),
                          dplyr::slice_sample(subset(population, preterm == 1),
                                              n = strata_sizes$late_preterm),
                          dplyr::slice_sample(subset(population, preterm == 0),
                                              n = strata_sizes$not_preterm))

    model <- stats::glm(autism ~ geriatric_preg
                        + factor(preterm)
                        + I(preterm > 0):geriatric_preg,
                        data = study_sample,
                        family = "binomial")

    model_estimates <- broom::tidy(model)

    model_estimates$iteration <- i

    return(model_estimates)

  })

  # Stop cluster
  parallel::stopCluster(cl)

  # Create dataset of simulations
  simulations <- data.table::rbindlist(simulations)

  # Expected counts
  exp_not_preterm  <- min(strata_sizes$not_preterm, (1 - sum(unlist(p_preterm))) * 1000000)
  exp_late_preterm <- min(strata_sizes$late, p_preterm$late * 1000000)
  exp_moderate_preterm <- min(strata_sizes$moderate, p_preterm$moderate * 1000000)
  exp_very_preterm     <- min(strata_sizes$very, p_preterm$very * 1000000)

  cat("Simulated", n_simulations, "datasets with\n")
  cat("the following expected preterm distrubution:\n")
  cat("   not preterm:", exp_not_preterm     , "\n")
  cat("   late:       ", exp_late_preterm    , "\n")
  cat("   moderate:   ", exp_moderate_preterm, "\n")
  cat("   very:       ", exp_very_preterm    , "\n")
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
