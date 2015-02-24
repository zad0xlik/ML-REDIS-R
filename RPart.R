##install.packages('rattle')
##install.packages('rpart.plot')
##install.packages('RColorBrewer')
##install.packages('xlsx')
##install.packages('party')
##install.packages('randomForest')
install.packages ("RPostgreSQL")
install.packages ("DBI")

library (RPostgreSQL)
library (DBI) # These first two packages are for building connection with PostgreSQL
library(rattle)
library(rpart.plot)
library(RColorBrewer)
library(xlsx)
library(party)
library(strucchange) # For the sctest function to extract p-values (see help for ctree and sctest)
library(randomForest) # readme - rfNews()


# <<<<<<< e5f0a1411120735bcbe2f9edca01c178e6d90b49
# setwd("/Professional/CODES") # set dir
# mydata <- read.xlsx("Workbook.xlsx", 1) # change tabs
# mydata <- mydata[1:40,]
# 
# attach(mydata)
# 
# rpart_model <- rpart(qty ~ call_option_symbol + call_bid_ask_size, data=mydata, method="class",control=rpart.control(minsplit=20, cp=0))
# par(mfrow = c(1,2), xpd = TRUE)
# 
# ##attributes(rpart_model)
# print(rpart_model)
# ##plot(rpart_model, uniform=T)
# fancyRpartPlot(rpart_model, uniform=TRUE, main="Classification Tree for Optionsnapshot")
# text(rpart_model, use.n=TRUE, all=TRUE, cex=.8)
# 
# detach(mydata)

drv = dbDriver("PostgreSQL")
hashed1 <- scrypt::hashPassword("Ready2go")
scrypt::verifyPassword(hashed1, "Ready2go")
con = dbConnect(drv, user = "ppei", password = "Ready2go", dbname = "QTRACK", host = "50.168.76.47", port = 5432)

setwd("/Professional/CODES/r_anomaly_detect")
mydata <- read.xlsx("tree_1.xlsx", 1) # change tabs
##mydata <- mydata[1:46,]

attach(mydata)

##############################################################################################################
##Regression Tree
##############################################################################################################
rpart_model1 <- rpart(oi ~ strike + dte + volume, data = mydata, control = rpart.control(minsplit=20, cp = 0))

##printcp(rpart_model) # display the results 
##plotcp(rpart_model1) # visualize cross-validation resultss
summary(rpart_model1) # detailed summary of splits

rpt <- printcp(rpart_model1)

fancyRpartPlot(rpart_model1, uniform=TRUE, main="Classification Tree for Optionsnapshot")
text(rpart_model1, use.n=TRUE, all=TRUE, cex=.6)
dbWriteTable(con, "regressiontree", rpt, append=T, row.names=F)
dbDisconnect(con)

##############################################################################################################

##############################################################################################################
##Conditional Inference Tree
##############################################################################################################

##ppei to fix
ctree_model2 <- ctree(oi ~ strike + dte + volume, data = mydata, ctree_control(maxsurrogate = 3))
summary(ctree_model2)

plot(ctree_model2, main="Conditional Inference Tree")
text(ctree_model2, use.n=TRUE, all=TRUE, cex=.8)
table(predict(ctree_model2), strike)


##############################################################################################################
##Random Forest 
##############################################################################################################

rf_model3 <- randomForest(
      oi ~ strike + dte + volume
    , data = mydata
    , ntree=500
    , keep.forest=FALSE
    , importance=TRUE)

print(rf_model3)      # view results 
importance(rf_model3) # importance of each predictor

plot(rf_model3, log='y')
varImpPlot(rf_model3)

set.seed(1)
rf_model4 <- randomForest(
      oi ~ strike + dte + volume
    , data=mydata
    , proximity=TRUE
    , keep.forest=FALSE)

##ppei to make mds plot working
##MDSplot()


detach(mydata)


# Interatively prune the tree
##new.rpart_model1 <- prp(rpart_model1,snip=TRUE)$obj # interactively trim the tree
##prp(rpart_model1) # display the new tree

##conventional way of plotting
##plot(rpart_model, uniform=TRUE, main="name of graph")
##text(rpart_model, use.n=TRUE, all=TRUE, cex=.8)
##>>>>>>> d1e5c037a0fd370dc2b7ac30dfd1bd4433d6fb4a
