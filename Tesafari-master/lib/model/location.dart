import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class TripLocation {
  final String id;
  final String name;
  final GeoPoint coordinates;

  TripLocation(this.id, this.name, this.coordinates);
}
