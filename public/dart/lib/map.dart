library map;

import 'dart:js';

class Map {
  final String elementId;
  var mapOptions;
  
  // JS contexts
  final jQuery = context['jQuery'];
  final gmaps = context['google']['maps']; 
  
  // Gmap3 plugin name
  final String gmap3 = 'gmap3';
  
  Map(this.elementId) {
    mapOptions = {
      'center': [48.161154, 17.137031],
      'mapTypeId': gmaps['MapTypeId']['ROADMAP'],
      'zoom': 15
    };
  }

  void setMapOptions({
    List<double> center
  }) {
    mapOptions['center'] = center;
  }
  
  JsObject _jsifyMapOptions() {
    return new JsObject.jsify({
      'map': {
        'options': mapOptions
      }
    });
  }
  
  void drawMap() {
    jQuery.apply([elementId]).callMethod(gmap3, [this._jsifyMapOptions()]);
  }
  
  void autofitMap() {
    var applied = jQuery.apply([elementId]);
    
    applied.callMethod(gmap3, ['autofit']);
  }
  
}