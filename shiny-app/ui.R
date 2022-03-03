library(shiny)
library(shinyWidgets)
library(reactable)
library(reactablefmtr)
library(tidyverse)
library(plotly)
library(ggridges)
library(reshape2)
library(ggwordcloud)

ui <- fluidPage(

 # sliderInput("valence", label="Select Valence")
  titlePanel("SONG PROFILES"),
  tags$head(
    # Note the wrapping of the string in HTML()
    tags$style(HTML("
      body {
        font-family: 'Roboto', sans-serif;
      }
      h3 {
        font-family: 'Roboto', sans-serif;
      }              
                    "))
  ),
  sidebarLayout(
    sidebarPanel(width=3,
      h3("ABOUT"),
      "Data collected using the Spotify API. Clicking on track titles will redirect to Spotify.",
      h3("FILTERS"),
      "Change the inputs below to change results displayed in the table.",
      h3(""),
      selectInput(
        inputId="genre",
        label="Music Genre",
        choices=c("Country","Dance Pop","Hip Hop","Rock"),
        selected=c("Country","Dance Pop","Hip Hop","Rock"),
        multiple=TRUE
      ),
      sliderInput(
        "valence",
        label="Valence",
        min=0, max=1,
        value=c(0,1)
      ),
      sliderInput(
        "danceability",
        label="Danceability",
        min=0, max=1,
        value=c(0,1)
      ),
      sliderInput(
        "energy",
        label="Energy",
        min=0, max=1,
        value=c(0,1)
      ),
      sliderInput(
        "acousticness",
        label="Acousticness",
        min=0, max=1,
        value=c(0,1)
      ),
    ),
    mainPanel(
      tabsetPanel(
        id = "tabset",
        tabPanel("Top Grams",
                 h4("Parameters"),
                 fluidRow(
                 column(4,
                 selectInput("nGrams",
                             label="Gram Split:",
                             choices=c("One"=1,
                                       "Two"=2),
                             selected=1),
                 selectInput("wordMetric",
                             label="Word Metric:",
                             choices=c("Word Count"="word_count",
                                       "Songs Containg"="songs",
                                       "Percentage of Songs" = "song_perc"),
                             selected="word_count")
                 ), 
                 column(4,
                  selectInput("wordType",
                              label="Word Type",
                              choices=c("All" = "all",
                                        "Action Verbs" = "action_verb",
                                        "Irregular Nouns" = "irr_noun",
                                        "Pronouns" = "pronoun",
                                        "Drugs & Alcohol" = "subst",
                                        "Racist Words" = "racist"
                              )),
                  radioButtons("includeStop", "Stop Words:",
                               inline=TRUE,
                               c("Include" = "yes",
                                 "Exclude" = "no"),
                               selected="no"
                  )
                 ),
                 column(4, 
                        sliderInput("nWordsTop",
                                    label="Number of Grams:",
                                    min=5,max=15,
                                    value=10)
                 )
                 ),
                 plotlyOutput("topWords")
                 ),
        tabPanel("Word Cloud",
                 h4("Parameters"),
                 fluidRow(
                     column(5,
                     sliderInput("nWords",
                                 label="Number of Top Words:",
                                 min=20, max=150,
                                 value=100)
                     ),
                     column(5,
                     radioButtons("includeStopWords", "Stop Words:",
                                  inline=TRUE,
                                  c("Include" = "yes",
                                    "Exclude" = "no")
                                  )
                     )
                 ),
                 plotOutput("wordCloud", height="500px")
      ),
        tabPanel("Cross Analysis",
           h4("Parameters"),
           fluidRow(
            column(5,
            selectInput("xScatter", 
                        label="X Variable",
                        choices=c("valence","danceability","energy","acousticness"),
                        selected="valence")
            ),
            column(5,
            selectInput("yScatter", 
                        label="Y Variable",
                        choices=c("valence","danceability","energy","acousticness"),
                        selected="danceability")
           )),
            plotlyOutput("plotlyScatter")),
        tabPanel("Audio Profile",
                 reactableOutput("songTable")
        )
    )
  )
  
)
)