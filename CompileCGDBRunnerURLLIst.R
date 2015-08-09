# Load the libraries necessary to read pages from the web.
library(httr)
library(XML)

# Initialize variables.
factionVector <- c("anarch", "criminal", "shaper")
factionIndex <- integer()
faction <- factor(character(), levels = factionVector)
pageIndex <- integer()  
indexURLTemplate <- 
  "http://www.cardgamedb.com/index.php/netrunner/android-netrunner-submitted-decks/_/faction/?search_value=&sort_col=record_updated&sort_order=desc&per_page=100&st="
deckIndexPage <- character()
deckIndexPageSplit <- list()
deckURLList <- character()
newURLList <- character()

# Iterate through the factions; each has its own sub-forum on Card Game DB.
# Read all of the forum index pages for each faction, extracting URL's to posted
# decks on each page, and assembling those links into a single vector of
# character strings.  Reading and saving all the URL's at once all allows the
# individual decks to be read later without having to worry about skipping one
# or more decks if decks are added or updated in the forum during the process
# of downloading (thereby changing the order in which they're listed), and
# ensures that the database of downloaded decks represents the decks available
# online at the same time for every faction.
for (factionIndex in 1:length(factionVector)) {
  faction <- factionVector[factionIndex]
  pageIndex <- 0
  repeat {
    # Download a forum index page as a character vector, using a URL based on
	# deckURLTemplate, substituting the name of the current faction, and
	# starting with the first post in the sorted list, and, on subsequent pages,
	# the post after the last post displayed on the previous page (the forum
	# software does not allow listing all posts of decks for a given faction at
	# once).  The search flags in indexURLTemplate sort the posts in reverse
	# order of the last update to each deck.  Check to make sure that a valid
    # index page was downloaded, and not an error page. If the page is an error
	# page, wait 30 seconds and then try again.
    repeat {
	  deckIndexPage <- content(GET(paste0(sub("faction", faction, 
	    indexURLTemplate), as.character(pageIndex))), as = "text")
	  if (grepl("Android: Netrunner Submitted Decks", deckIndexPage)) {break}
	  Sys.sleep(30)
	  }
    # Check to see if there are any posts listed on the current index page.
	# (The forum software replaces the index of posts with the text "No decks
	# found" in this case.) If there are no more posts, break and proceed to the
	# next faction, if any.
	if (grepl("No decks found", deckIndexPage)) {break}
    # Convert the space-separated elements of the index page into a vector of
	# character strings, making it easier to isolate the links to deck pages
	# from other links.  In hindsight, it might have been easier just to read
	# the links as HTML elements, but this works.
	deckIndexPageSplit <- strsplit(deckIndexPage," +")[[1]]
	# Extract a list of URL's for the posts indexed on the page, and append it
	# to deckURLList. 
	newURLList <- sub(".*(http.*)\\'.*", "\\1", 
	  deckIndexPageSplit[grep("android-netrunner-submitted-decks.*?r[0-9]+\\'",
	  deckIndexPageSplit)])
    deckURLList <- c(deckURLList, newURLList)
	pageIndex <- pageIndex + 100
	# Suspend execution for 10 seconds, to avoid spamming the server.
	Sys.sleep(10)
	}
  }
setwd("C:/text/Data Science/Netrunner")
# Delete any earlier version of the output file.
if (file.exists("RunnerURLList.txt")) {
  file.remove("RunnerURLList.txt")}
# Write the list of URL's to a file.
write(deckURLList, file = "RunnerURLList.txt")
