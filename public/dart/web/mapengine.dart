import 'dart:html';
import 'dart:js';
import 'package:mapengine/map.dart' as GMap;

void main() {  
  var map = new GMap.Map('#map');
  map.drawMap();
  map.autofitMap();
}






