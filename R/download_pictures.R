
#'@export
download_pictures <- function(year = 2017) {

  stats <- c("RUSHING", "PASSING", "RECEIVING")
  dat <- data.frame()
  for(i in 1:length(stats)) {
    lastPage <- FALSE
    p = 1
    print(stats[i])
    while(!lastPage) {
      print(p)
      lines <- readLines(paste0("http://www.nfl.com/stats/categorystats?tabSeq=0&season=2017&seasonType=REG&Submit=Go&experience=&archive=false&statisticCategory=", stats[i], "&d-447263-p=", p, "&conference=null&qualified=false"))

      players <- lines[grep("/players/", lines)]
      if(length(players) < 50) {
        lastPage <- TRUE
      }
      players <- plyr::ldply(players, function(x) {
        x <- strsplit(x, "a href=\\\"")[[1]][2]
        link <- paste0("http://www.nfl.com", strsplit(x, "\\\">")[[1]][1])
        name <- strsplit(strsplit(x, "\\\">")[[1]][2], "<")[[1]][1]
        return(cbind(name, link))
      })
      dat <- rbind(dat, players)
      p <- p + 1
    }
  }

  dat$name <- as.character(dat$name)
  dat$link <- as.character(dat$link)

  dat <- unique(dat)

  for(i in 1:nrow(dat)) {
    print(i/nrow(dat))
    lines <- readLines(dat$link[i])
    lines <- lines[grep(paste0(strsplit(dat$link[i], "profile\\?id=")[[1]][2], ".png"), lines)]
    piclink <- strsplit(lines, "src=\\\"")[[1]][2]
    piclink <- strsplit(piclink, "\\\"")[[1]][1]
    e <- tryCatch({download.file(piclink, destfile = paste0("/Users/colin/Documents/fantasy-football/images/", dat$name[i], ".jpg"),
                  quiet = TRUE)}, error = function(e) {e})
    if("error" %in% class(e)) {
      if(!grepl("cannot open URL", e$message))
      stop()
    }
  }
}
