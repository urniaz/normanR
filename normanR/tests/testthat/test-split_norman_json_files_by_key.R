test_that("split_norman_json_files_by_key correctly splits JSON records into folders by unique keys", {
  
  # Create temporary input and output directories
  input_dir <- file.path(tempdir(), "test_split_key_in")
  output_dir <- file.path(tempdir(), "test_split_key_out")
  dir.create(input_dir, showWarnings = FALSE)
  
  # Create a mock JSON file with nested data
  mock_records <- list(
    Data = list(
      list(id = 1, Country = "Poland"),
      list(id = 2, Country = "Germany"),
      list(id = 3, Country = "Poland")
    )
  )
  
  jsonlite::write_json(mock_records, file.path(input_dir, "sample.json"), auto_unbox = TRUE, pretty = TRUE)
  
  # Execute splitting
  result <- suppressMessages(
    split_norman_json_files_by_key(
      input_dir = input_dir,
      output_dir = output_dir,
      split_key = "Country",
      data_path = "Data"
    )
  )
  
  expect_true(result)
  
  # Check if subfolders were created based on unique 'Country' values
  expect_true(dir.exists(file.path(output_dir, "Poland")))
  expect_true(dir.exists(file.path(output_dir, "Germany")))
  
  # Check if split files exist
  expect_true(file.exists(file.path(output_dir, "Poland", "sample.json")))
  expect_true(file.exists(file.path(output_dir, "Germany", "sample.json")))
  
  # Clean up directories
  unlink(input_dir, recursive = TRUE)
  unlink(output_dir, recursive = TRUE)
})