### PURPOSE: Scrape text data to update environmental policy uncertainty index and associated graph/widget
### LAST EDITED: 5/15/2026

rm(list = ls())

library(htmlwidgets)
library(stringr)
library(lubridate)
library(plotly)
library(foreign)
library(haven)
library(psych)
library(purrr)
library(data.table)
library(tibble)
library(dplyr)
library(tidyr)
library(zoo)
library(jsonlite)

### Setting paths
scrapewd <- "Data/toscrape"
cleanwd <- "Data/clean"

################################################################################
### Scraping txt data and calculating indices
################################################################################
### Defining scraping function
scrape <- function(input, keyword){
  for (i in 1:length(input)){
    if (str_detect(input[i], "jQuery.extend")==TRUE){
      n <- i
    }
  }
  dat <- map(input[n], function(x) {
    tibble(text = unlist(str_split(x, pattern = ':\\{\"'))) %>%
      rowid_to_column(var = "line")
  })
  dat <- as.data.frame(bind_rows(dat, .id = "page"))
  dat <- dat %>% mutate_at("text", function(x)(gsub(x, pattern = "\"", replacement = "")))
  dat$count <- str_extract(dat$text, "(?i)(?<=count:)\\d+")
  dat$label <- str_match(dat$text, "label:\\s*(.*?)\\s*,")[,2]
  dat$field <- str_match(dat$text, "field:\\s*(.*?)\\s*,")[,2]
  dat <- dat %>% filter(field=="yrmo")
  dat <- dat %>% separate(label, c("month", "year"), " ")
  dat <- dat[, -c(1, 2, 3, 7)]
  colnames(dat) <- c(paste(keyword, sep = ""), "month", "year")
  return(dat)
}

### Scraping data
file.names <- dir(path = scrapewd, pattern = "*.txt")
listofdf <- list()
i <- 1
for (file in file.names) {
  fullpath <- file.path(scrapewd, file)
  name <- file
  subname <- sub('.txt', '', file)
  df <- readLines(fullpath)
  df <- scrape(df, subname)
  listofdf[[i]]<- df
  i <- i+1
}
# Saving test data
test <- list_rbind(listofdf)
write.csv(test, file = file.path(cleanwd, "test.csv"))
#for (j in 1:(length(file.names)-1)) {
#  df <- listofdf[[j]]
#  df2 <- listofdf[[j+1]]
#  df2 <- merge(df, df2, by = c("year", "month"), all = T)
#  i <- j+1
#  listofdf[[i]] <- df2
#}
newsbank <- df2
newsbank[is.na(newsbank)] <- 0

### Taking in raw counts and calculating the index
newsbank <- newsbank %>% 
  mutate(
    month = as.integer(factor(newsbank$month, levels = month.name)) 
  )
newsbank <- newsbank[order(newsbank$year, newsbank$month),]
newsbank$epu <- as.numeric(newsbank$epu)
newsbank$all <- as.numeric(newsbank$all)
newsbank$ep <- as.numeric(newsbank$ep)
newsbank$ep_count <-newsbank$ep
newsbank$epu_count <- newsbank$epu
newsbank$epu <- newsbank$epu/newsbank$all
newsbank$ep <- newsbank$ep/newsbank$all

mean <- mean(newsbank[newsbank$year<2010,]$epu)
newsbank$epu <- (newsbank$epu/mean)*100

mean <- mean(newsbank[newsbank$year<2010,]$ep)
newsbank$ep <- (newsbank$ep/mean)*100

### Saving the results as a csv file
write.csv(newsbank, file = file.path(cleanwd, "epu_indices.csv"))

################################################################################
### Generating graphs (for webpage)
################################################################################
### Creating graph of indices
newsbank$date <- as.yearmon(paste(newsbank$year, newsbank$month), "%Y %m")
ay <- list(
  tickfont = list(color = "green"),
  overlaying = "y",
  side = "right",
  title = "Environmental Policy Uncertainty (EnvPU) and Environmental Policy (EnvP) Indices"
)
fig <- plot_ly(
  newsbank, 
  x = as.Date(as.yearmon(newsbank$date, "%b %Y"), format = "%b %Y"), 
  y = ~epu, 
  type = "scatter", 
  mode = "lines", 
  name = "EnvPU"
)
fig <- add_trace(
  fig, 
  data = newsbank, 
  x = as.Date(as.yearmon(newsbank$date, "%b %Y"), format = "%b %Y"), 
  y = ~ep, 
  type = "scatter", 
  mode = "lines", 
  name = "EnvP"
)
fig <- fig %>% 
  layout(
    title = "Environmental Policy Uncertainty (EnvPU) and Environmental Policy (EnvP) Indices",
    yaxis2 = ay,
    yaxis = list(title = ""),
    xaxis = list(rangeslider = list(type = "date")),
    legend = list(font = list(size = 16))
  )

### Saving figure as HTML in root directory
saveWidget(fig, file = "../epuindex.html", selfcontained = T)
