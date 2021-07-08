df2015 <- read.csv("2015.csv")
df2016 <- read.csv("2016.csv")
df2017 <- read.csv("2017.csv")
df2018 <- read.csv("2018.csv")
df2019 <- read.csv("2019.csv")

colnames(df2015)
colnames(df2016)
colnames(df2017)
colnames(df2018)
colnames(df2019)

library(dplyr)
library(DataExplorer)

colnames(df2015) <- c("country", "region", "rank", "score", "misc1", "gdp_per_capita", "social_support", "healthy_life_expectancy", "freedom_life_choices", "perceptions_of_corruption", "generosity", "misc3")
rownames(df2015) <- paste0(df2015$country, "_2015")
df2015_clean <- df2015 %>% select("score", "gdp_per_capita", "social_support", "healthy_life_expectancy", "freedom_life_choices", "generosity", "perceptions_of_corruption")
plot_histogram(df2015_clean)

colnames(df2016) <- c("country", "region", "rank", "score", "misc1", "misc2", "gdp_per_capita", "social_support", "healthy_life_expectancy", "freedom_life_choices", "generosity", "perceptions_of_corruption", "misc3")
rownames(df2016) <- paste0(df2016$country, "_2016")
df2016_clean <- df2016 %>% select("score", "gdp_per_capita", "social_support", "healthy_life_expectancy", "freedom_life_choices", "generosity", "perceptions_of_corruption")
plot_histogram(df2016_clean)

colnames(df2017) <- c("country", "rank", "score", "misc1", "misc2", "gdp_per_capita", "social_support", "healthy_life_expectancy", "freedom_life_choices", "generosity", "perceptions_of_corruption", "misc3")
rownames(df2017) <- paste0(df2017$country, "_2017")
df2017_clean <- df2017 %>% select("score", "gdp_per_capita", "social_support", "healthy_life_expectancy", "freedom_life_choices", "generosity", "perceptions_of_corruption")
plot_histogram(df2017_clean)

colnames(df2018) <- c("rank", "country", "score", "gdp_per_capita", "social_support", "healthy_life_expectancy", "freedom_life_choices", "generosity", "perceptions_of_corruption")
df2018 <- df2018[df2018$perceptions_of_corruption != "N/A", ]
df2018$perceptions_of_corruption <- as.numeric(df2018$perceptions_of_corruption)
rownames(df2018) <- paste0(df2018$country, "_2018")
df2018_clean <- df2018 %>% select("score", "gdp_per_capita", "social_support", "healthy_life_expectancy", "freedom_life_choices", "generosity", "perceptions_of_corruption")
plot_histogram(df2018_clean)

colnames(df2019) <- c("rank", "country", "score", "gdp_per_capita", "social_support", "healthy_life_expectancy", "freedom_life_choices", "generosity", "perceptions_of_corruption")
rownames(df2019) <- paste0(df2019$country)
df2019_clean <- df2019 %>% select("score", "gdp_per_capita", "social_support", "healthy_life_expectancy", "freedom_life_choices", "generosity", "perceptions_of_corruption")
plot_histogram(df2019_clean)

happiness_train <- rbind(df2015_clean, df2016_clean, df2017_clean, df2018_clean)
happiness_test <- df2019_clean

usethis::use_data(happiness_train, overwrite = TRUE)
usethis::use_data(happiness_test, overwrite = TRUE)