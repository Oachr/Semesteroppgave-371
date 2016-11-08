library(jsonlite)
library(rjson)
library(gsubfn) # additional string functions


JSonToDF <- function(FBName) {
    return (fromJSON(txt = paste("Output/", FBName, ".json", sep ="")))
}

DfToJson <- function(dataFrame) {
    return (toJSON(dataFrame))
}