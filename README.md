# U.S-Flight-Patterns-
Mapping out the fastest and slowest flight carriers and departure destinations in the U.S. 

In 2015, FiveThirtyEight, a data journalism website, analyzed over six million flights domestic flights in the United States. The goal of their analysis was to find the fastest airline on any particular route (i.e. Houston to Los Angeles) and determine the best-and-worst performing airlines and airports.

Under slightly different motivation, we built a logistic regression model tracking the probability that a flight is delayed by at least fifteen minutes using U.S. domestic flight data from the U.S. Department of Transportation in June 2016. The response (departure delay of fifteen minutes) is a binary variable taking on a 0 (not delayed fifteen minutes) or 1 outcome (delayed fifteen minutes). The predictor variables for this model are the day of the week, flight distance, airline carrier, and the origin airport.

The model is split into training and testing datasets as a measure for cross-validation. We found that the unique carrier (i.e. airline) and the flight distance were the most predictive variables in the model according to the variable importance feature that returns scaled results in the range of 0 to 100 (Figure 1 below).

According to Bloomberg, a business website, carrier delays exceeded weather delays and delays in the air traffic system for the first time in 2016. Carrier delays are most often caused by a late arriving aircraft (39.2%), a carrier delay such as a lack of flight crew (32.6%), or a national aviation system delay (23.7%). Another more recent element to flight delays are computer glitches that continue to ground thousands of passengers each year ranging giving airlines including Delta Airlines and United Airlines bad PR.

To a lesser degree, the origin airport and the day of the week also play a role in getting a fifteen-minute delay. Flights departing from Los Angeles (LAX) or New York City (LaGuardia) are far more prone to fifteen-minute delays than smaller market airports such as Cincinnati or San Diego.
