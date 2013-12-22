library gmap;

import 'dart:async';
import 'dart:html';
export 'dart:html';
import 'package:mapengine/js_helper.dart';
import 'dart:convert';

class GMap {
  // Properties
  final String elementId; // HTML element that the map is bound to.
  Map mapOptions;
  Map mapEvents = {};
  // used to identify markers, should increment if new marker is added
  int _lastMarkerId = -1;
  Map<int, Map> _markers = {}; // map of markers, key is marker's ID

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

  void addMarkersToMap(List<Map> markers, Map events, {bool autofit: false}) {
    var params = {
        'marker': {
            'values': markers,
            'events': events
        }
    };

    js.gmap3(params);

    if (autofit) {
      this.autofit();
    }
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

      // Clear overlays that might be opened.
      clearAllOverlays();

      var jsLatLng = event['latLng'];

      var newMarker = {
        'latLng' : [jsLatLng['nb'], jsLatLng['ob']],
        'data' : {
          'heading' : '',
          'body' : ''
        },
        'id' : ++_lastMarkerId
      };

      _markers[newMarker['id']] = newMarker;

      addMarkersToMap([newMarker], _generateNewMarkerEvents());
      createSimpleOverlay(newMarker['id'], editable: true);

    });
  }

/**
  * Returns events for new marker that has been added to the map
  * by clicking on it.
*/
  Map _generateNewMarkerEvents() {
    return {

      'mouseover': js.func((jsThis, marker, event, context) {

        createSimpleOverlay(context['id']);

      }),

      'mouseout' : js.func((jsThis, marker, event, context) {

        clearAllOverlays();

      }),

      'click' : js.func((jsThis, marker, event, context) {

        clearAllOverlays();

        var mouseOutFunction = js.func((jsThis, event) {
          clearAllOverlays();
        });

        js.gmaps['event'].callMethod('clearListeners', [marker, 'mouseout']);

        createSimpleOverlay(context['id'], editable: true, callback: () {
          js.gmaps['event']['addListener'].apply([marker, 'mouseout', mouseOutFunction]);
        });
      })
    };
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
        ..id = 'heading-input'
        ..autofocus = true;

      body = new TextAreaElement()
        ..text = data['body']
        ..id = 'body-input';

      ButtonElement confirmButton = new ButtonElement()
        ..text = 'Save'
        ..id = 'save-marker';

      ButtonElement deleteButton = new ButtonElement()
        ..text = 'Remove'
        ..id = 'remove-marker';

      overlayContainer.children.add(confirmButton);
      overlayContainer.children.add(deleteButton);

    } else {
      heading = new DivElement()
        ..classes.add('text')
        ..text = data['heading'];

      body = new ParagraphElement()
        ..text = data['body']
        ..classes.add('text');
    }

    headingContainer.children.add(heading);
    bodyContainer.children.add(body);

    return overlayContainer.outerHtml;
  }

/**
  * This method creates simple overlay over the map for specified marker
  * at the specified position with specified data for specified marker.
  * The marker will hold the data (heading and body text).
*/
  void createSimpleOverlay(int markerId, {editable: false, callback}) {
    var params = {
      'overlay' : {
        'latLng' : _markers[markerId]['latLng'],
        'options' : {
          'content' : createSimpleOverlayTemplate(_markers[markerId]['data'], editable: editable),
          'offset' : {
            'y' : -80,
            'x' : 30
          }
        },
        'events' : {
          'click' : js.func((jsThis, sender, event, context) {
            // event[0] is a mouse click event that was triggered by
            // clicking on the button
            if (event[0].target.id == 'save-marker') {
              InputElement heading = querySelector('#heading-input');
              InputElement body = querySelector('#body-input');

              String headingText = heading.value;
              String bodyText = body.value;

              _markers[markerId]['data']['heading'] = headingText;
              _markers[markerId]['data']['body'] = bodyText;

              clearAllOverlays();

              if (callback != null) {
                callback();
              }
            } else if (event[0].target.id == 'remove-marker') {
              _removeMarker(_markers[markerId]['id']);
              clearAllOverlays();
            }
          })
        }
      }
    };

    js.gmap3(params);
  }

  void clearAllOverlays() {
    var params = {
      'clear' : 'overlay'
    };

    js.gmap3(params);
  }

  void _removeMarker(int markerId) {
    var params = {
      'clear' : {
        'id' : markerId.toString()
      }
    };

    js.gmap3(params);

    _markers.remove(markerId);
  }


  String exportMarkersAsJSON() {
    List<Map> markersToExport = new List();

    for (Map marker in _markers.values) {
      markersToExport.add(marker);
    }

    return JSON.encode(markersToExport);
  }

  void importMarkersFromJSON(String markersInJSON) {
    var newMarkers = JSON.decode(markersInJSON);

    for (Map marker in newMarkers) {
      marker['id'] = ++_lastMarkerId;
      _markers[marker['id']] = marker;
    }

    addMarkersToMap(newMarkers, _generateNewMarkerEvents(), autofit: true);

  }

  void removeAllMarkersFromMap() {
    var params = {
      'clear' : {
        'name' : "marker"
      }
    };

    js.gmap3(params);

    _markers = {};
  }

}













