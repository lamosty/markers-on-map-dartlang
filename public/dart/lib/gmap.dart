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


  /**
    * This method zooms and centers the map in such a way that all the objects
    * are visible on the map (markers, overlays, etc).
  */
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

      createSimpleOverlay(event['latLng'], {'heading': 'My Super Marker', 'body': 'My super body'});
    });
  }

/**
  * Creates overlay (basically something that floats above the Google Map)
  * with specified data (heading and body texts). If editable flag is on,
  * overlay creates itself with input boxes where the data can be changed.
*/
  String createSimpleOverlayTemplate(Map data, {editable: false}) {
    DivElement overlayContainer = new DivElement()..classes.add('map-item');
    DivElement headingContainer = new DivElement()..classes.add('heading');
    DivElement bodyContainer = new DivElement()..classes.add('body');

    overlayContainer.children.add(headingContainer);
    overlayContainer.children.add(bodyContainer);

    Node heading;
    Node body;

    if (editable) {
      heading = new InputElement(type: 'text')
        ..setAttribute('value', data['heading'])
        ..id = 'heading-input';

      body = new TextAreaElement()
        ..text = data['body']
        ..id = 'body-input';

      ButtonElement confirmButton = new ButtonElement()
        ..text = 'Save Marker'
        ..id = 'save-marker';
      overlayContainer.children.add(confirmButton);

    } else {
      heading = new Text(data['heading']);

      body = new ParagraphElement()
        ..text = data['body'];
    }

    headingContainer.children.add(heading);
    bodyContainer.children.add(body);

    return overlayContainer.outerHtml;
  }

  void createSimpleOverlay(position, data) {
    var params = {
      'overlay' : {
        'latLng' : position,
        'options' : {
          'content' : createSimpleOverlayTemplate(data, editable: true)
        },
        'events' : {
          'click' : js.func((jsThis, sender, event, context) {
            // event[0] is a mouse click event that was triggered by
            // clicking on the button
            if (event[0].target.id == 'save-marker') {
              String headingText = querySelector('#heading-input').value;
              String bodyText = querySelector('#body-input').value;
              print(sender['latLng']);

            }
          })
        }
      }
    };

    js.gmap3(params);

  }

}













