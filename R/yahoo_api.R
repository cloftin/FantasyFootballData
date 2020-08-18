# options("httr_oob_default" = T)
# library(httr)
#
# b_url <- "https://fantasysports.yahooapis.com" #base url
#
# #Create Endpoint
# yahoo <- httr::oauth_endpoint(authorize = "https://api.login.yahoo.com/oauth2/request_auth"
#                               , access = "https://api.login.yahoo.com/oauth2/get_token"
#                               , base_url = b_url)
#
# cKey = "dj0yJmk9Ykw1MzlaR014ODRpJmQ9WVdrOVRVVktaVTFTTkdjbWNHbzlNQS0tJnM9Y29uc3VtZXJzZWNyZXQmeD1hMw--"
# cSecret = "00577f6f12188543bc24330149e4a3a8a5c9f0b9"
# #Create App
# yahoo_app <- httr::oauth_app("yahoo", key=cKey, secret = cSecret,redirect_uri = "oob")
#
# #Open Browser to Authorization Code
# yahoo <- httr::oauth_endpoint(authorize = "https://api.login.yahoo.com/oauth2/request_auth"
#                               , access = "https://api.login.yahoo.com/oauth2/get_token"
#                               , base_url = "https://fantasysports.yahooapis.com")
#
# httr::BROWSE(httr::oauth2.0_authorize_url(yahoo, yahoo_app, scope="fspt-w"
#                                           , redirect_uri = yahoo_app$redirect_uri))
#
# code <- readline(prompt = "Enter Yahoo-provided code: ")
# #Create Token
# yahoo_token<- httr::oauth2.0_access_token(yahoo,yahoo_app,code=code)
#
# ## All Years of Fantasy Game Info
# url <- "https://fantasysports.yahooapis.com/fantasy/v2/games;game_codes=nfl"
# a <- httr::GET(url, httr::content_type("applilcation/xml"),
#                httr::add_headers(Authorization = paste0("Bearer ", yahoo_token$access_token)))
# a <- XML::xmlToList(XML::xmlParse(a))
# a$.attrs <- NULL
# a$games$.attrs <- NULL
# a <- as.data.frame(data.table::rbindlist(a$games))
#
#
# ## This Year of Fantasy Game Info
# url <- "https://fantasysports.yahooapis.com/fantasy/v2/game/nfl"
# a <- httr::GET(url, httr::content_type("applilcation/xml"),
#                httr::add_headers(Authorization = paste0("Bearer ", yahoo_token$access_token)))
# a <- XML::xmlToList(XML::xmlParse(a))
# a$.attrs <- NULL
# a <- as.data.frame(data.table::rbindlist(a))
#
# ## League Info
# url <- "https://fantasysports.yahooapis.com/fantasy/v2/league/380.l.121038"
# a <- httr::GET(url, httr::content_type("applilcation/xml"),
#                httr::add_headers(Authorization = paste0("Bearer ", yahoo_token$access_token)))
# a <- xmlToDataFrame(XML::xmlParse(a))
#
# ## League Settings
# url <- "https://fantasysports.yahooapis.com/fantasy/v2/league/380.l.121038/settings"
# a <- httr::GET(url, httr::content_type("applilcation/xml"),
#                httr::add_headers(Authorization = paste0("Bearer ", yahoo_token$access_token)))
# a <- content(a)
# a <- XML::xmlParse(a)
# a <- XML::xmlToList(a)
# b <- RJSONIO::toJSON(a)
# b <- jsonlite::fromJSON(b, flatten = T)$league
#
# url <- "https://fantasysports.yahooapis.com/fantasy/v2/league/380.l.121038/standings"
# a <- httr::GET(url, httr::content_type("applilcation/xml"),
#                httr::add_headers(Authorization = paste0("Bearer ", yahoo_token$access_token)))
# a <- content(a)
# a <- XML::xmlParse(a)
# a <- XML::xmlToList(a)
# a <- a$league$standings$teams[c(1:12)]
# a <- plyr::ldply(a, function(x) {
#   return(data.frame(team = x$name,
#                     manager = x$managers$manager$nickname,
#                     wins = x$team_standings$outcome_totals$wins,
#                     losses = x$team_standings$outcome_totals$losses,
#                     points_for = x$team_standings$points_for,
#                     points_against = x$team_standings$points_against))
# })
# a$.id <- NULL
#
#
# playerlist <- data.frame()
# for(i in 0:7) {
#   url <- paste0("https://fantasysports.yahooapis.com/fantasy/v2/league/380.l.121038/players;sort=OR;start=", 25*i)
#   a <- httr::GET(url, httr::content_type("applilcation/xml"),
#                  httr::add_headers(Authorization = paste0("Bearer ", yahoo_token$access_token)))
#   a <- content(a)
#   a <- XML::xmlToList(XML::xmlParse(a))
#   a$league$players$.attrs <- NULL
#
#   a <- plyr::ldply(a$league$players, function(x) {
#     data.frame(name = x$name$full)
#   })
#   a$.id <- NULL
#   playerlist <- rbind(playerlist, a)
# }
