library(data.table)
library(csv)
setwd('/home/labuser/cloudera/src_analysis/processData')
DRGdf <- read.csv('Medicare_Provider_Charge_Inpatient_DRG100_FY2011_parsed.csv')
APCdf <- read.csv('Medicare_Provider_Charge_Outpatient_APC30_CY2011_v2_parsed.csv')
names(DRGdf) <-c('Procedure.Id', 'Provider.Id', 'Region', 'Services', 'Cost', 'Payments')
names(APCdf) <- c('Procedure.Id', 'Provider.Id', 'Region', 'Services', 'Cost', 'Payments')
DRGdf$APC <- 0
DRGdf$DRG <- 1
APCdf$APC <- 1
APCdf$DRG <- 0
df <- rbind(DRGdf, APCdf)
df$TotalCost <- df$Services * df$Cost
df$TotalPayments <- df$Services * df$Payments
DT <- data.table(df)
aggDf <- DT[, j = list(sumServices = sum(Services),sumTotalCost = sum(TotalCost),varCost = var(Cost), 
                       sumTotalPayments = sum(TotalPayments), sumAPC = sum(APC), sumDRG = sum(DRG),
                       sumProc = sum(APC)+sum(DRG)), by = 'Region']
aggDf <- na.omit(aggDf)
Region.names = as.vector(aggDf$Region)
##plot to sumTotalCost vs all other features 4 graphs
aggDf$state <- substring(Region.names, 1, 2)



# mydata<-subset(aggDf, state == 'MA', select = c('sumServices','sumTotalCost','varCost','sumTotalPayments','sumAPC','sumDRG','sumProc'))
# mydata.names <- subset(aggDf, state == 'MA', select = c('Region'))

mydata<-subset(aggDf, select = c('sumServices','sumTotalCost','varCost','sumTotalPayments','sumAPC','sumDRG','sumProc'))
mydata.names <- subset(aggDf,  select = c('Region'))

dim(mydata)
data <- scale(mydata)


# Determine number of clusters
wss <- (nrow(data)-1)*sum(apply(data,2,var))
for (i in 2:40) wss[i] <- sum(kmeans(data, centers=i)$withinss)
plot(1:40, wss, type="b", xlab="Number of Clusters", ylab="Within groups sum of squares")

fit <- kmeans(data, 35) 
aggregate(data,by=list(fit$cluster),FUN=mean)
data <- data.frame(data, fit$cluster)

library(cluster)
#row.names(mydata) <- paste(substring(names, 1, 2), seq(1, length(names)), sep = '')
#row.names(mydata) <- seq(1,length(data$fit.cluster))
row.names(mydata) <- mydata.names$Region
clusplot(mydata, data$fit.cluster, diss = FALSE,
         stand = FALSE,
         lines = 2, shade = FALSE, color = FALSE,
         labels= 2, plotchar = TRUE,
         span = TRUE,
         add = FALSE,
         xlim = NULL, ylim = NULL,
         main = paste("CLUSPLOT(", deparse(substitute(x)),")"),
         xlab = "Component 1", ylab = "Component 2",
         verbose = getOption("verbose")
)
