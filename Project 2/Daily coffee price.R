library(tidyverse)
library(ggplot2)
library(tidyquant)

# Read in Wilson Chau's daily coffee price data from .csv and check.
data <- read.csv("https://raw.githubusercontent.com/beninbar/DATA-607/main/Project%202/Daily%20coffee%20price.csv")
data

# Convert dates to Date class for easier graphing. Drop NAs.
data <- drop_na(data)
data$Date = as.Date(data$Date, format = "%m/%d/%Y")

# Pivot coffee price at different points of the day from wide to long.
coffee <- pivot_longer(data, cols=c(2:5), names_to="Disposition", values_to="Price")
print(n=100, coffee)

# Window function to find year to date moving average of the price.
coffee <- coffee |> mutate(Moving_daily_average=cummean(Price))

# First we can visualize the data as is.
ggplot(data=coffee, aes(x=Date, y=Price, color=Disposition)) +
  geom_line() +
  geom_point() +
  labs(y="Price (USD)", x="Date (2000)") +
  scale_x_date(date_breaks = "2 day", date_labels = "%b-%d") +
  theme(axis.text.x=element_text(angle=60, hjust=1)) #+
  #facet_grid(Disposition ~ .)

# Let's add the daily moving average to get a better sense overall
movingavg <- coffee |> group_by(Date) |> summarize(meanaverage=mean(Moving_daily_average))
movingavg

ggplot(data=movingavg, aes(x=Date, y=meanaverage)) +
  geom_line() +
  geom_point() +
  labs(y="Price (USD)", x="Date (2000)") +
  scale_x_date(date_breaks = "2 day", date_labels = "%b-%d") +
  theme(axis.text.x=element_text(angle=60, hjust=1)) +
  geom_line(data=coffee, aes(y=Price, color=Disposition))

# Ok, but would be better to see the variation for each day. Easily done with the help of the "tidyquant" library. Note that this graphic was generated
# using the wide version of the data. Tick marks represent open and close values, while highs and lows are at each end of each line. 
ggplot(data=data, aes(x=Date)) +
  geom_barchart(aes(open = Open, high = High, low = Low, close = Close), colour_up = "darkgreen", colour_down = "red") +
  labs(y="Price (USD)", x="Date (2000)") +
  scale_x_date(date_breaks = "2 day", date_labels = "%b-%d") +
  theme(axis.text.x=element_text(angle=60, hjust=1))

