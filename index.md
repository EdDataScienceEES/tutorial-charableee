## Natural Laguage Processing and LDA model in R
*Xiaoye Ren*

## Tutorial aims 

Understanding the use of the tidytext package in R for data analysis and visualization.  
Performing sentiment scoring on datasets using basic sentiment lexicons provided by the tidytext package.  
Learning how to apply the LDA (Latent Dirichlet Allocation) topic model in R for topic analysis.  
Exploring the use of mapping techniques for conducting data analysis across different documents.  

## Tutorial steps 

[**Introduction**](#introduction)  
[**Part 1: Basic word segmentation**](#part-1-basic-word-segmentation)  
[**a. Tokenize the text**](#a-tokenize-the-text)  
[**b. Use of word cloud**](#b-use-of-word-cloud)  
[**c. Sentiment analysis**](#c-sentiment-analysis)  
[**d. Visualization**](#d-visualization)  
[**Part 2: Using LDA model**](#part-2-using-lda-model)  
[**a. What is LDA model and how it works?**](#a-what-is-lda-model-and-how-it-works)  
[**b. Creating corpus**](#b-creating-corpus)  
[**c. Analyze keyword weights for each topic**](#c-analyze-keyword-weights-for-each-topic)  
[**d. Comprehensive keyword comparison and overall analysis**](#d-comprehensive-keyword-comparison-and-overall-analysis)  
[**e. Visualization**](#e-visualization)  

## Introduction 


Natural Language Processing (NLP) is a computational capability that enables the understanding of human written language. Applications of this technology include semantic analysis, topic modeling, and sentiment recognition. NLP techniques allow for the rapid analysis of large-scale textual data, enabling the identification of conceptual connections within documents.


![image](https://github.com/EdDataScienceEES/tutorial-charableee/blob/master/Picture%20for%20tutorial/pic1_NLP.png?raw=true)

Source:[AMAZIUM-What is NLP and how it is implemented in our lives](https://amazinum.com/insights/what-is-nlp-and-how-it-is-implemented-in-our-lives/) 

The raw dataset we use in this class is from Environment News Dataset, you can find the raw dataset [here]( https://www.kaggle.com/datasets/beridzeg45/guardian-environment-related-news?resource=download). However, we recommended you to download the version of the dataset with the original article text column removed [here]( https://github.com/charableee/Guide-to-NLP-in-R-script).In this tutorial, we will primarily use this dataset to analyze the introduction section of the articles.


## Part 1: Basic word segmentation 

Before starting our tutorial, please ensure that you have downloaded and loaded the following extension packages:

#### Summary of Library Contributions in Code

| Library        | Usage and Contribution                                                                           |
|----------------|--------------------------------------------------------------------------------------------------|
| **tidyverse**   | Data cleaning (`dplyr`), visualization (`ggplot2`).                                              |
| **tidytext**    | Tokenization, stopword removal, sentiment analysis, extracting word distributions from LDA models. |
| **tm**          | Text cleaning (e.g., removing punctuation, stopwords, lowercase conversion) and creating document-term matrices for LDA. |
| **topicmodels** | Train LDA models and extract topic-word distributions and document-topic assignments.            |
| **wordcloud**   | Generate keyword clouds related to `pollution`.                                                  |
| **ggpubr**      | Combine multiple plots and add shared legends for final visualization.                           |


In this tutorial, we will begin by learning how to use the `tidytext`  package in R to perform text tokenization, keyword frequency analysis, word cloud visualization, and sentiment analysis on environmental-themed articles from The Guardian.


## a. Tokenize the text 


First, create a new blank script in RStudio by navigating to the following path:

`File -> New File -> R Script` 

Now, let’s configure our working environment. At this step, if you encounter the error message "No such file in directory", just simply use ` getwd()`  to double-check your working directory.

```
# Coding Club tutorial
# Xiaoye Ren
# 25/11/2024

# Set working directory
setwd("file-path")

# Set up library
library(tidyverse)
library(tidytext)
library(tm)
library(topicmodels)
library(wordcloud)
library(ggpubr)

## Load csv Data 
news_data <- read.csv("your_file_path")
```

Now, we want to study topics related to **pollution** . First, we will create a frame related to the pollution topic, let's call it `pollution_data`. 

When observing the raw data dataset, you may notice some blank entries, which can interfere with subsequent analysis. Therefore, we will remove these entries. Additionally, if we intend to analyze the data by year, we observe that some years contain only a small amount of data. To ensure reliable analysis, we will exclude these underrepresented years.

```
pollution_data <- news_data %>%
  filter(
    grepl("pollution", Intro.Text, ignore.case = TRUE) &  # Detect "pollution", ignoring case
      if_all(everything(), ~ . != "") &                   # Filter out rows with blank data
      !(year(as.Date(Date.Published)) %in% c(2017, 2024)) # Remove data from years 2017 and 2024
  ) %>%
  select(Intro.Text, Date.Published) %>%                  # Keep only the Intro.Text and Date.Published columns
  mutate(Date.Published = as.character(Date.Published)) %>% # Convert Date.Published to character format
  arrange(Date.Published)                                 # Sort the data by Date.Published
  
# remember always examine the data frame before you start the next step
head(pollution_data) 
str(pollution_data)
```
Next, we will load the `stop_words` dataframe, which is included in the `tidytext` package.

```
data("stop_words")  #Input stop_words dataframe from tidytext
```
You can try opening the `stop_words` dataframe to explore its structure. The format of this stop words lexicon is as follows. Under the `lexicon` column, the label `SMART` represents a class of information retrieval systems. This indicates that the stop word list originates from the SMART stop word set.

| word       | lexicon |
|------------|---------|
| a          | SMART   |
| a's        | SMART   |
| able       | SMART   |
| about      | SMART   |
| above      | SMART   |
| according  | SMART   |

Next, we use the `tidytext` package to tokenize our sentences into individual words. By using the `stop_words` dataframe, we will remove common words from the tokenized words and filter our `pollution` topic.
Please note that in the following code, we exclude the word `pollution` itself. This is because we aim to avoid having pollution dominate the results. The goal is to identify keywords that co-occur with this term, rather than the term itself.

```
pollution_counts <- pollution_data %>%
  unnest_tokens(word, Intro.Text) %>%                # text tokenized into individual words
  anti_join(stop_words, by = "word") %>%             # Remove stop words
  filter(any(word == "pollution")) %>%               # Filter documents containing the word "pollution"
  ungroup() %>%                                      # Ungroup data 
  filter(word != "pollution") %>%                    # Exclude "pollution" word itself
  count(word, sort = TRUE)                           # Count the frequency 
```


## b. Use of word cloud 


Pointcloud is a simple way for us to visualize the frequency frame information. It can help us visually see the frequency of occurrence of the frame.To visualise the pointcloud, we need to run the `wordcloud` package in R.

```
wordcloud(
  words = pollution_counts$word,                    # Words to include in the word cloud
  freq = pollution_counts$n,                        # Setting frequencies of the words
  max.words = 50,                                   # Maximum number of words to display
  scale = c(3, 0.5),                                # Scaling for word size
  colors = brewer.pal(6, "Dark2")                   # color palette
)
```

This will be the output of our pointcloud:

![image](https://github.com/EdDataScienceEES/tutorial-charableee/blob/master/diagram/word%20cloud%20plotting.png?raw=true)

## c. Sentiment analysis 

_Sentiment analysis_ is crucial in our report, as it helps us uncovering the emotional tone embedded in the articles.By identifying the sentiment, we can then track how media frames issues, such as our topic, pollution, over time. 

In our study, we want to analyze the monthly sentiment trend. Here, we can tokenize the text first and then match it with a built-in sentiment lexicon from `tidytext`.
Here, we tokenize the text first. We use `Bing` package from `tidytext` to analyze sentiment.

```
sentiment_pollution <- pollution_data %>%
  unnest_tokens(word, Intro.Text) %>%               # Tokenize the text
  inner_join(get_sentiments("bing"), by = "word")  # Match with Bing sentiment lexicon
```
We want to extract each year and month in our study to get the sentiment trend overtime. 
Then, we calculate the sentiment counts using `mutate()` and reshape data into wide format to make it easy to view.

```
monthly_sentiment <- sentiment_pollution %>%
  mutate(
    Year = year(as.Date(Date.Published)),      # Extract the year
    Month = month(as.Date(Date.Published))    # Extract the month
  ) %>%
  count(Year, Month, sentiment) %>%           # Count occurrences by year, month, and sentiment type
  spread(sentiment, n, fill = 0) %>%          # Reshape data to a wide format
  mutate(Sentiment = positive - negative)     # Calculate net sentiment score
```
This will be the dataframe we will get after we run the code now:

| Year | Month | negative | positive | Sentiment |
|------|-------|----------|----------|-----------|
| 2018 | 1     | 0        | 1        | 1         |
| 2018 | 2     | 11       | 3        | -8        |
| 2018 | 3     | 8        | 1        | -7        |
| 2018 | 4     | 8        | 1        | -7        |
| 2018 | 5     | 11       | 2        | -9        |


## d. Visualization 

Take a closer look at our dataset, which includes a summary of positive and negative terms. Now, we aim to visualize this information intuitively.
First, we want to determine the proportion of positive and negative sentiments in our dataset. To achieve this, we will use a **diverging bar chart**, which clearly represents the positive and negative values in the data. 

```
ggplot(monthly_sentiment, aes(x = factor(Month), y = positive, fill = "Positive")) +
  geom_col(alpha = 0.7) +                                         # set positive sentiment transparency 
  geom_col(aes(y = -negative, fill = "Negative"), alpha = 0.7) +  # set negative sentiment transparency 
  facet_wrap(~ Year, scales = "free_x") +                         # Split plot into facets by Year
  scale_fill_manual(values = c("Positive" = "firebrick", "Negative" = "steelblue")) +  # Customize colors
  labs(
    title = "Monthly Sentiment Trend",
    x = "Month",
    y = "Number of Sentiment Words",
    fill = "Sentiment"
  ) +
  theme_minimal()  # Apply a minimal theme for clean and simple appearance
```

This will be the output of our plot:

![image](https://github.com/EdDataScienceEES/tutorial-charableee/blob/master/diagram/monthly%20sentiment.png?raw=true)


Next, we will examine how the sentiment score is distributed across different years. For this, we will use a **line chart** to visually represent the sentiment trend over time.

```
ggplot(monthly_sentiment, aes(x = factor(Month), y = Sentiment, group = Year)) +
  geom_line(color = "steelblue", size = 1) +        # Draw sentiment lines 
  geom_point(color = "firebrick", size = 2) +        # Add points for each sentiment score
  facet_wrap(~ Year, scales = "free_y") +          # Create separate plots for each year
  labs(
    title = "Monthly Sentiment Trends by Year",    
    x = "Month",                                  
    y = "Sentiment Score"                          
  ) +
  theme_minimal() 
```

And this will be the output of our plot:

![image](https://github.com/EdDataScienceEES/tutorial-charableee/blob/master/diagram/Monthly%20sentiment%20trends%20by%20year.png?raw=true)


## Part 2: Using LDA model 

## a. What is LDA model and how it works?  

**The LDA model** is a commonly used topic modeling method. It helps users quickly identify influential topics within a large corpus of documents. This probabilistic model assumes that the distribution of words in each document is associated with specific underlying topics.

For example, we can assume that each document contains a mixture of multiple topics. A report might allocate 30% of its content to the topic of **water pollution** and 70% to **plastic pollutio**n. Furthermore, each topic is characterized by a set of prominent keywords. For instance, the **water pollution** topic may include keywords like **water** and **river** while the plastic pollution topic might include keywords such as **manufacturing** and **factory**
It is also possible for overlapping keywords to appear across topics. For example, if a document discusses plastic particles in rivers, the keyword **river** could be associated with both the water pollution and plastic pollution topics.

![image](https://raw.githubusercontent.com/EdDataScienceEES/tutorial-charableee/refs/heads/master/Picture%20for%20tutorial/pic%202_LDA.webp)

Source:[Medium-All about LDA in NLP](https://mohamedbakrey094.medium.com/all-about-latent-dirichlet-allocation-lda-in-nlp-6cfa7825034e) 

## b. Creating corpus 

To start using the LDA model in R, we need to use the `topicmodels` and `tm`. We will first start from creating `corpus` by using our previous frame and into content`pollution_data$Intro.Text`.

```
# Create a corpus and clean the text
corpus <- Corpus(VectorSource(pollution_data$Intro.Text))
```
Then, we use `tm` package to convert text and clear the text.

```
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
```
After completing the text cleaning process, we proceed to create a **Document-Term Matrix (DTM)**. This step transforms the raw, processed data into a structured format that can be understood and utilized by the LDA model for further computation.

```
# Create a document-term matrix
dtm <- DocumentTermMatrix(corpus)
```
Next, we move to the most interetsing step: training our **LDA model**. Let's begin by running the following code and allow about 30 seconds for the model to load, as LDA can take some time to process the data:

```
lda_model <- LDA(dtm, k = 20, control = list(seed = 123)) # Set random seed for reproducibility
```
In this code, we configure three main parameters:

`dtm`

The **Document-Term Matrix**, which is the structured input prepared earlier for the LDA model.

`k = 20`

The number of topics to extract. For example, here we have set the model to identify 20 distinct topics from the dataset.

`control = list(seed = 123)`

This sets the `control` options for the model training. Specifically, the `seed` parameter ensures consistent results across multiple runs. Since LDA involves random initialization, the output can vary with each execution. Setting a seed ensures reproducibility, allowing the same results every time the code is run.


Finally, we extract the top keywords for each topic. To preview the top 10 keywords for the generated topics, run the following code:
```
topic_terms <- terms(lda_model, 10)
print(terms(lda_model, 10))
```
Take a look at the output you get for now, what did you observed?

## c. Analyze keyword weights for each topic

Now that we have identified 20 topics along with the top 10 keywords for each topic, so: how can we intuitively identify the keywords for each topic and visualize this information?

First, we need to create a clear and organized dataframe that displays the weights of each word for each topic, as calculated by the LDA model. Start by running the following code:

```
# Extract the topic-term distribution matrix (keyword weights for each topic)
beta <- tidy(lda_model, matrix = "beta") # get beta matrix
````
This code extracts the beta matrix, which represents the topic-word distribution. Below is an example of the initial dataframe we obtain from this step:

| topic | term | beta            |
|-------|------|-----------------|
| 1     | big  | 3.674873e-194   |
| 2     | big  | 1.944736e-193   |
| 3     | big  | 6.070483e-03    |

However, since we are only interested in the top 10 words for each topic, we need to further filter the matrix. Use the following code to refine the results:

```
#Retrieve the top n keywords for each topic and their weights
n <- 10
top_terms <- beta %>%
  group_by(topic) %>%
  slice_max(beta, n = n, with_ties = FALSE) %>% # Select the top n terms for each topic
  ungroup()
```
This is the dataframe we get for the next step：

| topic | term       | beta       |
|-------|------------|------------|
| 1     | pollution  | 0.076661612|
| 1     | crisis     | 0.027573291|
| 1     | climate    | 0.019362111|

Here’s an important detail: in the line `slice_max(beta, n = 10, with_ties = FALSE)`, the `with_ties = FALSE` parameter ensures that we strictly limit each topic to **exactly 10 keywords**. Without this option, it is possible for some topics to include more than 10 words due to ties in beta values.

Finally, run the code below to generate a summarized dataframe that lists the top 10 keywords for each topic:

```
summary_table <- top_terms %>%
  group_by(topic) %>%
  summarize(
    keywords = paste(term, collapse = ", "), # Concatenate keywords
    avg_weight = mean(beta)                 # Calculate average weight of keywords
  )
```
And this will be our final expected dataframe：

| topic | keywords                                           | avg_weight |
|-------|----------------------------------------------------|------------|
| 1     | pollution, crisis, climate, will, report, scientists, deaths, air, ha... | 0.02107225 |
| 2     | pollution, air, can, found, european, year, plastic, study, deca...     | 0.02579200 |
| 3     | pollution, air, wood, good, burning, says, causes, will, cut, rise      | 0.01903042 |

Every data is ready to go for now! Let's run the code below to get a beautiful diagram:

```
top_terms %>%
  ggplot(aes(x = reorder_within(term, beta, topic), y = beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip() +
  labs(x = "Keywords", y = "Weight", title = "Top 10 Keywords for Each Topic") +
  scale_x_reordered() # Maintain consistent keyword order within facets
```
This is the diagram we expected to have:

![image](https://github.com/EdDataScienceEES/tutorial-charableee/blob/master/diagram/Top%2010%20Keywords%20for%20each%20topic.png?raw=true)


## d. Comprehensive keyword comparison and overall analysis

Now, we have the top 10 keywords for each topic and we just made a beautiful diagram. Take a look at the diagram, it seems like the "pollution" keyword often appears with topic words **air** and **plastic**.
So,how can we analyze data related to the topics "air" and "pollution"? To begin, we will customize a set of keywords and match them to their respective topic numbers.

We already have the `topic_terms` dataset, so we will use `lapply()` to iterate through the list of keywords for each category. Simultaneously, we will use `sapply()` to check if the keywords we defined earlier are present in the topic terms. Finally, we will use `which()` to extract the topic numbers that match our keywords.

```
# Define keyword categories and corresponding terms
keywords <- list(
  Air = "air",
  Plastic = "plastic"
)

# Automatically map topic numbers based on keywords
topic_map <- lapply(keywords, function(keyword) {
  which(sapply(topic_terms, function(terms) any(terms %in% keyword)))
})
```
In this code, `which()` returns the indices of the boolean vector in `sapply()` where the value is **TRUE**. Once all operations are complete, the resulting data will be stored in our `topic_map`. Next, we will append the topic numbers to our original `pollution_data` dataframe, allowing us to identify the main topic for each document.

```
pollution_data$Main_Topic <- topics(lda_model)
```
At this stage, we can examine our updated dataframe to check its current state:

| Intro.Text                                                       | Date.Published | Main_Topic |
|------------------------------------------------------------------|----------------|------------|
| Reduction largely wiped out by a rise in carbon pollution from… | 2018-01-18     | 3          |
| UK watchdog bans advert claiming lowest CO2 pollution of …       | 2018-01-26     | 11         |
| It’s clean transport, costs nothing and causes no pollution, …   | 2018-01-31     | 6          |

Now, we’re ready to map topic numbers to their respective categories. Run the following code:

```
pollution_data <- pollution_data %>%
  mutate(
    Category = case_when(
      Main_Topic %in% topic_map$Air ~ "Air",
      Main_Topic %in% topic_map$Plastic ~ "Plastic",
      TRUE ~ "Other"  # Unclassified topics
    ),
    Year = format(as.Date(Date.Published), "%Y")  # Extract the year
  )
```
...And take another look at our next dataframe:

| Intro.Text                                                       | Date.Published | Main_Topic | Category | Year |
|------------------------------------------------------------------|----------------|------------|----------|------|
| UK and eight other states will need to take drastic measures…   | 2018-02-14     | 17         | Plastic  | 2018 |
| Ultimately the only thing that matters: we need to cut carbon…   | 2018-02-15     | 4          | Other    | 2018 |
| In nearly 30 years, a bunch of surfers concerned about pollu…    | 2018-02-18     | 12         | Air      | 2018 |


You will see that a new column, `Category`, has been added. This column contains three possible values: `Air`, `Plastic`, and `Other`. In the previous code, we used the logic  `Main_Topic %in% topic_map$Air ~ "Air"` This assigns the category `Air` to any document whose `Main_Topic` matches the topics in `topic_map$Air`. This dataframe will serve as the foundation for the next step in data visualization.

Finally, we separate the `Air` and `Plastic` data into individual datasets for further visualization. Run the following code to extract these subsets:

```
# Summarize document counts by year and category
yearly_trends <- pollution_data %>%
  filter(Category != "Other") %>%  # We only want data from Air and plastic, so we exclude Other 
  group_by(Year, Category) %>%
  summarize(Count = n(), .groups = "drop")
``` 
This will be the final dataframe for us to work on the data visualization：

| Year | Category | Count |
|------|----------|-------|
| 2018 | Air      | 3     |
| 2018 | Plastic  | 2     |
| 2019 | Air      | 3     |


## e. Visualization 

With the data obtained above, the first and most straightforward insight we can observe is the yearly trends of different topics in the dataset. To visualize this, we can start by creating a simple line chart titled **Pollution Topics Over Time**.

```
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
```

Now,try plot this diagram：

```
print(plot_1)
```
This is the first diagram we expected to have:

![image](https://github.com/EdDataScienceEES/tutorial-charableee/blob/master/diagram/Pollution%20topics%20over%20time.png?raw=true)

Next, we can perform some basic calculations to extract additional insights. We now have a `Category` column indicating the type of topic for each data entry, as well as a `Count` column representing the number of corresponding documents. Using this data, we can compute basic metrics.

| Year | Category | Count |
|------|----------|-------|
| 2018 | Air      | 3     |
| 2018 | Plastic  | 2     |
| 2019 | Air      | 3     |

For example, consider the following example: in 2018, the "Air" topic appears 3 times, and the "Plastic" topic appears 2 times. In 2019, only the "Air" topic appears 3 times. We can calculate the relative proportions for each year to better understand the trends:

```
Overall count in 2018 ：3 + 2 = 5
Overall count in 2019 ：3
```

We use formula `Count / sum(Count)`. Then, our proportion will be:

```
In 2018：
Air topic proportion：3 / (3 + 2) = 3 / 5 = 0.6
Plastic topic proportion：2 / (3 + 2) = 2 / 5 = 0.4
In 2019：
Air topic proportion：3 / 3 = 1.0
```

These calculations allow us to visualize the yearly relative proportions of each topic, and this can be work in R using the following code:

```
# Calculate yearly proportions for each category
yearly_trends <- yearly_trends %>%
  group_by(Year) %>%
  mutate(Proportion = Count / sum(Count)) # Here, we calculate the propotion 
```
 Now we just need to run the following code to visualize our output：
 
```
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
```
 
We simply output the diagram to see the result：
 
 ```
 print(plot_2)
```

The second diagram we expected to have will be:

![image](https://github.com/EdDataScienceEES/tutorial-charableee/blob/master/diagram/Proportion%20of%20Pollution%20Topics%20by%20Year.png?raw=true)
 
Great job! It seems like it would be more obvious if we can combine these two diagram together, run this:

```
combined_plot <- ggarrange(
  plot_1, 
  plot_2, 
  nrow = 1,                # Place the plots side by side
  ncol = 2, 
  common.legend = TRUE,    # Share a common legend
  legend = "bottom"        # Position the legend at the bottom
)
```

And this will be our final output:

![image](https://github.com/EdDataScienceEES/tutorial-charableee/blob/master/diagram/Pollution%20topics.png?raw=true)

**Congratulations, you’ve completed the tutorial!! :)**  By the end of this tutorial, you have gained a solid understanding of how to use the tidytext package for data analysis and visualization in R. Now, you will be able to perform sentiment scoring with basic lexicons, apply the LDA topic model for uncovering hidden themes, and utilize mapping techniques to analyze and visualize data across multiple documents. These skills will equip you to handle textual data efficiently and extract meaningful insights for your future projects. 


##  Extra resources

There are some related topics in coding club tutorial you may interested relate to this tutorial.

If you want to learn more on survey topic analysis, see:

[Analysing ordinal data, surveys, count data](https://ourcodingclub.github.io/tutorials/qualitative/) 

If you want to learn more on data visualization, see:

[Beautiful and informative data visualisation](https://ourcodingclub.github.io/tutorials/datavis/) 

[Data visualisation 2](https://ourcodingclub.github.io/tutorials/data-vis-2/) 

Also, if you want to further explore the use of LDA model in R, take a look at these links：

[Text Mining with R: A Tidy Approach](https://www.tidytextmining.com/topicmodeling) 

[Topic Modeling with R](https://ladal.edu.au/topicmodels.html) 

[Beginner’s Guide to LDA Topic Modelling with R](https://towardsdatascience.com/beginners-guide-to-lda-topic-modelling-with-r-e57a5a8e7a25) 

[Topic Modeling Using Latent Dirichlet Allocation](https://www.analyticsvidhya.com/blog/2023/02/topic-modeling-using-latent-dirichlet-allocation-lda/) 

