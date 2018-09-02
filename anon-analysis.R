# Anonymous Work 

library(ggplot2)
library(plyr)
library(reshape2)
library(lubridate)
library(sqldf)
library(data.table)
#library(dplyr)       # consistent data.frame operations
library(ggthemes)    # has a clean theme for ggplot2
library(readr)
library(ggpubr)
library(RPostgreSQL)
library(gtools)
library(wesanderson)

# import datasets 
geordi <- read_csv("~/Dropbox/INSPIRE/Data/System dumps/geordi-1-5-17.csv") # The raw geordi dataet

# remove unnecessary columns 
geordi <- geordi[,-c(3,8,10:17,19)]


#
# Identifying anonymous events
#

# Find unique IP/user combinations
unique_combination <- unique(geordi[c("userID", "clientIP")])
unique_combination <- unique_combination[which(unique_combination$userID != "(anonymous)"),]

unique_ips <- ddply(unique_combination, c("clientIP"), summarise,
                    userids = length(unique(userID[which(userID != '(anonymous)')]))
                    )

# get IPs only associated with one user account
unique_ips <- unique_ips[which(unique_ips$userids == 1),]
# get their ids 
unique_ips <- merge(unique_ips, unique_combination, by ="clientIP",all.x = TRUE)

# get only anonymous from geordi data 
geordi_anonymous <- geordi[which(geordi$userID == "(anonymous)"),]
geordi_nonanonymous <- geordi[which(geordi$userID != "(anonymous)"),]
remove(geordi)
geordi_anonymous <- merge(geordi_anonymous,unique_ips, by="clientIP", all.x=TRUE)

# rename/remove columns
names(geordi_anonymous)[4]<-"userID"
names(geordi_anonymous)[10]<-"userID_a"
geordi_anonymous <- geordi_anonymous[,-c(9)]

geordi_nonanonymous$userID_a <- geordi_nonanonymous$userID

#Combine anon/non anon events
geordi <- rbind(geordi_anonymous,geordi_nonanonymous)
remove(geordi_anonymous,geordi_nonanonymous,unique_combination)


#
# Munging event data
#


# some activities can be removed e.g., type (login, logout)



