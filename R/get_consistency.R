
#' @export
get_consistency <- function() {
  dat <- read.csv(file = "data/gamelogs/2019.csv", header = T, stringsAsFactors = F)
  dat <- dat %>% filter(!is.na(game_num) & game_num <= 16)
  dat[is.na(dat)] <- 0
  dat <- dat[order(dat$player, dat$game_num),]
  dat$player[dat$player == "Odell Beckham"] <- "Odell Beckham Jr."

  dat$pts <- weekly_fantasy_points(dat)

  dat$starts <- 0
  dat$top <- 0

  qb <- data.frame()
  rb <- data.frame()
  wr <- data.frame()
  te <- data.frame()
  for(i in 1:16) {
    qbs <- dat %>% filter(position == "QB") %>% filter(game_num == i)
    qbs <- qbs[order(-qbs$pts),]
    qbs$top[c(1:3)] <- qbs$top[c(1:3)] + 1
    qbs$starts[c(1:12)] <- qbs$starts[c(1:12)] + 1
    qb <- rbind(qb, qbs)

    rbs <- dat %>% filter(position == "RB") %>% filter(game_num == i)
    rbs <- rbs[order(-rbs$pts),]
    rbs$top[c(1:6)] <- rbs$top[c(1:3)] + 1
    rbs$starts[c(1:24)] <- rbs$starts[c(1:12)] + 1
    rb <- rbind(rb, rbs)

    wrs <- dat %>% filter(position == "WR") %>% filter(game_num == i)
    wrs <- wrs[order(-wrs$pts),]
    wrs$top[c(1:9)] <- wrs$top[c(1:3)] + 1
    wrs$starts[c(1:36)] <- wrs$starts[c(1:12)] + 1
    wr <- rbind(wr, wrs)

    tes <- dat %>% filter(position == "TE") %>% filter(game_num == i)
    tes <- tes[order(-tes$pts),]
    tes$top[c(1:3)] <- tes$top[c(1:3)] + 1
    tes$starts[c(1:12)] <- tes$starts[c(1:12)] + 1
    te <- rbind(te, tes)
  }

  dat <- rbind(qb, rb, wr, te)
  dat <- dat[order(dat$player, dat$game_num),]
  rownames(dat) <- c(1:nrow(dat))

  b <- dat %>%
    group_by(player) %>%
    dplyr::mutate(starts = sum(starts), top = sum(top), pts_g = mean(pts), wk_sd = sd(pts), games = n()) %>%
    data.frame() %>%
    select(player, position, games, starts, top, pts_g, wk_sd) %>% unique()

  b$start_pct <- b$starts / b$games
  b$top_pct <- b$top / b$games

  b$cons <- b$wk_sd / b$pts_g
  # b$met <- log(((1/b$cons) ^ (20*b$pts_g)) * (100/(1-b$top_pct)) * (1/(1.2-b$start_pct)))
  b$met <- (30*b$pts_g + (20/(1-b$top_pct)) + (1/1.2-b$start_pct))# / b$cons)

  return(b)

}
