require(twitteR)

#Variables with values gathered from my twitter app @ http://apps.twitter.com

consumer_key <- 'XXXXXXXXXXXXXXXXXXXX'
consumer_secret <-
    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
access_token <-
    'XXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
access_secret <- 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'

#Setting up a handshake auth
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

1 # 1 for yes, 2 for no. (Store locally)


searchTwitterUser <- function(x) {
    result <-
        searchTwitter(
            paste("from:", x, sep = ""),
            n = 17
        )
}

getTwitterUser <- function(x) {
    result <- searchTwitter(paste("from:", x, sep = ""), n = 50)
    result <- unclass(result)
    return <- as.data.frame(result, stringsAsFactors = FALSE)
}
