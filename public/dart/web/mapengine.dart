import 'dart:html';
import 'dart:js';

void main() {
  var object = new JsObject(context['Object']);
  object['greeting'] = 'Hello';
  object['greet'] = (name) {
    return "${object['greeting']} $name";
  };

  var jsMap = new JsObject.jsify([1, 2, 3]);

  var result = test(jsMap);

  context.callMethod('alert', [result]);
}

dynamic test(f) {
  var result = 0;

  for (var i = 0; i < f.length; i++) {
    result += f[i];
  }

  return result;
}


