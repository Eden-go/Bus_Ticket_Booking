import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class Trip {
  int? tripId;
  GeoPoint start;
  GeoPoint destination;
  String startString;
  String destinationString;
  String? carType;
  String? status;
  double? price;
  int? driverId;
  String? driverName;
  String? driverPhone;
  int? carCapacity;
  DateTime dateTime;
  double? driverRating;

  Trip(this.start, this.startString, this.destination, this.destinationString,
      this.dateTime,
      {this.carType,
      this.carCapacity,
      this.status,
      this.price,
      this.driverId,
      this.driverName,
      this.driverPhone,
      this.tripId,
      this.driverRating});

  set setStatus(String value) {
    status = value;
  }

  set setDriverId(int value) {
    driverId = value;
  }

  set setDriver(String value) {
    driverName = value;
  }

  set setDriverPhone(String value) {
    driverPhone = value;
  }

  set setRating(double value) {
    driverRating = value;
  }

  toJsonEncodable() {
    Map<String, dynamic> tripMap = Map();
    tripMap['id'] = this.tripId;
    tripMap['start'] = '${this.start.latitude}, ${this.start.longitude}';
    tripMap['startStr'] = this.startString;
    tripMap['finalStr'] = this.destinationString;
    tripMap['final'] =
        '${this.destination.latitude}, ${this.destination.longitude}';
    tripMap['type'] = this.carType;
    tripMap['status'] = this.status ?? 'Pending';
    tripMap['price'] = this.price ?? '0.00';
    tripMap['capacity'] = this.carCapacity;
    tripMap['driverid'] = this.driverId;
    tripMap['driver'] = this.driverName;
    tripMap['driver_phone'] = this.driverPhone;
    tripMap['date'] = this.dateTime.toString();
    tripMap['rating'] = this.driverRating;

    return tripMap;
  }
}
