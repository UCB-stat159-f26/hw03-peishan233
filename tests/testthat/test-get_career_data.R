test_that("player names are formatted correctly", {
  expect_equal(format_player_name("Serena Williams"), "SerenaWilliams")
  expect_equal(format_player_name("serena williams"), "SerenaWilliams")
  expect_equal(format_player_name("Rafael Nadal"), "RafaelNadal")
  expect_equal(format_player_name("SerenaWilliams"), "SerenaWilliams")
})

test_that("invalid player names produce errors", {
  expect_error(format_player_name(""))
  expect_error(format_player_name("   "))
  expect_error(format_player_name(NA_character_))
  expect_error(format_player_name(123))
})

test_that("career JavaScript data is parsed correctly", {
  record <- rep("", 17)
  record[c(1, 5, 12, 17)] <- c(
    "20200101", "W", "Test Opponent", "19900101"
  )

  fake_js <- paste0(
    "var morematchmx = ",
    jsonlite::toJSON(list(record), auto_unbox = TRUE),
    ";"
  )

  matches <- parse_career_js(fake_js)

  expect_length(matches, 1)
  expect_equal(matches[[1]][[1]], "20200101")
  expect_equal(matches[[1]][[5]], "W")
  expect_equal(matches[[1]][[12]], "Test Opponent")
})

test_that("match records are converted to a data frame", {
  record <- rep("", 17)
  record[c(1, 5, 12, 17)] <- c(
    "20200101", "W", "Test Opponent", "19900101"
  )

  df <- matches_to_frame(list(record))

  expect_s3_class(df, "data.frame")
  expect_equal(nrow(df), 1L)
  expect_named(df, c(
    "match_date", "result", "opponent", "opponent_info"
  ))
  expect_equal(df$opponent[1], "Test Opponent")
})

test_that("match dates are converted correctly", {
  df <- data.frame(
    match_date = c("20200101", "20210615"),
    stringsAsFactors = FALSE
  )

  result <- convert_match_dates(df)

  expect_s3_class(result$match_date, "Date")
  expect_equal(result$match_date[1], as.Date("2020-01-01"))
  expect_equal(result$match_date[2], as.Date("2021-06-15"))
  expect_equal(nrow(result), 2L)
})

test_that("opponent ages are calculated correctly", {
  df <- data.frame(
    match_date = as.Date(c("2020-01-01", "2020-01-01")),
    opponent_info = c("19900101", "22.5")
  )

  result <- add_opponent_age(df)

  expected_age <- as.numeric(
    as.Date("2020-01-01") - as.Date("1990-01-01")
  ) / 365.25

  expect_equal(result$opponent_age[1], expected_age)
  expect_equal(result$opponent_age[2], 22.5)
  expect_type(result$opponent_age, "double")
  expect_equal(nrow(result), 2L)
})

test_that("age differences are calculated correctly", {
  df <- data.frame(
    player_age = c(25, 30, 20),
    opponent_age = c(30, 25, 20)
  )

  result <- add_age_difference(df)

  expect_equal(result$age_difference, c(-5, 5, 0))
  expect_equal(result$age_difference[1], -5)
  expect_equal(result$age_difference[2], 5)
  expect_equal(result$age_difference[3], 0)
})

test_that("invalid career matches are removed", {
  df <- data.frame(
    match_date = as.Date(c("2020-01-01", "2020-01-02")),
    opponent = c("Test Opponent", ""),
    result = c("W", "L"),
    player_age = c(25, 25),
    opponent_age = c(30, 26),
    age_difference = c(-5, -1)
  )

  expect_warning(
    clean_career_data(df),
    "1 invalid matches removed"
  )

  clean <- suppressWarnings(clean_career_data(df))

  expect_equal(nrow(clean), 1L)
  expect_equal(clean$opponent, "Test Opponent")
  expect_equal(clean$age_difference, -5)
})

test_that("invalid JavaScript data produces errors", {
  expect_error(
    parse_career_js("not a match array"),
    "No valid match data found"
  )

  expect_error(
    parse_career_js("var morematchmx = []"),
    "No career matches found"
  )
})

test_that("player birth dates are parsed correctly", {
  serena_js <- "var dob=19810926;"
  nadal_js <- "var dob=19860603;"

  expect_equal(
    parse_player_birth(serena_js),
    as.Date("1981-09-26")
  )

  expect_equal(
    parse_player_birth(nadal_js),
    as.Date("1986-06-03")
  )

  expect_error(
    parse_player_birth("var player = 'Unknown';"),
    "Player birth date not found"
  )
})

test_that("player ages are calculated correctly", {
  local_mocked_bindings(
    get_player_birth = function(player_name) {
      as.Date("2000-01-01")
    }
  )

  df <- data.frame(
    match_date = as.Date(c("2020-01-01", "2021-01-01"))
  )

  result <- add_player_age(df, "Mock Player")

  expected <- as.numeric(
    df$match_date - as.Date("2000-01-01")
  ) / 365.25

  expect_equal(result$player_age, expected)
  expect_equal(nrow(result), 2L)
  expect_equal(result$match_date, df$match_date)
})

test_that("get_career_data works with mock data", {
  record <- rep("", 17)
  record[c(1, 5, 12, 17)] <- c(
    "20200101", "W", "Test Opponent", "19900101"
  )

  fake_js <- paste0(
    "var morematchmx = ",
    jsonlite::toJSON(list(record), auto_unbox = TRUE),
    ";"
  )

  local_mocked_bindings(
    fetch_career_js = function(player_name) fake_js,
    get_player_birth = function(player_name) as.Date("2000-01-01")
  )

  df <- get_career_data("Mock Player")

  expect_s3_class(df, "data.frame")
  expect_equal(nrow(df), 1L)
  expect_equal(df$result, "W")
  expect_true(all(c("player_age", "opponent_age",
                    "age_difference") %in% names(df)))
})