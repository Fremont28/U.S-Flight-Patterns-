#12/21/18 

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler

flights=pd.read_csv("flights_us.csv")
flights.describe() 
flights.info() 

flights['ORIGIN_AIRPORT_ID'].head(3)
flights.REGION.unique() 

def class_seats(x):
    if x=="F":
        return 1
    if x=="L":
        return 2
    if x=="G":
        return 3
    if x=="P":
        return 4 

def region_score(x):
    if x=="D":
        return 1
    if x=="I":
        return 2
    if x=="L":
        return 3
    if x=="A":
        return 4
    if x=="P":
        return 5
    if x=="nan":
        return 6 

flights['class_score']=flights['CLASS'].apply(class_seats)
flights['region_score']=flights['REGION'].apply(region_score)

#passenger to available seat ratio 
flights['pass_seat']=flights['PASSENGERS']/flights['SEATS']

#outlier removal 
flights1=flights[~(np.abs(flights.pass_seat-flights.pass_seat.mean())>(2*flights.pass_seat.std()))]

flight_features=flights1[["DISTANCE","AIR_TIME","AIRLINE_ID","region_score","ORIGIN_AIRPORT_ID","DEST_AIRPORT_ID",
"MONTH","class_score","pass_seat"]]

flight_features.head(2)
flight_features.pass_seat.describe() 

#classification passenger to seat ratio****** 
def pass_seat_func(x):
    if x>=0.90:
        return 1 
    if x<0.90 and x>=0.70:
        return 2
    if x<0.70 and x>=0.50:
        return 3
    if x<0.50 and x>=0.30:
        return 4
    if x<0.30:
        return 5 

flight_features['pass_seat_class']=flight_features['pass_seat'].apply(pass_seat_func)
flight_features.info() 
flight_features=flight_features.fillna(0)

#convert integer to categorical 
flight_features['AIRLINE_ID']=flight_features['AIRLINE_ID'].astype('category')
flight_features['ORIGIN_AIRPORT_ID']=flight_features['ORIGIN_AIRPORT_ID'].astype('category')
flight_features['DEST_AIRPORT_ID']=flight_features['DEST_AIRPORT_ID'].astype('category')

#one-hot encoding?
from sklearn.preprocessing import LabelBinarizer
from sklearn.preprocessing import OneHotEncoder

#label binarizer 
one_hot_data=flight_features[["AIRLINE_ID","ORIGIN_AIRPORT_ID","DEST_AIRPORT_ID"]]
encoder=OneHotEncoder(handle_unknown="ignore")
encoder.fit(one_hot_data)

#######
flight_features1=flight_features[["DISTANCE","AIR_TIME","region_score","MONTH","class_score","pass_seat_class"]]

X=flight_features1.iloc[:,0:flight_features.shape[1]-1]
y=flight_features[["pass_seat_class"]]
X_train,X_test,y_train,y_test=train_test_split(X,y,test_size=0.30,random_state=101)

#******* 
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score 

#a. score accuracy 
rf=RandomForestClassifier(n_estimators=115,oob_score=True,random_state=3244323)
rf.fit(X_train,y_train)
predict_scores=rf.predict(X_test)
accuracy=accuracy_score(y_test,predict_scores)

#b. passenger to seat ratio probability
probs=rf.predict_proba(X_test)


































