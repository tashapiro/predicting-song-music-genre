library(tidyverse)
library(ggridges)
library(ggimage)
library(magick)
library(reshape2)

#import data
audio <- read.csv('../data/audio_features.csv')
audio<-audio%>%
  mutate(genre=case_when(genre=='rock'~'ROCK',
                         genre=='hip_hop'~'HIP HOP',
                         genre=='dance_pop'~'DANCE POP',
                         genre=='country'~'COUNTRY',
                         TRUE ~genre),
         image_path = paste0(artist_id,'.png'))


#reshape data
melted<-audio%>%select(genre, artist, track, danceability,energy, acousticness, valence)%>%
  melt(id.vars=c("genre","artist","track"), variable.name = "feature", value.name = 'score')

#create medians per genre and features
medians<-melted%>%
  group_by(genre,feature)%>%
  summarise(median = median(score))

#create additional data frames for plot

#text annotations
text<-data.frame(
  genre=c('DANCE POP','COUNTRY','ROCK'),
  feature = c('danceability','acousticness','danceability'),
  score = c(0.3, 0.7,0.85),
  label=c("Median Score \n per Genre & Feature","Country more \n acoustic than other genres","Rock is less \n danceable"),
  vjust=c(-2.3,-1.3, -1.8)
)

#labels for X axis
x_labels<-data.frame(
  genre=rep(0.6,8),
  label=c(rep("LESS",4),rep("MORE",4)),
  feature=rep(c("acousticness","danceability","energy","valence"),2),
  positions = c(rep(0.2,4),rep(0.8,4))
)

#labels for X ticks
x_ticks<-data.frame(
  y= rep(0.8,8),
  x= c(rep(0,4),rep(1,4)),
  label=c(rep(0,4),rep(1,4))
)

#custom for X axis
x_arrows<-data.frame(
  ystart= rep(0.8,2),
  yend = rep(0.8,2),
  xstart = c(0.4,0.6),
  xend = c(0.1,0.9)
)


#PLOT
ggplot(melted, aes(x=score,y =genre, fill=stat(x)))+
  facet_grid(~toupper(feature))+
  geom_density_ridges_gradient(scale = 0.85)+
  geom_density_ridges(inherit.aes=FALSE, data=melted, aes(x=score, y=genre), fill=NA, quantile_lines=TRUE, scale=0.85, quantiles=2, linetype='dashed')+
  geom_label(data=medians, aes(y=genre, x=median, label=round(median,2)), 
             family="Gill Sans", vjust=-0.9, size=4,
             label.size=NA, fill='black',color='white')+
  scale_fill_viridis_c(option='plasma')+
  geom_text(data=text, aes(x=score, y=genre, label=label, vjust=vjust), family="Gill Sans", size=3.5)+
  geom_curve(data = data.frame(feature='danceability', x1=0.35, x2=0.58, y1=2.4,y2=2.22),curvature = 0.2,
             aes(x = x1, y = y1, xend = x2, yend = y2), arrow = arrow(length = unit(0.02, "npc"))
  )+
  geom_text(data=x_labels, aes(x=positions, y=genre, label=label), family="Gill Sans")+
  geom_text(data=x_ticks, aes(x=x, y=y, label=label), family="Gill Sans", color="grey30")+
  geom_segment(data=x_arrows, aes(x=xstart,xend=xend,y=ystart,yend=yend), color="black", arrow=arrow(type="open", length=unit(0.2,"cm")))+
  labs(x='SCORE',y='GENRE',title='MUSIC GENRE AUDIO PROFILES', 
       subtitle="Audio features created by Spotify, scaled from 0 to 1",
       caption="Data from Spotify API | Chart by @tanya_shapiro")+
  theme_minimal()+
  scale_x_continuous(limits=c(0,1))+
  theme(text=element_text(family='Gill Sans'),
        plot.title = element_text(hjust=0.5, margin=margin(b=10), size= 16, family="Gill Sans Bold"),
        plot.subtitle=element_text(hjust=0.5, size = 12, margin=margin(b=20)),
        plot.margin=margin(t=20,b=0,l=10,r=10),
        plot.caption=element_text(size=9, vjust=7),
        legend.position = 'none',
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.title.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.x=element_blank()
  )

#SAVE FILE
ggsave("../plots/audio_profiles.jpeg", height=8, width=13)
