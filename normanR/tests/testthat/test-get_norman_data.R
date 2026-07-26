test_that("get_norman_data throws errors for invalid input arguments", {
  
  # Test invalid module
  expect_error(
    get_norman_data(module = "invalid_module", parameter = "nsid", value = "123"),
    "Error: Invalid module 'invalid_module'."
  )
  
  # Test invalid parameter for a valid module
  expect_error(
    get_norman_data(module = "susdat", parameter = "country", value = "PL"),
    "Error: Invalid parameter 'country' for module 'susdat'."
  )
  
  # Test invalid format
  expect_error(
    get_norman_data(module = "susdat", parameter = "nsid", value = "123", format = "csv"),
    "Error: Invalid format. Allowed values are 'json' or 'xml'."
  )
})