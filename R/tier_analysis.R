#' @export
tier_analysis <- function(dat = NULL, nclusters = 10) {
  if(is.null(dat)) {
    dat <- get_projections()
    dat <- projected_points(dat)
  }
  vorcluster <- kmeans(dat$VOR, nclusters)
  dat$cluster <- as.character(unlist(vorcluster$cluster))
  return(dat)
}
