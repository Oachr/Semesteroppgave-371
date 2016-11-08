## This script is used for aggregating information regarding Facebook data. 

library(dplyr)
library(jsonlite)
library(stringi)
library(qdap)
source("R/textmining.R")

# TODO: Find out if mean is more accurate than mode.
fbInteractionData <-  function(fbPage, politician.df) {
    # Names from FB
    from <- fbPage
    
    # Get the mean likes, kommentarer and Shares
    # Removes NA values
    meanLikes <-
        round(mean(as.numeric(politician.df$likes_count), na.rm = TRUE), 0)
    meanComments <-
        round(mean(as.numeric(politician.df$comments_count), na.rm = TRUE), 0)
    meanShares <-
        round(mean(as.numeric(politician.df$shares_count), na.rm = TRUE), 0)
    ########################################################
    # Posts with the highest likes, copmments and shares
    
    # Most liked
    # Removes NA values
    mostLikedMessageID <-
        politician.df$id[which.max(as.numeric(politician.df$likes_count))]
    mostLikedMessageCount <-
        max(as.numeric(politician.df$likes_count), na.rm = TRUE)
    mostLikedMessage <-
        politician.df$message[which(politician.df$id == mostLikedMessageID)]
    
    # Most shared
    # Removes NA values
    mostSharedMessageID <-
        politician.df$id[which.max(as.numeric(politician.df$shares_count))]
    mostSharedMessageCount <-
        max(as.numeric(politician.df$shares_count), na.rm = TRUE)
    mostSharedMessage <-
        politician.df$message[which(politician.df$id == mostSharedMessageID)]
    
    # Most commented
    # Removes NA values
    mostCommentedMessageID <-
        politician.df$id[which.max(as.numeric(politician.df$comments_count))]
    mostCommentedMessageCount <-
        max(as.numeric(politician.df$comments_count), na.rm = TRUE)
    mostCommentedMessage <-
        politician.df$message[which(politician.df$id == mostCommentedMessageID)]
    
    
    # Post information
    numberOfPosts <- length(politician.df$message)
    meanPostPerMonth <- mean(length(politician.df$message), 12)
    
    # Get information regarding word and character count
    wordCount.l <-
        as.list(lapply(politician.df$message, word_count), na.rm = TRUE)
    totalWordCount <- do.call(sum, wordCount.l)
    characterCount.l  <-
        as.list(lapply(politician.df$message, character_count), na.rm = TRUE)
    totalCharacterCount <- do.call(sum, characterCount.l)
    meanWordCount <-
        round(mean(unlist(as.numeric(wordCount.l)), na.rm = TRUE), 0)
    meanCharacterCount <-
        round(mean(unlist(as.numeric(
            characterCount.l
        )), na.rm = TRUE), 0)
    
    return(as.data.frame(
        cbind(
            from,
            meanLikes,
            meanShares,
            meanComments,
            meanWordCount,
            meanCharacterCount,
            totalWordCount,
            totalCharacterCount,
            mostLikedMessageID,
            mostLikedMessageCount,
            mostLikedMessage,
            mostSharedMessageID,
            mostSharedMessageCount,
            mostSharedMessage,
            mostCommentedMessageID,
            mostCommentedMessageCount,
            mostCommentedMessage
        )
    ))
}

# TODO: Currently not finished
# Aggregates all of the information regarding comments. 
aggreGateFBCommentData <- function(comments.df) {
    source("R/sentiment.R")
    comments.df <- melding.df
    count.df <- count(comments.df, comments.from_id)
    
}
# Takes a data frame and returns the term frequency. Must be 1 column.
politicianTermFrequency <- function(df) {
    source("R/textmining.R")
    freq <- getTermFrequency(df)
    frequency <- as.data.frame(freq)
    frequency$Percent <- frequency$freq / sum(frequency$freq)
    return (frequency)
}

# This function is used to aggregate all the information regarding the politicians. 
aggregateAllFbData <- function() {
    politicians.df <-
        as.data.frame(jsonlite::fromJSON (txt = paste("Data/politikere.json", sep = "")))
    fbPages <- as.list(unlist(politicians.df$politikere.FB))
    
    
    aggregated.l <- as.list(NULL)
    comments.l <- as.list(NULL)
    termfrequency.l <- as.list(NULL)
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
        # Aggregated the interaction data of a politican.
        aggregated.l[i] <-
            list(fbInteractionData(fbPages[i], politician.df))
        
        
        #############################
        # Finds and stores the term frequency of a facebook post. 
        termFrequency.df <- as.data.frame(politicianTermFrequency(as.data.frame(politician.df$message)))
        termFrequency.json <- jsonlite::toJSON(termFrequency.df)

        write(
            termFrequency.json,
            file = paste(
                "Dataset/fb-data/",
                fbPages[i],
                "-posts-2015/",
                fbPages[i],
                "-termFrequency",
                ".json",
                sep = ""
            )
        )
        ##############################
        
        # Used to aggregate all of the information regarding the 
        for (y in 1:length(politician.df$id)) {
            melding.df <-
                as.data.frame(jsonlite::fromJSON (
                    txt = paste(
                        "Dataset/fb-data/",
                        fbPages[i],
                        "-posts-2015/",
                        politician.df$id[y],
                        ".json",
                        sep = ""
                    )
                ))
            comments.l[y] <- list(melding.df)
        }
        aggregatedcomments.df <- do.call("rbind", comments.l)
        aggreGateFBCommentData(aggregatedcomments.df)
        ##################################
        # Calculate the term frequency for the comments
        commentTermFrequency.df <-
            politicianTermFrequency(as.data.frame(aggregatedcomments.df$comments.message))
        commentTermFrequency.json <-
            jsonlite::toJSON(commentTermFrequency.df)
        
        # Saving term frequency as json
        write(
            commentTermFrequency.json ,
            file = paste(
                "Dataset/fb-data/",
                fbPages[i],
                "-posts-2015/",
                fbPages[i],
                "-comments-termFrequency",
                ".json",
                sep = ""
            )
        )
        
        ##################################
        # Reset the list for the next loop
        comments.l <- as.list(NULL)
        aggregatedcomments.df <- as.data.frame(NULL)
        
    }
    
    aggregated.df <- do.call("rbind", aggregated.l)
    aggregated.json <- jsonlite::toJSON(aggregated.l)
    
    aggregated.df <- do.call("rbind", termfrequency.l)
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
    
    
    
    #### Testing ngrams ####
    # Doesnt save results
    tdm <- calculateNgrams(politician.df$message, 3)
    tdm.matrix <- as.matrix(tdm)
    findFreqTerms(tdm, lowfreq = 2)
    
    # Write all of the information aggregated to json file
    write(
        aggregated.json ,
        file = paste(
            "Dataset/fb-data/",
            "AggregatedPoliticianInfo.json",
            sep = ""
        )
    )
}



############# Currently not in use
## convert Facebook date format to R date format
format.facebook.date <- function(datestring) {
    date <-
        as.POSIXct(datestring, format = "%Y-%m-%dT%H:%M:%S+0000", tz = "GMT")
}

# create data frame with average metric counts per month
df$datetime <- format.facebook.date(df$created_time)
df$month <- format(df$datetime, "%Y-%m")