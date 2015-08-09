# Load the libraries necessary to read decks from the web.
library(httr)
library(XML)
# It's necessary to use RJSONIO here instead of rjson or jsonlite, because the
# toJSON() functions in the latter two packages treat list elements as members
# of an array, rather than individual objects.
library(RJSONIO)

# Initialize variables.
deckURLList <- character()
deckIndex <- integer()
notFirstDeck <- FALSE
deckPage <- character()
deckName <- character()
deckID <- character()
deckAuthor <- character()
deckUpdated <- character()
deckObject <- character()
deck <- character()

setwd("C:/text/Data Science/Netrunner")
# Delete any earlier version of the output JSON database.
if (file.exists("RunnerDecksDB.json")) {
  file.remove("RunnerDecksDB.json")}
# Write the first line of the output database.
write("{ \"decks\": [", file = "RunnerDecksDB.json")
# Load the list of deck URL's.
deckURLList <- readLines(con = "RunnerURLList.txt")
# Iterate through the list of deck URL's, downloading each in turn.
for (deckIndex in 1:length(deckURLList)) {
  # If this isn't the first deck, write a line containing a comma to the output
  # file, to separate decks.
  if (notFirstDeck) {write(",", file = "RunnerDecksDB.json", append = TRUE)}
  # Download the page containing the next deck, then check to make sure that a
  # deck was downloaded, and not an error page. If the page is an error page,
  # wait 5 minutes and then try again.
  repeat {
	deckPage <- content(GET(deckURLList[deckIndex]), as = "text")
	if (grepl("Android: Netrunner Submitted Decks", deckPage)) {break}
	Sys.sleep(300)
	}
  # Extract the deck title, the Card Game DB ID number, the deck's author, the
  # date of the last update, and the JSON object describing the deck.
  deckName <- sub(".*<title>(.*?) -.*", "\\1", deckPage)
  deckID <- sub(".*theDeck = (.*?);.*", "\\1", deckPage)
  deckAuthor <- sub(".*.Submitted \\n\\t(.*?)\\n,.*", "\\1", deckPage)
  deckUpdated <- sub(".*updated (.*?20[0-9][0-9]).*", "\\1", deckPage)
  if (grepl("Yesterday", deckUpdated)) {
	deckUpdated <- format(Sys.Date() - 1, "%b %d %Y")
	}
  if (grepl("Today", deckUpdated)) {
	deckUpdated <- format(Sys.Date(), "%b %d %Y")
	}
  deckObject <- sub(".*var data = \\'(.*)\\'\\.evalJSON.*", "\\1", deckPage)
  # Add the title, ID, URL, author, and update date to the JSON object to create
  # a new JSON object containing all information for the current deck.
  deck <- sub("\\{",sub("\\}$",",",toJSON(list(deckinfo = list(name =
	deckName, ID = deckID, author = deckAuthor, updated = deckUpdated)))),
	deckObject)
  # Write the new JSON object to the next line of the Runner decks database.
  write(deck, file = "RunnerDecksDB.json", append = TRUE)
  notFirstDeck = TRUE
  # Delay execution for 10 seconds, to avoid spamming the server.
  Sys.sleep(10)
  }
# Write a final line to close off the array of decks and the top-level object
# in the output database.	  
write("]}", file = "RunnerDecksDB.json", append = TRUE)