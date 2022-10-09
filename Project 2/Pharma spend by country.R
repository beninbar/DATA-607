library(tidyverse)
library(ggplot2)

# Read in Jawaid Hakim's pharmaceutical drug spending .csv and check.
data <- read.csv("https://raw.githubusercontent.com/beninbar/DATA-607/main/Project%202/Pharma%20spend%20by%20country.csv")
head(data)

# Fortunately, this dataset is already relatively tidy and well-suited to analysis. But one problem that is immediately clear is that the number of
# observations for each country differs. Perhaps worse, some countries have data for differing years. 47 different years are represented, but not all
# countries are represented in each year.
data |> summarize(countries = count(data, LOCATION))
data |> summarize(countries = count(data, TIME))

# We can try plotting this anyway, per Jawaid's suggestions, just to see what it looks like visually. Note that figuring out how best to add labels
# took a while! But best I could do for the moment. In future would like cleaner ones.
# For the labels, I generated a summarized tibble extracted from the larger dataset to pull from.
for_label <- data |> group_by(LOCATION) |> summarize(year=max(TIME), totalspend=max(TOTAL_SPEND))

ggplot(data=data, aes(x=TIME, y=TOTAL_SPEND, group=LOCATION)) +
  geom_line() +
  geom_text(data=for_label, aes(x=year, y=totalspend + 4000, label=LOCATION))

# The USA is clearly far and away the biggest phara drug spender. We can remove USA to get a better look at the trends in the rest of the countries.
noUSA <- filter(data, LOCATION!="USA")
for_labelnoUSA <- noUSA |> group_by(LOCATION) |> summarize(year=max(TIME), totalspend=max(TOTAL_SPEND))

ggplot(data=noUSA, aes(x=TIME, y=TOTAL_SPEND, group=LOCATION)) +
  geom_line() +
  geom_text(data=for_labelnoUSA, aes(x=year, y=totalspend + 4000, label=LOCATION)) +
  ggtitle("NoUSA")

# For Jawaid's other suggestion of comparing growth in spend between countries, I summarized the data max in TOTAL_SPEND minus min in TOTAL_SPEND by 
# each country across all years, and graphed.
growth <- data |> group_by(LOCATION) |> summarize(growth=max(TOTAL_SPEND) - min(TOTAL_SPEND))
ggplot(data=growth, aes(x=LOCATION, y=growth)) +
  geom_bar(stat="identity") +
  geom_text(data=growth, aes(x=LOCATION, y=growth + 4000, label=LOCATION), size=3) +
  theme(axis.text.x=element_blank(), axis.title.x=element_blank()) +
  labs(y="Change in spending - all years")

# Once again we see that the US far eclipses other countries, not only in total spend but in growth in spending over time.