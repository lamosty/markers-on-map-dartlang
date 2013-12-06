library map;

import 'dart:js';

class Map {
  final String elementId;
  
  Map(
      this.elementId
  );
  
  void gmap3(options) {
    var jQuery = context['\$'];
    jQuery.apply([this.elementId]).callMethod('gmap3', [options]);

  }
}