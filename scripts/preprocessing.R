#za³adowanie bibliotek
library(tm)
library(hunspell)
library(stringr)

#zmiana katalogu roboczego
workDir <- "C:\\Users\\KwiatekJakub\\Desktop\\Studia\\przetwarzanie\\projekt"
setwd(workDir)

#definicja lokalizacji katalogów funkcjonalnych
inputDir <- ".\\data"
scriptDir <- ".\\scripts"
outputDir <- ".\\results"
workspaceDir <- ".\\workspaces"

#utworzenie katalogów wyjœciowych
dir.create(outputDir, showWarnings = F)
dir.create(workspaceDir, showWarnings = F)

#utworzenie korpusu dokumentów
corpusDir <- paste(
  inputDir,
  "articles - original",
  sep = "\\"
)
corpus <- VCorpus(
  DirSource(
    corpusDir,
    "UTF-8",
    "*.txt"
  ),
  readerControl = list(
    language = "pl_PL"
  )
)

#wstêpne przetwarzanie
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, content_transformer(tolower))

#usuniêcie s³ów ze stoplisty
stoplistFile <- paste(
  inputDir,
  "stopwords_pl.txt",
  sep = "\\"
)
stoplist <- readLines(stoplistFile, encoding = "UTF-8")
corpus <- tm_map(corpus, removeWords, stoplist)
corpus <- tm_map(corpus, stripWhitespace)

#usuniêcie em dash i 3/4
removeChar <- function(x,char) gsub(char, "", x)
corpus <- tm_map(corpus, content_transformer(removeChar), intToUtf8(8722))
corpus <- tm_map(corpus, content_transformer(removeChar), intToUtf8(190))

#usuniêcie w dokumentach podzia³ów na akapity
pasteParagraphs <- content_transformer(
  function(x, char) paste(x, collapse=char)
)
corpus <- tm_map(corpus, pasteParagraphs, " ")

#usuniêcie z nazw dokumentów rozszerzeñ
cutExtensions <- function(document){
  meta(document, "id") <- gsub(
    "\\.txt$",
    "",
    meta(document, "id")
  )
  return(document)
}
corpus <- tm_map(corpus, cutExtensions)

#lematyzacja
polish <- dictionary("pl_PL")
lemmatize <- content_transformer(
  function(text){
    simpleText <- str_trim(as.character(text))
    vectorizedText <- hunspell_parse(simpleText, dict = polish)
    lemmatizedText <- hunspell_stem(vectorizedText[[1]], dict = polish)
    for (i in 1:length(lemmatizedText)) {
      if(length(lemmatizedText[[i]]) == 0) lemmatizedText[i] <- vectorizedText[[1]][i]
      if(length(lemmatizedText[[i]])  > 1) lemmatizedText[i] <- lemmatizedText[[i]][1]
    }
    newText <- paste(lemmatizedText, collapse = " ")
    return(newText)
  }
)
corpus <- tm_map(corpus, lemmatize)

#eksport wstêpnie przetworzonego korpusu dokumentów
preprocessedDir <- paste(
  inputDir,
  "articles - transformed",
  sep = "\\"
)
dir.create(preprocessedDir,showWarnings = F)
writeCorpus(corpus, path = preprocessedDir)
