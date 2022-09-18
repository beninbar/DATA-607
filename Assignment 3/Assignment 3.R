# Read in fivethrityeight.com's college majors data and check it.
data <- read.csv("https://raw.githubusercontent.com/fivethirtyeight/data/master/college-majors/majors-list.csv")
class(data)
head(data)
colnames(data)

# #1. Using the 173 majors listed in fivethirtyeight.com’s College Majors dataset [https://fivethirtyeight.com/features/the-economic-guide-to-picking-a-college-major/], 
# provide code that identifies the majors that contain either "DATA" or "STATISTICS."
library(dplyr)
datamajors <- data %>% filter(grepl('data|statistics', Major, ignore.case=TRUE))
datamajors

# #2 Write code that transforms the data below:
# [1] "bell pepper"  "bilberry"     "blackberry"   "blood orange"
# 
# [5] "blueberry"    "cantaloupe"   "chili pepper" "cloudberry"  
# 
# [9] "elderberry"   "lime"         "lychee"       "mulberry"    
# 
# [13] "olive"        "salal berry"
# 
# Into a format like this:
# c("bell pepper", "bilberry", "blackberry", "blood orange", "blueberry", "cantaloupe", "chili pepper", "cloudberry", "elderberry", "lime", "lychee", "mulberry", "olive", "salal berry")
fruits <- '[1] "bell pepper"  "bilberry"     "blackberry"   "blood orange"

[5] "blueberry"    "cantaloupe"   "chili pepper" "cloudberry"  

[9] "elderberry"   "lime"         "lychee"       "mulberry"    

[13] "olive"        "salal berry"'

# This was extremely challenging given learning data types conversions, but here is the condensed code.
fruits
class(fruits)
library(tidyverse)

# This was key. Made new variable assignment to avoid accidentally modifying a previous stable data type.
fruits2 <- str_extract_all(fruits, "\\w+( \\w+)?", simplify=TRUE)
fruits2
length(fruits2)
class(fruits2)

# Flattened the matrix array to a vector
fruits3 <- unlist(as.list(fruits2))
is.vector(fruits3)
length(fruits3)
class(fruits3)

# Removed digits here. I attempted earlier in the code but failed. Would have liked to use RegEx to remove the digits sooner.
fruits4 <- fruits3[! fruits3 %in% c(0:9999)]
fruits4

#3 Describe, in words, what these expressions will match:
# (.)\1\1                 -----> The (.) will match any character and group it via parentheses, but since no parameters are specified around it, it will just return any (or in R, the first) character in the target string. Then the '\1\1' would indicate recalling the match result from that singular group, two times. Thus in our example it attempts to match "TTT," or "eee," which are not in our string. Note the lack of parentheses so add them and add the escape \.
# "(.)(.)\\2\\1"          -----> The (.)(.) will match and return any two characters of the target string into two different groups, then backreference the 2nd group result, and then the 1st. Thus in our example it attempts to match "ThhT," "anna," "$tt$," etc, which are obviously not in our string.
# (..)\1                  -----> The (..) will match a set of two characters that repeat themselves i.e. "an""an" in banana. Then, at "\1" it will backreference to match "an" which it does in "stand." Remember to add parentheses and the escape \.
# "(.).\\1.\\1"           -----> This will match a character set that has any repeat of the 1st (.) group, with "." any SINGLE character in between. In this case we get "anana" from "banana."
# "(.)(.)(.).*\\3\\2\\1"  -----> This will match any 3 characters grouped and a 4th, repeated zero or more times, and essentially reverse them and try to match. So it will attempt to match "Thereht," or "bananab," which obviously do not exist in the string.
regexstring <- c("There's money in the banana $tand.")
str_extract(regexstring, "(.)(.)(.).*\\3\\2\\1")

#4 Construct regular expressions to match words that:
# Start and end with the same character.
sentence <- "The refiner also worked the rotator all day."
str_extract_all(sentence, "\\b([:alpha:])[:alpha:]+\\1\\b")

# Contain a repeated pair of letters (e.g. "church" contains "ch" repeated twice.)
sentence2 <- "Church bells and gogo carts."
str_extract_all(sentence2, regex("([:alpha:][:alpha:])[:alpha:]+\\1|(..)\\2", ignore_case=TRUE))

# Contain one letter repeated in at least three places (e.g. "eleven" contains three "e"s.)
sentence3 <- "There are thirty bananas in pajamas in Mississippi."
str_extract_all(sentence3, "[:alpha:]*([:alpha:])[:alpha:]*\\1[:alpha:]*\\1[:alpha:]*")
