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
    map.drawMap();
    
    attachAllEventListeners();
    initializeMultiSelectBoxes();
  }
  
  void initializeMap() {
    List<double> mapCenter = [48.165548, 17.134799];
    int mapZoomLevel = 11;
    
    map.setMapOptions(
        center: mapCenter,
        zoom: mapZoomLevel
    );
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
}






