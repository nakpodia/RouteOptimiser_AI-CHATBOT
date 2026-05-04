
# Project Title
**Example: UK Route Optimiser - TSP Chatbot (R + Shiny)**

## Problem
What problem does this app solve?
(Relate to your recruiting/security job background if possible)
Example: Logistics teams in the East Midlands waste hours planning
delivery routes manually. This tool optimises routes across any
number of postcodes in seconds.

## Solution
What your app does in simple terms.
Example: An interactive R Shiny chatbot that applies 7 different
Travelling Salesman Problem algorithms to find the shortest delivery
route. A built-in chatbot advisor explains every method and
interprets results in plain English.

## Demo
![App Screenshot](screenshots/map_view.png)
![Chatbot Screenshot](screenshots/chatbot_view.png)
*(Include at least 2 screenshots or a short screen recording)*

## Tech Used
- R + Shiny
- TSP Package (Hahsler)
- Leaflet (interactive maps)
- Haversine distance formula
- shinythemes

## Key Features
- 7 TSP optimisation algorithms (NN, Two-Opt, Insertions...)
- Real-time route distance calculation (km)
- Interactive Leaflet map with colour-coded routes
- Conversational chatbot that explains algorithms
- Random postcode sampling across 100 East Midlands locations

## How to Run
```r
# Install required packages
install.packages(c('shiny','shinythemes','leaflet','TSP'))

# Run the app
shiny::runApp('app.R')
```

## Code Link
Full source code available in this repository.
Author: Clinton Nakpodia | Nakpodiaclinton@gmail.com
