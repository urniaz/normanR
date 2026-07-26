## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk_set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)


## -----------------------------------------------------------------------------
library(normanR)

# Fetch substance data by CAS number using the core function
data_cas <- get_norman_data(
  module = "susdat",
  parameter = "casrn",
  value = "1490-04-6",
  format = "json"
)

data_cas$`Compound name`


