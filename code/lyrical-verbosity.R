library(tidyverse)
library(ggridges)
library(ggtext)
library(ggimage)

lyrics <- read.csv('https://raw.githubusercontent.com/tashapiro/predicting-song-music-genre/main/data/lyrics.csv')
audio<-read.csv('https://raw.githubusercontent.com/tashapiro/predicting-song-music-genre/main/data/audio_features.csv')

df<-lyrics|>
  left_join(audio|>select(id, genre), by=c("id"))|>
  mutate(genre=toupper(str_replace_all(genre,"_"," ")),
         lyrics = str_replace_all(lyrics, "\\s*\\[[^\\)]+\\]",""),
         words=str_count(lyrics, "\\w+"))|>
  distinct(id, track, artist, lyrics, genre, words)
levels=c("HIP HOP","DANCE POP","COUNTRY","ROCK")
df$genre<-factor(df$genre, levels=levels)

medians<-df|>
  filter(words<1000)|>
  group_by(genre)|>
  summarise(median=median(words))
medians$genre<-factor(medians$genre, levels=levels)
medians$y<-c(1.1,2.1,3.25,4.3)


#title for ggtext
title="<span style='family:serif;font-size:20pt;'>**LYRICAL VERBOSITY BY MUSIC GENRE**</span><br><br>
Lyrics for 3600+ songs collected from <span style='color:#FFF265;'>Genius API</span>. Genre classifications based on playlists provided by <span style='color:#C165FF;'>The Every Noise at Once Project</span>. 
Select popular songs plotted for reference.<br><br>"

labels<-data.frame(
  y=c(2.3,4.3,1.5,1.3,3.3),
  x=c(720, 447, 138, 921,527),
  label=c("Fergalicious<br>**Fergie**",
          "Stairway To Heaven<br>**Led Zeppelin**",
          "Ms. Jackson<br>**Outkast**",
          "Slow Jamz<br>**Twista**",
          "Wishful Drinking<br>**Ingrid Andress**")
)

images<-data.frame(
  y=c(4.62,1.62,2.62,3.62),
  x=c(447,921,720,527),
  image=c("led-zep.png","Twista.png","fergie.png","ingrid-andress.png")
)

xlabels<-data.frame(x=seq(from=0, to=1000, by=250))

ggplot(df, aes(x=words, y=genre, fill=stat(x)))+
  geom_density_ridges_gradient(scale = 0.85, color="white")+
  geom_segment(data=labels, mapping=aes(x=x, xend=x, y=y, yend=floor(y)), color="white")+
  geom_density_ridges_gradient(scale = 0.85, color="white")+
  geom_density_ridges(inherit.aes=FALSE, data=df, aes(x=words, y=genre), 
                      color="white", fill=NA, quantile_lines=TRUE, scale=0.85, quantiles=2, linetype='dashed')+
  geom_label(data=medians, aes(y=y, x=median, label=round(median,2)), size=4, hjust=0.5,
             label.size=NA, fill='black',color='white')+
  #artist labels
  geom_richtext(inherit.aes=FALSE, data=labels, mapping=aes(x=x,y=y, label=label), label.color = NA, fill="black", color="white")+
  geom_image(inherit.aes=FALSE, data=images, mapping=aes(x=x,y=y,image=image), color="white", size=0.07)+
  geom_image(inherit.aes=FALSE, data=images, mapping=aes(x=x,y=y,image=image), size=0.066)+
  #median word count annotation
  annotate(geom="text", x=180, y=3.6, label="Median Word \n Count", color="white", size=3)+
  geom_segment(aes(x=145, xend=84, y=3.55, yend=3.32), color="white", arrow=arrow(length=unit(0.05,"inches")), size=0.1)+
  #new x axis label
  geom_text(data=xlabels, mapping=aes(x=x, y=0.8, label=x), color="white", size=3.5)+
  annotate(geom="text", x=500, y=0.55, label="WORD COUNT", color="white", fontface="bold")+
  scale_x_continuous(limits=c(0,1000))+
  scale_fill_viridis_c(option='plasma')+
  labs(title=title, caption="Graphic @tanya_shapiro")+
  theme(legend.position="none",
        text=element_text(color="white"),
        plot.title=element_textbox_simple(halign=0.5),
        panel.grid = element_blank(),
        plot.caption=element_text(color="grey80"),
        axis.title=element_blank(),
        axis.ticks=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y = element_text(color="white", vjust=-4, size=10, face="bold"),
        plot.margin=margin(t=20, b=20, l=20, r=20),
        panel.background = element_rect(fill="black"),
        plot.background = element_rect(fill="black"))


ggsave("verbosity.png",width=9, height=9)
