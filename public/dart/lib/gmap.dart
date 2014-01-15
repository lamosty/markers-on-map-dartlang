library gmap;

import 'dart:async';
import 'dart:html';
import 'package:mapengine/js_helper.dart';
import 'dart:convert';
import 'dart:math' as math;

class GMap {
  // Private properties
  Map<int, Map> _markers = {}; // map of markers, key is marker's ID
  Map<String, JsObject> _markerIcons = {}; // map of marker icons used on the GMap, key is icon url
  int _lastMarkerId = -1; // Unique id of the last marker placed on the map.
  
  // Public properties
  final String elementId; // HTML element that the map is bound to.
  Map mapOptions;
  Map mapEvents = {};
  Map mapOnces = {};
  

  // Helpers
  JsHelper js;
  
  // Getters
  int get nextMarkerId => ++_lastMarkerId;

  GMap(this.elementId) {
    // Initialize JsHelper with #map element id
    js = new JsHelper(elementId);

    mapOptions = {
      'center': [48.161154, 17.137031],
      'mapTypeId': js.gmaps['MapTypeId']['ROADMAP'],
      'zoom': 15
    };
  }

  void setMapOptions({
    List<double> center,
    int zoom
  }) {
    mapOptions['center'] = center;
    mapOptions['zoom'] = zoom;
  }

  void addMapEvent(String eventName, Function eventFunction) {
    mapEvents[eventName] = js.func(eventFunction);
  }
  
  /**
   * Add events that fire only once (thus the name onces).
   */
  void addMapOnces(String eventName, Function eventFunction) {
    mapOnces[eventName] = js.func(eventFunction);
  }

  Map getMapParams() {
    return {
        'map': {
            'options': mapOptions,
            'events':  mapEvents,
            'onces': mapOnces
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

 /**
  * Redraws the map with changed map options.
  */
  void redrawMap(Map newMapOptions) {
    var params = {
      'map': {
        'options': newMapOptions
      }
    };

    js.gmap3(params);
  }

/**
  * Returns Google Map as a normal Google Map JS map version
*/
  JsObject getJsMap() {
    return js.gmap3('get');
  }
    
  JsObject getJsMarker(int markerId) {
    return js.gmap3({
      'get' : {
        'id' : markerId.toString()
      }
    });
  }
  
  void addJsMarkerEvent(JsObject jsMarker, String eventName, JsFunction eventFunction) {
    js.gmaps['event'].callMethod('addListener', 
        [jsMarker, eventName, eventFunction]
    );
  }

  /**
    * This method zooms and centers the map in such a way that all the objects
    * are visible on the map (markers, overlays, etc).
  */
  void autofit() {
    js.gmap3('autofit');
  }
  
  int addNewMarker(
      List<double> latLng, 
      {
        Map markerOptions : const {}, 
        Map markerData : const {}, 
        Map markerEvents : const {}
      }
  ) {
    if (markerOptions != null) {
      if (markerOptions.containsKey('icon')) {
        
        markerOptions['icon'] = _iconGenerator(markerOptions['icon']);
      }
    }
    
    int newMarkerId = nextMarkerId;
    
    var newMarker = {
      'latLng' : latLng,
      'options' : markerOptions,
      'data' : markerData,
      'events' : markerEvents,
      'id' : newMarkerId.toString()
    };
        
    _markers[newMarkerId] = newMarker;
    
    // Return ID of currently added marker.
    return newMarkerId;
  }

  /**
   * Draws markers specified by their IDs on the Google Map.
   * If autofit is set to true, map will zoom out so all new added
   * markers can be seen on the map.
   */
  void drawMarkersOnMap(List<int> markerIds, {bool autofit: false}) {
    var params = {
        'marker': {
            'values': () {
              var markersInList = [];
              for (var markerId in markerIds) {
                markersInList.add(_markers[markerId]);
              }
              
              return markersInList;
            }()
        }
    };

    js.gmap3(params);

    if (autofit) {
      this.autofit();
    }
  }
  
  void reloadMapWithNewMarkers({
    List<Map> markers,
    bool autofit: true,
    Map events
  }) {
    this._clearMarkersFromMap(() {
    // Let's have a little delay in case map hasn't cleared yet.
      return new Future.delayed(new Duration(milliseconds: 1), () {
        var params = {
            'marker': {
                'values': markers,
                'events': events
            }
        };

        // Run params on the map.
        js.gmap3(params);

        // After markers have been added to the map, autofit it if necessary.
        new Future.delayed(new Duration(milliseconds: 1), () {
          if (autofit) {
            this.autofit();
          }
        });

      });

    });
  }

  void triggerResize() {
    var map = js.gmap3('get');
    var center = map.callMethod('getCenter', []);
    js.gmaps['event'].callMethod('trigger', [map, 'resize']);
    map.callMethod('setCenter', [center]);
  }

  // Returns marker by markerId.
  Map getMarker(int markerId) {
    return _markers.containsKey(markerId) ? _markers[markerId] : {};
  }
  
  
/**
  * This method creates simple overlay over the map for specified marker
  * at the specified position with specified data for specified marker.
  * The marker will hold the data (heading and body text).
*/
  void createSimpleOverlay(
       int markerId, 
       String overlayHtmlTemplate, 
       dynamic overlayClickFunction
   ) {
    var params = {
      'overlay' : {
        'latLng' : _markers[markerId]['latLng'],
        'options' : {
          'content' : overlayHtmlTemplate,
          'offset' : {
            'y' : -80,
            'x' : 30
          }
        },
        'events' : {
          'click' : overlayClickFunction(markerId)
        }
      }
    };

    js.gmap3(params);
  }

  /**
   * Clears all overlays from the map.
   */
  void clearAllOverlays() {
    var params = {
      'clear' : 'overlay'
    };

    js.gmap3(params);
  }

  void removeMarker(int markerId) {
    _markers.remove(markerId);
    
    var params = {
      'clear' : {
        'id' : markerId.toString()
      }
    };
    js.gmap3(params);   
  }
  
  /**
   * Change basic marker options.
   */
  void changeMarkerOptions(int markerId, {String iconUrl, List<int> iconSize}) {
    if (_markers.containsKey(markerId)) {
      if (iconUrl != null) {
        _markers[markerId]['options']['icon'] = _iconGenerator(iconUrl, iconSize);
        
        var jsMarker = getJsMarker(markerId);
        jsMarker.callMethod('setIcon', [_markers[markerId]['options']['icon']]);
      } 
    }
  }
  
  /**
   * This method generates new icon based on specified arguments and
   * saves it into local cache. Next time the same icon is being called,
   * it loads from cache instead of creating new one.
   */
  JsObject _iconGenerator(String iconUrl, [List<int> iconSize]) {
    if (_markerIcons.containsKey(iconUrl)) {
      return _markerIcons[iconUrl];
    }
    
    if (iconSize == null) {
      iconSize = [32, 37];
    }
    
    var iconSizeObject = new JsObject(js.gmaps['Size'], iconSize);
    
    _markerIcons[iconUrl] = js.jsify({
      'url' : iconUrl,
      'size' : iconSizeObject,
      'anchor' : new JsObject(js.gmaps['Point'], [17, 15])
    });
    
    return _markerIcons[iconUrl];
  }
  
  /**
   * Return markerId by comparing all marker latLng's stored against supplied
   * latitude and longitude. If there is no such marker with specified lat and lng,
   * return -1;
   */
  int getMarkerIdByLatLng(List<double> latLngInList) {
    for (var marker in _markers.values) {
      if (marker['latLng'][0] == latLngInList[0] && marker['latLng'][1] == latLngInList[1]) {
        return marker['id'];
      }
    }
    
    return -1;
  }
  
  List<double> extractLatLngFromGoogleMarker(dynamic marker) {
    var latLng = marker['latLng'];
    return _shortenLatLngNumberDigits([latLng['b'], latLng['d']]);
  }
  
  List<double> _shortenLatLngNumberDigits(List<double> latLng, [int numOfDigits = 6]) {
    int pow = math.pow(10, numOfDigits);
    double lat = (latLng[0] * pow).round() / pow;
    double lng = (latLng[1] * pow).round() / pow;
    
    return [lat, lng];
  }
  
  /**
   * This method returns reverse-geocoded results as
   * the result of the Dart's [Future] for specified 
   * latitude and longitude that can be used to find address of
   * the specified lat and lng.
   */
  Future<JsObject> reversedGeocodeLatLng(List<double> latLng) {
    Completer c = new Completer();
    
    var params = {
      'getaddress' : {
        'latLng' : latLng,
        'callback' : js.func((jsThis, results, _) {
          c.complete(results);
        })
      }
    };
    
    js.gmap3(params);
    
    return c.future;
  }


//  String exportMarkersAsJSON() {
//    List<Map> markersToExport = new List();
//
//    for (Map marker in _markers.values) {
//      markersToExport.add(marker);
//    }
//
//    return JSON.encode(markersToExport);
//  }
//
//  void importMarkersFromJSON(String markersInJSON) {
//    var newMarkers = JSON.decode(markersInJSON);
//
//    for (Map marker in newMarkers) {
//      marker['id'] = ++_lastMarkerId;
//      _markers[marker['id']] = marker;
//    }
//
//    addMarkersToMap(newMarkers, _generateNewMarkerEvents(), autofit: true);
//
//  }
//
//  void removeAllMarkersFromMap() {
//    var params = {
//      'clear' : {
//        'name' : "marker"
//      }
//    };
//
//    js.gmap3(params);
//
//    _markers = {};
//  }

}













