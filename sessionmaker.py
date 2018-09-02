import pandas as pd
import numpy as np 
import re
import datetime
from itertools import tee, islice, chain, izip
from dateutil.parser import parse

############## Import Raw datafile ##############
#%cd "/Users/coreyjackson/Dropbox/INSPIRE/Papers & Presentations/Anonymous Work/Analysis/Higgs Hunters/Archive"
raw_data = pd.read_csv('GravitySpyClassifications.csv') # CHANGE NAME OF .CSV FILE
anon_population =raw_data 

anon_population['datetime'] = pd.to_datetime(anon_population['time'])
anon_population = anon_population.sort_values(['userID','datetime'], ascending=[1, 1])
anon_population['same_name'] = anon_population['userID'].shift() == anon_population['userID']
anon_population['datetime2'] = anon_population['datetime'] 
anon_population.datetime2 = anon_population.datetime2.shift(1)
anon_population['datetime'] = pd.to_datetime(anon_population['datetime'])
anon_population['datetime2'] = pd.to_datetime(anon_population['datetime2'])
anon_population['timespent'] = anon_population['datetime2'] - anon_population['datetime']

time = anon_population['timespent']
time_sec = []
for i in time:
  timeseconds = i.total_seconds()
  time_sec.append(timeseconds)
anon_population['Time_Seconds'] = time_sec
anon_population['Time_Seconds'] = anon_population['Time_Seconds']*(-1)

# Function for iterating 
def previous_and_next(some_iterable):
    prevs, items, nexts = tee(some_iterable, 3)
    # prevs = chain([None], prevs)
    prevs = chain([0], prevs)
    next# s = chain(islice(nexts, 1, None), [None])
    nexts = chain(islice(nexts, 1, None), [0])
    return izip(prevs, items, nexts)

# Count through the number of annotation by ip address
ip = anon_population['userID']
classification_no = []
for previous, item, nxt in previous_and_next(ip):
  if item == previous:  	
	classification = classification + 1
	classification_no.append(classification)
   # print "Item is now", item, "next is", nxt, "previous is", previous
  else:
	classification = 1
	classification_no.append(classification)
anon_population['Classifications'] = classification_no

# Loop to iterate and create session variable by ip address
time = anon_population['Time_Seconds']
ip = anon_population['userID']
same = anon_population['same_name']
session_no = []
session = 1
for i,j,l,m,n in zip(ip, ip[1:], time, time[1:],same):
  #print i,j,l,m,n
  if n == True and l <= 1800:
    session = session
    session_no.append(session)
  elif n == True and l > 1800: 
    session = session + 1
    session_no.append(session)
  else :  
    session = 1
    session_no.append(session)
          
# Add one element to beginning of list. Required for appending list
session_no.extend([1])
del anon_population['datetime2']
# Paste list to anon_population dataframe 
anon_population['Session'] = session_no
#anon_population.Session = anon_population.Session.shift(-1)

### Get gold data
#golddata = anon_population.loc[anon_population.GoldLabel.notnull()]

# Sort dataframe by user, gold, by date
#golddata = golddata.sort_values(['userID','datetime'], ascending=[1,1])

#ip = golddata['userID']
#gold_no = []
#for previous, item, nxt in previous_and_next(ip):
#  if item == previous:    
#        gold = gold + 1
#        gold_no.append(gold)
#  else:
#        gold = 1
#        gold_no.append(gold)
#golddata['Gold_Seq'] = gold_no

#list(golddata.columns.values)

#golddata = golddata.drop(golddata.columns[0:8],axis=1)
#cols = [1,3,4,5,6,8]
#golddata.drop(golddata.columns[cols],axis=1,inplace=True)
#anon_population = pd.merge(anon_population, golddata, how='left', on=['userID', 'Classifications'])

### Add classification order for loggedin
#anon_population['datetime'] = pd.to_datetime(anon_population['datetime'])
#anon_population = anon_population.sort_values(['user_anon','datetime'], ascending=[1, 1])

#del classification_no

#ip2 = anon_population['user_anon']
#session2 = anon_population['Session']
#classification_no = []
#classification = 1
#for i,j,l,m in zip(ip2, ip2[1:], session2,session2[1:]):  
#    if i == j and l == m:
#        classification = classification + 1
#        classification_no.append(classification)
#    else:
#        classification = 1
#        classification_no.append(classification)
#a = 1
#classification_no = [a] + classification_no
#anon_population['SessionLoggedInClassification'] = classification_no


# Export dataframe
anon_population.to_csv('GravitySpy_LoggedinIdentified.csv') #Change File name to project name. 
