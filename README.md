# Music Genre Classification

The main question of this capstone is to explore which subset of song features can create the strongest predictor of music genre - music or lyrics? To answer this question, this project collected data from  **[Spotify](https://www.spotify.com/us/)** (audio features) and **[Lyric Genius](https://genius.com/)**. Although each dataset contained the same songs, they were treated independently to build separate models (one using only audio feature data, the other using only lyric data for NLP).

The dataset is comprised of ~3500 songs and each song falls into 1 of the 4 following music genres: Country, Dance Pop, Hip Hop, or Rock. Song genres are identified using classifications created by the **[Every Noise At Once Project](https://everynoise.com/engenremap.html)** created by Glenn McDonald.

The full presentation is available [here](https://github.com/tashapiro/predicting-song-music-genre/blob/main/genre-classification-presentation.pdf).

## Background

From [Wikipeida](https://en.wikipedia.org/wiki/Music_genre), music genres can be defined as such:

> A music genre is a conventional category that identifies some pieces of music as belonging to a shared tradition or set of conventions. It is to be distinguished from musical form and musical style, although in practice these terms are sometimes used interchangeably.

> Music can be divided into genres in varying ways, such as popular music and art music, or religious music and secular music. The artistic nature of music means that these classifications are often subjective and controversial, and some genres may overlap.


## Data Collection

For the data collection process, music songs were collected from the **Every Nosie At Once Project** Spotify playlists. " Using **[Spotipy](https://spotipy.readthedocs.io/en/2.19.0/)** , all songs for each of the 4 respective playlists were scraped - dataset was comprised of song details such as track name, artist, and album as well as [audio feature data defined by Spotify](https://developer.spotify.com/documentation/web-api/reference/#/operations/get-several-audio-features) (e.g. acousticness, instrumentalness, etc).

For some songs, there was a genre overlap, e.g. a song could appear on the Rock and Country playlists. These items were dropped to ensure that each song only represented one genre. After de-duping the dataset, a second scraping process ensued: lyric data was collected for each song with the Python wrapper for **[Lyric Genius](https://lyricsgenius.readthedocs.io/en/master/)**. 

It is important to note the class imbalance - there are not an even amount of songs per class, Country songs comprised less than a quarter of the dataset while Rock songs comprised almost 30%. During the data modeling stage, **oversampling** techniques were used on the training data to create a balanced song (e.g. country songs were inflated with duplicate records to match the majority class record count).

The final step of the data collection phase included a pre-processing step: lyric data was parsed and cleaned to exclude HTML tags (e.g. \n) and ancillary text data (e.g. [Verse 1], [Chorus]). Additional songs were dropped from the dataset due to poor data collection (data scraping did not yield actual lyrics, some produced miscellaneous reseults).


*Data Collection Summary*

| Playlist                           | Number of Songs | De-Duped Count | Final Song Count | %  Total Songs |
|:-----------------------------------|----------------:|---------------:|-----------------:|------------------:|
| [The Sound of Country][Country]    | 608             | 586            | 574              | 16.8%             |
| [The Sound of Dance Pop][DancePop] | 1127            | 1037           | 980              | 28.7%             |
| [The Sound of Hip Hop][HipHop]     | 969             | 935            | 841              | 24.6%             |
| [The Sound of Rock][Rock]          | 1173            | 1094           | 1025             | 30%               |

[Rock]: https://open.spotify.com/playlist/7dowgSWOmvdpwNkGFMUs6e?si=2f6661c09c4e45e0
[Country]: https://open.spotify.com/playlist/4mijVkpSXJziPiOrK7YX4M?si=a05559bc40e14d83
[DancePop]: https://open.spotify.com/playlist/2ZIRxkFuqNPMnlY7vL54uK?si=285daa3611b54089
[HipHop]: https://open.spotify.com/playlist/6MXkE0uYF4XwU4VTtyrpfP?si=38a3397ac0b64b66


## Methodology

Overview of the project steps.

![plot](/images/methodology.png)

## EDA

**All EDA visualizations were produced using RStudio.**

The most noteable discrepancies among genres and their respective audio features are song **danceability** and song **acousticness**. Country music songs can sometimes be more "acoustic" compared to songs in other genres, and Rock music appears to be less "danceable" compared to other genres.

### Audio Feature Distribution (Spotify Audio Metrics)
![plot](/plots/audio_dist.jpeg)

The biggest takeaway from word count distribution analysis for lyrics data: hip hop songs tend to be more verbose compared to songs classified in other genres.

## Word Count Distribution (Lyrics)
![plot](/images/lyric_word_dist.png)

## Shiny Application

To facilitate EDA, I built an **[R Shiny application](https://tshapiro.shinyapps.io/music-genre-classification/)** using the data sets collected from Spotify and Lyric Genius. The application allows users to explore several facets of the data, such as most common words per genre, relationships between different audio features, and song examples with audio feature data.

**Screenshot 1: Most Common Words**

![plot](/images/shiny-app-ngrams.png)

**Screenshot 2: Relationship Between Audio Features**

![plot](/images/shiny-app-scatter.png)

**Screenshot 3: Audio Features Per Track**

![plot](/images/shiny-app-table.png)

## Model Results

Different sklearn multinomial classifier models were used to generate models for audio feature data and lyric data seperately. These models were then tested with an oversampling technique to see if class imbalances impacted accuracy scores.

### Results - Audio Features
![plot](/images/model_results_audio.png)

### Results - Lyrics
![plot](/images/model_results_lyrics.png)

### Model Analysis
- **Close Call.** Best Audio Features model beat out best Lyric model, only by 5% points 
- **Best Overall.** Although Random Forest (Audio) had the highest accuracy (73%), SVM Audio should not be overlooked – more balanced across genres with accuracy.
- **Oversampling.** This technique helped improve most model accuracy by ~1-2 % points
- **Hip Hop** songs were classified correctly more often compared to songs in other genres (true for both audio and lyrics)
- **Country** commonly misclassified as rock – small sample size issue or close genre overlap?

## Recommendations for Future Research

- **Model Tuning.** Work with finding best parameters settings for different models
- **Songs Overlap Genres.** This problem might be better suited for multilabel classification
- **Get More Data.**  Sample sizes & class imbalances can impact model performance.
- **Genre Evolution.** Future research should take into consideration time (Rock in the 60s vs. 80s) and sub-genre classifications (Rock might be too broad – Grunge vs. Indie?)
- **Exploring Rhyme Patterns.**  Is there a relationship between rhyme patterns and genre?
- **Combining Audio & Lyrics.**  What would the modeling results look like if we tested both?
- **Additional Applications.** Option to explore creating Recommendation Systems based on song features


