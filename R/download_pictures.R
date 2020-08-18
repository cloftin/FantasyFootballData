
#'@export
download_pictures <- function(year = 2019) {

  stats <- c("RUSHING", "PASSING", "RECEIVING")
  dat <- data.frame()
  for(i in 1:length(stats)) {
    lastPage <- FALSE
    p = 1
    nextPage <- ""
    print(stats[i])
    while(!lastPage) {
      print(p)
      url <- if(p == 1) {
        paste0("https://www.nfl.com/stats/player-stats/category/", stats[i], "/", year, "/REG/all/", tolower(stats[i]), "yards/desc")
      } else {
        nextPage
      }
      lines <- readLines(url)

      players <- lines[grep("href=\"/players/", lines)]
      if(length(players) < 25) {
        lastPage <- TRUE
      }
      players <- plyr::ldply(players, function(x) {
        x <- strsplit(x, "href=\\\"")[[1]][2]
        link <- paste0("http://www.nfl.com/players/", strsplit(strsplit(x, "players/")[[1]][2], "\\/\\\"")[[1]][1])
        name <- strsplit(strsplit(x, "players/")[[1]][2], "\\/\\\"")[[1]][1]
        return(cbind(name, link))
      })
      dat <- rbind(dat, players)
      p <- p + 1

      if(!lastPage) {
        nextPage <- strsplit(lines[grep("nfl-o-table-pagination__next", lines)], "=\\\"")[[1]][2]
        nextPage <- paste0("https://www.nfl.com", strsplit(nextPage, "\\\"")[[1]][1])
      }
    }
  }

  dat$name <- as.character(dat$name)
  dat$link <- as.character(dat$link)
  dat <- unique(dat)

  for(i in 400:nrow(dat)) {
    print(i/nrow(dat))
    lines <- readLines(dat$link[i])
    "https://static.www.nfl.com/image/private/t_player_profile_landscape_3x/f_auto/league/vygpdc31jwc0zrusaeg5"
    lines <- lines[grep("image/private/t_player_profile_landscape_3x", lines)]
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
