# Model only works for 15-man rosters with this format of players!
num.teams <- 10
qb <- 1
rb <- 2
wr <- 2
te <- 1
flex <- 1
def <- 1
pk <- 1
bench <- 6
flex.pos <- c("RB","WR")

# Data dtructure for team drafts
teams <- lapply(1:num.teams, function(i) {
  list("QB"=rep(NA, qb),
       "RB"=rep(NA, rb),
       "WR"=rep(NA, wr),
       "TE"=rep(NA, te),
       "FLEX"=rep(NA, flex),
       "PK"=rep(NA, pk),
       "DEF"=rep(NA, def),
       "BENCH"=rep(NA, bench))
})

draft.order <- rep(c(1:num.teams,rev(1:num.teams)), 7)
draft.order <- c(draft.order, 1:num.teams)
