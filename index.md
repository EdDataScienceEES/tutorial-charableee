*Xiaoye Ren*
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
[**c. sentiment analysis**](#c-sentiment-analysis)  
[**d. Visualization**](#d-visualization)  
[**Part 2: Using LDA model**](#part-2-using-lda-model)  
[**a. What is LDA model and how it works?**](#a-what-is-lda-model-and-how-it-works)  
[**b. Creating corpus**](#b-creating-corpus)  
[**c. Use of word cloud**](#c-use-of-word-cloud)  
[**d. sentiment analysis**](#d-sentiment-analysis)  
[**e. Visualization**](#e-visualization)  

---

## Introduction 

Natural Language Processing (NLP) is a computational capability that enables the understanding of human written language. Applications of this technology include semantic analysis, topic modeling, and sentiment recognition. NLP techniques allow for the rapid analysis of large-scale textual data, enabling the identification of conceptual connections within documents.

（pic 1）

The raw dataset we use in this class is from Environment News Dataset, you can find the raw dataset here（ https://www.kaggle.com/datasets/beridzeg45/guardian-environment-related-news?resource=download）
However, we recommended you to download the version of the dataset with the original article text column removed here（）In this tutorial, we will primarily use this dataset to analyze the introduction section of the articles.

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

### a. Tokenize the text 

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

### b. Use of word cloud 



```

wordcloud(
  words = pollution_counts$word,
  freq = pollution_counts$n,
  max.words = 50, 
  scale = c(3, 0.5),
  colors = brewer.pal(6, "Dark2")
)

```




### c. sentiment analysis 


### d. Visualization 



## Part 2: Using LDA model 

### a. What is LDA model and how it works?  



### b. Creating corpus 



### c. Use of word cloud 


### d. sentiment analysis 


### e. Visualization 


```{r cars}
summary(cars)
```

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.


