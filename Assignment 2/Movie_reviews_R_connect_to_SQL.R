# Access SQL movie reviews. Step 1: Install the handy dandy RMySQL package and load it.
install.packages("RMySQL")
library(RMySQL)

# Step 2: Connect to the SQL database using the "blinded user" created in the SQL script.
movies = dbConnect(MySQL(), user='ACatlin', password='BenAssignment2', dbname='movie_reviews')

# Step 3: Check that connection was made successfully. Call on fields (like colnames) in the Results table.
dbListFields(movies, 'Results')

# Step 4: Grab the data from the Results table and place it into a dataframe. GetQuery not SendQuery.
get_table_data_df = dbGetQuery(movies, "select * from Results")
class(get_table_data_df)
head(get_table_data_df)