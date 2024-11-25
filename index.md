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

我们开始配置我们的工作环境。在这一步中，如果您发现RStudio返回了No such file in directory的报错，请使用`getwd()`再次确认您的工作路径。

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

现在，我们想要研究和"pollution"相关的主题，因此，我们首先Create a frame related to pollution topic。
当我们观察raw data数据集的时候，我们会发现一些空白数据，这些数据会干扰我们后续分析，所以我们也将其移除。
如果我们要针对年份进行分析，该数据集中存在部分年份只包含极少的数据，因此我们移除掉这些数据过少的年份。

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
接着，我们开始使用`tidytext`包自带的停用词词包。我们首先加载`stop_words`dataframe.

```
data("stop_words")  #Input stop_words dataframe from tidytext

```
您可以尝试打开`stop_words` dataframe，该停用词词包格式如下。`lexion` 列下方的`SMART` 是一类信息检索系统。这意味着该停用词词包来源于该停用词集合。

    word      |   lexion
------------- | -------------
      a       |   SMART
     a's      |   SMART


下一步，我们使用`tidytext`包首先将我们的句子分成独立的单词。接着，我们使用`stop_words`包移除tokenized words中的常见词语，并将我们研究的主题`pollution`筛选出来。请注意，我们在下列代码中选择`Exclude "pollution" word itself` 是因为我们需要避免`pollution`主导统计结果。因为我们需要找到的是与该词汇共线的关键词而非该词语本身。 

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

当我们

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


