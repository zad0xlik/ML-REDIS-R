install.packages('rattle')
install.packages('rpart.plot')
install.packages('RColorBrewer')
install.packages('xlsx')

library(rattle)
library(rpart.plot)
library(RColorBrewer)
library(xlsx)

setwd("/Professional/CODES")
mydata <- read.xlsx("Workbook.xlsx", 1) # change tabs
##mydata <- mydata[1:40,]

attach(mydata)

## Split data into testing and training using
set.seed(1234)
train <- sample(2, nrow(mydata), replace=TRUE, prob=c(0.7, 0.3))

test <- -train
training_data <- mydata[train,]
testing_data <- mydata[test,]

rpart_model <- rpart(qty ~., data=training_data, method="class",control=rpart.control(minsplit=20, cp=0))
attributes(rpart_model)
print(rpart_model)
fancyRpartPlot(rpart_model, uniform=TRUE, main="Classification Tree for Optionsnapshot")
text(rpart_model, use.n=TRUE, all=TRUE, cex=.8)

detach(mydata)