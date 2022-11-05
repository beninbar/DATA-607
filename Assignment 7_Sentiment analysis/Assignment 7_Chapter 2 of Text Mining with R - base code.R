# Base code is from Text Mining with R. Load Jane Austin library, tidytext.
# Can be found here: https://www.tidytextmining.com/sentiment.html
# Also needed to install sentiment analyzers "nrc," "afinn," and "bing."
# NRC lexicon citation: This dataset was published in Saif M. Mohammad and Peter Turney. (2013), ``Crowdsourcing a Word-Emotion Association Lexicon.'' 
#                       Computational Intelligence, 29(3): 436-465.
library(tidytext)
library(janeaustenr)
library(tidyverse)
library(stringr)

# Create a tidied version of the austen_books data, add columns 'linenumber' and 'chapter' to track the words. 
tidy_books <- austen_books() |> group_by(book) |> 
  mutate(linenumber = row_number(), chapter = cumsum(str_detect(text, regex("^chapter [\\divxlc]", ignore_case = TRUE)))) |>
  ungroup() |> unnest_tokens(word, text)

head(tidy_books)

# Get "joy" sentiment words from 'nrc' lexicon.
nrc_joy <- get_sentiments("nrc") |> filter(sentiment == "joy")

# Perform inner_join on tidy_books dataframe to joy sentiment words by 'word'
tidy_books |> filter(book == "Emma") |> inner_join(nrc_joy) |> count(word, sort = TRUE)

# Get positive/negative sentiments from 'bing' lexicon, join to tidy_books by word, count per 80 line chunks, pivot wide, and add a net sentiment calculation.
# In layterms: shows number of "negative" vs "positive" words, plus an overall differential between the two, in a wide format
jane_austen_sentiment <- tidy_books |> inner_join(get_sentiments("bing")) |> count(book, index = linenumber %/% 80, sentiment) |>
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) |> mutate(sentiment = positive - negative)

head(jane_austen_sentiment)

# Plot sentiment score across the 80-line chunk indexes.
library(ggplot2)
ggplot(jane_austen_sentiment, aes(index, sentiment, fill = book)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~book, ncol = 2, scales = "free_x")

## Get just the words from Pride and Prejudice
pride_prejudice <- tidy_books |> filter(book == "Pride & Prejudice")

# Use 'afinn' lexicon to get the -5 to +5 score for each word, summarize to get sum for all word scores for each chunk.
afinn <- pride_prejudice |> inner_join(get_sentiments("afinn")) |> group_by(index = linenumber %/% 80) |>
  summarise(sentiment = sum(value)) |> mutate(method = "AFINN")
print(afinn, n=20)

# Use BOTH 'bing' and 'nrc' lexicons to get the positive/negative sentiments, pivot wide, and add net sentiment calculation.
bing_and_nrc <- bind_rows(pride_prejudice |> inner_join(get_sentiments("bing")) |> 
  mutate(method = "Bing"), pride_prejudice |> inner_join(get_sentiments("nrc") |> 
  filter(sentiment %in% c("positive", "negative"))) |>
  mutate(method = "NRC")) |> count(method, index = linenumber %/% 80, sentiment) |> 
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) |> 
  mutate(sentiment = positive - negative)
head(bing_and_nrc)
tail(bing_and_nrc)

# Bind both 'afinn' and 'bing'/'nrc' tibbles and graph sentiment vs index.
bind_rows(afinn, bing_and_nrc) |>
  ggplot(aes(index, sentiment, fill = method)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~method, ncol = 1, scales = "free_y")

# Why is 'nrc' sentiment so high relative to the other lexicons? Higher ratio of positive to negative words vs 'bing'
get_sentiments("nrc") |> filter(sentiment %in% c("positive", "negative")) |> count(sentiment)
get_sentiments("bing") |> count(sentiment)

## Take a look at number of words contributing to sentiment
bing_word_counts <- tidy_books |> inner_join(get_sentiments("bing")) |> count(word, sentiment, sort = TRUE) |> ungroup()
head(bing_word_counts)

# Plot
bing_word_counts |> group_by(sentiment) |> slice_max(n, n = 10) |> ungroup() |> mutate(word = reorder(word, n)) |>
  ggplot(aes(n, word, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~sentiment, scales = "free_y") +
  labs(x = "Contribution to sentiment", y = NULL)

# Wordcloud for all Jane Austen words using anti_join to visual everything but stop words.
library(wordcloud)
tidy_books |> anti_join(stop_words) |> count(word) |> with(wordcloud(word, n, max.words = 100))
warnings()

# Use reshape's acast to turn dataframe into matrix after joining to bing, counting, and finally use a "comparison cloud."
library(reshape2)
tidy_books |> inner_join(get_sentiments("bing")) |> count(word, sentiment, sort = TRUE) |>
  acast(word ~ sentiment, value.var = "n", fill = 0) |>
  comparison.cloud(colors = c("red", "blue"), max.words = 100)

# Look at sentences, instead of just words.
p_and_p_sentences <- tibble(text = prideprejudice) |> unnest_tokens(sentence, text, token = "sentences")
head(p_and_p_sentences)

# Get the negative sentiment words from 'bing' lexicon, get the number of words per chapter per book, join, get ratio
# of negative words to words for each chapter, show max negative ratios for each book.
bingnegative <- get_sentiments("bing") |> filter(sentiment == "negative")

wordcounts <- tidy_books |> group_by(book, chapter) |> summarize(words = n())

tidy_books |> semi_join(bingnegative) |> group_by(book, chapter) |> summarize(negativewords = n()) |>
  left_join(wordcounts, by = c("book", "chapter")) |> mutate(ratio = negativewords/words) |> filter(chapter != 0) |>
  slice_max(ratio, n = 1) |> ungroup()

# When text data is in a tidy data structure, sentiment analysis can be implemented as an inner join.
