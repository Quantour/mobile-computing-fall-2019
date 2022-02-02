# Wanderlust: Community for Hikers

* This project is a part of the course [Mobile Computing and its Applications](http://sugang.snu.ac.kr/sugang/cc/cc103.action?openSchyy=2019&openShtmFg=U000200002&openDetaShtmFg=U000300001&sbjtCd=4190.406B&ltNo=001&lang=eng), delivered in Fall 2019 @ [Seoul National University](http://en.snu.ac.kr/).

We built a mobile application which serves as both a guide and a community to hikers all over the world. We used Flutter, Google Maps, and Google Firebase to build our application. The main functionalities available on the user's side are as follows:

- Follow routes on the Cloud database
- Create a new route on the map and try the route
- Explore new routes which will be tracked automatically
- Rate routes & Add pins for special spots



### Note: How to add Google Maps API Key to the project

Create a file Wanderlust/lib/google_maps_api.dart with the following content:
`const String kGoogleMapsApiKey = "API_KEY";`
where `API_KEY` is replaced by the API Key from the google developer console.

