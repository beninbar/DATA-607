library(tidyverse)
library(ggplot2)

# Read in csv and check.
data <- read.csv("https://raw.githubusercontent.com/beninbar/DATA-607/main/Assignment%204/Arrival%20delays.csv")
data

# Clean. Drop NA rows, and replace blank values in Airline column with NA and fill them (since did not default these to NA on read-in).
colnames(data)[1] <- "Airline"
colnames(data)[2] <- "Disposition"
data <- drop_na(data)
data[data==''] <- NA
data <- fill(data, Airline)
data

# Pivot to a longer data format, and then, crucially, chain a pivot to wider format for the "on time" and "delayed" row values to that. Thanks to classmates for inspiration on the chaining of the pivot_wide.
longified <- pivot_longer(data, cols=c(3:7), names_to="Destination", values_to="Number of flights") |> pivot_wider(names_from="Disposition", values_from="Number of flights")
longified

# Find percent delayed, mutate to dataframe, and graph grouped by destination and binned by airline to get an overview of most delayed flights by destination and airline.
longified <- mutate(longified, `Percent delayed` = 100*(delayed / `on time`))
ggplot(data=longified, aes(x=Destination, y=`Percent delayed`, fill=Airline)) +
    geom_bar(stat="identity", position="dodge") +
    scale_fill_brewer(palette="Paired") +
    ggtitle("Flights") +
    theme(axis.title.y=element_blank()) +
    coord_flip()

# Take a quick look at means of percent delays
longified |> group_by(Airline) |> summarize(`Mean percent delayed`=mean(`Percent delayed`))
