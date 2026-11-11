# Convert a player's name to the Tennis Abstract format
format_player_name <- function(player_name) {
  if (!is.character(player_name) || length(player_name) != 1L ||
      is.na(player_name) || !nzchar(trimws(player_name))) {
    stop("Please provide one valid player name.", call. = FALSE)
  }

  name <- trimws(player_name)
  if (!grepl("[[:space:]]", name)) return(name)

  parts <- strsplit(tolower(name), "[[:space:]]+")[[1]]
  paste0(paste0(toupper(substring(parts, 1, 1)),
                substring(parts, 2)), collapse = "")
}

# Generate the Tennis Abstract career data URL
career_data_url <- function(player_name) {
  name <- format_player_name(player_name)
  paste0("https://www.tennisabstract.com/jsmatches/",
         name, "Career.js")
}

# Retrieve the raw career match data
fetch_career_js <- function(player_name) {
  url <- career_data_url(player_name)

  tryCatch(
    paste(suppressWarnings(readLines(url, warn = FALSE)), collapse = "\n"),
    error = function(e) {
      stop(
        paste("Could not retrieve career data for", player_name),
        call. = FALSE
      )
    }
  )
}

# Convert raw JavaScript text into R match records
parse_career_js <- function(js_text) {
  start <- regexpr("[", js_text, fixed = TRUE)[1]
  end <- utils::tail(gregexpr("]", js_text, fixed = TRUE)[[1]], 1)

  if (start < 1 || end < start) {
    stop("No valid match data found.", call. = FALSE)
  }

  json_text <- substr(js_text, start, end)
  matches <- tryCatch(
    jsonlite::fromJSON(json_text, simplifyVector = FALSE),
    error = function(e) stop("Could not parse match data.", call. = FALSE)
  )

  if (!is.list(matches) || length(matches) == 0) {
    stop("No career matches found.", call. = FALSE)
  }
  matches
}

# Convert match records into a data frame
matches_to_frame <- function(matches) {
  required <- c(1L, 5L, 12L, 17L)

  if (!all(vapply(matches, function(x) length(x) >= max(required), logical(1)))) {
    stop("Some match records are missing required fields.", call. = FALSE)
  }

  data.frame(
    match_date = vapply(matches, function(x) x[[1]], character(1)),
    result = vapply(matches, function(x) x[[5]], character(1)),
    opponent = vapply(matches, function(x) x[[12]], character(1)),
    opponent_info = vapply(matches, function(x) x[[17]], character(1)),
    stringsAsFactors = FALSE
  )
}

# Convert match dates into R Date objects
convert_match_dates <- function(df) {
  df$match_date <- as.Date(
    df$match_date,
    format = "%Y%m%d"
  )
  df
}

# Calculate opponent ages for male and female players
add_opponent_age <- function(df) {
  info <- trimws(df$opponent_info)

  # Identify birth dates in YYYYMMDD format
  is_birth_date <- grepl("^[0-9]{8}$", info)

  # Convert existing numeric ages
  opponent_age <- suppressWarnings(as.numeric(info))

  # Calculate ages when birth dates are provided
  if (any(is_birth_date)) {
    birth_dates <- as.Date(info[is_birth_date], format = "%Y%m%d")
    opponent_age[is_birth_date] <- as.numeric(
      df$match_date[is_birth_date] - birth_dates
    ) / 365.25
  }

  df$opponent_age <- opponent_age
  df
}

# Retrieve a player's birth date from Tennis Abstract
get_player_birth <- function(player_name) {
  url <- sub("Career\\.js$", ".js", career_data_url(player_name))

  js <- tryCatch(
    suppressWarnings(readLines(url, warn = FALSE)),
    error = function(e) {
      stop("Could not retrieve player profile.", call. = FALSE)
    }
  )

  parse_player_birth(js)
}

# Calculate the player's age at each match
add_player_age <- function(df, player_name) {
  birth <- get_player_birth(player_name)

  df$player_age <- as.numeric(
    df$match_date - birth
  ) / 365.25

  df
}

# Calculate the age difference between player and opponent
add_age_difference <- function(df) {
  df$age_difference <- df$player_age - df$opponent_age
  df
}

# Remove invalid records and select the final columns
clean_career_data <- function(df) {
  valid <- !is.na(df$match_date) &
    !is.na(df$opponent) & nzchar(trimws(df$opponent)) &
    df$result %in% c("W", "L") &
    is.finite(df$player_age) &
    is.finite(df$opponent_age) &
    is.finite(df$age_difference) &
    df$player_age >= 0 & df$opponent_age >= 0

  if (any(!valid)) {
    warning(sum(!valid), " invalid matches removed.", call. = FALSE)
  }

  columns <- c("match_date", "opponent", "result",
               "player_age", "opponent_age", "age_difference")
  clean <- df[valid, columns, drop = FALSE]

  if (nrow(clean) == 0) stop("No valid career matches found.", call. = FALSE)
  clean
}

#' Retrieve Tennis Career Match Data
#'
#' @param player_name Name of the tennis player.
#' @return A cleaned data frame of career matches.
#' @export
get_career_data <- function(player_name) {
  matches <- parse_career_js(fetch_career_js(player_name))
  df <- matches_to_frame(matches)
  df <- convert_match_dates(df)
  df <- add_opponent_age(df)
  df <- add_player_age(df, player_name)
  df <- add_age_difference(df)
  clean_career_data(df)
}

# Extract a player's birthday from JavaScript data
parse_player_birth <- function(js_lines) {
  dob_line <- grep("var dob\\s*=\\s*[0-9]{8}",
                   js_lines, value = TRUE, perl = TRUE)

  if (length(dob_line) != 1L) {
    stop("Player birth date not found.", call. = FALSE)
  }

  dob <- sub(".*dob\\s*=\\s*([0-9]{8}).*", "\\1",
             dob_line, perl = TRUE)

  birth <- as.Date(dob, format = "%Y%m%d")

  if (is.na(birth)) {
    stop("Invalid player birth date.", call. = FALSE)
  }

  birth
}