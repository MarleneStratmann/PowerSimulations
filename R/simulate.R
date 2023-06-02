#' Power calculation with Monte Carlo simulation
#'
#' Helper function for `run_simulations()`.
#' For more information see parameter definition there.


simulate <- function(n_obs, p_preterm, p_autism, p_geriatric_preg) {

  dta <- data.frame(id = 1:n_obs)

  dta$geriatric_preg <- stats::rbinom(n_obs, 1, p_geriatric_preg)

  dta$preterm <- pmax(0,
                      stats::rbinom(n_obs, 1, p_preterm[["late"]])    * 1,
                      stats::rbinom(n_obs, 1, p_preterm[["moderate"]])* 2,
                      stats::rbinom(n_obs, 1, p_preterm[["very"]])    * 3)

  dta$autism <- stats::rbinom(n_obs, 1, p_autism
                              + dta$geriatric_preg  * 0.04
                              + I(dta$preterm == 1) * 0.10
                              + I(dta$preterm == 2) * 0.05
                              + I(dta$preterm == 3) * 0.025
                              + dta$geriatric_preg * I(dta$preterm > 0) * 0.05)

  return(dta)

}
