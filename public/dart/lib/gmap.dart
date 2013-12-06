library gmap;

import 'dart:js';
import 'package:mapengine/js_helper.dart';

part 'src/marker.dart';

class GMap {
  // Properties
  final String elementId;
  var mapOptions;
  
  // JS contexts
  final gmaps = context['google']['maps']; 
  
  // Helpers
  JsHelper js;
  
  GMap(this.elementId) {
    mapOptions = {
      'center': [48.161154, 17.137031],
      'mapTypeId': gmaps['MapTypeId']['ROADMAP'],
      'zoom': 15
    };
    
    // Initialize JsHelper with #map element id
    js = new JsHelper(elementId);
    
  }

  void setMapOptions({
    List<double> center
  }) {
    mapOptions['center'] = center;
  }
  
  Map getMapParams() {
    return {
      'map': {
        'options': mapOptions
      }
    };
  }
  

  void _clearMarkersFromMap([callback]) {
    var params = {
      'clear': {
        'name': "marker",
        'callback': js.func((jsThis, event) {
          if (callback != null) {
            callback();
          }
        })
      }
    };
    
    js.gmap3(params);
  }
  
  void drawMap() {
    // Initialize the map and draw it.
    js.gmap3(getMapParams());
    
  }
 
  
  void autofit() {
    js.gmap3('autofit');
  }
  
  void addMarkersToMap(List<Marker> markers) {
    
  }
  
  
}