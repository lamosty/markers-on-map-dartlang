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
  
  JsObject _jsify(params) {
    return new JsObject.jsify(params);
  }
  
  void _callGmapWithParams(dynamic params) {
    jQuery.apply([elementId]).callMethod(gmap3, [params]);
  }
  
  void _clearMarkersFromMap([callback]) {
    var params = this._jsify({
      'clear': {
        'name': "marker",
        'callback': new JsFunction.withThis((jsThis, event) {
          if (callback != null) {
            callback();
          }
        })
      }
    });
    
    this._callGmapWithParams(params);
  }
  
  void drawMap() {
    // Initialize the map and draw it.
    
    this._callGmapWithParams(this._jsifyMapOptions());
    
    this._clearMarkersFromMap(() {
      print('hello');
    });
  }
 
  
  void autofitMap() {
    this._callGmapWithParams('autofit');
  }
  
}