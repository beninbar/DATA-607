library(rvest)
library(jsonlite)
library(XML)
library(RCurl)

# Pull from HTML. Use the rvest package, and convert the html table from the html read-in to a dataframe.
html <- read_html("https://raw.githubusercontent.com/beninbar/DATA-607/main/Assignment%205/Books.html")
data <- html |> html_table()
html_df <- as.data.frame(data)
html_df

# Pull from JSON. Use the jsonlite package and simplifyVector=TRUE to read directly into a dataframe.
json <- read_json("https://raw.githubusercontent.com/beninbar/DATA-607/main/Assignment%205/Books.json", simplifyVector=TRUE)
json

# Pull from XML. Use the RCurl library to pull the page, which then allows the xml parser to work.
url <- getURL("https://raw.githubusercontent.com/beninbar/DATA-607/main/Assignment%205/Books.xml")
xml <- xmlToDataFrame(url)
xml
