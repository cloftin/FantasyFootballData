action_network <- function() {

  positions <- c("qb", "rb", "wr", "te")

  big <- as.data.frame(matrix(ncol=11, nrow=0))
  colnames(big) = c("Player","Pos","Team","PassYds","PassTDs","PassInts","RushYds","RushTDs","Receptions","RecYds","RecTDs")

  for(i in 1:length(positions)) {

    t <- readLines(paste0("https://www.actionnetwork.com/nfl/article/2018-fantasy-football-projections-",
                          positions[i]))

    t <- t[grep("src=embed", t)]
    t <- strsplit(strsplit(t, "src=\\\"")[[1]][2], "\\\">")[[1]][1]
    t <- readLines(t)

    a <- t[grep("window.infographicData=", t)]
    a <- unlist(strsplit(a, split = "\\["))
    start <- grep("Tm", a)+1
    end <- grep("\\]]]", a)
    a <- a[c(start:end)]
    a[length(a)] <- unlist(strsplit(a[length(a)], "\\]]]")[[1]][1])
    dat <- plyr::ldply(a, function(x) {
      t <- unlist(strsplit(x, "\\\""))
      t <- t[!(t %in% c(",", "", "],"))]
      t <- t(cbind(t))
      return(t)
    })
    colnames(dat) <- if(positions[i] == "qb") {
      c("Player", "Team", "Pts", "PassYds", "PassTDs", "PassInts", "RushYds", "RushTDs")
    } else if (positions[i] == "rb") {
      c("Player", "Team", "Pts", "RushYds", "RushTDs", "Receptions", "RecYds", "RecTDs")
    } else if (positions[i] == "wr") {
      c("Player", "Team", "Pts", "Receptions", "RecYds", "RecTDs", "RushYds", "RushTDs")
    } else if (positions[i] == "te") {
      c("Player", "Team", "Pts", "Receptions", "RecYds", "RecTDs")
    }
    dat[] <- lapply(dat, as.character)
    for(j in 3:ncol(dat)) {
      dat[,j] <- as.numeric(dat[,j])
    }

    dat$Pos <- toupper(positions[i])
    big <- merge(big, dat, all = T)
  }

  big[is.na(big)] <- 0
  big <- big[order(-big$Pts),]
  big$Pts <- NULL
  big$Fumbles <- 0
  big$TwoPts <- 0
  return(big)
}
