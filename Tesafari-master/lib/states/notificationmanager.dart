import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mutex/mutex.dart';
import 'package:tesafari/model/trip.dart';
import 'package:tesafari/states/drivernotifier.dart';
import 'package:tesafari/model/notification.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:universal_io/io.dart';

class NotificationManager extends ChangeNotifier {
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;
  var _initializationSettingsAndroid;
  List<TesafariNotification> _notificationsList = [];
  LocalStorage? storage = new LocalStorage('notifications');
  DriverNotifier? _driverNotifier;
  String? deviceId;
  int _unreadNotificationsCount = 0;
  Mutex mutex = Mutex();

  NotificationManager() {
    //TODO: Get suitable icon
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    InitializationSettings initializationSettings =
        InitializationSettings(android: _initializationSettingsAndroid);

    FlutterLocalNotificationsPlugin().initialize(initializationSettings);

    _readLocalStorage();

    notifyListeners();
  }

  Future<void> getNotificationsFromServer(Future<String?> rawJson) async {
    String rawNotifications = await rawJson ?? '';

    if (rawNotifications.isNotEmpty) {
      final notifications = json.decode(rawNotifications);

      for (dynamic notification in notifications) {
        if (notification != null) {
          final payload = json.decode(notification['payload']);

          TesafariNotification tesafariNotification = TesafariNotification(
              notification['id'],
              payload['title'],
              payload['body'],
              DateTime.now(),
              _getPriorityLevel(payload['priority']),
              json.encode(payload['data']));

          if (!_notificationExists(notification['id'])) {
            _notificationsList.add(tesafariNotification);
            _showNotification(tesafariNotification);
          }
        }
      }
      setUnreadNotificationsCount = _getUnreadNotificationsCount();
      _saveToStorage();
    }
  }

  Importance _getPriorityLevel(String status) {
    switch (status) {
      case 'HIGH':
        return Importance.high;
      case 'LOW':
        return Importance.low;
      default:
        return Importance.defaultImportance;
    }
  }

  Future<void> _showNotification(TesafariNotification notification) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        notification.id.toString(), notification.title,
        description: notification.message, importance: notification.importance);
    await _flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    if (notification.dataJson != '' &&
        notification.dataJson != '{"status":"Cancelled"}') {
      final data = json.decode(notification.dataJson);

      if (data != null) {
        if (data['status'] == 'Pending')
          _driverNotifier!.addTrip(new Trip(
            GeoPoint(
                latitude: double.parse(data['from'].split(',')[0]),
                longitude: double.parse(data['from'].split(',')[1].trim())),
            data['fromStr'],
            GeoPoint(
                latitude: double.parse(data['to'].split(',')[0]),
                longitude: double.parse(data['to'].split(',')[1].trim())),
            data['toStr'],
            DateTime.parse(data['date']),
            carType: data['vehicle'],
            carCapacity: data['capacity'],
            status: data['status'],
            price: double.parse(data['price']),
            tripId: data['tripid'],
          ));
        else
          _driverNotifier!.changeTripStatus(
              (data['tripid'] is int)
                  ? data['tripid']
                  : int.parse(data['tripid']),
              status: data['status'],
              driverId:
                  (data['status'] == 'Confirmed') ? data['driverid'] : null,
              driver: (data['status'] == 'Confirmed') ? data['driver'] : null,
              phone: (data['status'] == 'Confirmed') ? data['phone'] : null,
              rating: (data['status'] == 'Confirmed')
                  ? double.parse(data['rating'])
                  : null,
              price: (data['status'] == 'Completed')
                  ? double.parse(data['price'])
                  : null);
      }
    }

    Fluttertoast.showToast(
        msg: notification.message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
        backgroundColor: Colors.indigoAccent,
        textColor: Colors.white);

    _flutterLocalNotificationsPlugin?.show(
        notification.id,
        notification.title,
        notification.message,
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description,
                setAsGroupSummary: true)));
  }

  void _readLocalStorage() async {
    try {
      bool isReady = await storage!.ready;
      if (isReady) {
        var notifications = storage?.getItem('notifications');
        if (notifications != null) {
          _notificationsList = List<TesafariNotification>.from(
            (notifications as List).map(
              (notification) => TesafariNotification(
                  notification['id'],
                  notification['title'],
                  notification['message'],
                  DateTime.parse(notification['timeStamp']),
                  _getPriorityLevel(notification['importance']),
                  notification['data'],
                  isRead: notification['isRead']),
            ),
          );
        }

        setUnreadNotificationsCount = _getUnreadNotificationsCount();
        notifyListeners();
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void addNotification(Response? res) {
    final notification = json.decode(res!.body);

    final id = notification['id'];
    final payload = notification['payload'];

    TesafariNotification tesafariNotification = TesafariNotification(
        id,
        payload['title'],
        payload['body'],
        DateTime.now(),
        _getPriorityLevel(payload['priority']),
        json.encode(payload['data']));
    _notificationsList.add(tesafariNotification);
    _saveToStorage();
    setUnreadNotificationsCount = _getUnreadNotificationsCount();
    _showNotification(tesafariNotification);
    notifyListeners();
  }

  void _saveToStorage() async {
    await mutex.protect(() async =>
        await storage!.setItem('notifications', _toJsonEncodable()));
  }

  List<dynamic> _toJsonEncodable() {
    return _notificationsList.map((notification) {
      return notification.toJsonEncodable();
    }).toList();
  }

  void deleteNotification(TesafariNotification notification) {
    _deleteFromServer(_notificationsList.indexOf(notification));
    _notificationsList.remove(notification);
    _unreadNotificationsCount = _getUnreadNotificationsCount();
    _saveToStorage();
    notifyListeners();
  }

  void deleteAllNotification() {
    for (TesafariNotification notification in _notificationsList)
      _deleteFromServer(_notificationsList.indexOf(notification));

    _notificationsList.clear();
    _unreadNotificationsCount = 0;
    _saveToStorage();
    notifyListeners();
  }

  void _deleteFromServer(int index) async {
    final uri = Uri.https(dotenv.env['URL']!, '/mark');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    try {
      await http.post(uri,
          headers: headers,
          body: json.encode({'id': _notificationsList[index].id}));
      _saveToStorage();
    } catch (error) {
      debugPrint(error.toString());
    } finally {
      notifyListeners();
    }
  }

  List<TesafariNotification> markNotificationAsRead(int index) {
    _notificationsList[index].isRead = true;
    notifyListeners();
    _deleteFromServer(index);
    _unreadNotificationsCount = _getUnreadNotificationsCount();
    return _notificationsList;
  }

  int _getUnreadNotificationsCount() {
    int count = 0;

    for (TesafariNotification notification in _notificationsList) {
      if (!notification.isRead) count++;
    }

    return count;
  }

  bool _notificationExists(int id) {
    for (TesafariNotification notification in _notificationsList)
      if (notification.id == id) return true;

    return false;
  }

  List<TesafariNotification> get getNotifications =>
      _notificationsList.reversed.toList();
  int get getUnreadNotificationsCount => _unreadNotificationsCount;

  set setUnreadNotificationsCount(int value) {
    if (_unreadNotificationsCount != value) {
      _unreadNotificationsCount = value;
      notifyListeners();
    }
  }

  set setDriverNotifier(DriverNotifier driverNotifier) {
    _driverNotifier = driverNotifier;
  }
}
