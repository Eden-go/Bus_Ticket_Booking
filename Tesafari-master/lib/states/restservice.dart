import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mutex/mutex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as crypto;
import 'package:tesafari/model/location.dart';
import 'package:tesafari/model/paymentgateway.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tesafari/model/vehicle.dart';

class RESTService extends ChangeNotifier {
  List<Vehicle> _vehicleTierList = [];
  List<PaymentGateway> _paymentGatewayList = [];
  List<TripLocation> _locationList = [];
  double? profitRate;
  double? initialPrice;
  double? petrolRate;
  double? dieselRate;
  bool _updateExists = false;
  Mutex mutex = Mutex();
  String _errorMsg = "";
  bool _isConnected = false;
  final String url = dotenv.env['URL']!;
  final String sharingLocationUrl = dotenv.env['PLAYSTORE']!;
  String? deviceId;
  PaymentGateway? _paymentGateway;

  RESTService() {
    connectToServer();

    notifyListeners();
  }

  set setDeviceId(String? value) {
    deviceId = value;
  }

  set setPaymentGateway(PaymentGateway? value) {
    _paymentGateway = value;
    notifyListeners();
  }

  Future<bool> _getUpdates() async {
    try {
      final response = await http.get(Uri.https(url, '/updates'));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        PackageInfo tesafariPackageInfo = await PackageInfo.fromPlatform();

        if (body['client_version'] !=
            '${tesafariPackageInfo.version}.${tesafariPackageInfo.buildNumber}') {
          _updateExists = true;
          notifyListeners();
          return Future.value(true);
        } else {
          _updateExists = false;
          return Future.value(false);
        }
      } else {
        _updateExists = false;
        return Future.value(false);
      }
    } catch (error) {
      _updateExists = false;
      return Future.value(false);
    }
  }

  Future<bool> connectToServer() async {
    try {
      final response = await http.get(Uri.https(url, '/init'));

      if (response.statusCode == 200) {
        _isConnected = true;
        _paymentGatewayList = _populatePaymentGatewayList(response.body);
        _locationList = _populateLocationList(response.body);
        await _getPriceInfo();
        print(_vehicleTierList);
        _getUpdates();
        notifyListeners();
        return Future.value(true);
      } else {
        _isConnected = false;
        return Future.value(false);
      }
    } catch (error) {
      _isConnected = false;
      debugPrint(error.toString());
      return Future.value(false);
    }
  }

  Future<String> getNotifications() async {
    try {
      final response = await http
          .get(Uri.https(url, '/getnotifications', {"deviceId": deviceId}));
      if (response.statusCode == 200) {
        return Future.value(response.body);
      }
    } catch (error) {
      debugPrint(error.toString());
    }

    return Future.value('');
  }

  Future<Response> tripStartRequest(Map<String, Object?> body) async {
    final jsonString = json.encode(body);
    final readyUri = Uri.https(url, '/customerready');
    final tripStartUri = Uri.https(url, '/starttrip');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    try {
      await http.post(readyUri, headers: headers, body: jsonString);

      while (true) {
        final response =
            await http.post(tripStartUri, headers: headers, body: jsonString);

        if (response.statusCode == 200) return response;
      }
    } catch (error) {
      debugPrint(error.toString());
      return http.Response(error.toString(), 400);
    }
  }

  Future<Response> tripOrderRequest(
      Map<String, Object?> body, String phNumber) async {
    body.addAll({'customer_phoneNumber': _encryptAesCbc14(phNumber)});

    final jsonString = json.encode(body);
    final uri = Uri.https(url, '/triprequest');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    try {
      return await http.post(uri, headers: headers, body: jsonString);
    } catch (error) {
      debugPrint(error.toString());
      return http.Response(error.toString(), 400);
    }
  }

  Future<Response> rateTripRequest(Map<String, Object?> body) async {
    final jsonString = json.encode(body);
    final uri = Uri.https(url, '/rate');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    try {
      return await http.post(uri, headers: headers, body: jsonString);
    } catch (error) {
      debugPrint(error.toString());
      return http.Response(error.toString(), 400);
    }
  }

  Future<Response> tripCancelRequest(Map<String, Object?> body) async {
    final jsonString = json.encode(body);
    final uri = Uri.https(url, '/tripcancel');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    try {
      return await http.post(uri, headers: headers, body: jsonString);
    } catch (error) {
      debugPrint(error.toString());
      return http.Response(error.toString(), 400);
    }
  }

  Future<Response> tripCompleteRequest(Map<String, Object?> body) async {
    final jsonString = json.encode(body);
    final readyUri = Uri.https(url, '/customerready');
    final paymentUri = Uri.https(url, '/tripcomplete');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    try {
      await http.post(readyUri, headers: headers, body: jsonString);

      while (true) {
        final response =
            await http.post(paymentUri, headers: headers, body: jsonString);

        if (response.statusCode == 200) return response;
      }
    } catch (error) {
      debugPrint(error.toString());
      return http.Response(error.toString(), 400);
    }
  }

  Future<Response?> submitComplaint(Map<String, Object?> body) async {
    final jsonString = json.encode(body);
    final uri = Uri.https(url, '/submitcomplaint');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    try {
      return await http.post(uri, headers: headers, body: jsonString);
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<void> _getPriceInfo() async {
    final response = await http.get(Uri.https(url, '/vehicletiers'));

    if (response.statusCode == 200) {
      List<dynamic> rawBody = json.decode(response.body) as List<dynamic>;

      profitRate = double.parse(rawBody[rawBody.length - 1]['profit']);
      rawBody.removeLast();

      for (Map<String, dynamic> vehicle in rawBody) {
        List<String> rawString = (vehicle['price_rate'] as String).split(',');
        List<double> vehicleTiers = [];

        rawString.forEach((value) => vehicleTiers.add(double.parse(value)));

        _vehicleTierList.add(Vehicle(
            name: vehicle['vehiclename'],
            initialPrice: double.parse(vehicle['initial_price']),
            priceRates: vehicleTiers,
            image: vehicle['image_src']));
      }
    }
  }

  List<PaymentGateway> _populatePaymentGatewayList(String body) {
    var rawBody = json.decode(body) as Map<String, dynamic>;
    List<PaymentGateway> list = [];

    for (Map<String, dynamic> gateway in rawBody['Payment']) {
      String id = gateway['paymentid'].toString();
      String name = gateway['paymentname'];

      list.add(new PaymentGateway(id, name));
    }

    return list;
  }

  List<TripLocation> _populateLocationList(String body) {
    var rawBody = json.decode(body) as Map<String, dynamic>;
    List<TripLocation> list = [];

    for (Map<String, dynamic> location in rawBody['Locations']) {
      String id = location['locationid'].toString();
      String name = location['name'];
      List coordinates = (location['coordinates'] as String).split(',');

      list.add(new TripLocation(
          id,
          name,
          GeoPoint(
              latitude: double.parse(coordinates[0]),
              longitude: double.parse(coordinates[1]))));
    }

    return list;
  }

  String _encryptAesCbc14(String text) {
    final key = crypto.Key.fromUtf8('topsecretkeyonlyadminuseY4c-dV/1');
    final iv = crypto.IV.fromUtf8('OwzViCfJRQ4E/bj/');
    final encrypter =
        crypto.Encrypter(crypto.AES(key, mode: crypto.AESMode.cbc));

    return encrypter.encrypt(text, iv: iv).base16;
  }

  String decrypt(String text) {
    final key = crypto.Key.fromUtf8('topsecretkeyonlyadminuseY4c-dV/1');
    final iv = crypto.IV.fromUtf8('OwzViCfJRQ4E/bj/');
    final encrypter =
        crypto.Encrypter(crypto.AES(key, mode: crypto.AESMode.cbc));

    return encrypter.decrypt16(text, iv: iv);
  }

  bool get isConnectionAlive => _isConnected;
  bool get updateExists => _updateExists;
  List<Vehicle> get getVehicleTierList => _vehicleTierList;
  PaymentGateway? get getPaymentGateway => _paymentGateway;
  List<PaymentGateway> get getGateways => _paymentGatewayList;
  List<TripLocation> get getTripLocations => _locationList;
  String get getURL => url;
  String get getAppStoreUrl => sharingLocationUrl;
  String get getError => _errorMsg;
}
