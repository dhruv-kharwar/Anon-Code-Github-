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

# create anon/non anon datasets
geordi_anonymous <- geordi[which(geordi$userID == "(anonymous)"),] # create dataset with only anonymous
geordi_nonanonymous <- geordi[which(geordi$userID != "(anonymous)"),]
remove(geordi)
geordi_anonymous <- merge(geordi_anonymous,unique_ips, by="clientIP", all.x=TRUE) # puts userIDs next to events associated with one userID

# rename/remove columns in both datasets
names(geordi_anonymous)[4]<-"userID" # rename columns
names(geordi_anonymous)[10]<-"userID_a"
geordi_anonymous <- geordi_anonymous[,-c(9)] # remove column
geordi_nonanonymous$userID_a <- geordi_nonanonymous$userID # adds userID to columns to make datasets the same length

geordi <- rbind(geordi_anonymous,geordi_nonanonymous) #Combine anon/non anon events
remove(geordi_anonymous,geordi_nonanonymous,unique_combination) # remove unnecessary dataframes

#
# Munging event data
#


# These are all the high-level event
#  [1] "classify"                "login"                   "register-link"           "talk-view"              
#  [5] "view-profile-sidebar"    "project-menu"            "close-field-guide"       "open-field-guide"       
#  [9] "profile-menu"            "metadata"                "change-page"             "footer-menu"            
# [13] "top-menu"                "register"                "view-discussion"         "view-profile-author"    
# [17] "collect-menu"            "about-menu"              "change-project-sidebar"  "hashtag-sidebar"        
# [21] "subject-image"           "discussion-time"         "breadcrumb"              "view-subject-direct"    
# [25] "reply-post"              "search"                  "tutorial-completion"     "search-back"            
# [29] "interventionStart"       "recent-comments-sidebar" "like-post"               "classificationStart"    
# [33] "globe-menu"              "link-post"               "favorite"                "edit-post"              
# [37] "update-comment"          "new-discussion"          "add-comment"             "logout"                 
# [41] "delete-post"             "unfavorite"              "subscribe"               "message-user"           
# [45] "send-message"            "report-post"             "experimentStart"         "mini-course-completion" 

# 637 relatedIDs
# 9533 data: includes search terms


# concatenate events data
geordi$new.categories <- paste(geordi$type, geordi$relatedID, geordi$data, sep="-")

# get unique events to determine activity
events <- unique(geordi[c("type","new.categories")])

# remove highlevel events not needed for analysis
events <- events[which(!events$type %in% c("experimentStart",)),]

           
#  [9]                                         "footer-menu"            
# [13] "top-menu"                "register"                "view-discussion"         "view-profile-author"    
# [17] "collect-menu"            "about-menu"              "change-project-sidebar"  "hashtag-sidebar"        
# [21] "subject-image"           "discussion-time"         "breadcrumb"              "view-subject-direct"    
# [25] "reply-post"              "search"                  "tutorial-completion"     "search-back"            
# [29] "interventionStart"       "recent-comments-sidebar" "like-post"               "classificationStart"    
# [33] "globe-menu"              "link-post"               "favorite"                "edit-post"              
# [37] "update-comment"          "new-discussion"          "add-comment"             "logout"                 
# [41] "delete-post"             "unfavorite"              "subscribe"               "message-user"           
# [45] "send-message"            "report-post"             ""         "mini-course-completion" 

investigate high-level
"project-menu"
"view-profile-sidebar"
"profile-menu" 
"metadata"
"change-page"



