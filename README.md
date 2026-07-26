# normanR: R Interface to the Norman Network API

<!-- badges: start -->
[![R-CMD-check](https://github.com/urniaz/normanR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/urniaz/normanR/actions)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.XXXXXXX.svg)](https://doi.org/10.5281/zenodo.XXXXXXX)
<!-- badges: end -->

## Overview

**`normanR`** provides helper functions to query the **Norman Network Database System (NDS) REST API** and process the retrieved chemical and ecotoxicological data. 

The package enables researchers in environmental chemistry and ecotoxicology to retrieve chemical substance data, ecotoxicological parameters, and EMPODAT monitoring datasets, handle batch queries across multiple identifiers, flatten complex nested API responses into clean tabular structures, and organize local JSON data files.

### Key Features
* **Core API Integration (`get_norman_data`):** Direct querying of all main NDS modules (`susdat`, `ecotox`, `empodat`, `passive`) with strict input parameter validation.
* **Batch Processing (`get_norman_data_multi`, `get_norman_empodat_batch_data`):** Query multiple parameters (e.g., vectors of CAS numbers) and perform multi-page EMPODAT data retrieval with automated pagination and optional disk caching.
* **Nested Field Extraction (`extract_norman_fields`):** Recursively search and extract nested JSON list outputs into tidy `data.frame` formats.
* **Offline File Organization (`split_json_files_by_key`, `split_json_files_by_pattern`):** Partition bulk offline JSON files into structured subdirectories based on specific field keys or regular expressions.
* **API Metadata Lookup (`load_api_definitions`):** Load API dictionary definitions from local JSON storage.

---

## Installation

You can install the development version of `normanR` directly from GitHub using `devtools` or `remotes`:

```r
# Install devtools if not already installed
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Install normanR from GitHub
devtools::install_github("urniaz/normanR")
```

or from CRAN

```r
# Install normanR from CRAN
install.packages("normanR")
```

## Quick Start / Usage Example
### Single API Query & Field Extraction

```r
library(normanR)

# Query substance data using a CAS Registry Number
susdat_data <- get_norman_data(
  module = "susdat",
  parameter = "casrn",
  value = "1490-04-6",
  format = "json"
)

# Extract nested JSON fields into a clean data.frame
fields <- c("id", "Name", "City", "Value")
df <- extract_norman_fields(
  data_list = susdat_data$Data, 
  field_names = fields
)

head(df)
```
