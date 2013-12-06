library map;

import 'dart:js';
import 'package:mapengine/js_helper.dart';

class GMap {
  final String elementId;
  JsHelper js;
  var mapOptions;
  
  // JS contexts
  final gmaps = context['google']['maps']; 
  
  GMap(this.elementId) {
    mapOptions = {
      'center': [48.161154, 17.137031],
      'mapTypeId': gmaps['MapTypeId']['ROADMAP'],
      'zoom': 15
    };
    
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
  
}