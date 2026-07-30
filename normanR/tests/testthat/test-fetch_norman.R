test_that("get_norman_data_multi processes vector of values and handles errors gracefully", {
  
  # Mock get_norman_data to avoid real network API requests during testing
  mockery_get_norman_data <- function(module, parameter, value, page = NULL, format = "json") {
    if (value == "FAIL_VAL") {
      stop("API Request Failed: 404 Not Found")
    }
    list(Data = list(id = value, status = "ok"))
  }
  
  # Temporarily override get_norman_data inside test
  testthat::with_mocked_bindings(
    get_norman_data = mockery_get_norman_data,
    {
      values <- c("1490-04-6", "FAIL_VAL", "3380-34-5")
      
      # Suppress expected warnings from tryCatch for cleaner test output
      suppressWarnings({
        results <- fetch_norman(
          module = "susdat",
          parameter = "casrn",
          values = values,
          verbose = FALSE
        )
      })
      
      # 1. Check returned structure
      expect_type(results, "list")
      expect_named(results, values)
      
      # 2. Check successful API call result
      expect_equal(results[["1490-04-6"]]$Data$id, "1490-04-6")
      
      # 3. Check error handling (should return string starting with 'Error:' instead of crashing)
      expect_type(results[["FAIL_VAL"]], "character")
      expect_true(grepl("^Error:", results[["FAIL_VAL"]]))
    }
  )
})