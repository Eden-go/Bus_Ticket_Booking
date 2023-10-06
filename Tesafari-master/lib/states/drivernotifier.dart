import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mutex/mutex.dart';
import 'package:tesafari/model/trip.dart';
import 'package:tesafari/model/vehicle.dart';

class DriverNotifier extends ChangeNotifier {
  LocalStorage? _tripStorage;
  List<Trip> _recentTrips = [];
  List<Trip> _favTrips = [];
  String? _fromDest;
  String? _toDest;
  RoadInfo? _tripInfo;
  Vehicle? _vehicle;
  int _passengerAmount = 0;
  FocusNode? _fromFocusNode;
  FocusNode? _toFocusNode;
  GeoPoint? _fromGeoPoint;
  GeoPoint? _toGeoPoint;
  DateTime _leavingDateTime = DateTime.now();
  Mutex mutex = Mutex();
  bool _isDrawing = false;

  DriverNotifier() {
    _tripStorage = LocalStorage("trips");
    _readFavLocalStorage();
    _readTripLocalStorage();
    notifyListeners();
  }

  set setFrom(String? value) {
    _fromDest = value;
    notifyListeners();
  }

  set setTo(String? value) {
    _toDest = value;
    notifyListeners();
  }

  set setFromFocus(FocusNode? value) {
    _fromFocusNode = value;
    notifyListeners();
  }

  set setToFocus(FocusNode? value) {
    _toFocusNode = value;
    notifyListeners();
  }

  set setFromGeoPoint(GeoPoint? value) {
    _fromGeoPoint = value;
    notifyListeners();
  }

  set setToGeoPoint(GeoPoint? value) {
    _toGeoPoint = value;
    notifyListeners();
  }

  set setVehicle(Vehicle? value) {
    _vehicle = value;
    notifyListeners();
  }

  set setCapacity(int value) {
    _passengerAmount = value;
    notifyListeners();
  }

  set setDate(DateTime value) {
    _leavingDateTime = value;
    notifyListeners();
  }

  set setTripInfo(RoadInfo? value) {
    _tripInfo = value;
  }

  set setIsDrawing(bool value) {
    _isDrawing = value;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getPlacemarks(MapController _mapController,
      Placemark placemark, GeoPoint? other) async {
    try {
      List<Location> location = await locationFromAddress(placemark.name!);
      String destination = '${placemark.name!}, ${placemark.country!}';

      GeoPoint geoPoint = GeoPoint(
          latitude: location[0].latitude, longitude: location[0].longitude);

      _mapController.clearAllRoads();
      _mapController.goToLocation(geoPoint);
      _mapController.geopoints.then((value) {
        value.forEach((marker) {
          if (other == null)
            _mapController.removeMarker(marker);
          else {
            if (marker.latitude != other.latitude &&
                marker.longitude != other.longitude)
              _mapController.removeMarker(marker);
          }
        });
      });

      _mapController.addMarker(geoPoint,
          markerIcon: MarkerIcon(
              icon: Icon(Icons.location_pin, size: 75, color: Colors.red)));

      return Future.value(
          {'dest': destination, 'geopoint': geoPoint, 'other': other});
    } catch (error) {}

    return null;
  }

  void addFavTrip(Trip trip) {
    if (!_checkIfExists(trip)) {
      _favTrips.add(trip);
      _saveToStorage(true);
      notifyListeners();
    }
  }

  void clearInputs() {
    _fromFocusNode = null;
    _toFocusNode = null;
  }

  bool _checkIfExists(Trip trip) {
    bool exists = false;

    for (Trip item in _recentTrips) {
      if (trip.start == item.start && trip.destination == item.destination) {
        exists = true;
        break;
      }
    }

    return exists;
  }

  Trip? getActiveTrip() {
    Trip? activeTrip;

    for (Trip trip in _recentTrips) {
      if (trip.status != 'Completed' && trip.status != 'Cancelled') {
        activeTrip = trip;
        break;
      }
    }

    return activeTrip;
  }

  void addTrip(Trip trip) {
    if (!_checkIfExists(trip)) {
      _recentTrips.add(trip);
      _saveToStorage(false);
      notifyListeners();
    }
  }

  void changeTripStatus(int tripId,
      {String? status,
      int? driverId,
      String? driver,
      String? phone,
      double? rating,
      double? price}) {
    _recentTrips.forEach((Trip trip) {
      if (trip.tripId == tripId) {
        trip.setStatus = status!;
        if (status == 'Confirmed') {
          trip.setDriverId = driverId!;
          trip.setDriver = driver!;
          trip.setDriverPhone = phone!;
          trip.setRating = rating!;
        }

        if (status == 'Completed') trip.price = price;
      }
    });

    _saveToStorage(false);
    notifyListeners();
  }

  void deleteTrip(Trip trip) {
    _recentTrips.remove(trip);
    _saveToStorage(false);
    notifyListeners();
  }

  void _readTripLocalStorage() {
    try {
      _tripStorage!.ready.then((bool value) {
        var trips = _tripStorage!.getItem('trip');

        if (trips != null) {
          _recentTrips = List<Trip>.from(
            (trips as List).map(
              (trip) => Trip(
                  GeoPoint(
                      latitude:
                          double.parse(trip['start'].toString().split(',')[0]),
                      longitude: double.parse(
                          trip['start'].toString().split(',')[1].trim())),
                  trip['startStr'],
                  GeoPoint(
                      latitude:
                          double.parse(trip['final'].toString().split(',')[0]),
                      longitude: double.parse(
                          trip['final'].toString().split(',')[1].trim())),
                  trip['finalStr'],
                  DateTime.parse(trip['date']),
                  carType: trip['type'],
                  carCapacity: trip['capacity'],
                  tripId: trip['id'],
                  status: trip['status'],
                  driverId: trip['driverid'],
                  driverName: trip['driver'],
                  driverPhone: trip['driver_phone'],
                  price: trip['price'],
                  driverRating: trip['rating']),
            ),
          );
        }

        notifyListeners();
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<RoadInfo?> drawTripPath(MapController _mapController, GeoPoint from,
      GeoPoint to) async {
    try {
      late RoadInfo roadInfo;

      await Future.delayed(Duration(seconds: 3), () {
        _isDrawing = true;
        notifyListeners();
      }).then(((value) async {
        roadInfo = await _mapController.drawRoad(from, to,
            roadType: RoadType.car,
            roadOption: RoadOption(
              roadWidth: 10,
              roadColor: Colors.indigoAccent,
              zoomInto: true,
            ));

        _tripInfo = roadInfo;
        _isDrawing = false;
        notifyListeners();
      }));

      return roadInfo;
    } catch (error) {}
    return null;
  }

  void clearAllInputs() {
    _fromDest = null;
    _toDest = null;
    _tripInfo = null;
    _vehicle = null;
    _passengerAmount = 0;
    _fromFocusNode = null;
    _toFocusNode = null;
    _leavingDateTime = DateTime.now();
    notifyListeners();
  }

  void _readFavLocalStorage() {
    try {
      _tripStorage!.ready.then((bool value) {
        var favs = _tripStorage!.getItem('fav');

        if (favs != null) {
          _favTrips = List<Trip>.from(
            (favs as List).map(
              (trip) => Trip(
                  GeoPoint(
                      latitude:
                          double.parse(trip['start'].toString().split(',')[0]),
                      longitude: double.parse(
                          trip['start'].toString().split(',')[1].trim())),
                  trip['startStr'],
                  GeoPoint(
                      latitude:
                          double.parse(trip['final'].toString().split(',')[0]),
                      longitude: double.parse(
                          trip['final'].toString().split(',')[1].trim())),
                  trip['finalStr'],
                  DateTime.parse(trip['date']),
                  carType: trip['type'],
                  carCapacity: trip['capacity'],
                  tripId: trip['id'],
                  status: trip['status'],
                  driverId: trip['driverid'],
                  driverName: trip['driver'],
                  driverPhone: trip['driver_phone'],
                  price: trip['price'],
                  driverRating: trip['rating']),
            ),
          );
        }

        notifyListeners();
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void _saveToStorage(isFav) async {
    isFav
        ? await mutex.protect(() async =>
            await _tripStorage!.setItem('fav', _toJsonEncodable(isFav)))
        : await mutex.protect(() async =>
            await _tripStorage!.setItem('trip', _toJsonEncodable(isFav)));
  }

  List<dynamic> _toJsonEncodable(bool isFav) {
    return isFav
        ? _favTrips.map((trip) {
            return trip.toJsonEncodable();
          }).toList()
        : _recentTrips.map((trip) {
            return trip.toJsonEncodable();
          }).toList();
  }

  String? get getFrom => _fromDest;
  String? get getTo => _toDest;
  Vehicle? get getVehicle => _vehicle;
  int get getNumPassengers => _passengerAmount;
  FocusNode? get getFromFocus => _fromFocusNode;
  FocusNode? get getToFocus => _toFocusNode;
  GeoPoint? get getFromGeoPoint => _fromGeoPoint;
  GeoPoint? get getToGeoPoint => _toGeoPoint;
  DateTime get getLeavingDateTime => _leavingDateTime;
  RoadInfo? get getTripInfo => _tripInfo;
  List<Trip> get getRecentTrips => _recentTrips;
  List<Trip> get getFavorites => _favTrips;
  bool get isDrawing => _isDrawing;
}
