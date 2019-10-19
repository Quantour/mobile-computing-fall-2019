# Data models -  Wanderlust #

## User ##
field | type
------------ | -------------
User ID | String
Username | String
profile picture | [URL to Image?]
expertise | Integer from 1 to 5

## Pin ##
field | type
------------ | -------------
Pin ID | String
location | (latitude, longitude) [int,double...?]
type | one of {picture point, water fountain, restroom, restaurant, resting place}
*Alternatively*: type | subset of {picture point, water fountain, restroom, restaurant, resting place}


## Hiking Route ##

#required, final, only editable by Creator


field | type
------------ | -------------
Route ID | String
Creator/User ID | String
route information | List of (longitude, latitude)
timestamp, when created|  [Integer (UNIX Style time stamp)?]

#optional, changeable, editable by everyone

field | type
------------ | -------------
description|	String
tips & tricks|	String
images|	[List of URLs to Images?]


#not directly visible information by user

field | type
------------ | -------------
user rating| 	List of {user ID: String, rating: Integer from 1 to 5}
difficulty rating| List of {user ID: String, difficulty: Integer from 1 to 5}
time estimation| List of {user ID: String, Time: [Integer in seconds (UNIX Style time unit)?]}

#derived information

field | type
------------ | -------------
average rating| floating point number from 1.0 to 5.0
average difficulty| floating point number from 1.0 to 5.0
average time| [Integer in seconds (UNIX Style time unit)?]
length of route| Integer in meter
steepness (either difference from lowest to highest or more sophisticated metric)| Integer in meter
nearest city (City, Country)| (String, String)
*For later extension of the project if sufficient time left*: Q&A section/community board|  List of (List of Messages {User ID: String, message: String}), where first message is the start of a new thread or the question and all other messages are answers.



## My Hikes ##

```diff
! Not discussed yet with the group:
```

my time, my (user-/difficulty-)rating, ID of route

save for each user, so he can have a list of his activities
-> [Dont safe here](#not-directly-visible-information-by-user)

