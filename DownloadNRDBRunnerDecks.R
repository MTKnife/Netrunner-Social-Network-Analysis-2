# Load the library necessary to read decks from the web.
library(RSelenium)

# Initialize variables.
NRDB <- remoteDriver()
deckURLList <- character()
deckIndex <- integer()
buttonList <- list()
exportButton <- webElement()
plaintextButton <- webElement()
pageTitle <- character()
deckTitle <- character()
deckElem <- webElement()
deck <- character()

# Open the Selenium server.
startServer()
NRDB <- remoteDriver$new()
NRDB$open()

setwd("C:/text/Data Science/Netrunner")
# Delete any earlier version of the output database.
if (file.exists("NRDBRunnerDecksDB.txt")) {
  file.remove("NRDBRunnerDecksDB.txt")}
  
# Load the list of deck URL's.
deckURLList <- readLines(con = "NRDBRunnerURLList.txt")
  
# Iterate through the list of deck URL's, downloading each in turn.  I've added
# Sys.sleep() functions throughout, because otherwise, sometimes a statement
# will execute before the previous statement has completed, due to delays in
# receiving a response from the web server.  The total delay is 12 seconds,
# which is just greater than the 10 seconds I would otherwise use at the end of
# each loop, in order to avoid spamming the server.
for (deckIndex in 1:length(deckURLList)) {
  # Download the page containing the next deck, find the list of buttons on the
  # page that includes first button that needs to be clicked, and then check to
  # make sure that the page is a valid deck, and not an error page.  If the page
  # is an error page, wait 5 minutes and then try again.
  NRDB$navigate(deckURLList[deckIndex])
  Sys.sleep(2)
  repeat {
	buttonList <- NRDB$findElements(using = "class name",
	  value = "dropdown-toggle")
	if (length(buttonList) > 1) {break}
	Sys.sleep(300)
	NRDB$refresh()
	}
  # Find and click the two buttons that need to be clicked in order to display
  # the deck list as a modal pop-up.
  exportButton <- buttonList[[2]]
  Sys.sleep(2)
  exportButton$clickElement()
  plaintextButton <- NRDB$findElement(using = "id", value = "btn-export-plaintext")
  Sys.sleep(2)
  plaintextButton$clickElement()
  # Extract the deck title, which is also the first portion of the page title.
  # The deck title is also included in the deck list, but it's difficult to
  # distinguish it from the name of the Identity card (see next comment).
  pageTitle <- NRDB$getTitle()
  Sys.sleep(2)
  deckTitle <- sub("(.*?) · NetrunnerDB", "\\1", pageTitle)
  # Extract the deck list.  The getElementText() function isn't ideal here,
  # because it loses escaped characters, including linefeeds, and having the
  # linefeeeds would make the data file both easier to manipulate and easier
  # for a human to read, especially for distinguishing the deck title from the
  # identity card.  Unfortunately, at least some of the deck pages on the
  # website are constructed differently, with some added escaped characters,
  # with the result that xpathApply from the XML package won't identity the
  # correct node, and string manipulation of the page source using sub() won't
  # work, either.
  Sys.sleep(2)
  deckElem <- NRDB$findElement(using = "id", value = "export-deck")
  Sys.sleep(2)
  deck <- deckElem$getElementText()[[1]]
  # Write the deck title and the deck list to the next line of the Corp decks
  # database, adding linefeeds after the title and the list to make the file
  # easier to read.
  Sys.sleep(2)
  write(paste0(deckTitle, "\n", deck, "\n"), file = "NRDBRunnerDecksDB.txt", append = TRUE)
  }