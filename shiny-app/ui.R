library(shiny)
library(shinyWidgets)
library(shinydashboard)
library(reactable)
library(reactablefmtr)
library(tidyverse)
library(plotly)
library(ggridges)
library(reshape2)
library(ggwordcloud)
library(tidytext)
library(bslib)

ui <- fluidPage(
  
  theme = bs_theme(
    bg = "#000000", fg = "white", primary = '#FFBC42', #"#FFCF00",
    base_font = font_google("Roboto"),
    code_font = font_google("Roboto")
  ),

  h2("MUSIC OR LYRICS: Song Genre Classification"),
  h3(""),
  sidebarLayout(
    sidebarPanel(width=3,
      h5("FILTERS"),
      "Change the inputs below to change results displayed in the main panel.",
      h5(),
      selectInput(
        inputId="genre",
        label="Music Genre",
        choices=c("Country","Dance Pop","Hip Hop","Rock"),
        selected=c("Country","Dance Pop","Hip Hop","Rock"),
        multiple=TRUE
      ),
      h5(""),
      conditionalPanel(condition="input.tabset==3 | input.tabset==4",
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
      sliderInput(
        "instrumentalness",
        label="Instrumentalness",
        min=0, max=1,
        value=c(0,1)
      ),
      sliderInput(
        "speechiness",
        label="Speechiness",
        min=0, max=1,
        value=c(0,1)
      )
    ),
    conditionalPanel(condition="input.tabset==2",
                              sliderInput("nWords",
                                          label="Number of Top Words:",
                                          min=20, max=150,
                                          value=100),
                              radioButtons("includeStopWords", "Stop Words:",
                                           inline=TRUE,
                                           c("Include" = "yes",
                                             "Exclude" = "no")
                              )
                     ),
    conditionalPanel(condition="input.tabset==1",
       radioButtons("includeStop", "Stop Words:",
                    inline=TRUE,
                    c("Include" = "yes",
                      "Exclude" = "no"),
                    selected="no"
       ),
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
                   selected="word_count"),
       selectInput("wordType",
                   label="Word Type",
                   choices=c("All" = "all",
                             "Action Verbs" = "action_verb",
                             "Irregular Nouns" = "irr_noun",
                             "Pronouns" = "pronoun",
                             "Drugs & Alcohol" = "subst",
                             "Racist Words" = "racist"
                   )),
       sliderInput("nWordsTop",
                   label="Number of Grams:",
                   min=5,max=15,
                   value=10)
    )
    ),
    mainPanel(
      tabsetPanel(
        id = "tabset", 
        tabPanel("Top Grams",value=1,
                 plotlyOutput("topWords")
                 ),
        tabPanel("Word Cloud", value=2,
                 plotOutput("wordCloud", height="500px")
      ),
        tabPanel("Cross Analysis", value=3,
           h5("Variables"),
           fluidRow(
            column(5,
            selectInput("xScatter", 
                        label="X Variable",
                        choices=c("acousticness","danceability","energy","instrumentalness","speechiness","valence"),
                        selected="valence")
            ),
            column(5,
            selectInput("yScatter", 
                        label="Y Variable",
                        choices=c("acousticness","danceability","energy","instrumentalness","speechiness","valence"),
                        selected="danceability")
           )),
            plotlyOutput("plotlyScatter")),
        tabPanel("Audio Profile", value=4,
                 reactableOutput("songTable")
        )
    )
  )
  
)
)