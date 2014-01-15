import 'package:mapengine/gmap.dart';
import 'package:mapengine/js_helper.dart';
import 'dart:html';
import 'dart:async';
import 'dart:convert';

void main() {
  MapEngine mapEngine = new MapEngine('#map');
}

class MapEngine {
  GMap map; // Map we are working with
  JsHelper js = new JsHelper(); // JS helper class
  
  int _lastMarkerId = -1; // Id of the last marker that was shown on the GMap
  
  final Map<String, String> _markerIcons = {
    'mapengine' : '/assets/markers/mapengine.png',
    'home' : '/assets/markers/home.png',
    'work' : '/assets/markers/work.png'
  };
  
  MapEngine([String mapContainerId = '#map']) {
    map = new GMap(mapContainerId);
    initializeMap();
    
    attachAllEventListeners(); 
    map.drawMap();
    
    initializeAllComponents();
  }
  
  void initializeMap() {
    List<double> mapCenter = [48.165548, 17.134799];
    int mapZoomLevel = 11;
    
    map.setMapOptions(
        center: mapCenter,
        zoom: mapZoomLevel
    );
    
    map.addMapEvent('click', createNewMarker);   
    map.addMapOnces('idle', loadMarkersFromServer);
  }
  
  /**
   * Attaches all event listeners to to web.
   */
  void attachAllEventListeners() {
    
  }
  
  void initializeAllComponents() {
    _initializeMultiSelectBoxes();
    _initializePlacesAutocomplete();
  }
   
  Function createNewMarker(jsThis, sender, event, context) {
    if (_lastMarkerId != -1) {
      map.removeMarker(_lastMarkerId);
    }
    
    // Clear overlays that might be opened.
    map.clearAllOverlays();

    int newMarkerId = map.addNewMarker(
        map.extractLatLngFromGoogleMarker(event),
        markerData: {
          'heading' : '',
          'body' : '',
          'markerType' : 'mapengine',
          'street' : '',
          'zip' : '',
          'city' : '',
          'country' : ''
        },
        markerOptions: {
          'icon' : _markerIcons['mapengine']
        },
        markerEvents : defaultMarkerEvents()
    );
        
    map.drawMarkersOnMap([newMarkerId]);
    map.createSimpleOverlay(
        newMarkerId, 
        createSimpleOverlayTemplate(map.getMarker(newMarkerId), editable: true),
        _overlayClickFunction
    );
    
    _lastMarkerId = newMarkerId;
  }
  
  /**
   * Loads and draw on the Google Map markers from the server.
   */
  Function loadMarkersFromServer(jsThis, sender, event, context) {    
    var url = "http://${window.location.host}/markers/all.json";
    
    HttpRequest.getString(url).then((markers) {
      Map markersInJson = JSON.decode(markers);
      List markersInList = JSON.decode(markersInJson['markers']);

      if (markersInList.isEmpty) {
        return;
      }
      
      print(markersInList);
      
      List<int> newMarkersIds = [];
      
      for (var marker in markersInList) {
        newMarkersIds.add(
          map.addNewMarker(
            [marker['lat'], marker['lng']],
            markerData: {
              'heading' : marker['heading'],
              'body' : marker['body'],
              'markerType' : marker['markerType'],
              'street' : marker['street'],
              'zip' : marker['zip'],
              'city' : marker['city']['title'],
              'country' : marker['country']['title']
            },
            markerOptions: {
              'icon' : _markerIcons[marker['markerType']]
            },
            markerEvents : defaultMarkerEvents()
          )
        );
      }
      
      map.drawMarkersOnMap(newMarkersIds);
    });
  }
    
  /**
   * Returns events for new marker that has been added to the map
   * by clicking on it.
  */  
  Map defaultMarkerEvents() {
    return {

      'mouseover': js.func((jsThis, marker, event, context) {
        if (_lastMarkerId != -1) {
          return;
        }
        
        var markerId = int.parse(context['id']);
        
        map.createSimpleOverlay(
            markerId, 
            createSimpleOverlayTemplate(map.getMarker(markerId)),
            _overlayClickFunction
        );

      }),

      'mouseout' : js.func((jsThis, marker, event, context) {
        if (_lastMarkerId != -1) {
          return;
        }
        map.clearAllOverlays();

      }),

      'click' : js.func((jsThis, marker, event, context) {
        var markerId = int.parse(context['id']);
        
        if (_lastMarkerId != -1) {
          if (_lastMarkerId == markerId) {
            return;
          }
          map.removeMarker(_lastMarkerId);
        }
        
        map.clearAllOverlays();
         
        _lastMarkerId = markerId;
        
        map.createSimpleOverlay(
            markerId, 
            createSimpleOverlayTemplate(map.getMarker(markerId), editable: true),
            _overlayClickFunction
        );
      })
    };
  }
  
  /**
   * Creates overlay (basically something that floats above the Google Map)
   * with specified data (heading, body texts and marker type). If editable flag is on,
   * overlay creates itself with input boxes where the data can be changed.
  */
  String createSimpleOverlayTemplate(Map marker, {editable: false}) {
    DivElement overlayContainer = new DivElement()..classes.add('map-item');
    DivElement headingContainer = new DivElement()..classes.add('heading');
    DivElement bodyContainer = new DivElement()..classes.add('body');
    DivElement typesContainer = new DivElement()..classes.add('types');

    overlayContainer.children.add(headingContainer);
    overlayContainer.children.add(bodyContainer);
    overlayContainer.children.add(typesContainer);

    Node heading;
    Node body;

    if (editable) {
      heading = new InputElement(type: 'text')
        ..setAttribute('value', marker['data']['heading'])
        ..id = 'heading-input'
        ..autofocus = true;

      body = new TextAreaElement()
        ..text = marker['data']['body']
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
        ..text = marker['data']['heading'];

      body = new ParagraphElement()
        ..text = marker['data']['body']
        ..classes.add('text');
    }

    headingContainer.children.add(heading);
    bodyContainer.children.add(body);
    
    List<Map> markerTypes = [
      {'heading' : 'Engine', 'iconName' : 'mapengine', 'inputValue' : 'mapengine'},
      {'heading' : 'Home', 'iconName' : 'home', 'inputValue' : 'home'},
      {'heading' : 'Work', 'iconName' : 'work', 'inputValue' : 'work'}
    ];
    
    for (var markerType in markerTypes) {
      bool selectedType = false;
      if (markerType['inputValue'] == marker['data']['markerType']) {
        selectedType = true;
      }
      typesContainer.children.add(_typeContainerTemplate(
          markerType['heading'],
          markerType['iconName'],
          markerType['inputValue'],
          editable, selectedType
      ));
    }   

    return overlayContainer.outerHtml;
  }
  
  LabelElement _typeContainerTemplate(String heading, String iconName, String inputValue, 
                                      bool editable, [bool selected]) {
    LabelElement typeContainer = new LabelElement();
    
    typeContainer
      ..classes.add('type')
      ..attributes['for'] = inputValue;
    
    if (selected) {
      typeContainer.classes.add('selected');
    }
    
    HeadingElement title = new HeadingElement.h4()
      ..text = heading;
    
    ImageElement img = new ImageElement(src: "/assets/markers/$iconName.png");
    
    typeContainer.children
      ..add(title)
      ..add(img);
    
    if (editable) {
      RadioButtonInputElement input = new RadioButtonInputElement()
      ..id = inputValue
      ..value = inputValue
      ..name = 'radio-group';
      
      if (selected) {
        input.attributes['checked'] = 'checked';
      }
      
      typeContainer.children.add(input);
    }
    
    return typeContainer;
  }
  
  JsFunction _overlayClickFunction(int markerId) {
    return js.func((jsThis, sender, event, context) {
      // event[0] is a mouse click event that was triggered by
      // clicking on the button
      HtmlElement target = event[0].target;

      // Button to save the marker
      if (target.id == 'save-marker') {
        
        InputElement heading = querySelector('#heading-input');
        InputElement body = querySelector('#body-input');
        InputElement type = querySelector('input[checked="checked"]');

        String headingText = heading.value;
        String bodyText = body.value;

        var marker = map.getMarker(markerId);
        marker['data']['heading'] = headingText;
        marker['data']['body'] = bodyText;
        marker['data']['markerType'] = type.value;
        
        _lastMarkerId = -1;
        
        map.clearAllOverlays();
        
        // If city is not empty, the lat lng has already
        // been reverse geocoded. Skip geocoding and just save the
        // marker.
        if (!marker['data']['city'].isEmpty) {
          saveMarkersOnServer(marker);
          return;
        }
        
        _addLocalityDataToMarker(marker)
        .then((_) {
          saveMarkersOnServer(marker);
        });
                
        
        
      } 
      // Button to remove the marker
      else if (event[0].target.id == 'remove-marker') {
        _lastMarkerId = -1;
        
        var marker = map.getMarker(markerId);
        map.removeMarker(markerId); 
        deleteMarkerFromServer(marker);
           
        map.clearAllOverlays();
      } 
      // Marker type switcher
      else if (target.id != 'heading-input' && target.id != 'body-input') {
        String nodeName = target.nodeName;
        
        querySelector('.selected')
        ..classes.remove('selected')
        ..querySelector("input").attributes.remove('checked');
        
        if (nodeName == 'IMG' || nodeName == 'INPUT' || nodeName == 'H4') {
          target.parent.classes.add('selected');
          target.parent.querySelector("input").attributes['checked'] = 'checked';
        } else if (nodeName == 'LABEL') {
          target.classes.add('selected');
          target.querySelector("input").attributes['checked'] = 'checked';
        }
        
        var typeInput = querySelector('.selected').querySelector('input') as InputElement;
        map.changeMarkerOptions(markerId, iconUrl: _markerIcons[typeInput.value]);
      }
    });
  }
    
  void saveMarkersOnServer(Map marker) {
    HttpRequest request = new HttpRequest();
    
    var url = "http://${window.location.host}/markers.json";
    
    request.open("POST", url);
    
    var csrf = querySelector('meta[name="csrf-token"]').attributes['content'];
    request.setRequestHeader('X-CSRF-Token', csrf);
    request.setRequestHeader("content-Type", "application/json");
    
    Map markerToSend = {
      'lat' : marker['latLng'][0],
      'lng' : marker['latLng'][1],
      'heading' : marker['data']['heading'],
      'body' : marker['data']['body'],
      'markerType' : marker['data']['markerType'],
      'street' : marker['data']['street'],
      'zip' : marker['data']['zip'],
      'city' : marker['data']['city'],
      'country' : marker['data']['country']
    };
    
    request.send(JSON.encode(markerToSend));
  }
  
  void deleteMarkerFromServer(Map marker) {
    HttpRequest request = new HttpRequest();
    
    var url = "http://${window.location.host}/markers/all.json";
    
    request.open("DELETE", url);
    
    var csrf = querySelector('meta[name="csrf-token"]').attributes['content'];
    request.setRequestHeader('X-CSRF-Token', csrf);
    request.setRequestHeader("content-Type", "application/json");
    
    Map markerToSend = {
      'lat' : marker['latLng'][0],
      'lng' : marker['latLng'][1],
    };
    
    request.send(JSON.encode(markerToSend));
  }
  
  void _initializePlacesAutocomplete() {
    InputElement addressInput = querySelector('.search-input');
    
    // Remove any text if user clicks on address input box.
    [addressInput.onClick, addressInput.onTouchStart].forEach((stream) {
      stream.listen((onData) {
        addressInput.value = '';
      });
    });

    var autocomplete = new JsObject(js.gmaps['places']['Autocomplete'],
        [addressInput]);

    autocomplete.callMethod('bindTo', ['bounds', map.getJsMap()]);
    
    ButtonElement btn = querySelector('.search-btn');
    
    btn.onClick.listen((event) {
      event.preventDefault();
      
      js.gmaps['event'].callMethod('trigger', [autocomplete, 'place_changed']);
      return false;
    });

    // After user clicks on autocompleted item
    js.gmaps['event'].callMethod('addListener', [autocomplete, 'place_changed', js.func((jsThis) {
      var place = autocomplete.callMethod('getPlace', []);
      print(place);
      if (place['geometry'] == null) {
        return;
      }
      
      var viewport = place['geometry']['viewport'];
      
      if (viewport != null) {
        map.getJsMap().callMethod('fitBounds', [viewport]);
      } else {
        map.redrawMap({
          'center': place['geometry']['location'],
          'zoom': 15
        });
      }
    })]);
  }
  
  void _initializeMultiSelectBoxes() {
    js.$('#locality-select', 'select2');
    js.$('#type-select', 'select2');
  }
  
  /**
   * Add address, city, zipcode and country data to the specified
   * marker with the help of Google Geocoder service.
   */
  Future _addLocalityDataToMarker(Map marker) {
    Completer c = new Completer();
    
    var markerData = marker['data'];
    
    map.reversedGeocodeLatLng(marker['latLng'])
    .then((geocodingResults) {
      for (int i = 0; i < geocodingResults['length']; i++) {
        var geoResult = geocodingResults[i];
        
        switch (geoResult['types'][0]) {
          case 'street_address':
            String street = geoResult['formatted_address'];
            var commaIndex = street.indexOf(',');
            
            if (commaIndex > 0) {
              markerData['street'] = street.substring(0, commaIndex);
            }
            
            break;
            
          case 'postal_code':
            markerData['zip'] = geoResult['address_components'][0]['long_name'];
            break;
            
          case 'locality':
            markerData['city'] = geoResult['address_components'][0]['long_name'];
            break;
            
          case 'country':
            markerData['country'] = geoResult['address_components'][0]['long_name'];
            break;
        }
      }
      
      c.complete();
    });
    
    return c.future;
  }
}






