
#'@export
download_pictures <- function(year = 2020) {

  stats <- c("RUSHING", "PASSING", "RECEIVING")
  dat <- data.frame()

  lastPage <- FALSE
  p = 1
  nextPage <- ""
  # print(stats[i])
  while(!lastPage) {
    print(p)

    url <- paste0("https://fantasy.nfl.com/research/projections?offset=", (25*(p-1) + 1), "&position=O&sort=projectedPts&statCategory=projectedStats&statSeason=2021&statType=weekProjectedStats&statWeek=1#researchProjections=researchProjections%2C%2Fresearch%2Fprojections%253Foffset%253D", (25*(p-1) + 1), "%2526position%253DO%2526sort%253DprojectedPts%2526statCategory%253DprojectedStats%2526statSeason%253D2021%2526statType%253DweekProjectedStats%2526statWeek%253D1%2Creplace")

    lines <- readLines(url)

    players <- lines[grep("href=\"/players/card", lines)]
    players <- unlist(strsplit(players, "playerCard playerName playerNameFull playerNameId-"))
    players <- players[-1]

    if(length(players) != 25) {
      lastPage <- TRUE
    }

    players <- plyr::ldply(players, function(x) {
      x <- strsplit(x, "</a>")[[1]][1]
      link <- paste0("https://fantasy.nfl.com/players/card?leagueId=0&playerId=", strsplit(x, " ")[[1]][1])
      name <- strsplit(x, ">")[[1]][2]
      return(cbind(name, link))
    })
    dat <- rbind(dat, players)
    p <- p + 1

  }


  dat$name <- as.character(dat$name)
  dat$name <- tolower(gsub(" ", "-", dat$name))
  dat$link <- as.character(dat$link)
  dat <- unique(dat)

  for(i in 1:nrow(dat)) {
    print(i/nrow(dat))
    lines <- readLines(dat$link[i])
    "https://static.www.nfl.com/image/private/t_player_profile_landscape_3x/f_auto/league/vygpdc31jwc0zrusaeg5"
    "https://static.www.nfl.com/image/private/w_200,h_200,c_fill/league/drtb4db2p0sl2sqeiutd"
    lines <- lines[grep("w_200,h_200,c_fill", lines)]
    piclink <- strsplit(lines, "src=\\\"")[[1]][2]
    piclink <- strsplit(piclink, "\\\"")[[1]][1]
    piclink <- gsub("t_lazy/", "", piclink)
    e <- tryCatch({download.file(piclink, destfile = paste0("/Users/colin/Documents/fantasy-football/www/", dat$name[i], ".jpg"),
                                 quiet = TRUE)}, error = function(e) {e})
    if("error" %in% class(e)) {
      if(!grepl("cannot open URL", e$message))
        stop()
    }
  }

  dat <- data.frame()
  lines <- readLines("http://www.nfl.com/fantasyfootball/story/0ap3000001029062/article/2019-dynasty-fantasy-football-rookie-rankings")
  players <- lines[grep("<a href=\"/player/", lines)]
  players <- plyr::ldply(players, function(x) {
    x <- strsplit(x, "a href=\\\"")[[1]][2]
    link <- paste0("http://www.nfl.com", strsplit(x, "\\\">")[[1]][1])
    name <- strsplit(strsplit(x, "\\\">")[[1]][2], "<")[[1]][1]
    return(cbind(name, link))
  })
  dat <- rbind(dat, players)

  dat$name <- as.character(dat$name)
  dat$name <- tolower(gsub(" ", "-", dat$name))
  dat$link <- as.character(dat$link)

  dat <- unique(dat)

  for(i in 1:nrow(dat)) {
    print(i/nrow(dat))
    lines <- readLines(dat$link[i])
    lines <- lines[grep(paste0("static.nfl.com/static/content/public/static/img/fantasy/transparent/200x200"), lines)]
    if(length(lines) > 0) {
      piclink <- strsplit(lines, "src=\\\"")[[1]][2]
      piclink <- strsplit(piclink, "\\\"")[[1]][1]
      e <- tryCatch({download.file(piclink, destfile = paste0("/Users/colin/Documents/fantasy-football/www/", dat$name[i], ".jpg"),
                                   quiet = TRUE)}, error = function(e) {e})
      if("error" %in% class(e)) {
        if(!grepl("cannot open URL", e$message))
          stop()
      }
    }
  }

}
