# This script is used to find news stories that include tracked politicians and
# will perform sentiment analysis on those stories if key people are identified.
library(stringr)
library(jsonlite)
library(tm)
library(plyr)
library(dplyr)
source("R/sentiment.R")
source("R/textmining.R")

##################################################
# Get the name of political parties
# Currently this is not implemented as the politican names were arguably more important.
political_parties.df  <-
    as.data.frame(jsonlite::fromJSON (txt = paste("Data/partier.json",
                                                  sep = "")))
political_parties <-
    as.list(political_parties$Partier.navn,
            political_parties$Partier.short)
##################################################

##################################################
# Get the names of political figures
political_figures.df <-
    as.data.frame(jsonlite::fromJSON (txt = paste("Data/politikere.json",
                                                  sep = "")))

# Create full names from
political_figures.df <-
    mutate(political_figures.df,
           politikere.navn = paste(politikere.fornavn, politikere.etternavn))
###
# This list is used for the data frame as all the mentions start at 0 and will count upwards by the function(analyzePoliticiansInText).
mentions <- as.list(NULL)
for (i in 1:length(political_figures.df$politikere.navn)) {
    mentions[i] <- 0
}
##################################################

politicianFullNames <- as.list(political_figures.df$politikere.navn)
political_parties = as.list(sapply(political_parties, tolower))

# Tries to identify politicians in the text
identifyPoliticians <- function(post) {
    # Loop through full names to find at least one match
    found <- FALSE
    for (i in 1:length(political_figures.df$politikere.navn)) {
        if (grepl(political_figures.df$politikere.navn[i], post)) {
            found <- TRUE
            return(found)
        }
    }
    return (found)
}

analyzePoliticiansInText <- function(post) {
    # Use text mining to find the frequency of words and create a corpus
    postCorpus <- GetCorpus(post)
    dtm <- DocumentTermMatrix(postCorpus)
    
    # Create a data frame to hold the amount of mentions that each politician has in the text
    mentions.df <-
        as.data.frame(cbind(politicianFullNames, mentions))
    
    # When we have the document term matrix, find how many times names have been mentioned
    for (i in 1:length(mentions.df$politicianFullNames)) {
        for (y in 1:length(dtm$dimnames$Terms)) {
            if (grepl(
                dtm$dimnames$Terms[y],
                political_figures.df$politikere.etternavn[i],
                ignore.case = TRUE
            ))
                # Add how many times word/name was mentioned
                # Currently it may override a higher value with a lesser value
                mentions.df$mentions[i] <- dtm$v[y]
        }
    }
    # Replace 0 with NA
    mentions.df[mentions.df == 0] <- NA
    
    # Return the results
    return(as.data.frame(mentions.df))
}


###############################
## Find stories containing politicians and figure out if they are positive or negative.
# This will also allow the see how many times a politician was mentioned in the article.
# TODO: Currently the analyzePoliticiansInText will return an incomplete data frame
# that omits the mentions each politican has(even though the data frame inside the method works fine).
# One solution to this could be to store each part of the analysis separatley, but this means more work when writing a parser/analyzer for the files.

# Load vg data as a data frame
json <-
    as.data.frame(jsonlite::fromJSON (txt = paste("Dataset/Papers-json/vg.json",
                                                  sep = "")))
result.l <- as.list(NULL)
# Loop through the articles
for (i in 1:length(json$tekster)) {
    # Checks if the last name of a politician exists in the text
    if (identifyPoliticians(json$tekster[i])) {
        # Adds to list if true
        result.l <- as.list(NULL)
        # Add the amount of mentions as a data frame
        result.l[1] <-
            as.data.frame(analyzePoliticiansInText(json$tekster[i]))
        # Do sentiment analysis on article text
        result.l[2] <-
            as.data.frame(calculateSentimentOfPost(json$tekster[i]))
        # Create a json file using the results
        result.l[3] <- json$titler[i]
        results.json <- toJSON(result.l)
        
        write(results.json ,
              file = paste("Dataset/bias-data/",
                           i,
                           ".json",
                           sep = ""))
    }
}