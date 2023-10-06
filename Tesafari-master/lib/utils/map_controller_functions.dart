import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tesafari/model/trip.dart';
import 'package:tesafari/model/vehicle.dart';
import 'package:tesafari/states/drivernotifier.dart';
import 'package:tesafari/states/notificationmanager.dart';
import 'package:tesafari/states/personaldata.dart';
import 'package:tesafari/states/restservice.dart';
import 'package:tesafari/widgets/components/personalinfoform.dart';

Function(PanelController, MapController, DriverNotifier) mapTouchEventListener =
    (PanelController panelController, MapController mapController,
        DriverNotifier driverNotifier) async {
  GeoPoint? selectedPoint = mapController.listenerMapSingleTapping.value;

  if (selectedPoint != null) {
    List<GeoPoint> markers = await mapController.geopoints;
    FocusNode? fromFocus = driverNotifier.getFromFocus;
    FocusNode? toFocus = driverNotifier.getToFocus;
    GeoPoint? fromGeoPoint = driverNotifier.getFromGeoPoint;
    GeoPoint? toGeoPoint = driverNotifier.getToGeoPoint;

    if (fromFocus != null) {
      driverNotifier.setFromGeoPoint = selectedPoint;
      driverNotifier.setFromFocus = null;
      driverNotifier.setFrom =
          '${selectedPoint.latitude}, ${selectedPoint.longitude}';
    }

    if (toFocus != null) {
      driverNotifier.setToGeoPoint = selectedPoint;
      driverNotifier.setToFocus = null;
      driverNotifier.setTo =
          '${selectedPoint.latitude}, ${selectedPoint.longitude}';
    }

    markers.forEach((marker) async {
      if (fromGeoPoint == null && toGeoPoint == null) {
        await mapController.removeMarker(marker);
      } else {
        GeoPoint? temp;

        if (fromGeoPoint != null) {
          if ((marker.latitude != fromGeoPoint.latitude &&
              marker.longitude != fromGeoPoint.longitude)) temp = marker;
        }

        if (toGeoPoint != null) {
          if ((marker.latitude != toGeoPoint.latitude &&
              marker.longitude != toGeoPoint.longitude))
            temp = marker;
          else
            temp = null;
        }

        if (temp != null) await mapController.removeMarker(marker);
      }
    });

    if (fromFocus != null || toFocus != null)
      await mapController.addMarker(selectedPoint,
          markerIcon: MarkerIcon(
              icon: Icon(Icons.location_pin, size: 75, color: Colors.red)));

    if (driverNotifier.getFromGeoPoint != null &&
        driverNotifier.getToGeoPoint != null &&
        driverNotifier.getFrom != null &&
        driverNotifier.getTo != null) {
      await driverNotifier.drawTripPath(mapController,
          driverNotifier.getFromGeoPoint!, driverNotifier.getToGeoPoint!);
      if(panelController.isPanelClosed) panelController.open();
    }
  }
};

Function(DriverNotifier, MapController) reRenderMap =
    (DriverNotifier driverNotifier, MapController mapController) async {
  GeoPoint? _from;
  GeoPoint? _to;
  Trip? activeTrip = driverNotifier.getActiveTrip();

  if (activeTrip == null) {
    _from = driverNotifier.getFromGeoPoint;
    _to = driverNotifier.getToGeoPoint;

    if (_from != null && _to != null && driverNotifier.getTripInfo == null)
      await driverNotifier.drawTripPath(mapController, _from, _to);
  } else {
    _from = activeTrip.start;
    _to = activeTrip.destination;

    if (driverNotifier.getTripInfo == null)
      await driverNotifier.drawTripPath(mapController, _from, _to);
  }

  await Future.delayed(Duration(seconds: 2), (() async {
    try {
      if (_from == null && _to == null) {
        mapController.clearAllRoads();
      } else {
        await mapController.addMarker(_from!,
            markerIcon: MarkerIcon(
                icon: Icon(Icons.location_pin, size: 75, color: Colors.red)));
        await mapController.addMarker(_to!,
            markerIcon: MarkerIcon(
                icon: Icon(Icons.location_pin, size: 75, color: Colors.red)));

        if (driverNotifier.getTripInfo == null)
          await driverNotifier.drawTripPath(mapController, _from, _to);
      }
    } catch (error) {}
  }));
};

Function(TextEditingController, TextEditingController, MapController,
        PanelController, BuildContext, Map<String, dynamic>) onDoneCallback =
    (TextEditingController fromController,
        TextEditingController toController,
        MapController mapController,
        PanelController panelController,
        BuildContext context,
        Map<String, dynamic> providers) async {
  final driverNotifier = providers['driver'] as DriverNotifier;
  final restService = providers['rest'] as RESTService;
  final notificationProvider = providers['notification'] as NotificationManager;
  final personalData = providers['personal'] as PersonalData;
  final tripInfo = driverNotifier.getTripInfo;
  final profitRate = restService.profitRate;
  String fromString = fromController.value.text;
  String toString = toController.value.text;
  GeoPoint? from = driverNotifier.getFromGeoPoint;
  GeoPoint? to = driverNotifier.getToGeoPoint;
  Vehicle? vehicleType = driverNotifier.getVehicle;
  int passengers = driverNotifier.getNumPassengers;
  bool? destInvalidToastBool;

  Future<void> Function() showVehicleErrorToast = () async {
    await Fluttertoast.showToast(
        msg: 'selectcar'.tr(),
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.indigoAccent,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0,
        webPosition: 'center');
  };

  Future<void> Function() showPassengerErrorToast = () async {
    await Fluttertoast.showToast(
        msg: 'selectpassengers'.tr(),
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.indigoAccent,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0,
        webPosition: 'center');
  };

  if (from != null && to != null && vehicleType != null && passengers != 0) {
    String name = '';
    String number = '';

    driverNotifier.drawTripPath(mapController, from, to);

    var personalInfo = await showDialog<Map<String, String>>(
        context: context,
        builder: (BuildContext context) {
          return PersonalInfoForm();
        });

    if (personalInfo != null) {
      name = (personalInfo['name'] != null && personalInfo['name']!.length > 0)
          ? personalInfo['name']!
          : (personalData.getName ?? '');
      number =
          (personalInfo['number'] != null && personalInfo['number']!.length > 0)
              ? personalInfo['number']!
              : (personalData.getNumber ?? '');

      String deviceId;
      int priceRatePerPassengerIndex = driverNotifier.getNumPassengers == 1
          ? 0
          : driverNotifier.getNumPassengers - 1;

      if (restService.deviceId != null && restService.deviceId!.length > 0)
        deviceId = restService.deviceId!;
      else
        deviceId = await personalData
            .setDeviceId('$name$number${DateTime.now().toString()}');

      Response response = await restService.tripOrderRequest({
        'deviceid': deviceId,
        'customer':
            (personalData.checkInfoExists()) ? personalData.getName : name,
        'fromDest': '${from.latitude}, ${from.longitude}',
        'fromString': fromString,
        'toDest': '${to.latitude}, ${to.longitude}',
        'toString': toString,
        'leavingDateTime': driverNotifier.getLeavingDateTime.toString(),
        'vehicleType': vehicleType.name,
        'passengers': passengers,
        'price': (((tripInfo!.distance! *
                        vehicleType.priceRates[priceRatePerPassengerIndex] *
                        1.5) +
                    vehicleType.initialPrice) *
                (profitRate ?? 1.4))
            .toStringAsFixed(2),
      }, (personalData.checkInfoExists()) ? personalData.getNumber! : number);

      notificationProvider.addNotification(response);

      if (response.statusCode == 200) {
        driverNotifier.clearAllInputs();
        panelController.close();
        driverNotifier.drawTripPath(mapController, from, to);
      } else
        Fluttertoast.showToast(
            msg: 'failedrequest'.tr(),
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.indigoAccent,
            textColor: Colors.white,
            gravity: ToastGravity.BOTTOM,
            fontSize: 16.0,
            webPosition: 'center');
    }
  }

  if (fromString.length == 0 || toString.length == 0)
    destInvalidToastBool = await Fluttertoast.showToast(
        msg: 'selectdestinations'.tr(),
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.indigoAccent,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0,
        webPosition: 'center');

  if (destInvalidToastBool != null) {
    if (vehicleType == null)
      await Future.delayed(Duration(seconds: 3), showVehicleErrorToast);
    if (passengers == 0)
      await Future.delayed(Duration(seconds: 3), showPassengerErrorToast);
  } else {
    if (vehicleType == null) {
      await showVehicleErrorToast();
      if (passengers == 0)
        await Future.delayed(Duration(seconds: 3), showPassengerErrorToast);
    } else {
      if (passengers == 0) showPassengerErrorToast();
    }
  }
};
