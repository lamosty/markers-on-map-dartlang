import 'package:mapengine/gmap.dart';
import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:mapengine/js_helper.dart';

void main() {
  var map = new GMap('#map');
  
  // Sete map's center and zoom level according to country/state.
  initializeMap(map); 
  
  map.addMapEvent('dragend', mapDragEndEvent);
  map.addMapEvent('zoom_changed', mapDragEndEvent);
  map.addMapOnces('idle', mapDragEndEvent);

  map.drawMap();

  attachAllEventListeners(map);
  initializePlacesAutocomplete(map);
}

void initializeMap(GMap map) {
  InputElement localeInput = querySelector('#locale');
  var locale = localeInput.value;
  
  List<double> mapCenter;
  int mapZoomLevel;
  
  if (locale == '' || locale == 'sk') {
    mapCenter = [48.165548, 17.134799];
    mapZoomLevel = 11;
  } else if (locale == 'cz') {
    mapCenter = [50.05187, 14.45944];
    mapZoomLevel = 10;
  }
  
  map.setMapOptions(
      center: mapCenter,
      zoom: mapZoomLevel
  );
}

void attachAllEventListeners(GMap map) {
  var form = querySelector('#filter');
  var propertyCategory = form.querySelector('#property_category');
  var propertyType = form.querySelector('#property_type');
  var stateType = form.querySelector('#state_type');
  var numOfRooms = form.querySelector('#num_of_rooms');
  
  [propertyCategory, propertyType, stateType, numOfRooms].forEach((el) {
    el.onChange.listen((onData) {
      sendFilter(prepareDataForSendFilter(map: map));
    });
  });
    
  // Handling slider movements
  // We need to delay the querySelector because slider html is not
  // appended to the body immediately after loading the page
  new Future.delayed(new Duration(seconds: 2), () {
    
    var sliderHandles = form.querySelectorAll('.ui-slider-handle');
    
    // onClick for desktop, onTouchEnd for touchscreens
    [sliderHandles.onClick, sliderHandles.onTouchEnd].forEach((ElementStream stream) {
      stream.listen((onData) {
        sendFilter(prepareDataForSendFilter(map: map));
      });
    });
    
  });
}

void initializePlacesAutocomplete(GMap map) {
  InputElement addressInput = querySelector('#address');
  
  // Remove any text if user clicks on address input box.
  [addressInput.onClick, addressInput.onTouchStart].forEach((stream) {
    stream.listen((onData) {
      addressInput.value = '';
    });
  });

  var autocomplete = new JsObject(context['google']['maps']['places']['Autocomplete'],
    [addressInput]);

  autocomplete.callMethod('bindTo', ['bounds', map.getJsMap()]);

  // After user clicks on autocompleted item
  map.js.gmaps['event'].callMethod('addListener', [autocomplete, 'place_changed', map.js.func((jsThis) {
    var place = autocomplete.callMethod('getPlace', []);
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

    sendFilter(prepareDataForSendFilter(map: map));

  })]);

}

String prepareDataForSendFilter({GMap map, mapFromJs}) {
  FormElement form = querySelector('#filter');
  var dataToSend = new Map.from(formToMap(form));
  
  var googleMap = Object;
  
  // If GMap object map was supplied, obtain its javascript version
  // else use mapFromJs (if it is supplied instead)
  if (map != null) {
    googleMap = map.js.gmap3('get');
  } else {
    googleMap = mapFromJs;
  }
  
  var bounds = googleMap.callMethod('getBounds', []);
  
  // Add LatLngs of north-east and south-west points of the Google Map
  dataToSend.addAll(_extractLatLngFromMapBounds(bounds));
  
  // Add zoom level of the map
  dataToSend['zoomLevel'] = googleMap.callMethod('getZoom', []);
  
  // Add map's center lat and lng
  var mapCenter = googleMap.callMethod('getCenter', []);
  dataToSend['mapLat'] = mapCenter.callMethod('lat', []);
  dataToSend['mapLng'] = mapCenter.callMethod('lng', []);
  
  return serializeDataToUrl(dataToSend);
}

void mapDragEndEvent(jsThis, sender, event, context) {
  sendFilter(prepareDataForSendFilter(mapFromJs: sender)); 
}

Map _extractLatLngFromMapBounds(mapBounds) {
  var northEast = mapBounds.callMethod('getNorthEast', []);
  var southWest = mapBounds.callMethod('getSouthWest', []);
  
  return {
    'neLat': northEast.callMethod('lat', []),
    'neLng': northEast.callMethod('lng', []),
    'swLat': southWest.callMethod('lat', []),
    'swLng': southWest.callMethod('lng', [])
  };
}

Map formToMap(FormElement form) {
  Map data = {};
  final formElementSelectors = "select, input";
  
  form.querySelectorAll(formElementSelectors).forEach((SelectElement el) {
    data[el.name] = el.value; 
  });
  
  return data;
}

/**
 * Serializes {key: value} pairs into url-encodable string (e.g. key=value&key2=value2)
 */
String serializeDataToUrl(Map data) {
  var parameters = "";
  for (var key in data.keys) {
    if (parameters.isNotEmpty) {
      parameters += "&";
    }
    parameters += '$key=${data[key]}';
  }
  
  return parameters;
}

/**
 * params in form of "param1=value1&param2=value2..."
 */
void sendFilter(String params) {
  var url = '/properties/show.json?$params';
  
  HttpRequest.getString(url)
  .then(processLocalityData);
}

void processLocalityData(String localityDataAsString) {
  var localityData = JSON.decode(localityDataAsString);
  displayLocalityData(localityData);  
}

/**
 * Adds locality data (average price, ...) to the html
 * on the left side of the map under the 'Locality' heading.
 */
void displayLocalityData(Map data) {
  var averagePrice = querySelector('#average-price')
  ..text = _formatPrice(data['averagePrice'], data['locale']);
  
  var averagePriceM2 = querySelector('#average-price-m2')
  ..text = _formatPrice(data['averagePriceM2'], data['locale']);
  
  var numOfProperties = querySelector('#num-of-properties')
  ..text = data['numOfProperties'].toString();
}

/**
 * Formats the price according to specified locale with currency sign.
 * Returns the formatted price as a string.
 */
String _formatPrice(num price, String locale) {
  NumberFormat priceFormat;
  String currency;
  
  if (locale == 'sk') {
    priceFormat = new NumberFormat("#,##0", "sk_SK");
    currency = "€";
  } else if (locale == 'cz') {
    priceFormat = new NumberFormat("#,##0", "cs_CZ");
    currency = "Kč";
  }
  
  return "${priceFormat.format(price)} $currency";
}
