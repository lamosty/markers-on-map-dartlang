**MapEngine**

MapEngine is a web application which by using Google Maps API enables the user to display, filter, add and remove items (data) on this map. When I say 'items', what I really mean are markers serving for getting the attention of our users to the fact that there is something on the place they are just standing on. I will not focus on specific type of items (e.g. beauty salons) that will be displayed on the map but rather on a system that makes it simple and easy to add or change these data. Therefore, the result of my project is going to be a carefully crafted application with refined user interface in which its users will be able to plug-in different types of data streams and subsequently show and add it on the Google Maps by means of markers.

**Short Description of MapEngine behavior**

The project is divided into two main parts - back-end (the server) and front-end (the client). There will be running an application on the back-end which will be connected to database storing marker's data. The application will listen to incoming requests from the client (a person browsing the page on his or her computer) evaluating them and returning the requested data. An application on the client side (in user's browser) will also be running, responding to the user's demands by sending them to the back-end, from which it will subsequently be awaiting a response with appropriate result.

An Example:  

A user called Rasto visits our website powered by MapEngine which is specialised on beauty salons. He will instantly see Google Maps with a lot of markers representing specific beauty salons (e.g. in Stare Mesto in Bratislava). There could be salons such as Adriana Salon offering hairdressing and manicure, Alfa Centrum Salon offering massages and lotions and plenty of other beauty salons located just in the visible area of the map among them. Rasto needs a quality massage and lotion urgently but he does not have the time and willingness to search through large number of markers on the map and so he types these requirements in the filter located on the left side of the page: "I want a massage (he checks a field saying 'massages' in the service filter) but also a lotion (he also checks a field saying 'lotions'), it should be located in the Stare Mesto in Bratislava (he types Bratislava in the input field saying 'locality' and confirms it by mouse click) and I want only those beauty salons that are offering their services also to a man (he checks a field saying 'a man' in the Select your Gender part of the filter). Then he clicks on the search button and the map centers on the Stare Mesto and only results fulfilling all his requirements  are displayed for him instantly. After that, he clicks on the marker closest to his flat and a small window with additional information (such as opening hours, phone number, address, etc.) about the selected beauty salon opens up.

By using Google Maps for displaying specified items, Rasto both did not have to scroll through those large endless lists of beauty salons and also did not have to look at each of them in order to discover their location or what they are really offering him.

**Result and Operation of MapEngine**

It will be possible to establish a web portal with for example beauty salons, miscellaneous shops, selling and buying real estate and others with custom layouts and design in a really short period of time thanks to the MapEngine. The newly-created website will take advantage of various pre-made components and functionality without the need of programming all of these parts. After that, it will be deployed on our client's server and ready to go.

**Note**
All the Dart code is located inside ./public/dart folder. It includes my custom Dart library for working with Google Maps API v3 and a simple application on top of that.
