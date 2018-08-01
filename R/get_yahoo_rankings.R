
#' @export
get_yahoo_rankings <- function() {
  options(stringsAsFactors = FALSE)

  base.url = "https://partners.fantasypros.com/external/widget/nfl-staff-rankings.php?source=2&id=7:8:9:285:699&year=2018&week=0&position=ALL&scoring=HALF&ajax=true&width=640&export=xls"

  yahoorankings <- readLines(base.url)

  yahoorankings <- yahoorankings[c(5:length(yahoorankings))]
  yahoorankings <- plyr::ldply(yahoorankings, function(x) {
    unlist(strsplit(x, "\\t"))[c(1:4)]
  })
  yahoorankings <- yahoorankings %>% select(V2, V1, V3, V4)
  yahoorankings$V1 <- as.numeric(yahoorankings$V1)
  colnames(yahoorankings) <- c("Player", format(Sys.Date(), "%m/%d"), "PosRank", "Team")
  yahoorankings$PosRank <- gsub("RB",  "RB_",   yahoorankings$PosRank)
  yahoorankings$PosRank <- gsub("WR",  "WR_",   yahoorankings$PosRank)
  yahoorankings$PosRank <- gsub("QB",  "QB_",   yahoorankings$PosRank)
  yahoorankings$PosRank <- gsub("TE",  "TE_",   yahoorankings$PosRank)
  yahoorankings$PosRank <- gsub("K",   "K_",    yahoorankings$PosRank)
  yahoorankings$PosRank <- gsub("DST", "DST_", yahoorankings$PosRank)
  yahoorankings$Pos <- unlist(lapply(yahoorankings$PosRank, function(x) {
    strsplit(x, "_")[[1]][1]
  }))

  yahoorankings <- yahoorankings %>% filter(Pos != "DST", Pos != "K")
  yahoorankings <- yahoorankings %>% select(-PosRank, -Pos)

  cn <- DBI::dbConnect(RSQLite::SQLite(), "/Users/colin/Documents/GitHub/FantasyFootballData/data/YahooRankings.sqlite3")

  t <- tryCatch({DBI::dbGetQuery(cn, "Select * from YahooRankings")},
                error = function(e) {
                  if(grepl("no such table", e$message)) {
                    print("Table not found. Writing to new table.")
                    DBI::dbWriteTable(cn, "YahooRankings", yahoorankings)
                  } else {
                    stop("Error:", e)
                  }
                }
  )

  if(class(t) == "logical") {
    t <- DBI::dbGetQuery(cn, "Select * from YahooRankings")
    for(i in 2:ncol(t)) {
      t[,i] <- as.numeric(t[,i])
    }
  }

  t <- merge(t, yahoorankings, by = c("Player", "Team"))
  t <- t %>% select(Player, Team, colnames(t)[c(3:(ncol(t) - 0))])
  t <- t[order(t[,ncol(t)]),]

  maxdate <- colnames(t)[ncol(t)]
  if(Sys.Date() >= as.Date(paste0("2018/", maxdate), "%Y/%m/%d")) {

    t$match <- t[,ncol(t) - 1] == t[,ncol(t)]
    if(FALSE %in% t$match) {
      DBI::dbSendQuery(cn, "Drop Table YahooRankings")
      DBI::dbWriteTable(cn, "YahooRankings", t %>% select(-match))
    }
    t$match <- NULL

  }


  return(t)
}
