#' Extract Specific Fields from Nested Norman List
#'
#' This function iterates through a list of nested data (e.g., from the Norman API)
#' and extracts values for specific field names provided by the user.
#' It uses a recursive search to find the fields, meaning the user does not need
#' to know the full path (e.g., just "City" instead of "Data source$Organisation$City").
#'
#' @param data_list A list of lists (the standard output from JSON parsing).
#' @param field_names A character vector of field names to extract (e.g., c("E-mail", "City")).
#'
#' @return A data.frame where columns are the requested fields and rows correspond
#'   to the items in the input list. Missing values are filled with NA.
#'
#' @examples
#' \dontrun{
#'   fields <- c("id", "Name", "City", "Value", "Unit")
#'   df <- extract_norman_fields(data_cas_1$Data, fields)
#'   print(df)
#' }
#'
#' @export
extract_norman_fields <- function(data_list, field_names) {
  
  # --- Internal Helper Function: Recursive Search ---
  # This function looks for a 'key' anywhere inside a 'node' (list)
  find_value_recursive <- function(node, key) {
    # 1. Direct match: Check if the key exists at the current level
    if (key %in% names(node)) {
      return(as.character(node[[key]]))
    }
    
    # 2. Deep search: Iterate through list elements to find the key in sub-lists
    for (element in node) {
      if (is.list(element)) {
        result <- find_value_recursive(element, key)
        # If found (result is not NULL), return it immediately
        if (!is.null(result)) {
          return(result)
        }
      }
    }
    
    # 3. Not found: Return NULL
    return(NULL)
  }
  
  # --- Main Processing Loop ---
  
  # Iterate over each record in the main data_list
  row_list <- lapply(data_list, function(record) {
    
    # For the current record, extract every requested field
    extracted_values <- lapply(field_names, function(fn) {
      val <- find_value_recursive(record, fn)
      
      # Handle missing values (NULL) or empty lists by returning NA
      if (is.null(val) || length(val) == 0) {
        return(NA)
      }
      return(val)
    })
    
    # Set names for the list elements so they match column names later
    names(extracted_values) <- field_names
    return(extracted_values)
  })
  
  # --- Convert to Data Frame ---
  # Combine the list of rows into a single data frame
  # strict=FALSE ensures that mismatched types don't crash the bind
  result_df <- do.call(rbind, lapply(row_list, as.data.frame.list, stringsAsFactors = FALSE))
  
  return(result_df)
}