test_that("get_norman_empodat_batch_data iterates through pages and handles file saving/memory options", {
  
  # Mock API response for pagination logic
  mock_empodat_api <- function(module, parameter, value, page = NULL, format = "json") {
    if (is.null(page) || page == 1) {
      return(list(`Total pages` = 2, Data = list(list(id = 1, val = value))))
    } else if (page == 2) {
      return(list(`Total pages` = 2, Data = list(list(id = 2, val = value))))
    }
  }
  
  testthat::with_mocked_bindings(
    get_norman_data = mock_empodat_api,
    {
      temp_dir <- tempdir()
      test_values <- c("3380-34-5")
      
      # Test pagination and memory dropping
      res <- suppressMessages(
        get_norman_empodat_batch_data(
          parameter = "casrn",
          values = test_values,
          saveToDir = temp_dir,
          dropMemory = TRUE
        )
      )
      
      # 1. Check if files were actually created
      val_file <- file.path(temp_dir, "3380-34-5.json")
      final_file <- file.path(temp_dir, "final_results.json")
      
      expect_true(file.exists(val_file))
      expect_true(file.exists(final_file))
      
      # 2. Check dropMemory behavior ($Data should be NULL in memory)
      expect_null(res[["3380-34-5"]]$Data)
      
      # Clean up temp files
      unlink(val_file)
      unlink(final_file)
    }
  )
})