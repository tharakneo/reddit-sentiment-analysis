###############################################
# Reddit Sentiment Analysis: iPhone Product Launch
# Tharak Bhupathi | MS Data Science, RIT
###############################################

# ============================================
# 1. Setup & Libraries
# ============================================

# Install packages (run once)
# install.packages(c("RedditExtractoR", "tidyverse", "tidytext", "lubridate", "textdata"))

library(RedditExtractoR)
library(tidyverse)
library(tidytext)
library(lubridate)
library(textdata)

# ============================================
# 2. Data Collection — Scrape Reddit Comments
# ============================================

# Fetch top threads from r/iPhone (last month)
iphone_threads <- find_thread_urls(
  subreddit = "iPhone",
  sort_by   = "top",
  period    = "month"
)

cat("Total threads found:", nrow(iphone_threads), "\n")

# Sort by comment count to get the most active discussions
iphone_sorted <- iphone_threads |>
  arrange(desc(comments))

# Preview top 10 busiest threads
head(iphone_sorted[, c("title", "comments")], 10)

# Select top 40 threads for scraping
top_n_threads <- 40
urls_to_fetch <- head(iphone_sorted$url, top_n_threads)

# Scrape comments from each thread
all_comments <- list()

for (i in seq_along(urls_to_fetch)) {
  cat("Fetching thread", i, "of", length(urls_to_fetch), "\n")
  
  thread_content <- try(get_thread_content(urls_to_fetch[i]), silent = TRUE)
  
  if (inherits(thread_content, "try-error") || 
      is.null(thread_content$comments) || 
      !("comment" %in% names(thread_content$comments))) {
    next
  }
  
  all_comments[[length(all_comments) + 1]] <- thread_content$comments
}

# Combine into single dataframe
iphone_comments <- bind_rows(all_comments)
cat("Total comments scraped:", nrow(iphone_comments), "\n")

# Keep relevant columns
iphone_comments_clean <- iphone_comments |>
  select(comment, date, url) |>
  mutate(date = as_datetime(date))

# Save raw data
write.csv(iphone_comments_clean, "iphone_comments_raw.csv", row.names = FALSE)

# ============================================
# 3. Text Preprocessing & Tokenization
# ============================================

data("stop_words")

iphone_tokens <- iphone_comments_clean |>
  filter(!is.na(comment)) |>
  unnest_tokens(word, comment) |>
  anti_join(stop_words, by = "word") |>
  filter(str_detect(word, "[a-zA-Z]"))

cat("Total tokens after cleaning:", nrow(iphone_tokens), "\n")

# Save tokens
write.csv(iphone_tokens, "iphone_tokens.csv", row.names = FALSE)

# ============================================
# 4. Sentiment Analysis — Bing (Positive/Negative)
# ============================================

bing_lexicon <- get_sentiments("bing")

# Sentiment word counts
iphone_sentiment_words <- iphone_tokens |>
  inner_join(bing_lexicon, by = "word") |>
  count(word, sentiment, sort = TRUE)

# Overall positive vs negative
iphone_sentiment_summary <- iphone_tokens |>
  inner_join(bing_lexicon, by = "word") |>
  count(sentiment)

cat("\nOverall Sentiment Distribution:\n")
print(iphone_sentiment_summary)

# Save outputs
write.csv(iphone_sentiment_words, "iphone_sentiment_words.csv", row.names = FALSE)
write.csv(iphone_sentiment_summary, "iphone_sentiment_summary.csv", row.names = FALSE)

# ============================================
# 5. Sentiment Trend Over Time
# ============================================

iphone_sentiment_by_day <- iphone_tokens |>
  inner_join(bing_lexicon, by = "word") |>
  mutate(
    score = ifelse(sentiment == "positive", 1, -1),
    day   = as.Date(date)
  ) |>
  group_by(day) |>
  summarise(
    total_score = sum(score),
    avg_score   = mean(score),
    word_count  = n(),
    .groups     = "drop"
  )

cat("\nSentiment by Day:\n")
print(head(iphone_sentiment_by_day))

# Save
write.csv(iphone_sentiment_by_day, "iphone_sentiment_by_day.csv", row.names = FALSE)

# ============================================
# 6. Emotion Analysis — NRC Lexicon
# ============================================

nrc_lexicon <- get_sentiments("nrc")

iphone_emotions <- iphone_tokens |>
  inner_join(nrc_lexicon, by = "word", relationship = "many-to-many") |>
  count(sentiment) |>
  arrange(desc(n))

cat("\nEmotion Breakdown:\n")
print(iphone_emotions)

# Save
write.csv(iphone_emotions, "iphone_emotions.csv", row.names = FALSE)

# ============================================
# 7. Visualizations
# ============================================

# Top 20 positive words
top_positive <- iphone_sentiment_words |>
  filter(sentiment == "positive") |>
  head(20)

ggplot(top_positive, aes(x = reorder(word, n), y = n)) +
  geom_col(fill = "#2ecc71") +
  coord_flip() +
  labs(title = "Top 20 Positive Words", x = NULL, y = "Count") +
  theme_minimal()

ggsave("top_positive_words.png", width = 8, height = 6)

# Top 20 negative words
top_negative <- iphone_sentiment_words |>
  filter(sentiment == "negative") |>
  head(20)

ggplot(top_negative, aes(x = reorder(word, n), y = n)) +
  geom_col(fill = "#e74c3c") +
  coord_flip() +
  labs(title = "Top 20 Negative Words", x = NULL, y = "Count") +
  theme_minimal()

ggsave("top_negative_words.png", width = 8, height = 6)

# Sentiment trend over time
ggplot(iphone_sentiment_by_day, aes(x = day, y = avg_score)) +
  geom_line(color = "#3498db", linewidth = 1) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  labs(
    title = "Daily Sentiment Trend — r/iPhone",
    x = "Date", y = "Average Sentiment Score"
  ) +
  theme_minimal()

ggsave("sentiment_trend.png", width = 10, height = 5)

# Emotion breakdown bar chart
ggplot(iphone_emotions, aes(x = reorder(sentiment, n), y = n)) +
  geom_col(fill = "#9b59b6") +
  coord_flip() +
  labs(title = "Emotion Breakdown (NRC Lexicon)", x = NULL, y = "Word Count") +
  theme_minimal()

ggsave("emotion_breakdown.png", width = 8, height = 6)

# ============================================
# 8. Export Thread Metadata
# ============================================

iphone_threads_used <- iphone_sorted |>
  slice(1:40) |>
  select(title, comments, url)

write.csv(iphone_threads_used, "iphone_threads_used.csv", row.names = FALSE)

# ============================================
# Summary
# ============================================

cat("\n==========================================\n")
cat("  ANALYSIS COMPLETE\n")
cat("==========================================\n")
cat("Comments scraped:", nrow(iphone_comments_clean), "\n")
cat("Tokens generated:", nrow(iphone_tokens), "\n")
cat("Sentiment words:", sum(iphone_sentiment_summary$n), "\n")
cat("\nFiles saved:\n")
cat("  - iphone_comments_raw.csv\n")
cat("  - iphone_tokens.csv\n")
cat("  - iphone_sentiment_words.csv\n")
cat("  - iphone_sentiment_summary.csv\n")
cat("  - iphone_sentiment_by_day.csv\n")
cat("  - iphone_emotions.csv\n")
cat("  - iphone_threads_used.csv\n")
cat("  - top_positive_words.png\n")
cat("  - top_negative_words.png\n")
cat("  - sentiment_trend.png\n")
cat("  - emotion_breakdown.png\n")
cat("\nNext step: Import CSVs into Tableau for dashboard\n")
