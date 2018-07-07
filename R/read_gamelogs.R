
#' @export
read_gamelogs <- function(player = NULL) {
  dat <- plyr::ldply(list.files("data/gamelogs"), function(x) {
    t <- read.csv(file = paste0("data/gamelogs/", x), header = T, stringsAsFactors = F)
    t$year <- as.numeric(substr(x, 1, 4))
    return(t)
  })
  dat <- dat %>% filter(!is.na(game_num))
  if(!is.null(player)) {
    dat <- dat %>% filter(player == player)
  }
  dat$player[dat$player == "Odell Beckham"] <- "Odell Beckham Jr."

  dat <- dat %>% select(player, year, game_num, rush_yds, rush_td, rec, rec_yds, rec_td, two_pt_md, pass_yds, pass_td, pass_int, kick_ret_yds, kick_ret_td, punt_ret_yds, punt_ret_td)

  dat[is.na(dat)] <- 0

  dat$pts <- weekly_fantasy_points(dat)

  return(dat)
}
