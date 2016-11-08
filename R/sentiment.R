### Sentiment analysis
# Inspiration from: http://datascienceplus.com/sentiment-analysis-on-donald-trump-using-r-and-tableau/
library(stringr)
library(tm)
library(dplyr)
library(plyr)
library(data.table)

# Load positive words, removing duplicate entries
positive_words <-
    unique(as.list(
        readLines(
        "Data/opinion-lexicon-English/positive_ord.txt"),
        encoding = "UTF-8"
    ))

# Load negative words, removing duplicate entries
negative_words <-
    unique(as.list(readLines(
        "Data/opinion-lexicon-English/negative_ord.txt"
    )))

# Calculte a sentiment score for Facebook post
# TODO: This method could be changed in favor of a text mining approach 
# using term frequency matrix to easier keep count of how many times a particular positive or negative word has been used.(See analyzePoliticiansInText in newsBias.R)
calculateSentimentOfPost <- function(post) {
    post = gsub("[[:punct:]]", "", post)    # remove punctuation
    post = gsub("[[:cntrl:]]", "", post)   # remove control characters
    #post = gsub('\d+', '', post)          # remove digits
    
    # Let's have error handling function when trying tolower
    tryTolower = function(x) {
        # create missing value
        y = NA
        # tryCatch error
        try_error = tryCatch(
            tolower(x),
            error = function(e)
                e
        )
        # if not an error
        if (!inherits(try_error, "error"))
            y = tolower(x)
        # result
        return(y)
    }
    # use tryTolower with sapply
    post = sapply(post, tryTolower)
    # split sentence into words with str_split function from stringr package
    words = unlist(str_split(post, " "))
    # compare words to the dictionaries of positive & negative terms
    positive_matches = na.omit(match(words, positive_words))
    negative_matches = na.omit(match(words, negative_words))
    
    # create a vector to save all positive matches as a character, comma separated, from each post
    positives <- c()
    for (i in 1:length(positive_matches)) {
        positives <-
            paste(positives, positive_words[positive_matches[i]], ",")
        }
    
    # create a vector to save all negative matches as a character, comma separated, from each post
    negatives <- c()
    for (i in 1:length(negative_matches)) {
        negatives <-
            paste(negatives, negative_words[negative_matches[i]], ",")
    }
    
    # final score
    score = length(positive_matches) - length(negative_matches)
    
    # return a data frame of each posts sentiment score, positive words and negative words
    return(as.data.frame(rbind(score, positives , negatives), stringsAsFactors = FALSE))
}
