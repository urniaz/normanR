#' Retrieve Multiple Datasets from Norman API
#'
#' This function acts as a wrapper for \code{get_norman_data()}. It allows the user 
#' to pass a vector of values (e.g., multiple CAS numbers or NSIDs). It iterates 
#' through each value, performs the API request, and aggregates the results 
#' into a named list.
#'
#' @param module A character string specifying the database module (e.g., "susdat", "empodat").
#' @param parameter A character string specifying the search parameter (e.g., "casrn", "nsid").
#' @param values A character or numeric vector containing the values to search for (e.g., c("1490-04-6", "3380-34-5")).
#' @param page (Optional) Integer. The page number for pagination. Defaults to NULL.
#' @param format A character string specifying the output format ("json" or "xml"). Defaults to "json".
#' @param verbose Logical. If TRUE, prints progress messages to the console. Defaults to TRUE.
#'
#' @return A named list where each element's name corresponds to the search value 
#'   and the content is the data returned by the API. If a request fails, the 
#'   element will contain an error message or NULL.
#'
#' @examples
#' \dontrun{
#'   # Define multiple CAS numbers
#'   cas_list <- c("3380-34-5", "1490-04-6")
#'   
#'   # Fetch data for all values
#'   results <- get_norman_data_multi(
#'     module = "susdat",
#'     parameter = "casrn",
#'     values = cas_list
#'   )
#'   
#'   # Access specific result
#'   triclosan_data <- results[["3380-34-5"]]
#' }
#'
#' @export
get_norman_data_multi <- function(module, parameter, values, page = NULL, format = "json", verbose = TRUE) {
  
  # --- 1. Initialization ---
  
  # Initialize an empty list to store results
  # Using a named list allows for easy access via results[["value"]]
  aggregated_results <- list()
  
  # --- 2. Iteration Loop ---
  
  if (verbose) {
    message(paste0("Starting batch request for ", length(values), " items..."))
  }
  
  for (val in values) {
    
    if (verbose) {
      message(paste0("Fetching data for ", parameter, ": ", val, "..."))
    }
    
    # --- 3. Execution with Error Handling ---
    
    # We use tryCatch to ensure that if one API call fails (e.g., 404),
    # the loop continues for the remaining values.
    result <- tryCatch({
      # Call the previously defined core function
      get_norman_data(
        module = module,
        parameter = parameter,
        value = val,
        page = page,
        format = format
      )
    }, error = function(e) {
      # Log the error and return a descriptive message instead of crashing
      warning(paste0("Failed to retrieve data for '", val, "': ", e$message))
      return(paste("Error:", e$message))
    })
    
    # Store the result in the list using the current value as the key
    aggregated_results[[as.character(val)]] <- result
  }
  
  if (verbose) {
    message("Batch request completed.")
  }
  
  return(aggregated_results)
}