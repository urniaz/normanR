test_that("load_api_definitions throws an error when the file does not exist", {
  
  # Simulate a non-existent file path
  fake_path <- "non_existent_definitions_file.json"
  expect_error(
    norman_api_definitions(path = fake_path),
    paste("File not found at:", fake_path)
  )
})