test_that("extract_norman_fields correctly extracts values from a nested list", {
  # Mock data simulating API response structure
  mock_data <- list(
    list(id = 1, Substance = list(Name = "Triclosan", Details = list(City = "Warsaw")), Value = 10),
    list(id = 2, Substance = list(Name = "Ibuprofen", Details = list(City = "Krakow")), Value = 20),
    list(id = 3, Substance = list(Name = "Aspirin")) # Missing city and value
  )
  
  fields <- c("id", "Name", "City", "Value")
  result <- extract_norman_fields(mock_data, fields)
  
  # Validate return type, dimensions, and contents
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)
  expect_equal(ncol(result), 4)
  expect_equal(result$City, c("Warsaw", "Krakow", NA))
  expect_equal(result$Value, c("10", "20", NA))
})