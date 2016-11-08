# Include
source("R/parser.r")
source("R/twitter.R")
source("R/textmining.R")

##########################################################################
# News parsing

ParseNews("BT")

### This is how you load the parsed data
json <-
    as.data.frame(jsonlite::fromJSON (txt = paste("Dataset/Papers-json/vg.json",
                                                  sep = "")))

source("R/nameSearcher.R")
matchesFound <- as.list(NULL)
for (i in 1:25) {
    matchesFound[i] <- politicalPartyAndPeopleFinder(json[[i, 3]])
}

source("R/textmining.R")
tdm <- calculateNgrams(json$tekster, 2)
tdm.matrix <- as.matrix(tdm)
findFreqTerms(tdm, lowfreq = 2)

library(dplyr)
vg.data.json <- dplyr::rename(json, from_name = titler, message = tekster)
##########################################################################

##########################################################################
# Facebook parsing done here.
# Start by getting the name of the facebook pages from politician json file
politicians.df <-
    as.data.frame(jsonlite::fromJSON (txt = paste("Data/politikere.json", sep = "")))
# Make a list of fb pages for iteration
fbPages <- as.list(unlist(politicians.df$politikere.FB))

# Load the facebook script
source("R/facebook.R")

fbPosts <- as.list(NULL)
for (i in 1:length(fbPages)) {
    #getAllFBData(fbPages[i])
    politician.df <-
        as.data.frame(jsonlite::fromJSON (
            txt = paste(
                "Output/",
                fbPages[i],
                "-posts-2015/",
                fbPages[i],
                ".json",
                sep = ""
            )
        ))
    
    for (y in 1:length(politician.df$id)) {
        # Here it will get all of the comments from the posts that were found
        # getPostInformation(fbPages[i], politician.df$id[y])
    }
    
}

##########################################################################

##########################################################################
# Get the most frequent terms of the data frame
corpus <- GetCorpus(df)
dtm <- DocumentTermMatrix(corpus)
freq <- colSums(as.matrix(dtm))
freq <- sort(freq, decreasing = TRUE)

# Plot into wordcloud
library(wordcloud)
words <- names(freq)
wordcloud(words[1:25],
          random.order = FALSE,
          freq[1:25],
          colors = brewer.pal(5, "Dark2"))
##########################################################################

##########################################################################
### GGPLOT IS BROKEN!
## Sentiment
library(stringr)
library(tm)
library(plyr)
library(dplyr)
library(ggplot2)

source("R/sentiment.R")
source("R/textmining.R")

scores.l <- as.list(NULL)
for (i in 1:length(json$message)) {
    scores.l[i] <-
        as.data.frame(calculateSentimentOfPost(json$message[i]))
}
scores.df <-  do.call("rbind", scores.l)
#####################################################3
# Sentiment 
politicians.df <-
    as.data.frame(jsonlite::fromJSON (txt = paste("Data/politikere.json", sep = "")))
fbPages <- as.list(unlist(politicians.df$politikere.FB))

for (i in 1:length(fbPages)) {
    politician.df <-
        as.data.frame(jsonlite::fromJSON (
            txt = paste(
                "Dataset/fb-data/",
                fbPages[i],
                "-posts-2015/",
                fbPages[i],
                ".json",
                sep = ""
            )
        ))
    ##################
    # Calculate sentiment score of each post
    scores.l <- as.list(NULL)
    for (y in 1:length(politician.df$message)) {
        scores.l[y] <-
            as.data.frame(calculateSentimentOfPost(politician.df$message[y]))
    }
    
    scores.df <-  as.data.frame(do.call(rbind, scores.l))
    sentimentScore.json <- jsonlite::toJSON(scores.df)

    # Finner og lagrer term frequency som json
    write(
        sentimentScore.json ,
        file = paste(
            "Dataset/fb-data/",
            fbPages[i],
            "-posts-2015/",
            fbPages[i],
            "-sentimentScores",
            ".json",
            sep = ""
        )
    )
    ##################
}

for (i in 1:length(fbPages)) {
    sentimentScore.df <-
        as.data.frame(jsonlite::fromJSON (
            txt = paste(
                "Dataset/fb-data/",
                fbPages[i],
                "-posts-2015/",
                fbPages[i],
                "-sentimentScores",
                ".json",
                sep = ""
            )
        ))
    # V2 are positives and V3 are negatives
    list <-  unlist(sentimentScore.df$V2)
    list <- un( )    
        
}








##################
# Calculate bigrams
tdm <- calculateNgrams(politician.df$message, 2)
tdm.matrix <- as.matrix(tdm)
tdm.matrix <- sort(rowSums(tdm.matrix), decreasing = TRUE )
df <-data.frame(word=names(tdm.matrix), tdm.matrix=tdm.matrix)

df <- slice(df, 1:20)
phraseSentiment <- as.list(NULL)
for(i in 1:length(df$word)){
    phraseSentiment[i] <-  as.data.frame(calculateSentimentOfPost(df$word[i]))
}    
top10.df <-  do.call("rbind", phraseSentiment)
top10.df <- cbind(top10.df, df)
bigrams.json <- jsonlite::toJSON(top10.df)

# Finner og lagrer term frequency som json
write(
    bigrams.json ,
    file = paste(
        "Dataset/fb-data/",
        fbPages[i],
        "-posts-2015/",
        fbPages[i],
        "-bigrams",
        ".json",
        sep = ""
    )
)





###################
# Calculate trigrams
tdm <- calculateNgrams(politician.df$message, 3)
tdm.matrix <- as.matrix(tdm)
tdm.matrix <- sort(rowSums(tdm.matrix), decreasing = TRUE )
df <-data.frame(word=names(tdm.matrix), tdm.matrix=tdm.matrix)

df <- slice(df, 1:20)
phraseSentiment <- as.list(NULL)
for(i in 1:length(df$word)){
    phraseSentiment[i] <-  as.data.frame(calculateSentimentOfPost(df$word[i]))
}    
top10.df <-  do.call("rbind", phraseSentiment)
top10.df <- cbind(top10.df, df)
trigrams.json <- jsonlite::toJSON(top10.df)

# Finner og lagrer term frequency som json
write(
    trigrams.json ,
    file = paste(
        "Dataset/fb-data/",
        fbPages[i],
        "-posts-2015/",
        fbPages[i],
        "-trigrams",
        ".json",
        sep = ""
    )
)
###################






##########################################################################

##########################################################################

#### TOPIC MODELING
##### Topic modeling
source("R/topicmodeling.R")
source("R/topicModelFB.R")
library(wordcloud)

#topic.list <- ModelTopic(df)
topic.list <- as.list(topicModelFBProfile("Per.Sandberg.FrP"))
for (i in 1:20) {
    topic.top.words <- topic.list[[i]]
    wordcloud(
        topic.top.words$words,
        topic.top.words$weights,
        c(4, 0.8),
        rot.per = 0,
        random.order = F,
        colors = brewer.pal(5, "Paired"),
        scale = c(4, .1)
    )
}
##########################################################################

##########################################################################

### This is how you load the parsed VG data
json <-
    as.data.frame(jsonlite::fromJSON (
        txt = paste(
            "Dataset/Papers-json/vg.json",
            sep = ""
        )
    ))

library(dplyr)
vg.data.json <- dplyr::rename(json, from_name = titler, message = tekster)

#### TOPIC MODELING FOR VG
source("R/topicmodeling.R")
source("R/topicModelFB.R")
library(wordcloud)

topic.list <- ModelTopic(vg.data.json)
for (i in 1:20) {
    topic.top.words <- topic.list[[i]]
    wordcloud(
        topic.top.words$words,
        topic.top.words$weights,
        c(4, 0.8),
        rot.per = 0,
        random.order = F,
        colors = brewer.pal(5, "Paired"),
        scale = c(4, .1)
    )
}
##########################################################################

##########################################################################

### This is how you load the parsed BT data
json <-
    as.data.frame(jsonlite::fromJSON (
        txt = paste(
            "Dataset/Papers-json/bt.json",
            sep = ""
        )
    ))

library(dplyr)
bt.data.json <- dplyr::rename(json, from_name = titler, message = tekster)

#### TOPIC MODELING FOR BT
source("R/topicmodeling.R")
source("R/topicModelFB.R")
library(wordcloud)

topic.list <- ModelTopic(bt.data.json)
for (i in 1:20) {
    topic.top.words <- topic.list[[i]]
    wordcloud(
        topic.top.words$words,
        topic.top.words$weights,
        c(4, 0.8),
        rot.per = 0,
        random.order = F,
        colors = brewer.pal(5, "Paired"),
        scale = c(4, .1)
    )
}

