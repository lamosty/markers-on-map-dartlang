import 'dart:async';
import 'package:mapengine/gmap.dart';

void main() {
  // Prepare a new map object with default map options.
  var map = new GMap('#map');
  map.addMapEvent('click', map.mapMouseDown);
  
  // Draw map with specified options.
  map.drawMap();

  // Some onClick listeners
  exportMarkersDataAsJSON(map);
  importMarkersFromJSON(map);
  removeAllMarkers(map);
  importExampleMarkers(map);

  // Add some testing marker to the map.
//  map.addMarkersToMap([{'latLng': [48.161154, 17.137031]}]);

}

// Testing functions
void addDelayedMarkers(int timeInMs, GMap map) {
  //  After some time, add some more markers with a mousedown event.
  new Future.delayed(new Duration(milliseconds: timeInMs), () {
    map.reloadMapWithNewMarkers(
        markers: [
                  {'latLng': [47, 16]},
                  {'latLng': [46, 15]},
                  {'latLng': [45, 14]},
                  {'latLng': [44, 13]},
                  {'latLng': [43, 12]}
                 ], 
        events: {'click': map.getDefaultMousedownEvent()}
    );
  });


}

// Export marker's data as json
void exportMarkersDataAsJSON(GMap map) {
  var exportPrepare = querySelector('#prepare-json-export');

  exportPrepare.onClick.listen((Event e) {
    e.preventDefault();

    AnchorElement exportLink = new AnchorElement()
      ..href = "data:text/json,${Uri.encodeComponent(map.exportMarkersAsJSON())}"
      ..target = "_blank"
      ..text = "Export (will open in new tab)"
      ..id = "json-export";

    var exportPrepareCopy = exportPrepare;

    exportPrepare.remove();

    DivElement mapContainer = querySelector('.export-container')
      ..children.add(exportLink);

    exportLink.onClick.listen((Event e) {
      exportLink.remove();
      mapContainer.children.add(exportPrepareCopy);

    });
  });
}

// Import markers from json
void importMarkersFromJSON(GMap map) {

  var importButton = querySelector('#import-markers');

  importButton.onClick.listen((Event e) {
    e.preventDefault();

    InputElement jsonInput = querySelector('#json-input');
    String json = jsonInput.value;
    jsonInput.value = '';

    map.importMarkersFromJSON(json);

  });
}

// Remove all the markers from the specified map
void removeAllMarkers(GMap map) {
  ButtonElement removeButton = querySelector('#remove-all-markers');

  removeButton.onClick.listen((Event e) {
    map.removeAllMarkersFromMap();
  });
}

// Imports example markers that I have created
void importExampleMarkers(GMap map) {
  ButtonElement importBtn = querySelector('#import-example-markers');

  importBtn.onClick.listen((Event e) {
    String exampleMarkersInJSON = '''
    [
   {
      "latLng":[
         48.15227276791817,
         17.07123041152954
      ],
      "data":{
         "heading":"Matfyz",
         "body":"Here I study Great place indeed!"
      },
      "id":2
   },
   {
      "latLng":[
         48.145057220951024,
         17.110133171081543
      ],
      "data":{
         "heading":"The Spot",
         "body":"Here I'm currently working. Best place ever. ;)"
      },
      "id":3
   },
   {
      "latLng":[
         48.154656252470794,
         17.174817323684692
      ],
      "data":{
         "heading":"Horvatka",
         "body":"Here I have studied some things and English Language :D"
      },
      "id":4
   },
   {
      "latLng":[
         48.16946286927866,
         17.275571823120117
      ],
      "data":{
         "heading":"My Great Village",
         "body":"This is a place where I live and drive dirt motorbikes."
      },
      "id":5
     }
  ]
    ''';

    map.importMarkersFromJSON(exampleMarkersInJSON);
  });
}





