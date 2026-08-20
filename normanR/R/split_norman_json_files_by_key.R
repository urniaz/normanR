#' Split JSON Files Based on Unique Key Values
#'
#' This function scans a source directory for JSON files, loads them, and splits 
#' each file into multiple smaller JSON files based on the unique values of a 
#' specified key. Each unique value results in a separate file.
#'
#' @param input_dir Character. Path to the directory containing source JSON files.
#' @param output_dir Character. Path to the directory where split files will be saved.
#' @param split_key Character. The name of the key/field used to isolate unique values 
#'   (e.g., "Name of country" or "Sample matrix").
#' @param data_path Character. If the JSON has a nested structure (like Norman API), 
#'   provide the name of the element containing the list of records (e.g., "Data"). 
#'   Defaults to NULL (assumes the JSON is a top-level list).
#'
#' @return Logical. Returns TRUE if the operation completes successfully.
#'
#' @details 
#' The function creates the output directory if it does not exist. Filenames are 
#' generated using the pattern: original_name.json.
#'
#' @importFrom stats na.omit
#' @export
split_by_key <- function(input_dir, output_dir, split_key, data_path = NULL) {
  
  # 1. Setup and Validation
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # List all JSON files in the input directory
  file_list <- list.files(path = input_dir, pattern = "\\.json$", full.names = TRUE)
  
  if (length(file_list) == 0) {
    stop("No JSON files found in the specified input directory.")
  }
  
  # 2. Process each file
  for (file_path in file_list) {
    message("Processing file: ", basename(file_path), " [", match(file_path, file_list), "/", length(file_list), "]")
    
    # Load JSON data
    raw_data <- jsonlite::fromJSON(file_path, simplifyVector = FALSE)
    
    # Navigate to the data list if data_path is provided
    records <- if (!is.null(data_path)) raw_data[[data_path]] else raw_data
    
    if (!is.list(records)) {
      warning("Skipping file: Data is not in a list format.")
      next
    }
    
    # 3. Extract unique values for the split_key
    # We use a helper function to find values even if nested
    extract_val <- function(x) {
      if (split_key %in% names(x)) return(as.character(x[[split_key]]))
      
      # Search one level deeper (for Substance$Name etc.)
      for (sub in x) {
        if (is.list(sub) && split_key %in% names(sub)) return(as.character(sub[[split_key]]))
      }
      return(NA)
    }
    
    key_values <- sapply(records, extract_val)
    unique_keys <- unique(na.omit(key_values))
    
    # 4. Filter and Save smaller files
    base_name <- tools::file_path_sans_ext(basename(file_path))
    
    for (u_val in unique_keys) {
      # Isolate records matching this unique value
      subset_indices <- which(key_values == u_val)
      subset_records <- records[subset_indices]
      
      # Create safe filename (remove non-alphanumeric characters)
      safe_val <- gsub("[^[:alnum:]]", "_", u_val) # <--- key values separated by, name for the sub-folder
      out_filename <- paste0(base_name, ".json") # , "_", safe_val, ".json") <--- base name (original file name) only
      out_path <- file.path(output_dir, safe_val, out_filename)
      
      # Create dir if not exist 
      if (!dir.exists(file.path(output_dir, safe_val))) {
        dir.create(file.path(output_dir, safe_val), recursive = TRUE)
      }
      
      # Save back to JSON
      jsonlite::write_json(subset_records, out_path, auto_unbox = TRUE, pretty = TRUE)
    }
    
    message("Finished splitting '", basename(file_path), "' into ", length(unique_keys), " files.")
  }
  
  return(TRUE)
}