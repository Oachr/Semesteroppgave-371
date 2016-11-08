## This script is used for text mining related tasks.

library(tm)

# Gets the corpus of a document 
GetCorpus <- function(df) {
    corpus <- Corpus(VectorSource(df)) 
    corpus <- tm_map(corpus, tolower) 
    corpus <- tm_map(corpus, removePunctuation)
    corpus <- tm_map(corpus, removeNumbers)
    corpus <- tm_map(corpus, stemDocument, language = "norwegian")
    corpus <- tm_map(corpus, removeWords, stopwords("norwegian"))  
    corpus <- tm_map(corpus, stripWhitespace)   
    corpus <- tm_map(corpus, PlainTextDocument)   
    
    return (corpus)
}

# Get the term frequncy of the document 
getTermFrequency <- function(df){
    dtm <- DocumentTermMatrix(GetCorpus(df))
    dtm2 <- as.matrix(dtm)
    frequency <- colSums(dtm2)
    return (sort(frequency, decreasing=TRUE))
}

# Method for calculating ngrams using RWeak package. Ng parameter = ngrams 
calculateNgrams <- function(string, ng){
    library(RWeka)
    input <- GetCorpus(string)
    options(mc.cores=2) # http://stackoverflow.com/questions/17703553/bigrams-instead-of-single-words-in-termdocument-matrix-using-r-and-rweka/20251039#20251039
    NgramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = ng, max = ng)) # create n-grams
    tdm <- TermDocumentMatrix(input, control = list(tokenize = NgramTokenizer)) # create tdm from n-grams
    return (tdm)
}
