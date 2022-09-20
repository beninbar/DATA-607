# Access SQL movie reviews from previous (slightly modified).
library(RMySQL)

# Connect to the SQL database using the "blinded user" created in the SQL script.
movies = dbConnect(MySQL(), user='ACatlin', password='BenAssignment2', dbname='movie_reviews')

# Check that connection was made successfully. Call on fields (like colnames) in the Results table.
dbListFields(movies, 'Results')

# Grab the data from the Results table and place it into a dataframe. GetQuery not SendQuery.
get_table_data_df = dbGetQuery(movies, "select * from Results")
class(get_table_data_df)
head(get_table_data_df)

# Flatten data frame, calculate means across rows and columns, as well as the overall mean, bind those to a new flattened array.
library(dplyr)
flattened <- xtabs(Score ~ Name + Movie, get_table_data_df, addNA = TRUE)
flattened
rowmeans <- rowMeans(flattened, na.rm = TRUE, dims = 1)
colmeans <- colMeans(flattened, na.rm = TRUE, dims = 1)
withmeans <- cbind(flattened, rowmeans)
withmeans <- rbind(withmeans, colmeans)
overallmean <- colMeans(get_table_data_df['Score'], na.rm = TRUE, dims = 1)
withmeans[7, 7] = overallmean
withmeans

# Calculate the differences in user means and movie means, and bind those to (another copy of) the array.
useravg_againstall <- rowmeans - overallmean
movieavg_againstall <- colmeans - overallmean
final_with_NAs <- cbind(withmeans, useravg_againstall)
final_with_NAs <- rbind(final_with_NAs, movieavg_againstall)
final_with_NAs

# Calculate rating for unseen item using difference variables calculated and impute to that index and column location in the array.
final <- final_with_NAs     # Make copy for comparison to NAs table and final table with imputed values
nulls <- which(is.na(final), arr.ind=TRUE)      # Get nulls
final[nulls] <- overallmean + movieavg_againstall[nulls[,2]] + useravg_againstall[nulls[,1]]      # For nulls in table "final", impute mean + movie average differential + user average differential for that specific row/column index.
final      # Check
final[nulls]    # Just null values.

# Based on these values, I would pick the highest baseline estimate and recommend that 'Jacqueline' see 'Nope.'
