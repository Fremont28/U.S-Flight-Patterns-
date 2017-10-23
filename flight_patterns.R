# U.S. domestic flights June, 2016
flights_ml<-read.csv(file.choose(),header=TRUE)
save(flights_ml, file="flights_ml.RData")
load(file="flights_ml.RData")

#libraries
library(dplyr)
library(plyr)
library(ggplot2)

# create testing and training datasets
smp_size <- floor(0.7 * nrow(flights_ml)) #sample size
set.seed(123) # replication
train_ind <- sample(seq_len(nrow(flights_ml)),size=smp_size)
train <- flights_ml[train_ind,]
test <- flights_ml[-train_ind,]

#subset testing and training datasets
train1<-subset(train,select=c(DAY_OF_WEEK,ORIGIN_AIRPORT_ID,DISTANCE,AIRLINE_ID,DEP_DEL15,ORIGIN,UNIQUE_CARRIER,ORIGIN_CITY_NAME))
test1<-subset(test,select=c(DAY_OF_WEEK,ORIGIN_AIRPORT_ID,DISTANCE,AIRLINE_ID,DEP_DEL15,ORIGIN,UNIQUE_CARRIER,ORIGIN_CITY_NAME))
#convert 15 minute departure delay binary variable (0,1) to a factor
train1$DEP_DEL15<-as.factor(train1$DEP_DEL15)
test1$DEP_DEL15<-as.factor(test1$DEP_DEL15)

#logistic regression model (predict if the flight is delayed by 15 minutes (0,1 outcome)
log_model<-glm(DEP_DEL15~DAY_OF_WEEK+ORIGIN_AIRPORT_ID+DISTANCE+AIRLINE_ID,family=binomial,data=train1)

# Checking logistic regression model conditions
library(pscl)
pR2(log_model)
#variable importance
library(caret)
varImp(log_model)
#wald test
library(survey)
regTermTest(log_model,'ORIGIN_AIRPORT_ID')
regTermTest(log_model,'DAY_OF_WEEK')
#classification rate
pred=predict(log_model,newdata=test1)
accuracy<-table(pred,test1[,"DAY_OF_WEEK"])
sum(diag(accuracy))/sum(accuracy)
#predict the probability of a 15 minute delay from the model
train1$predict_dep15<-predict(log_model,train1,type="response")
test1$predict_dep15<-predict(log_model,test1,type="response")
#slowest and fastest airport origin (mean departure delays)
airport_delays<-ddply(test1,~ORIGIN_CITY_NAME,summarise,mean=mean(predict_dep15))
#count the number of 15 minute delays by the origin
city_count_delays<-flights_ml %>%
  group_by(ORIGIN_CITY_NAME,DEP_DEL15) %>%
  summarise(n=n()) %>%
  mutate(freq=n/sum(n))
# count the number of 15 minute delays by the origin (airports with greater than 1,500 monthly flights)
city_count_delays1<-subset(city_count_delays,n>1500,select=c(1,2,3,4))
city_count_delays2<-subset(city_count_delays1,DEP_DEL15==1,select=c(1,2,3,4))
# plot the percentage of flights delayed by fifteen minutes (by airport)
v1<-ggplot(city_count_delays2, aes(x = reorder(ORIGIN_CITY_NAME, -freq), y = freq)) +
  geom_bar(stat = "identity")+coord_flip()+xlab("City")+ylab("Percent of Flights Delayed by Fifteen Minutes")+ggtitle("Don't Fly Out of Dallas")+
  theme(plot.title = element_text(hjust = 0.5))
require("gridExtra")
grid.arrange(arrangeGrob(v1))
#merge the probability of a 15 minute delay and the acutal percentage of 15 minute delays (by airport)
g1<-merge(city_count_delays2,airport_delays,by="ORIGIN_CITY_NAME")
g1$diff<-g1$mean-g1$freq
v2<-ggplot(g1, aes(x = reorder(ORIGIN_CITY_NAME, -diff), y = diff)) +
  geom_bar(stat = "identity")+coord_flip()+xlab("City")+ylab("Difference")+ggtitle("Minneapolis Minimizes Departure Delays")+
  theme(plot.title = element_text(hjust = 0.5))
require("gridExtra")
grid.arrange(arrangeGrob(v2))
# find the slowest and fastest carriers
carrier_delay<-ddply(test1,~UNIQUE_CARRIER,summarise,mean=mean(predict_dep15))
#count the number/frequency of 15 minute delays by the carrier
carrier_count_delays<-flights_ml %>%
  group_by(UNIQUE_CARRIER,DEP_DEL15) %>%
  summarise(n=n()) %>%
  mutate(freq=n/sum(n))
carrier_count_delays1<-subset(mergeCarrier,DEP_DEL15==1,select=c(1,2,3,4))
#probability of a 15 minute departure delay by the carrier
p3 <- ggplot(carrier_count_delays1, aes(x = reorder(UNIQUE_CARRIER, -mean), y = mean)) +
  geom_bar(stat = "identity")+coord_flip()+
  xlab("Carrier")+ylab("Probability of a 15 Minute Departure Delay")+ggtitle("Virgin Airlines is the Fastest in Our Model")+
  theme(plot.title = element_text(hjust = 0.5))
require("gridExtra")
grid.arrange(arrangeGrob(p3))
#merge carrier dataframes (number of flights per carrier and the predicted probability of q 15 minute delay)
mergeCarrier<-merge(carrier_delay,carrier_count_delays,by="UNIQUE_CARRIER")
mergeCarrier$diff<-(mergeCarrier$freq)-(mergeCarrier$mean)
sub_carrier<-subset(mergeCarrier,DEP_DEL15==1,select=c(UNIQUE_CARRIER,diff))
#plot the difference between the probability and the actual percentage of flights delayed by 15 minutes
p2 <- ggplot(sub_carrier, aes(x = reorder(UNIQUE_CARRIER, -diff), y = diff)) +
  geom_bar(stat = "identity")+coord_flip()+scale_fill_manual(values = c("HA" = "red"))+
  xlab("Difference")+ylab("Carrier")+ggtitle("Hawaiian Airline Flights Leave On Time")+
  theme(plot.title = element_text(hjust = 0.5))
require("gridExtra")
grid.arrange(arrangeGrob(p2))
#count the number of carriers
airline_count<-flights_ml%>%
  group_by(UNIQUE_CARRIER) %>%
  summarise (n = n()) %>%
  mutate(freq = n / sum(n))
#count the origin destination
origin_count<-flights_ml %>%
  group_by(ORIGIN_CITY_NAME,DEP_DEL15) %>%
  summarise(n=n()) %>%
  mutate(freq=n/sum(n))
# subset flights dataset
x1<-subset(flights_ml,select=c(ORIGIN_CITY_NAME,CARRIER_DELAY))
x2<-na.omit(x1)
#airports with the most carrier delays
airport_carrier_delays<-ddply(x2,~ORIGIN_CITY_NAME,summarise,mean=mean(CARRIER_DELAY))
# average flight distance from U.S. airport origin
airport_distance<-ddply(flights_ml,~ORIGIN_CITY_NAME,summarise,mean=mean(DISTANCE))
merge<-merge(origin_count,airport_distance1,by="ORIGIN_CITY_NAME")

ggplot(merge,aes(x=n,y=mean))+geom_point()+
  xlab("Flights in June 2016")+ylab("Average Distance (miles) From Origin")
merge1<-merge(origin_count,airport_carrier_delays,by="ORIGIN_CITY_NAME")

ggplot(merge1,aes(x=n,y=mean))+geom_point()+
  xlab("Flights in June 2016")+ylab("Average Carrier Delay (minutes) From Origin")

## origin and carrier counts
city_carrier<-flights_ml %>%
  group_by(ORIGIN_CITY_NAME,UNIQUE_CARRIER) %>%
  summarise(n=n()) %>%
  mutate(freq=n/sum(n))

city_carrier1<-subset(city_carrier,UNIQUE_CARRIER=="VX",select=c(1,2,3,4))

#carrier delay by day of the week
e<-subset(flights_ml,select=c(DISTANCE_GROUP,DEP_DELAY))
e1<-na.omit(e)
day_of_week_delays<-ddply(e1,~DISTANCE_GROUP,summarise,mean=mean(DEP_DELAY))
