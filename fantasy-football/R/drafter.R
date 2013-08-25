draft.sequence <- c()
rep.count <- floor((num.teams*15)/(2*num.teams))
draft.order <- rep(c(1:num.teams, rev(1:num.teams)), rep.count)
draft.order <- c(draft.order, 1:num.teams)

#Function for 
make.pick <- function(team_num) {
  team <- teams[[team_num]]
  selection.made <- FALSE
  selection.index <- 1
  while(!selection.made) {
    potential.pick <- training.probs[selection.index,]
    pid <- potential.pick$playerid
    pick.pos <- potential.pick$player_position
    # Basic chalk strategy
    if(any(is.na(team[[pick.pos]]))) {
      selection.made <- TRUE
    }
    else {
      if(pick.pos %in% flex.pos & any(is.na(team[["FLEX"]]))) {
        pick.pos <- "FLEX"
        selection.made <- TRUE
      }
      else {
        if(any(is.na(team[["BENCH"]]))) {
          pick.pos <- "BENCH"
          selection.made <- TRUE
        }
        else {
          selection.index <- selection.index + 1
        }
      }
    }
  }
  team[[pick.pos]][which(is.na(team[[pick.pos]]))[1]] <- pid
  teams[[team_num]]  <<- team
  draft.sequence <<- append(draft.sequence, pid)
  off.board(potential.pick$playerid)
}

off.board <- function(pid) {
  training.probs <<- subset(training.probs, playerid != pid)
}

# IMMA DO A DRAFF!
for(i in draft.order) {
  make.pick(i)  
}

results <- data.frame("playerid"=draft.sequence,
                      "fantasy_team"=draft.order,
                      stringsAsFactors=FALSE)
row.names(results) <- 1:150

