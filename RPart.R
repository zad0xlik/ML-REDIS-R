install.packages('rattle')
install.packages('rpart.plot')
install.packages('RColorBrewer')
install.packages('xlsx')

library(rattle)
library(rpart.plot)
library(RColorBrewer)
library(xlsx)

setwd("/Professional/CODES") # set dir
mydata <- read.xlsx("Workbook.xlsx", 1) # change tabs
mydata <- mydata[1:40,]

attach(mydata)

rpart_model <- rpart(qty ~ call_option_symbol + call_bid_ask_size, data=mydata, method="class",control=rpart.control(minsplit=20, cp=0))
par(mfrow = c(1,2), xpd = TRUE)

##attributes(rpart_model)
print(rpart_model)
##plot(rpart_model, uniform=T)
fancyRpartPlot(rpart_model, uniform=TRUE, main="Classification Tree for Optionsnapshot")
text(rpart_model, use.n=TRUE, all=TRUE, cex=.8)

detach(mydata)