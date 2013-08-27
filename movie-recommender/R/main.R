setwd("~/repos/yhat/yhat-examples/movie-recommender/R/")

# data from: http://www.grouplens.org/node/73
data <- read.table("./data/movielens.txt", header=TRUE, stringsAsFactors=FALSE)
data <- data[order(data$user_id, data$movie_id),]

movies <- read.csv("./data/movies.txt", header=TRUE, stringsAsFactors=FALSE, sep="|")
head(movies)
head(data)

find_common_reviewers <- function(movieA, movieB) {
  movieAViewers <- subset(data, movie_id==movieA)$user_id
  movieBViewers <- subset(data, movie_id==movieB)$user_id
  commonViewers <- intersect(movieAViewers, movieBViewers)
  commonViewers
}

get_review_correlation <- function(movieA, movieB) {
  common <- find_common_reviewers(movieA, movieB)
  cor(subset(data, user_id %in% common & movie_id==movieA)$rating,
      subset(data, user_id %in% common & movie_id==movieB)$rating)
}
# show an example
get_review_correlation(1, 7)

# install.packages("plyr")
library(plyr)

# find movies with >300 reviews
movies.count <- ddply(data, .(movie_id), nrow)
movies.count <- movies.count[movies.count$V1 > 300,]

# limit our data to movies w/ large sample size
data <- subset(data, movie_id %in% movies.count$movie_id)
movies <- subset(movies, id %in% unique(data$movie_id))
head(movies[,1:2])


rec_movies <- function(movieTitle) {
  id <- subset(movies, title==movieTitle)$id
  # compute the correlation between the movie a user specified
  # and each title
  ddply(movies, .(id, title), function(movie) {
    c("similarity"=get_review_correlation(id, movie$id))
  })
}

rec_movies("Indiana Jones and the Last Crusade (1989)")


library(yhatr)

model.require <- function() {
  library(plyr)
}

model.transform <- function(df) { df }

model.predict <- function(df) {
  recs <- rec_movies(df$title)
  # reorder from most to least similar
  o <- order(recs$similarity, decreasing=TRUE)
  recs <- recs[o,]
  # remove the same movie
  recs[-1,]
}

yhat.config <- c(
  username="greg",
  apikey="your-api-key"
)

yhat.deploy("movieRecommender")
# define what our inputs to the recommender will be:
#   unique, sorted list of movies w/ reviews>300
sample.data <- data.frame(title=sort(unique(movies$title)))
# try twice
yhat.document("movieRecommender", 1, sample.data)
# open the URL to view the model:
#   http://yhathq.com/models/greg/521d2566b517e80e324075a5



