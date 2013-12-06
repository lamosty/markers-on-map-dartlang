part of gmap;

class Marker {
  // Properties
  List<double> latLng;
  double id;
  Map data;
  Map options;
  
  // Helpers
  JsHelper js = new JsHelper();
  
  Marker({this.latLng, this.id, this.data, this.options}) {
  
    
  }
}

