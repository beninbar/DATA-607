# Call in httr and jsonlite libraries.
library(httr)
library(jsonlite)
Sys.setenv(CURL_SSL_BACKEND="openSSL")

# Hide my API key by calling it in from a file located in the directory related to this project. Get NYT movie reviews of Titanic.
getwd()
setwd("C:/Users/bpinb/OneDrive/Desktop/Coursework/DATA 607 Data Acquisition and Management/Assignment 6_NYT_API")
key <- read.delim("NYT_API.txt")
key <- colnames(key)
url <- paste0("https://api.nytimes.com/svc/movies/v2/reviews/search.json?query=titanic&api-key=", key)
NYT <- GET(url)
NYT

# Extract raw NYT data to text, then to JSON, then coerce to a dataframe.
text <- content(NYT, "text")
text_as_json <- fromJSON(text)
titanic_df <- as.data.frame(text_as_json)

titanic_df
