import 'package:mapengine/gmap.dart';
import 'package:mapengine/js_helper.dart';
import 'dart:html';
import 'dart:async';

void main() {
  MapEngine mapEngine = new MapEngine('#map');
}

class MapEngine {
  GMap map; // Map we are working with
  JsHelper js = new JsHelper(); // JS helper class
  
  MapEngine([String mapContainerId = '#map']) {
    map = new GMap(mapContainerId);
    initializeMap();
    
    attachAllEventListeners();
    initializeMultiSelectBoxes();
    
    map.drawMap();
  }
  
  void initializeMap() {
    List<double> mapCenter = [48.165548, 17.134799];
    int mapZoomLevel = 11;
    
    map.setMapOptions(
        center: mapCenter,
        zoom: mapZoomLevel
    );
    
    map.addMapEvent('click', createNewMarker);   
  }
  
  /**
   * Attaches all event listeners to to web.
   */
  void attachAllEventListeners() {
    
  }
  
  void initializeMultiSelectBoxes() {
    js.$('#locality-select', 'select2');
    js.$('#type-select', 'select2');
  }
  
  Function createNewMarker(jsThis, sender, event, context) {
    // Clear overlays that might be opened.
    map.clearAllOverlays();

    var jsLatLng = event['latLng'];

    int newMarkerId = map.addNewMarker(
        jsLatLng['b'], jsLatLng['d'],
        markerData: {
          'heading' : '',
          'body' : '',
          'type' : ''
        },
        markerEvents: defaultMarkerEvents()
    );

    map.drawMarkersOnMap([newMarkerId]);
    map.createSimpleOverlay(newMarkerId, editable: true);
  }
  
  /**
   * Returns events for new marker that has been added to the map
   * by clicking on it.
  */
  Map defaultMarkerEvents() {
    return {

      'mouseover': js.func((jsThis, marker, event, context) {
        map.createSimpleOverlay(context['id']);

      }),

      'mouseout' : js.func((jsThis, marker, event, context) {

        map.clearAllOverlays();

      }),

      'click' : js.func((jsThis, marker, event, context) {

        map.clearAllOverlays();

        var mouseOutFunction = js.func((jsThis, event) {
          map.clearAllOverlays();
        });

        js.gmaps['event'].callMethod('clearListeners', [marker, 'mouseout']);

        map.createSimpleOverlay(context['id'], editable: true, callback: () {
          js.gmaps['event']['addListener'].apply([marker, 'mouseout', mouseOutFunction]);
        });
      })
    };
  }

}






