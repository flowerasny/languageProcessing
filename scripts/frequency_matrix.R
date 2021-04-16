#za≈Çadowanie bibliotek
library(tm)
library(hunspell)
library(stringr)

#zmiana katalogu roboczego
workDir <- "C:\\Users\\KwiatekJakub\\Desktop\\Studia\\przetwarzanie\\projekt"
setwd(workDir)

#definicja lokalizacji katalogÛw funkcjonalnych
inputDir <- ".\\data"
scriptDir <- ".\\scripts"
outputDir <- ".\\results"
workspaceDir <- ".\\workspaces"

#utworzenie katalogÛw wyjúciowych
dir.create(outputDir, showWarnings = F)
dir.create(workspaceDir, showWarnings = F)

#utworzenie korpusu dokumentÛw
corpusDir <- paste(
  inputDir,
  "articles - transformed",
  sep = "\\"
)
corpus <- VCorpus(
  DirSource(
    corpusDir,
    "CP1250",
    "*.txt"
  ),
  readerControl = list(
    language = "pl_PL"
  )
)

#usuniÍcie z nazw dokumentÛw rozszerzeÒ
cutExtensions <- function(document){
  meta(document, "id") <- gsub(
    "\\.txt$",
    "",
    meta(document, "id")
  )
  return(document)
}
corpus <- tm_map(corpus, cutExtensions)

#tworzenie macierzy czÍstoúci
tdmTfIdfBounds1 <- TermDocumentMatrix(
  corpus, 
  control = list(
    weighting = weightTfIdf,
    bounds = list(
      global = c(2,16)
    )
  )
)
tdmTfIdfBounds2 <- TermDocumentMatrix(
  corpus, 
  control = list(
    weighting = weightTfIdf,
    bounds = list(
      global = c(4,12)
    )
  )
)
tdmTfIdfBounds3 <- TermDocumentMatrix(
  corpus, 
  control = list(
    weighting = weightTfIdf,
    bounds = list(
      global = c(11,20)
    )
  )
)

#konwersja macierzy rzadkich do macierzy klasycznych
tdmTfIdfBoundsMatrix1 <- as.matrix(tdmTfIdfBounds1)
tdmTfIdfBoundsMatrix2 <- as.matrix(tdmTfIdfBounds2)
tdmTfIdfBoundsMatrix3 <- as.matrix(tdmTfIdfBounds3)

#eksport macierzy czÍstoúci do pliku .csv
matrixFile <- paste(
  outputDir,
  "tdmTfIdfBoundsMatrix1.csv",
  sep = "\\"
)
write.table(tdmTfIdfBoundsMatrix1, file = matrixFile, sep = ";", dec = ",", col.names = NA)

matrixFile <- paste(
  outputDir,
  "tdmTfIdfBoundsMatrix2.csv",
  sep = "\\"
)
write.table(tdmTfIdfBoundsMatrix2, file = matrixFile, sep = ";", dec = ",", col.names = NA)

matrixFile <- paste(
  outputDir,
  "tdmTfIdfBoundsMatrix3.csv",
  sep = "\\"
)
write.table(tdmTfIdfBoundsMatrix3, file = matrixFile, sep = ";", dec = ",", col.names = NA)

