library(tidyverse)
library(tidytext)
library(sotu)
library(stringr)
library(ggplot2)
library(wordcloud)

# Sentiment analysis of US Presidential State of the Union speeches from 1950-2020. Originally, the idea was to scrape from a historical website, 
# then to pull each of the cleaned Kaggle .txt files (https://www.kaggle.com/datasets/rtatman/state-of-the-union-corpus-1989-2017?resource=download) 
# from my Github, but in the interest of time, I chose to use the R 'sotu' package (https://github.com/statsmaths/sotu/).

head(sotu_meta)
sotu_text[[1]]

# Take a subset of speeches from 1950-2020. We want the sentiment analyses to better match, as older speech text may not match as well.
metaset <- sotu_meta |> filter(sotu_meta$year>=1950)
textset <- tail(sotu_text, n=79)

metaset <- mutate(metaset, text=textset)
metaset[, c('X', 'sotu_type')] <- NULL
rownames(metaset) = seq(length=nrow(metaset))

# NRC lexicon citation: This dataset was published in Saif M. Mohammad and Peter Turney. (2013), ``Crowdsourcing a Word-Emotion Association Lexicon.'' 
#                       Computational Intelligence, 29(3): 436-465.

nrc <- get_sentiments('nrc')
afinn <- get_sentiments('afinn')
bing <- get_sentiments('bing')


# Extract words, and append words with president, year, and party to a new dataframe in long format.
words_all <- data.frame()
for (corpus in 1:nrow(metaset)) {
  words <- str_extract_all(metaset[corpus, 'text'], "[[:alpha:]]+")
  for (word in words) {
    df <- cbind(word, president=metaset[corpus, 'president'], year=metaset[corpus, 'year'], party=metaset[corpus, 'party'])
  }
  words_all <- rbind(words_all, df)
}

# Perform the same analysis as shown in Ch. 2 of Text Mining with R to get an overall sentiment score, but instead of per book, do so per President.
# Normalize across 100-word chunks of speech, for all speeches, per President.
bing_analysis1 <- words_all |> inner_join(bing) |> count(party, president, index=row_number() %/% 100, sentiment) |>
  pivot_wider(names_from = sentiment, values_from = n) |> mutate(sentiment = positive - negative)

# Plot, colorizing by party affiliation.
ggplot(bing_analysis1, aes(index, sentiment, fill=party)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~president, ncol = 2, scales = "free_x") +
  scale_fill_manual(values=c("darkblue", "darkred"))

# That was nice to see, but it might be better to just aggregate sentiment for each President. Normalize to 800 word chunks.
bing_analysis2 <- words_all |> inner_join(bing) |> group_by(president) |> slice_sample(n=800) |> count(sentiment) |>
  pivot_wider(names_from = sentiment, values_from = n) |> mutate(sentiment = positive - negative)

# Plot
ggplot(bing_analysis2, aes(reorder(president, sentiment), sentiment)) +
  geom_col(show.legend = FALSE, fill='darkblue') +
  coord_flip() +
  theme(axis.title.y=element_blank())

## To compare the other sentiment analysis lexicons, let's filter for just one President, Jimmy Carter, who seems to have the most verbose speeches.
## The following code is only minimally adapted from Ch. 2 of Text Mining with R.
jimmycarter <- words_all |> filter(president == "Jimmy Carter")

# Use 'afinn' lexicon to get the -5 to +5 score for each word, summarize to get sum for all word scores for each chunk.
afinn <- jimmycarter |> inner_join(afinn) |> group_by(index = row_number() %/% 100) |>
  summarise(sentiment = sum(value)) |> mutate(method = "AFINN")
print(afinn, n=20)

# Use BOTH 'bing' and 'nrc' lexicons to get the positive/negative sentiments, pivot wide, and add net sentiment calculation.
bing_and_nrc <- bind_rows(jimmycarter |> inner_join(bing) |> mutate(method = "Bing"), jimmycarter |> inner_join(nrc) |> 
  filter(sentiment %in% c("positive", "negative")) |> mutate(method = "NRC")) |> count(method, index = row_number() %/% 100, sentiment) |>
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) |>
  mutate(sentiment = positive - negative)
head(bing_and_nrc)
tail(bing_and_nrc)

# Bind both 'afinn' and 'bing'/'nrc' tibbles and graph sentiment. Interesting that for SOTU speeches, unlike for Pride and Prejudice,
# AFINN shows higher values than the other lexicons instead of NRC.
bind_rows(afinn, bing_and_nrc) |>
  ggplot(aes(index, sentiment, fill = method)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~method, ncol = 1, scales = "free_x")

# Quick look at the word cloud for all words, not including stop words.
words_all_nostop <- words_all |> anti_join(stop_words)
words_all_nostop |> count(word) |> with(wordcloud(word, n, max.words = 300))


# Extend this analysis using the 'loughran' lexicon, which I believe is part of the umbrella source for the lexicons established above.
loughran <- get_sentiments('loughran')
# Perform the same analysis as above for all Presidents, using loughran.
loughran_analysis1 <- words_all |> inner_join(loughran) |> count(party, president, index=row_number() %/% 100, sentiment) |>
  pivot_wider(names_from = sentiment, values_from = n) |> mutate(sentiment = positive - negative)

# Plot, again colorizing by party affiliation. Huge difference! We see a much more negative trends overall.
ggplot(loughran_analysis1, aes(index, sentiment, fill=party)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~president, ncol = 2, scales = "free_x") +
  scale_fill_manual(values=c("darkblue", "darkred"))


# Let's add the loughran sentiment analysis to the overall from before, still using Jimmy Carter for reference.
loughran_analysis2 <- loughran_analysis1 |> select(c('index', 'negative', 'positive', 'sentiment')) |> mutate(method='loughran')

# Combine and plot. It is very clear loughran has much more negative sentiment scoring, compared with any of the other lexicons.
bing_nrc_loughran <- bind_rows(bing_and_nrc, loughran_analysis2, afinn)
ggplot(bing_nrc_loughran, aes(index, sentiment, fill = method)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~method, ncol = 1, scales = "free_x")
