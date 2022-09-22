# Import chess player .txt file. Explore what we have. 195 observations. 1 massive column.
chessdata <- read.delim(file = "C:/Users/bpinb/OneDrive/Desktop/Coursework/DATA 607 Data Acquisition and Management/Project 1/7645617.txt", header = TRUE)
chessdata
class(chessdata)
head(chessdata)
chessdata[,1]
chessdata[1,]
chessdata[2,]
chessdata[3,]
chessdata[4,]
chessdata[5,]
chessdata[6,]
chessdata[7,]

# Drop "header" rows to make Regex slightly easier.
chessdata = chessdata[-c(1,2),]
chessdata

# Get players using RegEx, and remove blank returns from resulting matrix and coerce to vector.
library(tidyverse)
players <- str_extract_all(chessdata, "[:upper:]+\\s[:upper:]*\\s?[:upper:]+.?\\s?[:upper:]+", simplify=TRUE)
players <- players[!apply(players == "", 1, all), ]
players

# Get players' state.
state <- str_extract_all(chessdata, "\\s\\s\\b[:upper:]{2}\\b", simplify=TRUE)
state <- state[!apply(state == "", 1, all), ]
state <- sub('  ', '', state)
state

# Get total points.
points <- str_extract_all(chessdata, "[:digit:]\\.[:digit:]", simplify=TRUE)
points <- points[!apply(points == "", 1, all), ]
points

# Get player pre-ratings. Convert character vector to numeric to work with downstream average rating.
pre_rating <- str_extract_all(chessdata, "(?<=R:\\s{1,2})[:digit:]{3,4}(?=P*)", simplify=TRUE)
pre_rating <- pre_rating[!apply(pre_rating == "", 1, all), ]
pre_rating <- as.numeric(pre_rating)
dput(pre_rating)

# To get the average pre-chess rating of opponents, first get opponent IDs.
opponent_IDs <- str_extract_all(chessdata, "(?<=\\s{1,2})[:digit:]{1,2}\\|", simplify=TRUE)
opponent_IDs <- opponent_IDs[!apply(opponent_IDs == "", 1, all), ]
opponent_IDs <- sub('\\|', '', opponent_IDs)
opponent_IDs

# Then, convert opponent_IDs to numeric matrix, and substitute these opponent_IDs for pre-chess rating of each ID
# matching to the pre_rating vector above. Finally, get row means for the average pre-chess rating.
rating <- matrix(as.numeric(opponent_IDs), ncol=ncol(opponent_IDs))
rating
rating <- matrix(pre_rating[rating], ncol=ncol(rating))
rating
avg_rating_opponents <- rowMeans(rating, na.rm = TRUE, dims = 1)
avg_rating_opponents

# Finally, stitch together into a dataframe, and export as a CSV.
chessframe <- data.frame(players, state, points, pre_rating, avg_rating_opponents)
head(chessframe)
write.csv(chessframe, "C:/Users/bpinb/OneDrive/Desktop/Coursework/DATA 607 Data Acquisition and Management/Project 1/chessdata_csv.csv", row.names = FALSE)
