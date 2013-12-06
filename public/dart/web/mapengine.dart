import 'dart:html';
import 'dart:js';
import 'package:mapengine/map.dart' as GMap;

void main() {
  var jQuery = context['\$'];
  var googleMaps = context['google']['maps'];
  var mapOptions = new JsObject.jsify({
      'map': {
        'address':"POURRIERES, FRANCE",
        'options':{
          'zoom':10,
          'mapTypeId': googleMaps['MapTypeId']['ROADMAP'],
          'mapTypeControl': true
        }
      }
    });
  
  
  var map = new GMap.Map('#map');
  map.gmap3(mapOptions);
}






