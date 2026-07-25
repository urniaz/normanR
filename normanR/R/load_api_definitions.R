#' Load Norman API Definitions (Dictionary)
#'
#' This function loads the API definitions from a JSON file.
#' It returns a list structure that acts as a dictionary, allowing for
#' auto-completion (Intellisense) in RStudio when accessing modules and parameters.
#'
#' @param path A character string specifying the path to the JSON file.
#'   If NULL, it attempts to locate 'api_definitions.json' within the package's
#'   'extdata' directory.
#'
#' @return A named list (dictionary) containing two main sections:
#' \itemize{
#'   \item \code{modules}: A list where names are module names (e.g., susdat) and values are character vectors of allowed parameters.
#'   \item \code{parameters}: A list where names are parameter keys and values are their English descriptions.
#'   \item \code{patterns}: A collection of common regular expression patterns used for splitting or filtering data 
#' }
#' 
#' @examples
#' \dontrun{
#'   # 1. Load the definitions
#'   defs <- load_api_definitions()
#'
#'   # 2. Access available modules (RStudio will trigger auto-complete after $)
#'   # defs$modules$Substance
#'
#'   # 3. Access parameter descriptions
#'   # defs$parameters$`Country Alpha-2 code`
#' }
#'
#' @export
load_api_definitions <- function(path = NULL) {
  
  # If path is not provided, look in the installed package directory
  if (is.null(path)) {
    # Assuming the file is stored in inst/extdata/ inside the package
    path <- system.file("extdata", "api_definitions.json", package = "normanR")
    
    # Fallback if file is not found (e.g., during development without install)
    if (path == "") {
      stop("The file 'api_definitions.json' could not be found in the package.")
    }
  }
  
  # Load the JSON file
  if (!file.exists(path)) {
    stop(paste("File not found at:", path))
  }
  
  data <- jsonlite::fromJSON(path, simplifyVector = TRUE)
  
  return(data)
}