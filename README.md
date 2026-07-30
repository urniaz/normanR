<!-- badges: start -->
[![R-CMD-check](https://github.com/urniaz/normanR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/urniaz/normanR/actions)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![DOI](https://zenodo.org/badge/1155862583.svg)](https://doi.org/10.5281/zenodo.21611983)
<!-- badges: end -->

# normanR: An R client for the Network Database System REST API

**Rafal Urniaz, PhD** [![ORCID](https://img.shields.io/badge/ORCID-0000--0003--0192--2165-A6CE39?logo=orcid&logoColor=FFFFFF)](https://orcid.org/0000-0003-0192-2165) 

## Overview

**`normanR`** provides helper functions to query the **Norman Network Database System (NDS) REST API** and process the retrieved chemical and ecotoxicological data. 

The package enables researchers in environmental chemistry and ecotoxicology to retrieve chemical substance data, ecotoxicological parameters, and EMPODAT monitoring datasets, handle batch queries across multiple identifiers, flatten complex nested API responses into clean tabular structures, and organize local JSON data files.

### Key Features
* **Direct querying of all main NDS modules (`susdat`, `ecotox`, `empodat`, `passive`) with strict input parameter validation with automated pagination and optional disk caching.
* **Nested Field Extraction (`extract_norman_fields`):** Recursively search and extract nested JSON list outputs into tidy `data.frame` formats.
* **Offline File Organization (`split_json_files_by_key`, `split_json_files_by_pattern`):** Partition bulk offline JSON files into structured subdirectories based on specific field keys or regular expressions.
* **API Metadata Lookup (`load_api_definitions`):** Load API dictionary definitions from local JSON storage.

## Installation

You can install the development version of `normanR` directly from GitHub using `devtools` or `remotes`:

```r
# Install pack if not already installed
if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
}

# Install normanR from GitHub
pak::pak("urniaz/normanR/normanR")
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

# Fetch substance data by CAS number using the core function
data_cas <- get_norman_data(
  module = "susdat",
  parameter = "casrn",
  value = "1490-04-6",
  format = "json"
)

data_cas$`Compound name`
```

---

## Software Metadata

| Metadata element | Description |
| :--- | :--- |
| **Current Code Version** | `1.3.77` |
| **Permanent Code Repository** | [https://github.com/urniaz/normanR](https://github.com/urniaz/normanR) |
| **Legal Code License** | GNU General Public License v3.0 (GPL-3) |
| **Code Versioning System** | Git |
| **Software Language** | R (>= 4.1.0) |
| **Dependencies** | `httr2`, `jsonlite` |
| **Testing Framework** | `testthat` (>= 3.0.0) |

---
