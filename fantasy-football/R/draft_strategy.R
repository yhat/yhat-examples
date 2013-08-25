setwd("~/repos/yhat/templates/fantasy-football/R")
# download picks from: https://s3.amazonaws.com/demo-datasets/fantasyfootball/picks.csv
draft.join <- read.csv("~/Downloads/picks (4).csv", header=TRUE, stringsAsFactors=FALSE)
head(draft.join)

# Looking for the perfect formula to describe the true value of players
# based on their individual and position value.

library(plyr)

# Add league format data structures
source('league_format.R')

training.position <- ddply(draft.join, .(pk_overall, player_position), nrow)
training.position <- ddply(training.position, .(pk_overall), function(df) {
  data.frame(player_position=df$player_position,
             pos.count=df$V1,
             pos.prob=df$V1/sum(df$V1))
})

training.players <- ddply(draft.join, .(pk_overall, playerid, player_position), nrow)
training.players <- ddply(training.players, .(pk_overall), function(df) {
  data.frame(playerid=df$playerid,
             player_position=df$player_position,
             pk.count=df$V1,
             pk.prob=df$V1/sum(df$V1))
})


training.probs <- merge(training.position, training.players, by.all=c("pk_overall","player_position"))
training.probs <- ddply(training.probs, .(playerid), function(df) {
  data.frame(player_position=df$player_position,
             score=log(sum(((num.teams*15*df$pk.count)/df$pk_overall)^log((df$pos.count*num.teams*15)/df$pk_overall)))
  )
})

# 

training.probs <- unique(training.probs)
training.probs$playerid <- as.character(training.probs$playerid)
training.probs$player_position <- as.character(training.probs$player_position)
training.probs <- training.probs[with(training.probs, order(-score)),]

head(training.probs, 50)

# Do draft
source('drafter.R')

# Deploy
source('deploy.R')

