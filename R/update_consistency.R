
#' @export
update_consistency <- function(year = 2017) {
  t <- readLines(paste0("https://www.pro-football-reference.com/years/", year, "/fantasy.htm"))
  table_start <- grep("Fantasy Rankings Table", t)
  table_end <- grep("/table", t)

  players <- grep("/players/", t)
  players <- players[players > table_start]
  players <- players[players < table_end]

  players <- t[players]
  players <- players[c(1:350)]

  players <- plyr::ldply(players, function(x) {

    pos <- strsplit(strsplit(strsplit(x, "fantasy_pos")[[1]][2], ">")[[1]][2], "<")[[1]][1]
    temp <- strsplit(x, "<a href=\\\"")[[1]][2]
    temp <- strsplit(temp, "\\\">")
    link <- gsub(".htm", "", temp[[1]][1])
    name <- strsplit(temp[[1]][2], "<")[[1]][1]
    temp <- data.frame(Name = name, Link = link, Pos = pos)
    return(temp)
  })

  base <- "https://www.pro-football-reference.com"

  players$Link <- paste0(base, players$Link, "/gamelog/", year, "/")

  dat <- data.frame()

  for(i in 1:nrow(players)) {
    print(i)
    lines <- readLines(players$Link[i])
    stats <- lines[grep("stats\\.", lines)]
    if(length(stats) > 0) {
      for(j in 1:length(stats)) {
        split <- unlist(strsplit(stats[j], "data-stat=\\\""))
        stat_start <- grep("game_result", split) + 1
        stat_end <- grep("all_td", split) - 1
        if(length(stat_end) == 0) {
          stat_end <- length(split)
        }
        split <- split[c(4, stat_start:stat_end)]

        dat <- dplyr::bind_rows(dat, cbind(players$Name[i], players$Pos[i], i, plyr::ldply(split, function(x) {
          temp <- strsplit(x, "\\\" >")
          return(data.frame(stat = temp[[1]][1], value = strsplit(temp[[1]][2], "<")[[1]][1]))
        }) %>% spread(., stat, value)))

      }
    }
  }
  a <- dat
  colnames(dat)[c(1:4)] <- c("Player", "Pos", "I", "Week")

  dat[, grep("csk", colnames(dat))] <- NULL
  dat[, grep("NA", colnames(dat))] <- NULL

  for(i in 1:2) {
    dat[,i] <- as.character(dat[,i])
  }
  for(i in 3:ncol(dat)) {
    dat[,i] <- as.numeric(dat[,i])
  }

  dat[is.na(dat)] <- 0

  write.csv(dat, file = "data/consitency_gamelogs.csv", row.names = F)
}
