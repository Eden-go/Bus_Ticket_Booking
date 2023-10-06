import 'package:flutter/material.dart';
import 'package:tesafari/model/trip.dart';

enum SortType { bus, date, price, status }
class TripHistory extends ChangeNotifier {
  List<Trip> _trips = [];
  SortType _sortType = SortType.date;
  bool _isAscending = false;

  SortType get getSortType => _sortType;
  bool get getSortOrder => _isAscending;
  List<Trip> get getTrips => _trips;

  set setSortType(SortType value) {
    _sortType = value;
    notifyListeners();
  }

  set setSortOrder(bool value) {
    _isAscending = value;
    notifyListeners();
  }
  
}
