library js_helper;

import 'dart:js';

class JsHelper {
  // Properties
  String elementId;
  
  // JS contexts
  final jQuery = context['jQuery'];
  final gmaps = context['google']['maps'];
  
  
  // Public methods
  
  JsHelper(
    [this.elementId]
  );
  
  void gmap3(dynamic params) {
    var jsParams;
    
    if (params is String) {
      jsParams = params;
    } else if (params is Map) {
      jsParams = _jsify(params);
    }
    
    jQuery.apply([elementId]).callMethod('gmap3', [jsParams]);
  }
  
  JsFunction func(Function f) {
    return new JsFunction.withThis(f);
  }
  
  // Private methods
  
  JsObject _jsify(params) {
    return new JsObject.jsify(params);
  }
  
}