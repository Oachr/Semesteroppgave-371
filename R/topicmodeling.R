##### Topic analyse
library(mallet)

ModelTopic <- function(df) {
    mallet.instances <- mallet.import(df$from_name, df$message, "Data/stoppord.csv", FALSE)
    
    topic.num <- 10 
    
    #Topic model - trainer object
    topic.model <- MalletLDA(num.topics=topic.num)

    #Fill with data
    topic.model$loadDocuments(mallet.instances)
    
    #See which words are in vocabulary, can be useful for developing the stopword list
    #vocabulary <- topic.model$getVocabulary()
    #word.freqs <- mallet.word.freqs(topic.model)

    #Hyperparametre
    topic.model$setAlphaOptimization(40, 80)
    #topic.model$setAlphaOptimization(20, 50)
    
    
    #Train the model. Number of iterations in the parameters. 
    topic.model$train(400)
    
    ## run through a few iterations where we pick the best topic for each token, 
    ##  rather than sampling from the posterior distribution.
    topic.model$maximize(10)
    
    ## Get the probability of topics in documents and the probability of words in topics.
    topic.words <- mallet.topic.words(topic.model, smoothed=T, normalized=T)
    
    num.top.words<-100 # the number of top words in the topic you want to examine
    
    ## What are the top words in topic 7?
    ##  Notice that R indexes from 1, so this will be the topic that mallet called topic 6.
    mallet.top.words(topic.model, topic.words[topic.num,], num.top.words)
    
    #Unpacking the model
    topiclist <- list()
    for (i in 1:topic.num) {
        topiclist[[i]] <- topic.top.words <- mallet.top.words(topic.model, topic.words[i,], num.top.words)
    }    
    return (topiclist)
    
}


