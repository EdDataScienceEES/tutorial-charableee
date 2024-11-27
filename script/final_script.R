# Xiaoye ren
# Coding club tutorial script
# 27/11/2024

## Set Library ----
library(tidyverse)
library(tidytext)
library(tm)
library(topicmodels)
library(wordcloud)
library(ggpubr)

## Load csv Data ----
news_data <- read.csv("D:/myed/DataScience/Assignment/tutorial-charableee/data/news_data.csv")

## We want to study topics related to "pollution". Therefore, we first create a data frame related to the pollution topic ----
pollution_data <- news_data %>%
  filter(
    grepl("pollution", Intro.Text, ignore.case = TRUE) &  # Detect "pollution", ignoring case
      if_all(everything(), ~ . != "") &                   # Filter out rows with blank data
      !(year(as.Date(Date.Published)) %in% c(2017, 2024)) # Remove data from years 2017 and 2024
  ) %>%
  select(Intro.Text, Date.Published) %>%                  # Keep only the Intro.Text and Date.Published columns
  mutate(Date.Published = as.character(Date.Published)) %>% # Convert Date.Published to character format
  arrange(Date.Published)                                 # Sort the data by Date.Published

# Examine the tidy data frame
head(pollution_data)  # Display the first few rows of the data frame
str(pollution_data) # Browse the structure of the data frame

## 1.Basic word segmentation ----

# Tokenize the Article.Text column into individual words
## We want to study topics related to "pollution". Therefore, we first create a data frame related to the pollution topic ----
pollution_data <- news_data %>%
  filter(
    grepl("pollution", Intro.Text, ignore.case = TRUE) &  # Detect "pollution", ignoring case
      if_all(everything(), ~ . != "") &                   # Filter out rows with blank data
      !(year(as.Date(Date.Published)) %in% c(2017, 2024)) # Remove data from years 2017 and 2024
  ) %>%
  select(Intro.Text, Date.Published) %>%                  # Keep only the Intro.Text and Date.Published columns
  mutate(Date.Published = as.character(Date.Published)) %>% # Convert Date.Published to character format
  arrange(Date.Published)                                 # Sort the data by Date.Published

# Examine the tidy data frame
head(pollution_data)                                      # Display the first few rows of the data frame
str(pollution_data)                                       # Show the structure of the data frame

## 1. Basic word segmentation ----

# Tokenize the Article.Text column into individual words

data("stop_words")  # Input stop_words dataframe from tidytext

# Now, we want to analyze words that frequently co-occur with "pollution" to understand the key pollution topics reported in recent years.
# First, we tokenize the text, remove stop words, filter documents containing "pollution", and calculate co-occurrence frequencies.
pollution_counts <- pollution_data %>%
  unnest_tokens(word, Intro.Text) %>%                # Tokenize the text into individual words
  anti_join(stop_words, by = "word") %>%             # Remove stop words
  filter(any(word == "pollution")) %>%               # Filter documents containing the word "pollution"
  ungroup() %>%                                      # Ungroup the data to avoid grouping issues later
  filter(word != "pollution") %>%                    # Exclude "pollution" itself
  count(word, sort = TRUE)                           # Count the frequency of co-occurrence words

# Basic plot making: Word Cloud

wordcloud(
  words = pollution_counts$word,                    # Words to include in the word cloud
  freq = pollution_counts$n,                        # Frequencies of the words
  max.words = 50,                                   # Maximum number of words to display
  scale = c(3, 0.5),                                # Scaling for word size
  colors = brewer.pal(6, "Dark2")                   # Use the Dark2 color palette
)

## Basic plot making: Sentiment analysis of report headlines on 'pollution' ----

# If we want to analyze the monthly sentiment trend, we can tokenize the text and match it with a built-in sentiment lexicon from tidytext.
sentiment_pollution <- pollution_data %>%
  unnest_tokens(word, Intro.Text) %>%               # Tokenize the text
  inner_join(get_sentiments("bing"), by = "word")  # Match with Bing sentiment lexicon

# Extract year and month, then calculate sentiment counts
monthly_sentiment <- sentiment_pollution %>%
  mutate(
    Year = year(as.Date(Date.Published)),      # Extract the year
    Month = month(as.Date(Date.Published))    # Extract the month
  ) %>%
  count(Year, Month, sentiment) %>%           # Count occurrences by year, month, and sentiment type
  spread(sentiment, n, fill = 0) %>%          # Reshape data to a wide format
  mutate(Sentiment = positive - negative)     # Calculate net sentiment score

# Plot data for positive and negative score
ggplot(monthly_sentiment, aes(x = factor(Month), y = positive, fill = "Positive")) +
  geom_col(alpha = 0.7) +
  geom_col(aes(y = -negative, fill = "Negative"), alpha = 0.7) +
  facet_wrap(~ Year, scales = "free_x") +
  scale_fill_manual(values = c("Positive" = "firebrick", "Negative" = "steelblue")) +
  labs(
    title = "Monthly Sentiment Trend",
    x = "Month",
    y = "Number of Sentiment Words",
    fill = "Sentiment"
  ) +
  theme_minimal()

## Advanced data analysis: Creating topic models in R ----

# Create a corpus and clean the text
corpus <- Corpus(VectorSource(pollution_data$Intro.Text))
corpus <- tm_map(corpus, content_transformer(function(x) {
  x <- tolower(x)                           # Convert text to lowercase
  x <- gsub("['’`]", "", x)                 # Remove single quotes and similar characters
  x <- gsub("[-–—]", " ", x)                # Replace dashes with spaces
  x <- removePunctuation(x)                 # Remove punctuation
  x <- removeNumbers(x)                     # Remove numbers
  x <- removeWords(x, stopwords("en"))      # Remove common stop words
  x <- stripWhitespace(x)                   # Remove extra whitespace
  return(x)
}))

# Create a document-term matrix
dtm <- DocumentTermMatrix(corpus)

# Set the number of topics k and train an LDA model
lda_model <- LDA(dtm, k = 20, control = list(seed = 123)) # Set random seed for reproducibility

# Display the top 10 keywords for each topic
topic_terms <- terms(lda_model, 10)
print(terms(lda_model, 10))

## Analyze keyword weights for each topic ----

# Extract the topic-term distribution matrix (keyword weights for each topic)
beta <- tidy(lda_model, matrix = "beta") # Use the tidytext package

# Retrieve the top n keywords for each topic and their weights
n <- 10
top_terms <- beta %>%
  group_by(topic) %>%
  slice_max(beta, n = n, with_ties = FALSE) %>% # Select the top n terms for each topic
  ungroup()

# Display the top keywords and weights
print(top_terms)

# Summarize each topic with keywords and average weights
summary_table <- top_terms %>%
  group_by(topic) %>%
  summarize(
    keywords = paste(term, collapse = ", "), # Concatenate keywords
    avg_weight = mean(beta)                 # Calculate average weight of keywords
  )

# Visualize the top 10 keywords and their weights for each topic
top_terms %>%
  ggplot(aes(x = reorder_within(term, beta, topic), y = beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip() +
  labs(x = "Keywords", y = "Weight", title = "Top 10 Keywords for Each Topic") +
  scale_x_reordered() # Maintain consistent keyword order within facets

## Comprehensive keyword comparison and overall analysis ----
# Now, we have the top 10 keywords for each topic. The table shows that the "pollution" keyword often appears with words like air, water, and plastic.

# Define keyword categories and corresponding terms
keywords <- list(
  Air = "air",
  Plastic = "plastic"
)

# Automatically map topic numbers based on keywords
topic_map <- lapply(keywords, function(keyword) {
  which(sapply(topic_terms, function(terms) any(terms %in% keyword)))
})

# Add main topics to the data frame
pollution_data$Main_Topic <- topics(lda_model)

# Automatically map topic numbers to categories
pollution_data <- pollution_data %>%
  mutate(
    Category = case_when(
      Main_Topic %in% topic_map$Air ~ "Air",
      Main_Topic %in% topic_map$Plastic ~ "Plastic",
      TRUE ~ "Other"  # Unclassified topics
    ),
    Year = format(as.Date(Date.Published), "%Y")  # Extract the year
  )

# Summarize document counts by year and category
yearly_trends <- pollution_data %>%
  filter(Category != "Other") %>%  # Focus only on target categories
  group_by(Year, Category) %>%
  summarize(Count = n(), .groups = "drop")

# Display the summarized results
print(yearly_trends)

## Visualization ----

# Load required packages
# (1) Line chart: Time trends
plot_1 <- ggplot(yearly_trends, aes(x = Year, y = Count, color = Category, group = Category)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  labs(
    title = "Pollution Topics Over Time",
    x = "Year",
    y = "Number of Articles",
    color = "Pollution Type"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# (2) Calculate yearly proportions for each category
yearly_trends <- yearly_trends %>%
  group_by(Year) %>%
  mutate(Proportion = Count / sum(Count))

# (3) Stacked bar chart: Proportional distribution
plot_2 <- ggplot(yearly_trends, aes(x = Year, y = Proportion, fill = Category)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(
    title = "Proportion of Pollution Topics by Year",
    x = "Year",
    y = "Proportion",
    color = "Pollution Type"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# （4）Combine plot and add common legend
combined_plot <- ggarrange(
  plot_1, 
  plot_2, 
  nrow = 1,                # Place the plots side by side
  ncol = 2, 
  common.legend = TRUE,    # Share a common legend
  legend = "bottom"        # Position the legend at the bottom
)

# Output the plot
print(combined_plot)
    