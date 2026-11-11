test_that("plot_career returns a ggplot object", {
  mock_data <- data.frame(
    player_age = c(20, 25, 30),
    age_difference = c(-5, 0, 5),
    result = c("W", "L", "W")
  )

  plot <- plot_career(mock_data)

  expect_s3_class(plot, "ggplot")
  expect_equal(nrow(plot$data), 3L)
})

test_that("plot_career uses the correct axes", {
  mock_data <- data.frame(
    player_age = c(20, 25, 30),
    age_difference = c(-5, 0, 5),
    result = c("W", "L", "W")
  )

  plot <- plot_career(mock_data)
  built <- ggplot2::ggplot_build(plot)

  expect_equal(built$data[[1]]$x, c(20, 25, 30))
  expect_equal(built$data[[1]]$y, c(-5, 0, 5))
})

test_that("plot_career uses correct win and loss colors", {
  mock_data <- data.frame(
    player_age = c(20, 25, 30),
    age_difference = c(-5, 0, 5),
    result = c("W", "L", "W")
  )

  plot <- plot_career(mock_data)
  built <- ggplot2::ggplot_build(plot)

  expect_equal(
    built$data[[1]]$colour,
    c("#43C6E8", "#92368E", "#43C6E8")
  )
})