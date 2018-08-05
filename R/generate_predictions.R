
#' @export
generate_predictions <- function(testYear = 2017) {

  statsToPredict <- c("rush_att", "rush_yds", "rush_td", "targets", "rec", "rec_yds", "rec_td",
                      "pass_cmp", "pass_att", "pass_yds", "pass_td", "pass_int")

  gamelogs <- plyr::ldply(list.files("data/gamelogs/"), function(x) {

    t <- read.csv(file = paste0("data/gamelogs/", x), header = T, stringsAsFactors = F)
    t <- t[, c("player", "game_num", "rush_att", "rush_yds", "rush_yds_per_att", "rush_td", "targets",
               "rec", "rec_yds", "rec_yds_per_rec", "rec_td", "catch_pct",
               "pass_cmp", "pass_att", "pass_yds", "pass_td", "pass_int", "pass_rating",
               "pass_yds_per_att", "year")]
    t[is.na(t)] <- 0
    t <- t %>% filter(game_num >= 1 & game_num <= 16)
    return(t)

  })

  gamelogs <- unique(gamelogs)

  yearly <- gamelogs %>% group_by(player, year) %>%
    summarise(rush_att = sum(rush_att), rush_yds = sum(rush_yds),
              rush_yds_per_att = sum(rush_yds)/sum(rush_att),
              rush_td = sum(rush_td), targets = sum(targets),
              rec = sum(rec), rec_yds = sum(rec_yds),
              rec_yds_per_rec = sum(rec_yds)/sum(rec),
              rec_td = sum(rec_td), catch_pct = sum(rec)/sum(targets),
              pass_cmp = sum(pass_cmp), pass_att = sum(pass_att),
              pass_pct = sum(pass_cmp)/sum(pass_att),
              pass_yds = sum(pass_yds), pass_td = sum(pass_td),
              pass_int = sum(pass_int), pass_rating = mean(pass_rating),
              pass_yds_per_att = sum(pass_yds)/sum(pass_att)
    ) %>% data.frame()

  yearly <- apply(yearly, 2, function(x) ifelse(is.nan(x), NA, x))
  yearly <- as.data.frame(yearly)
  for(i in 2:ncol(yearly)) {yearly[,i] <- as.numeric(as.character(yearly[,i]))}
  yearly$player <- as.character(yearly$player)

  statmodels <- list()

  for(stat in 1:length(statsToPredict)) {
    print(statsToPredict[stat])
    currentStat <- statsToPredict[stat]
    category <- strsplit(currentStat, "_")[[1]][1]

    currentStatData <- data.frame()
    for(yearToTest in 2013:(testYear - 1)) {
      print(yearToTest)
      train <- yearly %>% filter(year <  yearToTest & (year >= (yearToTest - 3)))

      if(category == "pass") {
        train <- train %>% filter(pass_att > 100)
      } else if(category == "rush") {
        train <- train %>% filter(rush_att > 10)
      } else if(category == "rec") {
        train <- train %>% filter(targets > 10)
      }

      test  <- yearly %>% filter(year == yearToTest)

      train <- train %>% filter(player %in% test$player)
      test <- test %>% filter(player %in% train$player)

      temp_test  <- test[c("player", "year", currentStat)]
      temp_train <- train[c("player", "year", colnames(train)[grep(category, colnames(train))])]

      temp_train <- temp_train %>%
        group_by(player) %>%
        mutate(suffix = paste0("_", 1:n())) %>%
        gather(var, val, -c(player, suffix)) %>%
        unite(var_group, var, suffix, sep = "") %>%
        spread(var_group, val) %>% data.frame()

      temp_train$PredictStat <- currentStat
      temp_train <- merge(temp_test, temp_train, by = "player")

      currentStatData <- rbind(currentStatData, temp_train)
    }


    test_data <- yearly %>% filter(year >= (testYear-3) & year < testYear)
    if(category == "pass") {
      test_data <- test_data %>% filter(pass_att > 100)
    } else if(category == "rush") {
      test_data <- test_data %>% filter(rush_att > 10)
    } else if(category == "rec") {
      test_data <- test_data %>% filter(targets > 10)
    }
    test_data <- test_data[c("player", "year", colnames(test_data)[grep(category, colnames(test_data))])]

    test_data <- test_data %>%
      group_by(player) %>%
      mutate(suffix = paste0("_", 1:n())) %>%
      gather(var, val, -c(player, suffix)) %>%
      unite(var_group, var, suffix, sep = "") %>%
      spread(var_group, val) %>% data.frame()

    completetest <- test_data[complete.cases(test_data), ]

    temp_formula <- paste0(eval(expr = paste0(currentStat, " ~ ", paste(colnames(temp_train)[c(4:(ncol(temp_train) - 4))], collapse = " + "))))

    temp_lmmodel <- lm(formula = temp_formula, data = temp_train)
    temp_rfmodel <- randomForest::randomForest(formula = as.formula(temp_formula),
                                               data = temp_train,
                                               na.action = randomForest::na.roughfix)

    temp_lmpreds <- predict(temp_lmmodel, newdata=completetest)
    temp_rfpreds <- predict(temp_rfmodel, newdata=completetest)

    temp_list <- list(stat = currentStat,
                      testyear = yearToTest,
                      traindata = temp_train,
                      testpredictdata = test_data,
                      testdata = yearly %>% filter(year == testYear),
                      lmmodel = temp_lmmodel,
                      lmpreds = temp_lmpreds,
                      rfmodel = temp_rfmodel,
                      rfpreds = temp_rfpreds
                      )

    statmodels[i] <- list(temp_list)


  }

}
