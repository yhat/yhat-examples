library(yhatr)

model.require <- function() {
  library(plyr)
}

model.transform <- function(df) {
  df
}

model.predict <- function(df) {
  data.frame(
    "draft_sequence"=draft.sequence
  )  
}

yhat.config <- c(
  username="drew",
  apikey="your.api.key"
)

#get rid of any data; don't need to send that to Yhat
rm("draft.join")
print(yhat.deploy("fantasyFootballDraft"))
