import 'dart:html';
import 'dart:js';
import 'dart:async';
import 'package:mapengine/gmap.dart';

void main() {
  var map = new GMap('#map');
  map.drawMap();
  map.addMarkersToMap([{'latLng': [48.161154, 17.137031]}]);
  new Future.delayed(new Duration(milliseconds: 1000), () {
    map.reloadMapWithNewMarkers(
        markers: [
                  {'latLng': [47, 16]},
                  {'latLng': [46, 15]},
                  {'latLng': [45, 14]},
                  {'latLng': [44, 13]},
                  {'latLng': [43, 12]}
                 ], 
        events: {}, 
        autofit: true
    );
  });
  
}






