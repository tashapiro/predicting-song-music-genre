server <- function(input, output, session) {
  
  #load data
  audio <- read.csv('https://raw.githubusercontent.com/tashapiro/predicting-song-music-genre/main/data/audio_features.csv')
  artists<-read.csv('https://raw.githubusercontent.com/tashapiro/predicting-song-music-genre/main/data/artists2')
  words<-read.csv('https://raw.githubusercontent.com/tashapiro/predicting-song-music-genre/main/data/lyrics_words.csv')
  bis<-read.csv('https://raw.githubusercontent.com/tashapiro/predicting-song-music-genre/main/data/lyrics_bis.csv')
  
  #base links
  base = 'https://drive.google.com/uc?id='
  spotify_base = 'https://open.spotify.com/track/'
  
  #palettes
  
  bcolor <- "#000000"
  fcolor <- "#FFFFFF"
  
#TRANSFORM DATA
songs<-audio%>%
    left_join(artists%>%select(-link,-artist), by='artist_id')%>%
    mutate(genre = str_to_title(sub("_"," ", genre)))%>%
    filter(followers>=1000000)%>%
    mutate(image_url = paste0(base,id.y),
           song_url = paste0(spotify_base, id.x))
  
  
  df <-  reactive({songs%>%
    filter(genre %in% input$genre &
           valence >= input$valence[1]  &
           valence <= input$valence[2] & 
           energy >= input$energy[1]  &
           energy <= input$energy[2] & 
           danceability >= input$danceability[1]  &
           danceability <= input$danceability[2] & 
           acousticness >= input$acousticness[1]  &
           acousticness <= input$acousticness[2] &
           instrumentalness >= input$instrumentalness[1]  &
           instrumentalness <= input$instrumentalness[2]  &
           speechiness >= input$speechiness[1]  &
           speechiness <= input$speechiness[2] 
    )%>%
    arrange(-valence) })

  
  df_words<- reactive({words%>%
    filter(genre %in% input$genre)%>%
    group_by(word, stop_word)%>%
    summarise(word_count=sum(word_count))%>%
    filter(stop_word=='no')%>%
    arrange(-word_count)%>%head(input$nWords)
  })
  
  words$all<-"yes"
  
  top_words<-reactive({words%>%
    group_by(genre)%>% 
    filter(genre %in% input$genre
           & stop_word %in%input$includeStop
           & get(input$wordType) == 'yes')%>%
    slice_max(order_by=word_count, n = input$nWordsTop)
  })
  
  top_bis<-reactive({bis%>%
      group_by(genre)%>% 
      filter(genre %in% input$genre & stop_word=='no')%>%
      slice_max(order_by=word_count, n = input$nWordsTop)
  })
  
  
  col_pal <- c('#F2C14E','#DB324D','#2B59C3','#3CBBB1')
  
  #OUTPUTS
  output$songTable<-renderReactable({
    reactable(df()%>%select(image_url,artist,track,genre, valence, danceability, acousticness, energy),
            searchable=TRUE,
            theme = reactableTheme(
              cellStyle=list(display='flex',flexDirection='column',justifyContent='center'),
              style=list(fontFamily='Roboto'), backgroundColor=bcolor, color=fcolor,
              borderColor = "#303030"
            ),
            columns= list(
              image_url = colDef(name="",cell=embed_img(height=50,width=50)),
              artist = colDef(name='ARTIST'),
              track = colDef(name='TRACK', html=TRUE, cell= function(value,index){
                sprintf('<a style=text-decoration:none;color:#3DCEEE; href="%s" target="_blank">%s</a>', df()$song_url[index], value)
              }),
              genre = colDef(name='GENRE', align='center'),
              valence = colDef(name="VALENCE",style = color_scales(df()), align="center", format=colFormat(digits=2)),
              danceability = colDef(name="DANCEABILITY",style = color_scales(df()), align="center", format=colFormat(digits=2)),
              acousticness = colDef(name="ACOUSTICNESS",style = color_scales(df()), align="center", format=colFormat(digits=2)),
              energy = colDef(name="ENERGY",style = color_scales(df()), align="center", format=colFormat(digits=2))
            )
  )
})

  output$plotlyScatter <- renderPlotly({
    p<-ggplot(df())+
      geom_point(aes(x=get(input$xScatter),
                     y=get(input$yScatter),
                     text = paste0("Artist: ", artist,"\nTrack: ",track,
                                   '\n',input$xScatter,': ',get(input$xScatter),
                                   '\n',input$yScatter,': ', get(input$yScatter)),
                     fill=genre), alpha = 0.9, stroke=0.2, size=3, shape=21, color='white')+
      scale_fill_manual(values=col_pal)+
      facet_wrap(~genre)+
      labs(y=toupper(input$yScatter), x=toupper(input$xScatter))+
      theme_minimal()+
      theme(
        plot.background = element_rect(fill=bcolor),
        panel.background = element_rect(fill=bcolor),
        text = element_text(color=fcolor),
        strip.text= element_text(color=fcolor),
        axis.text = element_text(color=fcolor),
        panel.grid = element_line(color="grey30")
      )
    
    ggplotly(p, height=600, width=900, tooltip='text')%>%
      layout(font=list(family="Roboto"),
             legend = list(orientation = 'h', x=0, y=1.1, title=list(text='GENRE')))
  })
  
  
  output$wordCloud<- renderPlot({
    set.seed(42)
    ggplot(df_words(), aes(label = word, size = word_count)) +
      geom_text_wordcloud_area(eccentricity = 1, color=fcolor) +
      scale_size_area(max_size = 24) +
      theme_minimal()+
      theme(panel.background = element_rect(fill=bcolor, color=bcolor))
  })
  
  
  output$topWords <- renderPlotly({
    
   if(input$nGrams==1){data = top_words()}else{data = top_bis()}
    
    p<-ggplot(data, aes(y=reorder_within(word, get(input$wordMetric), genre), 
                       x= get(input$wordMetric),
                       text = paste0("Word: ", word, get(input$wordMetric)),
                       fill=genre))+
      scale_y_reordered() +
      geom_bar(stat='identity')+
      scale_fill_manual(values=col_pal)+
      facet_wrap(~genre, scales='free_y')+
      labs(y="WORDS",x=input$wordMetric)+
      theme_minimal()+
      theme(
        legend.position="none",
        plot.background = element_rect(fill=bcolor),
        panel.background = element_rect(fill=bcolor),
        text = element_text(color=fcolor),
        strip.text=element_text(color=fcolor),
        axis.text = element_text(color=fcolor),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.x= element_line(color="grey50"),
        panel.grid.minor.x=element_blank()
      )
    
    ggplotly(p, height=600, width=900, tooltip='text')%>%
      layout(font=list(family="Roboto"),
             legend = list(orientation = 'h', x=0, y=1.1, title=list(text='GENRE')))
    
    
  })

    
}
    
  
