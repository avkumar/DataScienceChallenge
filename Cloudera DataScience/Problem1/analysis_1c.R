library(data.table)
library(csv)
library(plyr)

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
dt <- data.table(df)

aggDf <- dt[, j = list(avg = sum(TotalCost)/sum(Services)), by = c('Region', 'Procedure.Id')]
aggDf$count <- 1
dmax = ddply(aggDf,~Procedure.Id,function(x){x[which.max(x$avg),]})
dmax = data.table(dmax)
aggDfmax <- dmax[, j = list(total = sum(count)), by = 'Region']
aggDfmax[order(aggDfmax$total),]
