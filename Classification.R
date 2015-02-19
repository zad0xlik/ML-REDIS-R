## Fitting Classification Tree Models

install.packages(c("ISLR", "gdata", "tree"))
library(ISLR)
library(gdata)
library(tree)

setwd("/Professional/CODES")
mydata <- read.csv("Workbook1.csv")
mydata <- mydata[1:50,]

##range(data$qty)
##range(data$call_volume)

High_qty <- ifelse(mydata$qty >= 150, "Yes", "No")
mydata <- data.frame(mydata, High_qty)

myvars <- names(mydata) %in% c("call_volume", "qty") 
mydata <- mydata[!myvars]

## Split data into testing and training using
set.seed(2)
train <- sample(1:nrow(mydata), nrow(mydata)/2)
test <- -train
training_data <- mydata[train,]
testing_data <- mydata[test,]
testing_High_qty <- High_qty[test]



## fit the tree model using training data
tree_model <- tree(High_qty ~ mydata$call_option_symbol , training_data, subset=1:5, mindev=1e-6, minsize=2)

plot(tree_model)
text(tree_model, pretty=0)

tree_pred = predict(tree_model, testing_data, type = "class")
mean(tree_pred != testing_High_qty) # 3.125%





