# Load the libraries necessary to read pages from the web.
library(RSelenium)

# Initialize variables.

pageIndex <- integer()
NRDB <- remoteDriver()
indexURLTemplate <-
  "http://netrunnerdb.com/en/decklists/find/PGIDX?sort=date&faction=Corp&lastpack=&author=&title="
URLElementList <- list()
deckURLList <- list()
newURLList <- list()

# Open the Selenium server.
startServer()
NRDB <- remoteDriver$new()
NRDB$open()

# Read all of the forum index pages for each faction, extracting URL"s to posted
# decks on each page, and assembling those links into a single vector of
# character strings.  Reading and saving all the URL"s at once all allows the
# individual decks to be read later without having to worry about skipping one
# or more decks if decks are added or updated in the forum during the process
# of downloading (thereby changing the order in which they"re listed), and
# ensures that the database of downloaded decks represents the decks available
# online at the same time for every faction.
pageIndex <- 1	
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
  NRDB$navigate(sub("PGIDX", pageIndex, indexURLTemplate))
  repeat {
	pageTitle <- NRDB$getTitle()
	if (grepl("Decklist search results", pageTitle)) {break}
	Sys.sleep(30)
	NRDB$refresh()
    }
  # Create a list of the webElements in the page that are links to deck pages.
  URLElementList <- NRDB$findElements(using = "class name",
      value = "decklist-name")
	# Check to see if there are any posts listed on the current index page.
	if (length(URLElementList) == 0) {break}
	# Extract a list of URL"s for the posts indexed on the page, and append it
	# to deckURLList. 
	newURLList <- lapply(URLElementList, function(x){x$getElementAttribute("href")[[1]]})
    deckURLList <- c(deckURLList, newURLList)
	pageIndex <- pageIndex + 1
	# Suspend execution for 10 seconds, to avoid spamming the server.
	Sys.sleep(10)
  }
setwd("C:/text/Data Science/Netrunner")
# Delete any earlier version of the output file.
if (file.exists("NRDBCorpURLList.txt")) {
  file.remove("NRDBCorpURLList.txt")}
# Write the list of URL"s to a file.
invisible(lapply(deckURLList, write, "NRDBCorpURLList.txt", append=TRUE))
