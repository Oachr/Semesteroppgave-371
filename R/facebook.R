### Facebook - gather Facebook posts
# using the Rfacebook package: https://cran.r-project.org/web/packages/Rfacebook/Rfacebook.pdf

require(Rfacebook)
library(plyr)
library(dplyr)
source("R/JSONToDf.R")


# Gets a facebook authorization token.  
auth <- fbOAuth(0000000000, "XXXXXXXXXXXXXXXXXXX")
save(auth, file = "auth")
load("auth")


# Takes a FB page and gets all of the information regarding publically available posts and statuses.  
getAllFBData <- function (fbPage) {
    # Start by choosing the the start and enddate of the first query. 
    startDate <- as.Date("2015-01-01")
    endDate <- startDate + 7
    fbPosts <- as.list(NULL)
    
    # This queries FB for one week at a time, this means we are more likely to get all of the posts since there is a restriction on how many posts we can get per query. 
    for (i in 1:53) {
        # Store all of posts found per week into a list of data frames. 
        fbPosts[i] <-
            list(try(getPage(
                fbPage,
                token = auth,
                n = 30,
                since = startDate,
                until = endDate
            ),
            silent = TRUE))
        
        
        # Increment by one week. 
        startDate <- endDate 
        endDate <- startDate + 7
    }
    
    
    # Create one data frame from all the frames
    df <- do.call(rbind, fbPosts)
    # Clean data frame removing error rows
    df <- cleanFBDataFrame(df)
    # Create Json file
    df.json <- jsonlite::toJSON(df)
    
    # Create dir if not exists
    dir.create(paste(getwd(),"/Output/", fbPage, "-posts-2015/", sep = ""), showWarnings = FALSE)
    
    
    # Save JSon file
    write(df.json, file = paste("Output/", fbPage, "-posts-2015/", fbPage,".json", sep = ""))
}

# Takes a facebook page and postID and retrieves all of the comments on a particular post. 
getPostInformation <- function(fbPage, postID){
    # Query Facebook for information about the different posts
    df <- getPost(postID, auth, n = 5000, n.likes = 10, n.comments = 5000)
    # Take out only the comments
    df.json <- DfToJson(as.data.frame(df[3]))
    
    # Create dir if not exists
    dir.create(paste(getwd(),"/Output/", fbPage, "-posts-2015/", sep = ""), showWarnings = FALSE)
    
    # Write the file 
    write(df.json, file = paste("Output/", fbPage, "-posts-2015/", postID, ".json", sep = ""))
}

# Tries to get public information from the Facebook profile, severly limited. 
getFbProfileInfo <- function(fbPage){
    df.json <- DfToJson(as.data.frame(getUsers(fbPage, auth)))
    write(df.json, file = paste("Output/", fbPage, "-posts-2015/", fbPage,"-userInfo", ".json", sep = ""))
} 

# Used to clean data frames from facebook
cleanFBDataFrame <- function(dataFrame){
    
    # Remove errors 
    dataFrame <- dplyr::filter(dataFrame, !grepl("Error",from_id))
    
    # Remove 2016 data which we are not using for this project. 
    dataFrame <- dplyr::filter(dataFrame, !grepl("2016",created_time))
    
    # Converts to UTF-8 icons and letters. 
    for(i in 1:length(dataFrame)){
        dataFrame[i] <- apply(dataFrame[i], 1, FUN = function(x) iconv(x, "UTF-8", "UTF-8"))
    }
    
    return (dataFrame)
}
