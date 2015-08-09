# It's necessary to use jsonlite here instead of rjson or RJSONIO, because the
# fromJSON() in jsonlite is the only one that will read these particular JSON
# objects properly.
library(jsonlite)

# Initialize variables.
deckCGDBRaw <- character()
decksCGDB <- list()

setwd("C:/text/Data Science/Netrunner")

# Read the JSON object containing the decks from Card Game DB, by collapsing the
# lines of the input file into a single character string.
decksCGDBRaw <- paste0(readLines(con = "CorpDecksDB.json"), collapse = " ")
# Convert the JSON object into a an R list.  Each item in the list is a nested
# list containing the details of a single deck.  We could use less memory by
# combining this and the previous statement, or setting decksCGDBRaw to an empty
# value after the conversion, but we're not dealing with enough data here to
# make that necessary.
decksCGDB <- fromJSON(decksCGDBRaw)
