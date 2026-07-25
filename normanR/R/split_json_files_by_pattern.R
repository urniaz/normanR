#' Split JSON Files Based on Partial Key Values (Pattern Matching)
#'
#' @param input_dir Character. Path to the folder containing source JSON files.
#' @param output_dir Character. Path to the folder where output files will be saved.
#' @param split_key Character. The JSON key to inspect (e.g., "Sampling date").
#' @param pattern Character (Regex). A pattern to extract. If NULL, splits by full value.
#' @param data_path Character. The element in the JSON containing the records list.
#'
#' @export
split_json_files_by_pattern <- function(input_dir, output_dir, split_key, pattern = NULL, data_path = NULL) {
  
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
  file_list <- list.files(path = input_dir, pattern = "\\.json$", full.names = TRUE)
  
  for (file_path in file_list) {
    message("Processing file: ", basename(file_path), " [", match(file_path, file_list), "/", length(file_list), "]")
    
    raw_data <- jsonlite::fromJSON(file_path, simplifyVector = FALSE)
    records <- if (!is.null(data_path)) raw_data[[data_path]] else raw_data
    
    # --- FIXED Internal Extraction Logic ---
    get_refined_value <- function(record) {
      val <- NULL
      
      # 1. Find the value (standard or nested)
      if (split_key %in% names(record)) {
        val <- record[[split_key]]
      } else {
        for (sub in record) {
          if (is.list(sub) && split_key %in% names(sub)) {
            val <- sub[[split_key]]
            break
          }
        }
      }
      
      if (is.null(val)) return(NA)
      val <- as.character(val)
      
      # 2. FIX: Handle NULL pattern vs Regex extraction
      if (is.null(pattern)) {
        # If no pattern, return the original value in full
        return(val)
      } else {
        # If pattern exists, try to extract the match
        m <- regexpr(pattern, val)
        if (m != -1) {
          return(regmatches(val, m))
        } else {
          return(NA) 
        }
      }
    }
    
    # Apply extraction to all records
    refined_values <- sapply(records, get_refined_value)
    
    # Filter out NA (where key or pattern match wasn't found)
    unique_groups <- unique(na.omit(refined_values))
    
    # --- Splitting and Saving ---
    base_filename <- tools::file_path_sans_ext(basename(file_path))
    
    for (group in unique_groups) {
      # Use identical() or %in% to safely handle NA in refined_values
      subset_indices <- which(refined_values == group)
      subset_records <- records[subset_indices]
      
      # Create safe filename (remove non-alphanumeric characters)
      safe_group <- gsub("[^[:alnum:]]", "_", group) # <--- key values separated by, name for the sub-folder
      out_filename <- paste0(base_filename, ".json") # , "_", safe_group, ".json") <--- base name (original file name) only
      out_path <- file.path(output_dir, safe_group, out_filename)
      
      # Create dir if not exist 
      if (!dir.exists(file.path(output_dir, safe_group))) {
        dir.create(file.path(output_dir, safe_group), recursive = TRUE)
      }
      
      jsonlite::write_json(subset_records, out_path, auto_unbox = TRUE, pretty = TRUE)
    }
    message("Finished splitting '", basename(file_path), "' into ", length(unique_groups), " files.")
  }
  return(TRUE)
}