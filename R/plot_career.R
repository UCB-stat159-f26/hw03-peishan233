#' Plot Tennis Career Matches
#'
#' @param data A cleaned data frame from get_career_data().
#' @return A ggplot object showing career match age differences.
#' @export
plot_career <- function(data) {
  ggplot2::ggplot(
    data,
    ggplot2::aes(x = player_age, y = age_difference, color = result)
  ) +
    ggplot2::geom_point(size = 1, alpha = 0.85) +
    ggplot2::geom_hline(yintercept = 0, color = "gray55") +
    ggplot2::scale_color_manual(
      values = c("W" = "#43C6E8", "L" = "#92368E"),
      labels = c("W" = "Win", "L" = "Loss")
    ) +
    ggplot2::labs(
      title = "Professional Tennis Career Matches",
      x = "Player's Age",
      y = "Player Age - Opponent Age",
      color = "Match Result"
    ) +
    ggplot2::theme_minimal()
}

