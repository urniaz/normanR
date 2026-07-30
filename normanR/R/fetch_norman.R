#' Fetch Multiple Datasets from Norman API
#'
#' This function interacts with the Norman Network Database System (NDS) API. It allows
#' the user to pass a vector of values (e.g., multiple CAS numbers or NSIDs). It iterates
#' through each value, performs the API request, and aggregates the results into a named 
#' list.
#'
#' @param module A character string specifying the database module.
#'   Allowed values:
#'   \itemize{
#'     \item \code{"susdat"} - Substance Database
#'     \item \code{"ecotox"} - Ecotoxicology Database
#'     \item \code{"empodat"} - EMPODAT Database
#'     \item \code{"passive"} - Passive Sampling Database
#'   }
#'
#' @param parameter A character string specifying the search parameter.
#'   The allowed parameters depend on the selected \code{module}:
#'   \itemize{
#'     \item For \code{module = "susdat"}: \code{"nsid"}, \code{"casrn"}, \code{"inchikey"}
#'     \item For \code{module = "ecotox"}: \code{"nsid"}, \code{"casrn"}, \code{"inchikey"}
#'     \item For \code{module = "empodat"}: \code{"nsid"}, \code{"casrn"}, \code{"inchikey"}, \code{"country"}, \code{"matrix"}, \code{"id"}
#'     \item For \code{module = "passive"}: \code{"nsid"}, \code{"casrn"}, \code{"inchikey"}, \code{"country"}, \code{"matrix"}
#'   }
#'   \strong{Parameter Descriptions:}
#'   \itemize{
#'     \item \code{nsid}: Norman SusDat ID (e.g., "NS00001027" or "1027")
#'     \item \code{casrn}: CAS Registry Number (e.g., "1490-04-6")
#'     \item \code{inchikey}: International Chemical Identifier Key (e.g., "NOOLISFMXDJSKH-UHFFFAOYSA-N")
#'     \item \code{country}: Country Alpha-2 code (e.g., "SK")
#'     \item \code{matrix}: Ecosystem/matrix ID (e.g., "3")
#'     \item \code{id}: Empodat ID or range (e.g., "100" or "100:150")
#'   }
#'
#' @param values A character or numeric value corresponding to the chosen \code{parameter}.
#'
#' @param page (Optional) Integer or character. The page number for pagination.
#'   If \code{NULL} (default), the page segment is omitted from the URL.
#'
#' @param format A character string specifying the output format.
#'   Allowed values: \code{"json"}, \code{"xml"}. Defaults to \code{"json"}.
#'
#' @return
#'   \itemize{
#'     \item If \code{format = "json"}: A list or data frame (parsed JSON).
#'     \item If \code{format = "xml"}: A raw character string (XML content).
#'   }
#'   
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
#'   results <- fetch_norman(
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
fetch_norman <- function(module, parameter, values, page = NULL, format = "json", verbose = TRUE) {
  
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