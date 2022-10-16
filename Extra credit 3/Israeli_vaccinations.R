library(tidyverse)
library(tidyr)

# This was somewhat painful. I tried to do as much as possible the "programmatic" way, though I'm sure there are easier ways.
# Call in Israeli vaccination dataset file. Since info we need is in the head, make this a dataframe.
data <- read.csv("https://raw.githubusercontent.com/beninbar/DATA-607/main/Extra%20credit%203/israeli_vaccination_data_analysis_start.csv")
head(data)
pop <- as.data.frame(head(data))
pop

# Use "sub-column" (2nd row) names for headers. Clean, add "Age" label to first column, get rid of extraneous rows and reset index, fill rows.
colnames(pop)
pop[1,] <- gsub('(\\n)\\1*|%', '', pop[1,])
colnames(pop) <- pop[1,]
colnames(pop)[1] <- "Age"
pop <- pop[2:5, -6]
rownames(pop) = seq(length=nrow(pop))
pop[c(2, 4), 1] <- NA
pop <- fill(pop, Age)
pop

# Rename 'per 100K' columns.
pop <- pop |> rename("Hospitalized_not_vaxed_per 100K" = "Not Vaxper 100Kp", "Hospitalized_vaxed_per 100K" = "Fully Vaxper 100K")

# Grab percents and place into a column
percents1 <- str_extract_all(as.matrix(pop[2,]), "\\d+\\.\\d(?=\\%)", simplify=TRUE)
percents1 <- percents1[!apply(percents1 == "", 1, all), ]
percents2 <- str_extract_all(as.matrix(pop[4,]), "\\d+\\.\\d(?=\\%)", simplify=TRUE)
percents2 <- percents2[!apply(percents2 == "", 1, all), ]
pop['% of total eligible'] <- c(percents1, percents2)

# Grab vaccination numbers and place into column
under50 <- as.matrix(pop[1, c(2,3)])
over50 <- as.matrix(pop[3, c(2,3)])
pop["Eligible population"] <- c(under50, over50)

# Add vaccination status.
pop["Vax status"] <- c("N", "Y", "N", "Y")

# Pivot to grab hospitalized cases and place into original dataframe (probably could have done this with the vaccination numbers).
longified <- pivot_longer(pop, c(4, 5), names_to="Status", values_to="Number_hosp") |> filter(Number_hosp != "")
pop["Hospitalized (per 100K)"] <- longified["Number_hosp"]

# Place newly generated and cleaned columns into their own dataframe.
tidied <- pop[c("Age", "Eligible population", "Vax status", "% of total eligible", "Hospitalized (per 100K)")]
tidied

# (1) Do you have enough information to calculate the total population? What does this total population represent?
print("It depends what we mean by total population. For total eligible population, yes. We simply divide the eligible population number by the percentage 
      of total population for each age group to get the total eligible (note since we have 2 values for each age group, we can take the mean of the two. 
      Then we add both means together to get a decent estimate for each age group). As an aside for how we know that the % value in the dataset is a 
      percent of the total *eligible* population and NOT of the groups in the dataset: 1. The value does not match the result of dividing each group by 
      its total e.g. for under 50s 1,116,834 / (1,116,834 + 3,501,118) = 0.24, which is higher than the value given by the dataset of 0.23, suggesting 
      the denominator should be larger, i.e. should be the total eligible population from as opposed to just those represented here. This is true for all 
      the % values. 2. Adding together the total eligible population based on the calculation described for each age group, we get ~7,152,415. Without 
      further information about eligibility parameters within the Israeli population, it would not be possible to get the total without the help of further
      info, such as from Google. Indeed, a quick Google search tells us that the vaccine eligible population in Israel in August 2021 included anyone 
      over 12 years of age, that the total population at the time was ~9,449,000, and that the population of those under 12 was ~27%, or approximately 
      the difference between total eligible and total population.")


# (2) Calculate the Efficacy vs. Disease; Explain your results. 
# Efficacy vs. severe disease = 1 - (% fully vaxed severe cases per 100K / % not vaxed severe cases per 100K). 
# First, let's find the % severe cases for each group. Let's take the rate of hospitalization per 100K, and normalize it to the eligible population. 
# To do this we take hospitalized and multiply by 100K, then divide by the eligible population value in that category (note we have to remove the commas
# from these large numbers in order to be able to use them in tidyverse mathematical operations. 
# This gives us a rate, or percentage of those being hospitalized in that group. From there, we can easily calculate Efficacy using the formula given.
tidied$`Eligible population` <- gsub(",", "", tidied$`Eligible population`) 
tidied <- tidied |> mutate(`% hospitalized` = as.numeric(`Hospitalized (per 100K)`) * 100000 / as.numeric(`Eligible population`))
tidied <- tidied |> group_by(`Age`) |> mutate(`Efficacy` = 1 - (`% hospitalized`[2] / `% hospitalized`[1]))
tidied$Efficacy[c(1, 3)] <- NA
tidied

print("\n\nBy utilizing the formula of 1 - (% vax'd severe per 100K / % not vax'd severe per 100K) we can see that the efficacy is about 91.8% for 
      the under 50 group, and 85.2% for the over 50 group.")

# (3) From your calculation of efficacy vs. disease, are you able to compare the rate of severe cases in unvaccinated individuals to that 
# in vaccinated individuals?					

print("To a degree, yes, we can compare the rate, particularly since rates were calculated in a stratified fashion between age groups, which helps to 
      offset group effects in which rates might appear lower in the general population. The rate calculation particularly helps to clarify the more
      empirical 'Hospitalized (per 100K)' values, which appear to be higher for the vaccinated population in those over 50 compared with any other group,
      likely in part simply because so many older eligible individuals are vaccinated. The weighted rate in `% hospitalized` is much lower. 
      The Efficacy calculation recapitulates this, as it is high for vaccinated individuals over 50, reflecting the low '% hospitalized' value despite
      the high empirical value of those hospitalized in that age group. Another advantage of our stratified analysis on Efficacy is that it reduces
      the effect of age on vaccine effectiveness, particularly for older populations which are already predisposed or have preconditions that
      make disease more likely to occur and more likely to be severe. We can see this play out when we try to calculate the Efficacy of Vax status
      across all age groups.")

tidied <- as.data.frame(tidied)
AllVax <- tidied |> group_by(`Vax status`) |> summarize(`Eligible pop all`=sum(as.numeric(`Eligible population`)), `Hospitalized per 100K`=sum(
  as.numeric(`Hospitalized (per 100K)`)))
AllVax <- AllVax |> mutate(`% hospitalized` = as.numeric(`Hospitalized per 100K`) * 100000 / as.numeric(`Eligible pop all`))
AllVax <- AllVax |> mutate(`Efficacy` = 1 - (`% hospitalized`[2] / `% hospitalized`[1]))
AllVax

print("\n\nBy utilizing the formula of 1 - (% vax'd severe per 100K / % not vax'd severe per 100K) across all groups we see Efficacy becomes 67.5%,
            significantly lower than the stratified efficacies.")