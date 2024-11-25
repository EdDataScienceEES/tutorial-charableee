---
title: "test"
output: html_document
date: "2024-11-21"
---

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

Natural Language Processing (NLP)是一种使用计算程序理解人类书面语言的能力。这一技术应用包含语义分析，主题建模，情感识别等。我们可以使用NLP技术快速挖掘大规模的文本数据并找到文档中的思想联系。
（pic 1）

我们课程中使用的数据包来源于Environment News Dataset，您可以在这里（ https://www.kaggle.com/datasets/beridzeg45/guardian-environment-related-news?resource=download）找到该数据包的raw data。
我们推荐您在这里（）下载该数据包删除文章原文column后的版本。在本教程中，我们会主要使用该数据包对文章的introduction部分进行分析。

## Part 1: Basic word segmentation 

在开始教程之前，请保证您已经下载并加载了以下拓展包：

#### Summary of Library Contributions in Code

| Library        | Usage and Contribution                                                                           |
|----------------|--------------------------------------------------------------------------------------------------|
| **tidyverse**   | Data cleaning (`dplyr`), visualization (`ggplot2`).                                              |
| **tidytext**    | Tokenization, stopword removal, sentiment analysis, extracting word distributions from LDA models. |
| **tm**          | Text cleaning (e.g., removing punctuation, stopwords, lowercase conversion) and creating document-term matrices for LDA. |
| **topicmodels** | Train LDA models and extract topic-word distributions and document-topic assignments.            |
| **wordcloud**   | Generate keyword clouds related to `pollution`.                                                  |
| **ggpubr**      | Combine multiple plots and add shared legends for final visualization.                           |

在本次教程中，我们将首先学习使用R语言中的tidytext包对英国卫报环境主题的文本进行文本分词，关键词词频分析与词云可视化和情感分析。

### a. Tokenize the text 

请首先在RStudio中按照以下路径创建一个新的空白脚本 

`File -> New File -> R Script` 

我们开始配置我们的工作环境

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
在这一步中，如果您发现RStudio返回了No such file in directory的报错，请使用`getwd()`再次确认您的工作路径。
我们想要研究和"pollution"相关的主题，因此，我们首先Create a frame related to pollution topic

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
  
```


```
# Examine the tidy data frame
head(pollution_data)
str(pollution_data)
```


### b. Use of word cloud 

aaaaa

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


