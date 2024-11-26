_Xiaoye Ren_
----

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

The raw dataset we use in this class is from Environment News Dataset, you can find the raw dataset [here]( https://www.kaggle.com/datasets/beridzeg45/guardian-environment-related-news?resource=download) However, we recommended you to download the version of the dataset with the original article text column removed here（）In this tutorial, we will primarily use this dataset to analyze the introduction section of the articles.


## Part 1: Basic word segmentation 


Before starting the tutorial, please ensure that you have downloaded and loaded the following extension packages:

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

Now, let’s configure our working environment. At this step, if you encounter the error message "No such file in directory", use ` getwd()`  to double-check your working directory.

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

Now, we want to study topics related to `pollution` . First, we will create a frame related to the pollution topic.
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


Next, we will examine how the sentiment score is distributed across different years. For this, we will use a **line chart** to visually represent the sentiment trend over time.。

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

To start using 


## b. Creating corpus 



## c. Analyze keyword weights for each topic


## d. Comprehensive keyword comparison and overall analysis


## e. Visualization 



If you want to further explore the use of LDA model in R, take a look at these links：
[Text Mining with R: A Tidy Approach](https://www.tidytextmining.com/topicmodeling) 
[Topic Modeling with R](https://ladal.edu.au/topicmodels.html) 
[Beginner’s Guide to LDA Topic Modelling with R](https://towardsdatascience.com/beginners-guide-to-lda-topic-modelling-with-r-e57a5a8e7a25) 
[Topic Modeling Using Latent Dirichlet Allocation](https://www.analyticsvidhya.com/blog/2023/02/topic-modeling-using-latent-dirichlet-allocation-lda/) 

