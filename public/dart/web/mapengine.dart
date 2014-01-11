import 'package:mapengine/gmap.dart';
import 'package:mapengine/js_helper.dart';
import 'dart:html';
import 'dart:async';

void main() {
  MapEngine mapEngine = new MapEngine('#map');
}

class MapEngine {
  GMap map; // Map we are working with
  JsHelper js = new JsHelper(); // JS helper class
  
  int _lastMarkerId = -1; // Id of the last marker that was shown on the GMap
  
  MapEngine([String mapContainerId = '#map']) {
    map = new GMap(mapContainerId);
    initializeMap();
    
    attachAllEventListeners();
    initializeMultiSelectBoxes();
    
    map.drawMap();
  }
  
  void initializeMap() {
    List<double> mapCenter = [48.165548, 17.134799];
    int mapZoomLevel = 11;
    
    map.setMapOptions(
        center: mapCenter,
        zoom: mapZoomLevel
    );
    
    map.addMapEvent('click', createNewMarker);   
  }
  
  /**
   * Attaches all event listeners to to web.
   */
  void attachAllEventListeners() {
    
  }
  
  void initializeMultiSelectBoxes() {
    js.$('#locality-select', 'select2');
    js.$('#type-select', 'select2');
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
          'type' : ''
        },
        markerOptions: {
          'icon' : '/assets/markers/mapengine.png'
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
    
    // Marker types represented by icons.  
    typesContainer.children.addAll([
        _typeContainerTemplate('Engine', 'mapengine', 'engine', editable),
        _typeContainerTemplate('Home', 'home', 'home', editable, true),
        _typeContainerTemplate('Work', 'workoffice', 'work', editable)
        ]
    );
    

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
      
      typeContainer.children.add(input);
    }
    
    return typeContainer;
  }
  
  JsFunction _overlayClickFunction(int markerId) {
    return js.func((jsThis, sender, event, context) {
      // event[0] is a mouse click event that was triggered by
      // clicking on the button
      if (event[0].target.id == 'save-marker') {
        InputElement heading = querySelector('#heading-input');
        InputElement body = querySelector('#body-input');

        String headingText = heading.value;
        String bodyText = body.value;

        var marker = map.getMarker(markerId);
        marker['data']['heading'] = headingText;
        marker['data']['body'] = bodyText;
        
        _lastMarkerId = -1;
        
        map.clearAllOverlays();
        
      } else if (event[0].target.id == 'remove-marker') {
        map.removeMarker(markerId);
        
        _lastMarkerId = -1;
        
        map.clearAllOverlays();
      }
    });
  }
}






