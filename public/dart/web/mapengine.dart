import 'dart:html';
import 'dart:js';

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
  /*jQuery.apply(['#map']).callMethod('gmap3', [mapOptions]);*/
  var j = new J('#map');
  j.gmap3(mapOptions);
}

void j(q) {
  var jQuery = context['\$'];

  var gmap3 = (options) {
    jQuery.apply([q]).callMethod('gmap3', [options]);
  };
}

class J {
  String selector;

  J(this.selector) {

  }

  void gmap3(options) {
    var jQuery = context['\$'];
    jQuery.apply([selector]).callMethod('gmap3', [options]);

  }
}



