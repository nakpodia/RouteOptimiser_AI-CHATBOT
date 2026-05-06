CODE EXPLANATION- ROUTE OPTIMISER
Author: CLINTON NAKPODIA
Date: 2026-04-13
Introduction to the Salesman Problem
They are different approach to solving thee TSP, the whole goal is simply looking for the best possible shortest route to go around different cities and return to the first initial city.
Approaches
Heuristic Approach
Heuristic: English definition.
the first and the most common one is the Heuristic approach
Symmetric TSP
Asymmetric TSP
DATA
r
#----loading my data------
datf <- (read.csv('Book1.csv'))
the data I'm using contains three variables, Post code, longitude and Lattitude
Post Codes  
because the salesman problem has to do with optimizing the nearest distance of location, it cannot use just the postcode to ascertain the distance from other relative postcodes. Hence why it is important to get the exact locations using the Longitude nd latitude
CHATGPT: Post code Example: DE22 2QE, NG9 4FG
This is just an identifier (label) for each location
TSP itself doesn’t use it for calculation
But it’s very important for output (so you know which place is which)
Longitude  
this represents how far East/west a location is
Latitude  
this represents how far north south a location is.
The Haversine Formula
The Haversine formula is the mathematical equation used to calculate the shortest distance between two points on the surface of a sphere (like Earth), using their latitude and longitude.
this is A mathematical function and what we are bassically doing in R is representing and writing this formular in R.
r
# ---- Haversine distance ----
dist_haversine <- function(loc1, loc2) {
  lat1 <- loc1[2]; lon1 <- loc1[1]
  lat2 <- loc2[2]; lon2 <- loc2[1]
  toRad <- function(d) d * pi / 180
  R <- 6371
  a <- sin(toRad(lat2 - lat1) / 2)^2 +
    cos(toRad(lat1)) * cos(toRad(lat2)) * sin(toRad(lon2 - lon1) / 2)^2
  R * 2 * atan2(sqrt(a), sqrt(1 - a))
}
#---1.0
Haversine (Code Explanation)
from the above code, We first called the function in R(inbuilt) and then we assign it a name. here Dist_H. is a function of two variables (locations) in our data set Loc1 and Loc2.
since a location say X is a function of two points longitude and latitude and it is given in the form X(long, lat). we assign this to R by naming Lat to be first function [1] and lon to be second function [2].
the 'function(d)' is there is a degree degree function in R, so what we are bassically telling to do in this case is to convert any where degree is to Radians since to make all units same and avoid unit errors.
the last bit of the code is just the Haversine mathematical function.
Distance Matrix (Code Explanation)
r
#-----Distance matrix
dist_haversine_n <- function(long_lat_mat) {
  n <- nrow(long_lat_mat)
  dist_mat <- matrix(0, nrow = n, ncol = n)
  for (i in seq_len(n))
    for (j in seq_len(n))
      dist_mat[i, j] <- dist_haversine(as.numeric(long_lat_mat[i, ]),
                                       as.numeric(long_lat_mat[j, ]))
  dist_mat
}
#----1.1
Explanation
There is a need to create a matrix because mathematically speaking, this shows the relationship between numbers in this case distance.
the above code in summary creates a distance matrix; basically creating and linking all the distance in a matrix form so you can see individual distances of this matrix.
note that this is an empty matrix and has no values yet. it just tells R that "create a 2xn matrix (long and lat) and assign it a name. i will give you the values later"
SOLVING THE TSP
This TSP problem in makinf thos app will be solved by the TSP library. the TSP library can autoomatically solve using any of the methods as far as a distance matric amongst others can be provided. IO am yet to braoden my knowledge on the capabilities of the TSP package.
The whole idea im going to be implementing on this app is creating a means for users to select the exact method in which he/she or... wants to use and the TSP package solves using the selected method.
Describing The Methods
the various methods we will be using involves different Heuristics approach
r
# ---- Method descriptions ----
method_descriptions <- list(
  nearest_insertion   = "Nearest Insertion builds the route by repeatedly inserting the closest unvisited city.",
  farthest_insertion  = "Farthest Insertion starts with the two furthest cities and inserts the farthest remaining city each step.",
  cheapest_insertion  = "Cheapest Insertion always inserts the city that increases the total tour length the least.",
  arbitrary_insertion = "Arbitrary Insertion picks random cities to insert, then optimises position.",
  nn                  = "Nearest Neighbour (greedy) always travels to the closest unvisited city next.",
  repetitive_nn       = "Repetitive Nearest Neighbour runs the NN heuristic from every starting city and keeps the best tour.",
  two_opt             = "Two-Opt improves an existing tour by swapping pairs of edges to remove route crossings."
)
#---2.0
the code above showa the diffrent Heuristics approach, Heuristc in general justs picks the nearest city (lazy and not very optimal); these aproaches just shows diffrent ways at which these nearest cities are picked.
MY CHATBOT
The Chat bot basically is going to handle basic Help to user(not very sophisticated YET! haha) its going to assist the user on things like definiong what each methods does, define terms, talk about the routes and postodes etc ...
r
# ---- Chatbot response logic ----
chatbot_response <- function(user_msg, n_postcodes, method, total_km) {
  msg <- tolower(trimws(user_msg))
  
  if (grepl("^(hi|hello|hey|good morning|good afternoon|good evening)", msg)) {
    return("Hello! I am the **UK Route Optimiser Bot**. I help you find the shortest delivery route across East Midlands postcodes using the Travelling Salesman Problem (TSP).\n\nTry asking:\n- How many postcodes should I use?\n- Which method is best?\n- What is the current route distance?\n- Explain nearest neighbour")
  }
  
  ...
}
#----2.1
Breaking Down The Code
The general idea is to create a function that can handle pur parameters that we have defined in the past. the parameters already have values.
r
#--chatbot_response <- function(user_msg, n_postcodes, method, total_km) {x}---#
Function Structure
r
#--- if Z <- function(x,y) {
#---{plus <- x * y}
#----Return(plus)
#---}
This is the first part of our syntax of assinging a function to a variable, basically this part of the syntax gives our functions parameters to work with.
Parameter Logic
the above code is very important in our code. it basically a function of posible response that our chatbot can deliver. we must note that these parameters have been pre-caculated and we already have in our shinny app. this is just supplying it to the Chatbot to give posible responses bounded by these input.
Formatting User Input
r
msg <- tolower(trimws(user_msg))
this bassically formats the User_msg parameter and makes it lower case.
IF + GREPL Logic
r
if (grepl("^(hi|hello|hey|good morning|good afternoon|good evening)", msg)) {
  return("Hello! I am the **UK Route Optimiser Bot**...")
}
GREPL Explanation
r
grepl(pattern Y, X)
means check for pattern Y in X.
IF Syntax
r
if (grepl(pattern,X)){
  return(result)
}
Pattern Example
r
grepl("^(hi|hello|hey|good morning|good afternoon|good evening)", msg)
means check for the following words in msg.
'^' means beginning of sentence
'|' means OR
