# UK ROUTE OPTIMISER + AI CHATBOT CODE EXPLANATION

![Status: Unfinished](https://img.shields.io/badge/Status-Unfinished-orange)

#### This document gives a brief, easy‑to‑follow overview of how the UK Route Optimiser works. It explains the key code components behind the Travelling Salesman Problem logic, postcode processing, route calculation, and the integrated chatbot. The goal is to help readers quickly understand the structure, purpose, and flow of the application.

----

### Introduction to the sales man problem (TSP)

They are different approach to solving thee TSP, the whole goal is simply looking for the best possible shortest route to go around different cities and return to the first initial city.

### Approaches

#### Heuristic Approach

Heuristic: English definition.

the first and the most common one is the Heuristic approach

#### Symetric TSP

#### Asymetric TSP

# DATA

``` r
#----loading my data------

datf <- (read.csv('Book1.csv'))
```

the data I'm using contains three variables, Post code, longitude and Lattitude

1. Post Codes because the salesman problem has to do with optimizing the nearest distance of location, it cannot use just the postcode to ascertain the distance from other relative postcodes. Hence why it is important to get the exact locations using the Longitude nd latitude
2.  Longitude: this represents how far East/west a location is
3.  Latitude: this represents how far north south a location is.

--

## The haversine formular

The Haversine formula is the mathematical equation used to calculate the shortest distance between two points on the surface of a sphere (like Earth), using their latitude and longitude.

this is A mathematical function and what we are bassically doing in R is representing and writing this formular in R.

``` r
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
```

### Haversine (Code Explanation)

from the above code, We first called the function in R(inbuilt) and then we assign it a name. here Dist_H. is a function of two variables (locations) in our data set Loc1 and Loc2.

since a location say X is a function of two points longitude and latitude and it is given in the form X(long, lat). we assign this to R by naming Lat to be first function [1] and lon to be second function [2].

the 'function(d)' is there is a degree degree function in R, so what we are bassically telling to do in this case is to convert any where degree is to Radians since to make all units same and avoid unit errors.

the last bit of the code is just the Haversine mathematical function.

### Distance Matrix (Code Explanation)

``` r

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
```

#### Explanation

There is a need to create a matrix because mathematically speaking, this shows the relationship between numbers in this case distance.

the above code in summary creates a distance matrix; basically creating and linking all the distance in a matrix form so you can see individual distances of this matrix.

note that this is an empty matrix and has no values yet. it just tells R that "create a 2xn matrix (long and lat) and assign it a name. i will give you the values later"


--
# SOLVING THE TSP

This TSP problem in makinf thos app will be solved by the TSP library. the TSP library can autoomatically solve using any of the methods as far as a distance matric amongst others can be provided. IO am yet to braoden my knowledge on the capabilities of the TSP package.

The whole idea im going to be implementing on this app is creating a means for users to select the exact method in which he/she or... wants to use and the TSP package solves using the selected method.

## Describing The Methods

the various methods we will be using involves different Heuristics approach

``` r
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
```

the code above showa the diffrent Heuristics approach, Heuristc in general justs picks the nearest city (lazy and not very optimal); these aproaches just shows diffrent ways at which these nearest cities are picked.

``` r
#--I NEED TO BREAK DOWN AND EXPLAIN THESE METHODS FOR MY INTERVIEWS--- 
```

# MY CHATBOT

The Chat bot basically is going to handle basic Help to user(not very sophisticated YET! haha) its going to assist the user on things like definiong what each methods does, define terms, talk about the routes and postodes etc ...

``` r
# ---- Chatbot response logic ----
chatbot_response <- function(user_msg, n_postcodes, method, total_km) {
  msg <- tolower(trimws(user_msg))
  
  if (grepl("^(hi|hello|hey|good morning|good afternoon|good evening)", msg)) {
    return("Hello! I am the **UK Route Optimiser Bot**. I help you find the shortest delivery route across East Midlands postcodes using the Travelling Salesman Problem (TSP).\n\nTry asking:\n- How many postcodes should I use?\n- Which method is best?\n- What is the current route distance?\n- Explain nearest neighbour")
  }
  
  if (grepl("help|what can you do|commands|options", msg)) {
    return("Here is what I can help with:\n\n**Route questions** - Ask about the current tour, distance, or postcodes.\n**Methods** - Ask me to explain any TSP algorithm.\n**Recommendations** - Ask which method or postcode count to try.\n\nUse the controls on the left to change settings and the map updates live!")
  }
  
  if (grepl("distance|km|kilomet|how far|tour length|total", msg)) {
    return(paste0("The current optimised tour covers **", total_km, " km** using **", title_case(method), "** across **", n_postcodes, " postcodes**."))
  }
  
  if (grepl("postcode|location|stop|city|node|point", msg)) {
    return(paste0("Currently **", n_postcodes, "** postcodes are selected at random from the East Midlands dataset (100 postcodes total). Try values between 5 and 30 for quick results, or up to 100 for a bigger challenge!"))
  }
  
  for (mkey in names(method_descriptions)) {
    pattern <- gsub("_", "[ _]?", mkey)
    if (grepl(pattern, msg)) {
      active <- if (method == mkey) " (currently active)" else ""
      return(paste0("**", title_case(mkey), "**", active, "\n\n", method_descriptions[[mkey]]))
    }
  }
  
  if (grepl("best method|recommend|which method|which algorithm|fastest|optimal", msg)) {
    return(paste0("**Method Recommendations:**\n\n- For **quality**: Repetitive Nearest Neighbour or Two-Opt give the shortest tours.\n- For **speed**: Nearest Neighbour is very fast.\n- For **balance**: Farthest Insertion performs well in practice.\n\nCurrently active: **", title_case(method), "**"))
  }
  
  if (grepl("how many|number of|recommend.*postcode|postcode.*recommend", msg)) {
    return(paste0("**Postcode count tips:**\n\n- **5-15** postcodes: Fast and easy to visualise.\n- **20-50** postcodes: Good for testing algorithm differences.\n- **50-100** postcodes: Computationally heavier.\n\nCurrently set to **", n_postcodes, "** postcodes."))
  }
  
  if (grepl("tsp|travelling salesman|traveling salesman|what is.*problem", msg)) {
    return("**The Travelling Salesman Problem (TSP)** asks: Given a list of cities and the distances between them, what is the shortest possible route that visits each city exactly once?\n\nIt is **NP-hard** - no known algorithm solves it perfectly for large inputs in polynomial time. This app uses **heuristic methods** that find good solutions quickly.")
  }
  
  if (grepl("haversine|distance formula|great.circle", msg)) {
    return("Distances are calculated using the **Haversine formula**, which computes the great-circle distance between two points on Earth given their latitude and longitude. This accounts for the Earth's curvature and is much more accurate than Euclidean distance for geographic routing!")
  }
  
  if (grepl("current.*method|active.*method|which.*method.*use", msg)) {
    return(paste0("The currently selected method is **", title_case(method), "**.\n\n", method_descriptions[[method]]))
  }
  
  if (grepl("who made|developer|author|about|credit", msg)) {
    return("This chatbot was converted from the original UKTSP Shiny app by Clinton Nakpodia, which used the TSP R-package by Michael Hahsler. The chatbot adds conversational guidance on top of the original route optimisation.")
  }
  
  return("I am not sure about that. Try asking:\n- The **current tour distance**\n- A specific **TSP method** (e.g. explain two opt)\n- **Recommendations** for method or postcode count\n- What the **TSP problem** is")
}


#----2.1
```

### Breaking Down The Code

The general idea is to create a function that can handle pur parameters that we have defined in the past. the parameters already have values.

``` r
#--chatbot_response <- function(user_msg, n_postcodes, method, total_km) {x}---#


#-----2.2
```

This is the first part of our syntax of assinging a function to a variable, basically this part of the syntax gives our functions parameters to work with, so a function is bassically like a code to be ran when ever that function name is called in ths case Chatbot_response. recall that;

``` r
#--- if Z <- function(x,y) {
#---{plus <- x * y}
#----Return(plus)
#---}



#-----2.3
```

the above code is very important in our code. it basically a function of posible response that our chatbot can deliver. we must note that these parameters have been pre-caculated and we already have in our shinny app. this is just supplying it to the Chatbot to give posible responses bounded by these input.

example of if Y is a function of A, B, C we write it as Y==Function(A, B, C) then we can say for every change in A,B,C there is a similar equal change in Y.

so in similar vain, for every message the chat bot gets about method, n_postcodes and total_km, the chatbot responds with something diffrent.

so basically the chatbot response function parameters is like a case of diffrent data where you can call these values to your chatbot. say for example it carries the parameter "method" and this parameter carries diffrent methods above, so all we need say on our chatbot is call out method and the chatbot tells ylu the method since it already has the data been supplied freom our response function.

so we can say

``` r
#---  Z in this case is our function name  
#----function (x,y) are parameters we have given to our function to work with 
#--and {plus<- (x*y) is the rule book, telling our function what to do with the parameter, how to behave what to check or how to use inputs in the case of TSP
#---}

#------2.4
```

from code 2.1 we move on the next part of the syntax which is refered to as the body of the syntax,

``` r
#--msg <- tolower(trimws(user_msg))

#-----2.5
```

this bassically formats the User_msg parameter and makes it lower case. i.e if the user inputs any string in any format, it converts it to a lower case by using the (tolower) and this makes the chatbot to see any input in lower case. the function also makes the chatbot ignore any space before and after the input by using the (trimws) function and then assigns the result to a new variable called 'msg'

example if the user inputs "HELLO, heLLo, " Hello ", " hello " . its sees it as just "hello".

``` r
 #(if (grepl("^(hi|hello|hey|good morning|good afternoon|good evening)", msg)) {
 #   return("Hello! I am the **UK Route Optimiser Bot**. I help you find the shortest delivery route across East Midlands postcodes using the Travelling Salesman Problem (TSP).\n\nTry asking:\n- How many postcodes should I use?\n- Which method is best?\n- What is the current route distance?\n- Explain nearest neighbour")

#---2.6
```

The code 2.6 is another body or rule boox in our chatbox response function, and it uses the if statement to check for conditions or what the user has inputted to give a corresponding response.

##### The If syntax

``` r
# ---if (....) 
#----{return(....)}


#-----2.7 
```

the if syntax in this study is paired with the GREPL function which in basic terms checks for patterns and returns if its true or false. the syntax is given below

``` r
#---grepl(pattern Y, X) 

#-- this means check for pattern Y in X. 

#----2.8
```

combining this with code 2.7 we have

``` r
#-if (grepl(pattern,X)){
 # return(result)
#--}

#---2.9
```

from 2.6,

(grepl("\^(hi\|hello\|hey\|good morning\|good afternoon\|good evening)", msg)

means, check for the following words in msg. the '\^' means that it has to check for these words only on the beginning of the user sentence. '\|' simply means or.
