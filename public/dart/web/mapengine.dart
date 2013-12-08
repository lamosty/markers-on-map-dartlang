import 'dart:html';
import 'dart:js';
import 'dart:async';
import 'package:mapengine/gmap.dart';

void main() {
  // Prepare a new map object with default map options.
  var map = new GMap('#map');
  
  // Draw map with specified options.
  map.drawMap();
  
  // Add some testing marker to the map.
  map.addMarkersToMap([{'latLng': [48.161154, 17.137031]}]);
  
  // After some time, add some more markers with a mousedown event.
  new Future.delayed(new Duration(milliseconds: 2000), () {
    map.reloadMapWithNewMarkers(
        markers: [
                  {'latLng': [47, 16]},
                  {'latLng': [46, 15]},
                  {'latLng': [45, 14]},
                  {'latLng': [44, 13]},
                  {'latLng': [43, 12]}
                 ], 
        events: {'mousedown': map.getDefaultMousedownEvent()}
    );
  });
  
}






