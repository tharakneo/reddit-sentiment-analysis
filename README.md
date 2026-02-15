# Reddit Sentiment Analysis: iPhone 17 & iOS 26 Launch

## Overview
Analyzed 20K+ Reddit comments from r/iPhone to understand public sentiment around Apple's iPhone 17 lineup and iOS 26 release. Scraped data from 40 top threads, performed sentiment analysis using Bing and NRC lexicons, and built an interactive Tableau dashboard for stakeholder insights.

## Key Findings
- **Negative sentiment dominated:** ~11K negative vs ~9K positive words — users were more frustrated than impressed
- **iOS 26 Liquid Glass** was the most criticized change, causing large negative sentiment spikes
- **iPhone Air** generated the highest discussion volume due to battery drain, durability, and overheating concerns
- **Trust** and **Anticipation** were the strongest emotions; **Anger** and **Fear** outpaced **Joy**
- Top complaints: battery drain, pink tint displays, lag, bugs, charging issues, overheating
- Competitor comparisons (Samsung, Google Pixel) appeared frequently in negative threads

## Methodology
1. **Data Collection:** Scraped 20K+ comments from r/iPhone using RedditExtractoR in R
2. **Text Preprocessing:** Tokenized, removed stopwords, filtered non-alphabetic tokens
3. **Sentiment Analysis:** Bing lexicon (positive/negative) and NRC lexicon (8 emotions)
4. **Time Series:** Tracked daily sentiment scores to identify spikes around key events
5. **Visualization:** Built Tableau dashboard with sentiment trends, topic bubbles, emotion breakdown, and top positive/negative words

## Dashboard
[View Interactive Tableau Dashboard](https://public.tableau.com/views/SentimentAnalysis_17633535667040/Dashboard1?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

## Tools
R, RedditExtractoR, tidyverse, tidytext, Bing & NRC Lexicons, ggplot2, Tableau

## Project Structure
```
├── reddit_sentiment_analysis.R       # Full analysis script
├── Sentiment_Analysis_Report.pdf     # Project report with findings
├── data/                             # All processed datasets
│   ├── iphone_comments_raw.csv
│   ├── iphone_tokens.csv
│   ├── iphone_sentiment_words.csv
│   ├── iphone_sentiment_summary.csv
│   ├── iphone_sentiment_by_day.csv
│   ├── iphone_emotions.csv
│   └── iphone_threads_used.csv
└── README.md
```

## How to Run
1. Open `reddit_sentiment_analysis.R` in RStudio
2. Install packages: `install.packages(c("RedditExtractoR", "tidyverse", "tidytext", "lubridate", "textdata"))`
3. Run the script — scrapes fresh data and generates all outputs
4. Import CSVs into Tableau to recreate the dashboard
