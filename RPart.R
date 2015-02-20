install.packages('rattle')
install.packages('rpart.plot')
install.packages('RColorBrewer')
library(rattle)
library(rpart.plot)
library(RColorBrewer)

mydata <- read.csv("Workbook1.csv")
mydata <- mydata[1:50,]

attach(mydata)

## Split data into testing and training using
set.seed(12)
train <- sample(2, nrow(mydata), replace=TRUE, prob=c(0.7, 0.3))
test <- -train
training_data <- mydata[train,]
testing_data <- mydata[test,]

rpart_model <- rpart(qty ~ call_option_symbol + call_bid_ask_size, data=training_data, method="class",control=rpart.control(minsplit=20))
attributes(rpart_model)
print(rpart_model)
fancyRpartPlot(rpart_model, uniform=TRUE, main="Classification Tree for Optionsnapshot")
text(rpart_model, use.n=TRUE, all=TRUE, cex=.8)

detach(mydata)