# This script follows the same structure and process as the sentiment analysis
library(stringr)
library(tm)
library(plyr)
library(dplyr)

### 
# Get the name of political parties
political_parties  <-
    as.data.frame(jsonlite::fromJSON (txt = paste("Data/partier.json",
                                                  sep = "")))
political_parties <- as.list(political_parties$Partier.navn, political_parties$Partier.short)
######
# Get the names of political figures
political_figures <- 
    as.data.frame(jsonlite::fromJSON (txt = paste("Data/politikere.json",
                                                  sep = "")))
political_figures <- as.list(political_figures$politikere.etternavn)
####
political_figures = as.list(sapply(political_figures, tolower))
political_parties = as.list(sapply(political_parties, tolower))



politicalPartyAndPeopleFinder <- function(tittle ,post) {
    post = gsub("[[:punct:]]", "", post)    # remove punctuation
    post = gsub("[[:cntrl:]]", "", post)   # remove control characters
    
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
    figure_matches <- na.omit(match(words, political_figures))
    party_matches <- na.omit(match(words, political_parties))
    
    if(figure_matches == 0 && party_matches == 0){
        return (NULL)
    }
    
    people <- c()
    for (i in 1:length(figure_matches)) {
        people <-
            paste(people, political_figures[figure_matches[i]], ",")
    }
    
    party <- c()
    for (i in 1:length(party_matches)) {
        party <-
            paste(party, political_parties[party_matches[i]], ",")
    }
    
    return (as.data.frame(rbind(people, party), stringsAsfactors = FALSE))
}

aggregateResults <- function(people, party){
    
    
    if(grepl("NULL", party)){
        party <- as.character("NA")
    }
    if(grepl("NULL", people)){
        people <- as.character("NA")
    }
    
    
} 
