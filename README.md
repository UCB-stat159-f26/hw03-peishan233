# Tennis Career

## Overview

tenniscareer is an R package developed for STAT 159 Homework 3 at UC Berkeley. It extends the work from Homework 1 and Homework 2 by turning the tennis career data analysis into a reusable R package.

The package retrieves professional tennis match data from Tennis Abstract, processes player and opponent age information, and generates scatter plots showing age differences across a player's career. 

The package provides two main functions:

- `get_career_data()`: Retrieves and cleans career match data
  for a specified tennis player.
- `plot_career()`: Creates a scatter plot showing the player's
  age and age difference with opponents, with points colored
  by match result.


## Installation

The `tenniscareer` package can be installed directly from GitHub.

First, install the `remotes` package if it is not already installed:

```r
install.packages("remotes")
```

Then install `tenniscareer`:

```r
remotes::install_github("UCB-stat159-f26/hw03-peishan233")
```

Load the package:

```r
library(tenniscareer)
```

**Note:** The GitHub repository is private. Installation requires GitHub access to the repository.


## Usage

The package provides two public functions:

- `get_career_data()` retrieves and cleans a player's career match data.
- `plot_career()` creates a scatter plot showing the player's age and age difference with opponents, colored by match result.

### Example 1: Serena Williams

```r
library(tenniscareer)

# Retrieve Serena Williams's career match data
serena <- get_career_data("Serena Williams")

# View the first six rows
head(serena)

# Generate the scatter plot
plot_career(serena)
```

### Example 2: Rafael Nadal

```r
# Retrieve Rafael Nadal's career match data
nadal <- get_career_data("Rafael Nadal")

# View the first six rows
head(nadal)

# Generate the scatter plot
plot_career(nadal)
```

### Invalid Player Names

If the requested player's career data cannot be retrieved, the package returns a meaningful error message.

```r
get_career_data("Gaston Sanchez")
```

Expected error:

```text
Error: Could not retrieve career data for Gaston Sanchez
```

### Output Data

The `get_career_data()` function returns a data frame containing six columns:

| Column | Description |
|---|---|
| `match_date` | Date of the match |
| `opponent` | Opponent's name |
| `result` | Match result (W or L) |
| `player_age` | Player's age at the match |
| `opponent_age` | Opponent's age at the match |
| `age_difference` | Player's age minus opponent's age |


## Testing and Validation

The package uses `testthat` for automated unit testing. Tests are located in the `tests/testthat/` directory.

### Running Unit Tests

To run all automated tests from the package's root directory:

```r
devtools::test()
```

The tests use mock data to validate the package's functionality without accessing the live Tennis Abstract server.

The tests cover:

- Player name formatting and invalid inputs
- JavaScript data parsing
- Match data frame construction
- Match date conversion
- Player and opponent age calculations
- Age difference calculations
- Invalid record removal
- Scatter plot coordinates and Win/Loss colors
- Complete data processing using mocked functions

The automated test suite passed all 49 expectations with no failures or warnings.

### Package Validation

To perform a full R package check, run:

```r
devtools::check()
```

The latest package check returned:

- 0 errors
- 0 warnings
- 1 note

The remaining note was related to the environment being unable to verify the current system time, rather than a detected problem with the package code.

### Installation Validation

The package was successfully installed directly from GitHub using `remotes::install_github()`.

Both public functions were tested after installation using Serena Williams and Rafael Nadal's career data.


## Project Structure

The repository is organized as follows:

```text
hw03-peishan233/
├── R/
│   ├── get_career_data.R
│   └── plot_career.R
├── man/
│   ├── get_career_data.Rd
│   └── plot_career.Rd
├── tests/
│   ├── testthat/
│   │   ├── test-get_career_data.R
│   │   └── test-plot_career.R
│   └── testthat.R
├── .Rbuildignore
├── DESCRIPTION
├── LICENSE
├── LICENSE.md
├── NAMESPACE
├── README.md
└── instructions.md
```

### R/
Contains the R functions used to retrieve, clean, and visualize tennis career match data.

### man/
Contains function documentation automatically generated using `roxygen2`.

### tests/
Contains automated unit tests written with `testthat`. Mock data is used to test the data-processing functions without accessing the live website.

### Package Configuration
- `DESCRIPTION`: Package metadata and dependencies.
- `NAMESPACE`: Exports the two public functions.
- `.Rbuildignore`: Excludes unnecessary files from package builds.
- `LICENSE` and `LICENSE.md`: MIT license information.


## Data Sources

The tennis match data used in this package comes from [Tennis Abstract](https://www.tennisabstract.com/), a website that provides historical professional tennis statistics.

The package retrieves data directly from Tennis Abstract's JavaScript files.

### Career Match Data

- [Serena Williams Career Matches](https://www.tennisabstract.com/jsmatches/SerenaWilliamsCareer.js)
- [Rafael Nadal Career Matches](https://www.tennisabstract.com/jsmatches/RafaelNadalCareer.js)

These files contain match dates, opponents, results, and other match information.

### Player Information

- [Serena Williams Player Data](https://www.tennisabstract.com/jsmatches/SerenaWilliams.js)
- [Rafael Nadal Player Data](https://www.tennisabstract.com/jsmatches/RafaelNadal.js)

These files provide player information, including birth dates used to calculate each player's age during matches.

### Data Processing

The `get_career_data()` function automatically downloads and processes the data. The package does not require users to manually download CSV files.

The package also handles differences in the opponent age formats between male and female player datasets.


## Personal Reflections

One of the biggest challenges I faced in this assignment was turning my HW2 scripts into a reusable R package. In HW2, I only needed to create a visualization for Serena Williams, so I could directly use her birth date in my code. However, HW3 required the same functions to work for different tennis players. I spent time examining the JavaScript files from Tennis Abstract and discovered that the birth date was stored in a separate player profile file. I also learned that male and female players had different formats for their opponents' ages. This made me realize that code working correctly for one dataset does not necessarily mean it will work for others.

Another important lesson was learning how to test and organize my code. Previously, I usually checked whether my final output looked correct, but I rarely tested each function separately. In this assignment, I used `testthat` and mock data to check individual functions without relying on the live website. I also encountered several NOTES when running `devtools::check()`, which helped me understand the importance of package structure and documentation. Instead of only focusing on generating the correct plot, I learned to think more about whether other people could install, understand, test, and reuse my code.