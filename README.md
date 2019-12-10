# airDates
This app represents a simple and concise Graphical User Interface wrapped around the API provided by episodate.com implementing its own unique features, allowing you to customize your own list of tracked TV shows. airDates is fully written in pure Swift and libraries provided by Apple, including CoreData and Foundation.
## Features
The main idea of airDates is to create a convenient cluster of information regarding TV shows in which the user can effortlessly track the release dates for the shows' upcoming episodes in real time.
## Libraries used
airDates uses CoreData store the list of TV shows that are tracked by the user and keep their relevant info. It heavily relies on remote connection to episodate's API through Foundation's URLSession class.