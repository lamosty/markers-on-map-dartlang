library gmap;

import 'dart:async';
import 'dart:html';
export 'dart:html';
import 'package:mapengine/js_helper.dart';

class GMap {
  // Properties
  final String elementId;
  Map mapOptions;
  Map mapEvents = {};

  // Helpers
  JsHelper js;

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
    List<double> center
  }) {
    mapOptions['center'] = center;
  }

  void addMapEvent(String eventName, Object eventFunction) {
    mapEvents[eventName] = eventFunction();
    print(mapEvents);
  }

  Map getMapParams() {
    return {
        'map': {
            'options': mapOptions,
            'events':  mapEvents
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


  void autofit() {
    js.gmap3('autofit');
  }

  void addMarkersToMap(List<Map> markers) {
    var params = {
        'marker': {
            'values': markers
        }
    };

    js.gmap3(params);
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

    JsFunction getDefaultMousedownEvent() {
      return js.func((jsThis, marker, event, context) {
        var markerPosition = marker.callMethod('getPosition', []);

        DivElement markerPositionDiv = new DivElement()
          ..text = 'Clicked marker position is: $markerPosition';

        querySelector('.map-container')
          ..append(markerPositionDiv);

      });
    }

  // Part of WEGA project
  JsFunction mapMouseDown() {
    return js.func((jsThis, _, event, something) {
        print('hello');
        window.console.log(jsThis);
        print(event['latLng']);
    });
  }
}













