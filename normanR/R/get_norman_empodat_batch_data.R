#' Batch Retrieve and Paginate Norman Empodat Database
#'
#' This function extends \code{get_norman_data} by supporting multiple search values
#' and automatic pagination for the 'empodat' module.
#'
#' @param parameter A character string (e.g., "nsid", "casrn").
#' @param values A character vector of values to search for (e.g., c("3380-34-5", "50-00-0")).
#' @param saveToDir = when NULL files are not saved, when directory the files are saved as "values.json" file name
#' @param dropMemory when true, it clears memory buffer after every loop, data will not be accessible from memory 
#'    (json$Data is NULL)
#'
#' @return A consolidated list containing all records retrieved across all 
#'   values and pages.
#'
# @export
get_norman_empodat_batch_data <- function(parameter, values, saveToDir = NULL, dropMemory = FALSE) {
  
  module = "empodat"
  format = "json"
  pages = "all"
  
  # Initialize a master list to store results from all values
  final_results <- list()
  
  # Loop 1: Iterate through each value provided in the vector
  for (current_value in values) {
    message(paste("Processing value:", current_value))
    
    # Perform the first request to get data and determine pagination info
    # We use 1 as the starting page if 'all' is requested
    start_page <- if (identical(pages, "all")) 1 else pages
    
    initial_resp <- get_norman_data(
      module = module, 
      parameter = parameter, 
      value = current_value, 
      page = start_page, 
      format = format
    )
    
    # Store results from the first request
    # Note: Structure depends on API response; usually records are in $Data
  
    final_results[[current_value]] <- initial_resp
    
    # Loop 2: Handle "all" pages (Specific to empodat logic)
    if (module == "empodat" && identical(pages, "all")) {
      
      # Extract total pages from API metadata
      # The Norman API typically provides this in the root of the JSON response
      if (!(is.null(initial_resp$`Total pages`))){
         total_pages <- as.numeric(initial_resp$`Total pages`)
      }else{ total_pages <- 0 }
      
      if (!is.na(total_pages) && total_pages > 1) {
        message(paste("Found", total_pages, "pages. Fetching remaining..."))
        
        # Loop from page 2 to the end
        for (p in 2:total_pages) {
          page_resp <- get_norman_data(
            module = module,
            parameter = parameter,
            value = current_value,
            page = p,
            format = format
          )
          
          if (!is.null(page_resp$Data)) {
            final_results[[current_value]]$Data <- append(final_results[[current_value]]$Data, page_resp$Data)
          }
        }
      }
    }
    # process data collect and keep in memory (saveToDir = NULL) 
    # or save data and report saveToDir = <dir>/<folder>
    if (is.null(saveToDir) == FALSE){
      jsonlite::write_json(final_results[[current_value]], file.path(saveToDir, paste0(current_value,".json")), pretty = TRUE)
    }
    # when true, clear memory buffer after every loop, data will not be accessible from memory
    if (dropMemory) { final_results[[current_value]]$Data <- NULL}
  }
  # Save table with results
  if (is.null(saveToDir) == FALSE){
    jsonlite::write_json(final_results, file.path(saveToDir, paste0("final_results.json")), pretty = TRUE)
  }
  
  return(final_results)
}