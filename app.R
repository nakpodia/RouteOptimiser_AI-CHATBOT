# ============================================================
# UK Travelling Salesman Problem (TSP) - Shiny Chatbot
# Converted from original UKTSP Shiny app
# ============================================================

library(shiny)
library(shinythemes)
library(leaflet)
library(TSP)

# ---- Load data ----
datg <- read.csv("Book1.csv")

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

dist_haversine_n <- function(long_lat_mat) {
  n <- nrow(long_lat_mat)
  dist_mat <- matrix(0, nrow = n, ncol = n)
  for (i in seq_len(n))
    for (j in seq_len(n))
      dist_mat[i, j] <- dist_haversine(as.numeric(long_lat_mat[i, ]),
                                       as.numeric(long_lat_mat[j, ]))
  dist_mat
}

# ---- Title-case helper (no external packages) ----
title_case <- function(x) {
  x <- gsub("_", " ", x)
  paste0(toupper(substring(x, 1, 1)), substring(x, 2))
}

# ---- Simple markdown renderer (no commonmark needed) ----
render_md <- function(txt) {
  txt <- gsub("\\*\\*(.+?)\\*\\*", "<b>\\1</b>", txt)
  txt <- gsub("\\*(.+?)\\*",       "<i>\\1</i>", txt)
  txt <- gsub("\n",                 "<br>",       txt)
  txt
}


`%||%` <- function(a, b) if (!is.null(a)) a else b

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


# ---- UI ----
ui <- fluidPage(
  theme = shinytheme("flatly"),
  tags$head(tags$style(HTML("
    body { background-color: #f4f6f9; }
    .chat-outer {
      border: 1px solid #ccd; border-radius: 8px;
      background: #fff; overflow: hidden;
    }
    .chat-container {
      height: 400px; overflow-y: auto;
      padding: 12px;
      display: flex; flex-direction: column; gap: 8px;
    }
    .msg-user {
      align-self: flex-end; background: #2c3e50; color: #fff;
      border-radius: 16px 16px 4px 16px;
      padding: 8px 14px; max-width: 78%; font-size: 0.92em;
      word-wrap: break-word;
    }
    .msg-bot {
      align-self: flex-start; background: #ecf0f1; color: #2c3e50;
      border-radius: 16px 16px 16px 4px;
      padding: 8px 14px; max-width: 82%; font-size: 0.92em;
      word-wrap: break-word;
    }
    .chat-footer {
      border-top: 1px solid #eee; padding: 10px;
      display: flex; gap: 8px; align-items: center;
    }
    .chat-footer .form-group { margin-bottom: 0; flex: 1; }
  "))),
  
  titlePanel(
    div(
      h2("UK Route Optimiser - TSP Chatbot"),
      p("Optimising delivery routes across East Midlands postcodes",
        style = "color:#7f8c8d; margin-top:-8px;")
    )
  ),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      h4("Route Settings"),
      numericInput("npostcodes", "Number of Postcodes:", value = 10, min = 2, max = 100),
      radioButtons("method", "Optimisation Method:",
                   choices = list(
                     "Nearest Insertion"   = "nearest_insertion",
                     "Farthest Insertion"  = "farthest_insertion",
                     "Cheapest Insertion"  = "cheapest_insertion",
                     "Arbitrary Insertion" = "arbitrary_insertion",
                     "Nearest Neighbour"   = "nn",
                     "Repetitive NN"       = "repetitive_nn",
                     "Two-Opt"             = "two_opt"
                   ),
                   selected = "farthest_insertion"
      ),
      hr(),
      actionButton("rerun", "New Random Sample", class = "btn-primary btn-block"),
      hr(),
      uiOutput("statsPanel")
    ),
    
    mainPanel(
      width = 9,
      fluidRow(
        column(7,
               h4("Optimised Route Map"),
               leafletOutput("leafletmap", height = "480px")
        ),
        column(5,
               h4("Route Advisor Chatbot"),
               div(class = "chat-outer",
                   div(class = "chat-container", id = "chatbox",
                       uiOutput("chatMessages")),
                   div(class = "chat-footer",
                       textInput("userMsg", label = NULL,
                                 placeholder = "Ask about the route or methods..."),
                       actionButton("sendMsg", "Send", class = "btn-info")
                   )
               )
        )
      )
    )
  )
)


# ---- Server ----
server <- function(input, output, session) {
  
  chat_history <- reactiveVal(list(
    list(role = "bot",
         text = "Hi! I am your Route Advisor. Ask me anything about the TSP route, methods, or the map. Type <b>help</b> to see all topics!")
  ))
  
  run_trigger <- reactiveVal(0)
  observeEvent(input$rerun, run_trigger(run_trigger() + 1))
  
  tour_data <- reactive({
    run_trigger()
    n      <- max(2, min(100, as.integer(input$npostcodes)))
    method <- input$method
    ind    <- sample(seq_len(nrow(datg)), n)
    df     <- datg[ind, ]
    distance <- dist_haversine_n(df[, 2:3])
    rownames(distance) <- colnames(distance) <- as.character(df[, 1])
    # TSP() constructor takes only the distance matrix (no method arg in newer versions)
    tsp_obj  <- TSP(distance)
    `%||%` <- function(a, b) if (!is.null(a)) a else b
    tour     <- solve_TSP(tsp_obj, method = method)
    total_km <- round(tour_length(tour), 2)
    list(df = df, tour = tour, total_km = total_km)
  })
  
  output$leafletmap <- renderLeaflet({
    td       <- tour_data()
    df       <- td$df
    tour     <- td$tour
    total_km <- td$total_km
    
    leaflet(df) %>%
      addTiles() %>%
      addCircleMarkers(lng = ~LONG, lat = ~LAT,
                       popup = ~Post.code,
                       color = "#2980b9", radius = 7, fillOpacity = 0.8) %>%
      addPolylines(lng = ~LONG, lat = ~LAT,
                   data = df[, c("LONG", "LAT")][tour, ],
                   color = "#e74c3c", weight = 3) %>%
      addMarkers(~LONG, ~LAT, popup = ~as.character(Post.code)) %>%
      addControl(
        paste0("<b>Total Tour Distance: ", total_km, " km</b>"),
        position = "topright"
      )
  })
  
  output$statsPanel <- renderUI({
    td <- tour_data()
    tagList(
      h4("Current Stats"),
      tags$table(
        style = "width:100%; font-size:0.9em;",
        tags$tr(tags$td("Postcodes:"), tags$td(strong(input$npostcodes))),
        tags$tr(tags$td("Method:"),    tags$td(strong(title_case(input$method)))),
        tags$tr(tags$td("Distance:"),  tags$td(strong(paste0(td$total_km, " km"))))
      )
    )
  })
  
  observeEvent(input$sendMsg, {
    req(nchar(trimws(input$userMsg)) > 0)
    user_text <- input$userMsg
    updateTextInput(session, "userMsg", value = "")
    
    td <- tour_data()
    bot_raw <- chatbot_response(
      user_msg    = user_text,
      n_postcodes = input$npostcodes,
      method      = input$method,
      total_km    = td$total_km
    )
    
    history <- chat_history()
    history <- c(history,
                 list(list(role = "user", text = user_text)),
                 list(list(role = "bot",  text = render_md(bot_raw))))
    chat_history(history)
  })
  
  output$chatMessages <- renderUI({
    msgs <- chat_history()
    tags$div(
      lapply(msgs, function(m) {
        cls <- if (m$role == "user") "msg-user" else "msg-bot"
        div(class = cls, HTML(m$text))
      })
    )
  })
}


shinyApp(ui = ui, server = server)
