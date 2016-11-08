library(gsubfn) # additional string functions
library(XML)


ParseNews <- function(input) {
    # Find all the dates to be searched
    # Mappe for avis
    # Lagt til egen path her
    input <- "bt"
    mappe <- paste(getwd(), "/Dataset/", input, "-2015/", sep = "")
    
    ## Henter ut filer som matcher s?kedato
    allFiles <- dir(path = mappe)

    parseFileList(allFiles, input)
}

parseFileList <- function(filer, input){
    #Lager vektorer for dato, tekst, forfatter
    
    tekster <- c()
    teksten.v <- c()
    teksten.c <- c()
    ingress <- c()
    ingresser <- c()
    titler <- c()
    tittel <- c()
    
    for (i in 1:length(filer)) {
        teksten.v <- c()
        teksten.c <- c()
        
        #For å se hvor i mappen det eventuelt stopper opp hvis feil i XML
        print(filer[i])
        
        #Lager treet
        artikkel.rot <-
            xmlRoot(xmlTreeParse(paste(mappe, filer[i], sep = "")))
        
        #stofftype - finnes i to elementer class1 og class2
        class1.element <-
            getNodeSet(artikkel.rot, "//attribute[@name ='class1']")
        stofftype.en <- xmlGetAttr(class1.element[[1]], "value")
        stofftype.en <- unlist(strsplit(unlist(stofftype.en), ","))
        stofftype.en <- tolower(stofftype.en)
        stofftyper <- stofftype.en
        
        
        if (stofftyper == "nyheter") {
            #tittel
            tittel <-
                xmlValue(getNodeSet(artikkel.rot, "//div[@type='title']")[[1]])
            #tittel <- iconv(tittel, from = "855", to = "UTF-8", sub ="å", mark = TRUE, toRaw = FALSE)
            tittel <- iconv(tittel, "UTF-8", "UTF-8")
            
            #ingress
            ingress <-
                xmlValue(getNodeSet(artikkel.rot, "//div[@type='ingress']")[[1]])
            ingress <- iconv(ingress, "UTF-8", "UTF-8")
            
            #teksten
            tekst.noder <-
                getNodeSet(artikkel.rot, "//div[@type='text']/p")
            if (length(tekst.noder) > 0) {
                for (x in 1:length(tekst.noder)) {
                    teksten.v <- c(teksten.v, xmlValue(tekst.noder[[x]]))
                }
                
                teksten.c <- paste(teksten.v, collapse = " ")
                
            } else
                teksten.c <- "tom"
            
            teksten.c <- iconv(teksten.c, "UTF-8", "UTF-8")
            
            #En vektor eller liste for hvert element
            tekster[i] <- teksten.c
            titler[i] <- tittel
            
            if (length(ingress > 0))
                ingresser[i] <- ingress
            else
                ingresser[i] <- NA
            
        }
        
        
        
    }  #END parsing
    
    #Lager en data-frame. NB: stringsAsFactors må være FALSE
    avis.df <-
        data.frame(titler,
                   ingresser,
                   tekster,
                   stringsAsFactors = FALSE)
    # Create Json file
    df.json <- jsonlite::toJSON(avis.df)
    # Save JSon file
    write(df.json, file = paste("Output/", input, ".json", sep = ""))
}
