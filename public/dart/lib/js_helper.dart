library js_helper;

import 'dart:js';
export 'dart:js';

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

  dynamic gmap3(dynamic params) {
    var jsParams;

    if (params is String) {
      jsParams = params;
    } else if (params is Map) {
      jsParams = _jsify(params);
    }
    
    return jQuery.apply([elementId]).callMethod('gmap3', [jsParams]);
  }
  
  /**
   * Calls jQuery on specified selector with specified method that is 
   * fed by specified arguments.
   */
  JsObject $(String selector, String methodName, [Map args = const {}]) {
    return jQuery.apply([selector]).callMethod(methodName, [_jsify(args)]);
  }

  JsFunction func(Function f) {
    return new JsFunction.withThis(f);
  }

  // Private methods

  JsObject _jsify(params) {
    return new JsObject.jsify(params);
  }

}
