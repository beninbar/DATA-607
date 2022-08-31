# Read in Covid approval polls data
data <- read.csv("https://raw.githubusercontent.com/fivethirtyeight/covid-19-polls/master/covid_approval_polls.csv")

# Check data
class(data)
head(data)

# Check column names
colnames(data)

# Grab columns relevant for predictive analytics. Note that subject would be our target or independent variable.
trimmed <- subset(data, select=c(pollster, sample_size, population, party, subject, approve, disapprove))
head(trimmed)

# Make data values easier to understand for 'population'
trimmed['population'][trimmed['population'] == 'a'] <- 'adult'
trimmed['population'][trimmed['population'] == 'rv'] <- 'registered voter'
trimmed['population'][trimmed['population'] == 'lv'] <- 'likely voter'
head(trimmed)
trimmed[1:20, 'population']
