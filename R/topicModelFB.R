### Handles the topic modeling task on facebook posts and comment section. 

library(dplyr)
library(plyr)
source("R/JSONToDf.R")
library(jsonlite)
source("R/topicmodeling.R")
poli.df <- as.data.frame(jsonlite::fromJSON (txt = paste("Data/politikere.json", sep = "")))

# Get the facebook pages as a list 
fbPages <- as.list(unlist(poli.df$politikere.FB))

# Runs topic modeling on a given facebook page if it exists in the dataset. 
topicModelFBProfile <- function(fbPage){
    poli.df <- as.data.frame(jsonlite::fromJSON (txt = paste("Dataset/fb-data/", fbPage,"-posts-2015/", fbPage,".json", sep ="")))
    return (ModelTopic(poli.df))
}
# Runs topic modelling on all the politicians that we have data of. 
topicModelAll <- function(){
    
    json.l <- as.list(NULL)
    for (i in 1:length(fbPages)) {
        json.l[i] <- list(jsonlite::fromJSON(txt = paste("Dataset/fb-data/", fbPages[i],"-posts-2015/", fbPages[i],".json", sep ="")))
    }
    df <- do.call("rbind",json.l)
    return (ModelTopic(df))
}

# Runs topic modelling on all the comments found by the facebook parser for one particular politician. 
topicModelFBComments <- function(fbPage){
    # Get a data frame of all the posts + extras
    politiker.df <- as.data.frame(jsonlite::fromJSON (txt = paste("Dataset/fb-data/", fbPage,"-posts-2015/", fbPage,".json", sep ="")))
    
    # Loop through the posts using the ID from the data frame. 
    ids.l <- as.list(politiker.df$id)
    json.l <- as.list(NULL)
    for(i in 1:length(ids.l)){
        json.l[i] <- list(jsonlite::fromJSON(txt = paste("Dataset/fb-data/", fbPage,"-posts-2015/", ids.l[i],".json", sep ="")))
    }
    # Put together all of the data frames to one large data frame. 
    df <- as.data.frame(do.call("rbind",json.l))
    
    # The ModelTopic method is designed for facebook posts, therefore we change the comment data frame to match that of a facebook page. 
    df <- dplyr::rename(df, from_name = comments.from_name, message = comments.message )
    
    # Returns the result of the topic modeling   
    return (ModelTopic(df))
}

