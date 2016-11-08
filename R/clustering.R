#########################################################
#########################################################
###                                                 ###
###  Networks of topics and documents               ###
###  Twingly api, iGraph april 2016                 ###
###                                                 ###
#########################################################
#########################################################

rm(list=ls(all=TRUE))
library(gsubfn) # additional string functions
library(XML)

###
### 1. LOADING THE DATA
###

#Gathering facebookdata from politicians
politicians.df <-
  as.data.frame(jsonlite::fromJSON (txt = paste("Data/politikere.json", sep = "")))
fbPages <- as.list(unlist(politicians.df$politikere.FB))

politicians.df$tekst <- 0

aggregated.l <- as.list(NULL)
comments.l <- as.list(NULL)
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
  
  #Make a dataframe with names of politicians and a text of the politicians facebook messages combined
  tekst <- paste(politician.df$message, collapse='. ')
  politicians.df$tekst[i] <- tekst
}

#Gathering newspaperdata from BT and VG
#newspapers.df <- data.frame(c("BT","VG"),c(0,0))
newspapers.df <- data.frame(c("BT","VG 1", "VG 2"),c(0,0,0))
colnames(newspapers.df) <- c("newspaper","text")
bt.df <-
  as.data.frame(jsonlite::fromJSON (
    txt = paste(
      "Dataset/Papers-json/bt.json",
      sep = ""
    )
  ))

newspapers.df$text[1] <- paste(bt.df$tekster, collapse='. ')

vg.df <-
    as.data.frame(jsonlite::fromJSON (
        txt = paste(
            "Dataset/Papers-json/vg.json",
            sep = ""
        )
    ))[1:5000,]

newspapers.df$text[2] <- paste(vg.df$tekster, collapse='. ')

vg2.df <-
    as.data.frame(jsonlite::fromJSON (
        txt = paste(
            "Dataset/Papers-json/vg.json",
            sep = ""
        )
    ))[5000:10000,]

newspapers.df$text[2] <- paste(vg2.df$tekster, collapse='. ')

##-----Topic modeling------##

#Create matrix
topic.m <- NULL

#Add facebook messages from politicians to matrix
for (i in 1:(length(politicians.df$politikere.FB))) {
  politiker.navn <- paste(politicians.df$politikere.fornavn[i], politicians.df$politikere.etternavn[i], sep=" ")
  politiker.tekst <- politicians.df$tekst[i]
  topic.m <- rbind(topic.m, c(politiker.navn, politiker.tekst))
}

#Add newspaper articles to matrix
for (i in 1:(length(newspapers.df$newspaper))) {
    topic.m <- rbind(topic.m, c(newspapers.df$newspaper[i], newspapers.df$text[i]))
}

#Test
#topic.m[1,2]
dim(topic.m)

#Document collection (se Jockers. s. 142)
documents <- as.data.frame(topic.m, stringsAsFactors=F)
colnames(documents) <- c("politiker", "tekst")

## Topic analysis
library(mallet)

#Mallet intance = Java-object
mallet.instances <- mallet.import(documents$politiker, documents$tekst,
                                  "Data/stoppord.csv", FALSE)
n.topics = 20
#Topic model - trainer object
topic.model <- MalletLDA(num.topics=n.topics)
class(topic.model)

#Fill with data
topic.model$loadDocuments(mallet.instances)

#See which words are in vocabulary
vocabulary <- topic.model$getVocabulary()
vocabulary[1:50] 

word.freqs <- mallet.word.freqs(topic.model)
head(word.freqs)
#Hyperparameter
topic.model$setAlphaOptimization(40, 80)

#Iterations
topic.model$train(400)

mallet.top.words(topic.model, mallet.topic.words(topic.model))

#Get matrix with documents as rows and topics as columns
doc.topics <- mallet.doc.topics(topic.model, smoothed=T, normalized=T)

doc.topics.red <- doc.topics[max(doc.topics) > 0.5]

#Set names on the rows = document labels
#rownames(doc.topics) <- politicians.df$politikere.etternavn
#rownames(doc.topics) <- c(politicians.df$politikere.etternavn, "BT", "VG")
rownames(doc.topics) <- c(politicians.df$politikere.etternavn, "BT", "VG 1", "VG 2")
#Check matrix formats
str(doc.topics)

#Clustering
library(cluster)
#The function daisy() creates a dissimilarity matrix
#This is a square matrix with documents as both rows and columns
#Dissimilarity means that the higher the number in the cell, 
#the more dissimar the documents are - 
#in the sense that they do not frequently share the same topics 
topic_df_dist <- as.matrix(daisy(doc.topics, metric = "euclidean", stand = TRUE))

str(topic_df_dist)

#Negate the matrix to get similarity instead of dissimilarity
adjm <- topic_df_dist
sort(adjm, decreasing=TRUE)
lowest <- max(adjm) + 1
adjm <- lowest-adjm
for (i in 1:nrow(adjm)) {
    adjm[i,i] <- 0
}


#Creating a graph of the most similar topics
#graph.adjacency very important
library(igraph)
g <- as.undirected(graph.adjacency(adjm, weighted=TRUE))
E(g)$width <- E(g)$weight/2
#E(g)$width <- E(g)$weight/4 #Less weight is useful when including newspapers
layout1 <- layout.fruchterman.reingold(g,  weight = E(g)$weight, niter=500)
plot(g, layout=layout1,edge.curved = FALSE, vertex.size = 5, vertex.color = "red", vertex.label.font = 2, edge.color=rgb(0,0,0,E(g)$weight/100), edge.arrow.width = E(g)$weight, vertex.label.dist=0.5, vertex.label = V(g)$name)
title(paste("Fruchterman Reingold - Number of topics:",n.topics))

plot(g, layout=layout.circle, vertex.size = 2+0.25*sqrt(graph.strength(g)), vertex.color= "red", edge.color=rgb(0,0,0,E(g)$weight/100), edge.arrow.width = E(g)$weight, vertex.label.dist=0.5, vertex.label = V(g)$name)
title(paste("Circular layout - Number of topics:",n.topics))

plot(g, layout=layout.kamada.kawai(g), vertex.size = 5+0.25*sqrt(graph.strength(g)), vertex.color= "red", edge.color=rgb(0,0,0,E(g)$weight/100), edge.arrow.width = E(g)$weight, vertex.label.dist=0.5, vertex.label = V(g)$name)
title(paste("Kamada kawai - Number of topics: ",n.topics))

#50% less opacity (Useful when including newspapers)
plot(g, layout=layout1,edge.curved = FALSE, vertex.size = 5, vertex.color = "red", vertex.label.font = 2, edge.color=rgb(0,0,0,E(g)$weight/200), edge.arrow.width = E(g)$weight, vertex.label.dist=0.5, vertex.label = V(g)$name)
title(paste("Fruchterman Reingold - Number of topics:",n.topics))

plot(g, layout=layout.circle, vertex.size = 2+0.25*sqrt(graph.strength(g)), vertex.color= "red", edge.color=rgb(0,0,0,E(g)$weight/200), edge.arrow.width = E(g)$weight, vertex.label.dist=0.5, vertex.label = V(g)$name)
title(paste("Circular layout - Number of topics:",n.topics))

plot(g, layout=layout.kamada.kawai(g), vertex.size = 2+0.25*sqrt(graph.strength(g)), vertex.color= "red", edge.color=rgb(0,0,0,E(g)$weight/200), edge.arrow.width = E(g)$weight, vertex.label.dist=0.5, vertex.label = V(g)$name)
title(paste("Kamada kawai - Number of topics: ",n.topics))

### Community detection

# Finds communities by optimizing modularity score
w <- cluster_fast_greedy(g)

# Optional way of finding communities
#w <- cluster_optimal(g)

sort(table(w$membership))

V(g)$color <- rep("white", length(w$membership))
keepTheseCommunities <- names(sizes(w))[sizes(w) > 1]

matchIndex <- match(w$membership, keepTheseCommunities)
colorVals <-rainbow(5)[matchIndex[!is.na(matchIndex)]]
V(g)$color[!is.na(matchIndex)] <- colorVals
plot.igraph(g, vertex.size = 2+0.25*sqrt(graph.strength(g)), edge.color=rgb(0,0,0,E(g)$weight/100), edge.arrow.width = E(g)$weight/2)
