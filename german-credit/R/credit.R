library(randomForest)
library(MASS)

rf <- randomForest(factor(response) ~ chk_acct + duration + history + purpose + amount + sav_acct, data=ger)

# helper function that casts all of the columns in a "new" data.frame with the same datatypes
# as another data.frame
ensure.same.types <- function(df1, df2) {
  for(col in colnames(df1)) {
    if (col %in% colnames(df2)) {
      if (is.factor(df1[,col])) {
        df2[,col] <- factor(df2[,col], unique(df1[,col]))
      }
    }
  }
  df2
}

library(yhatr)

model.require <- function() {
  library(randomForest)
  library(rattle)
}

model.transform <- function(df) {
  df <- ensure.same.types(ger, testcase)
  df
}

model.predict <- function(df) {
  prediction <- predict(rf.model, newdata=df)
  data.frame(prediction=prediction)
}

testcase <- data.frame(fromJSON(toJSON(ger[1,])))
(step1 <- model.transform(testcase))
str(step1)
model.predict(step1)

yhat.config <- c(
  username='YOUR_USERNAME',
  apikey='YOUR_APIKEY',
  env="http://cloud.yhathq.com/"
)

yhat.deploy("germanCredit")
yhat.predict("germanCredit", testcase)

