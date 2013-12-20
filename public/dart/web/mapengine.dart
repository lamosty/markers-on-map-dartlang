import 'dart:async';
import 'package:mapengine/gmap.dart';

void main() {
  // Prepare a new map object with default map options.
  var map = new GMap('#map');
  map.addMapEvent('click', map.mapMouseDown);
  
  // Draw map with specified options.
  map.drawMap();
  
  // Add some testing marker to the map.
//  map.addMarkersToMap([{'latLng': [48.161154, 17.137031]}]);


  
}

// Testing functions
void addDelayedMarkers(int timeInMs, GMap map) {
  //  After some time, add some more markers with a mousedown event.
  new Future.delayed(new Duration(milliseconds: timeInMs), () {
    map.reloadMapWithNewMarkers(
        markers: [
                  {'latLng': [47, 16]},
                  {'latLng': [46, 15]},
                  {'latLng': [45, 14]},
                  {'latLng': [44, 13]},
                  {'latLng': [43, 12]}
                 ], 
        events: {'click': map.getDefaultMousedownEvent()}
    );
  });
}






