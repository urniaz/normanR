test_that("split_by_pattern splits records based on regex pattern match", {
  
  input_dir <- file.path(tempdir(), "test_split_pat_in")
  output_dir <- file.path(tempdir(), "test_split_pat_out")
  dir.create(input_dir, showWarnings = FALSE)
  
  # Mock records with date strings
  mock_records <- list(
    list(id = 1, Date = "2023-05-12"),
    list(id = 2, Date = "2023-11-20"),
    list(id = 3, Date = "2024-01-01")
  )
  
  jsonlite::write_json(mock_records, file.path(input_dir, "dates.json"), auto_unbox = TRUE, pretty = TRUE)
  
  # Extract only the 4-digit year (regex: "^[0-9]{4}")
  result <- suppressMessages(
    split_by_pattern(
      input_dir = input_dir,
      output_dir = output_dir,
      split_key = "Date",
      pattern = "^[0-9]{4}",
      data_path = NULL
    )
  )
  
  expect_true(result)
  
  # Expect subfolders "2023" and "2024"
  expect_true(dir.exists(file.path(output_dir, "2023")))
  expect_true(dir.exists(file.path(output_dir, "2024")))
  
  # Verify folder "2023" has both 2023 records
  year_2023_data <- jsonlite::fromJSON(file.path(output_dir, "2023", "dates.json"))
  expect_equal(length(year_2023_data), 2)
  
  # Clean up directories
  unlink(input_dir, recursive = TRUE)
  unlink(output_dir, recursive = TRUE)
})