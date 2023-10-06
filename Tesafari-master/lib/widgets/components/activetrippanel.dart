import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:tesafari/model/trip.dart';
import 'package:tesafari/states/drivernotifier.dart';
import 'package:tesafari/states/notificationmanager.dart';
import 'package:tesafari/states/restservice.dart';
import 'package:tesafari/states/themenotifier.dart';

class ActiveTripPanel extends StatelessWidget {
  final Trip activeTrip;
  final MapController _mapController;
  ActiveTripPanel(this.activeTrip, this._mapController);

  @override
  Widget build(BuildContext context) {
    final driverNotifier = Provider.of<DriverNotifier>(context);
    final restService = Provider.of<RESTService>(context);
    final notificationProvider = Provider.of<NotificationManager>(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    Widget _cancelButton = ElevatedButton(
      style:
          ElevatedButton.styleFrom(primary: Color.fromARGB(255, 203, 64, 64)),
      child: Text('cancel'.tr()),
      onPressed: () async {
        Response response = await restService.tripCancelRequest({
          'id': activeTrip.tripId,
          'deviceid': restService.deviceId,
          'driverid': activeTrip.driverId
        });

        notificationProvider.addNotification(response);

        if (response.statusCode == 200) {
          driverNotifier.deleteTrip(activeTrip);
          driverNotifier.clearAllInputs();

          _mapController.clearAllRoads();
          _mapController.geopoints.then((value) {
            value.forEach((marker) {
              _mapController.removeMarker(marker);
            });
          });
        } else {
          var body = json.decode(response.body);
          var payload = body['payload'];
          var message = payload['body'] as String;

          if (message.contains('Trip does not exist')) {
            driverNotifier.deleteTrip(activeTrip);
            driverNotifier.clearAllInputs();

            _mapController.clearAllRoads();
            _mapController.geopoints.then((value) {
              value.forEach((marker) {
                _mapController.removeMarker(marker);
              });
            });
          }

          Fluttertoast.showToast(
              msg: 'failedrequest'.tr(),
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.indigoAccent,
              textColor: Colors.white,
              gravity: ToastGravity.TOP,
              fontSize: 16.0,
              webPosition: 'center');
        }
      },
    );

    Widget _panelControls = SizedBox();

    if (activeTrip.status == "Pending")
      _panelControls = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('searchingdrivers'.tr(),
              style: TextStyle(fontSize: 10, color: Colors.black)),
          _cancelButton
        ],
      );
    else if (activeTrip.status == "Started")
      _panelControls =
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
            (context.locale == Locale('en', 'US'))
                ? 'Rate ${activeTrip.driverName}'
                : 'ለ ${activeTrip.driverName} አስተያየት ይስጡ',
            style: TextStyle(fontSize: 15)),
        RatingBar(
            itemSize: 35,
            initialRating: 0,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            ratingWidget: RatingWidget(
                full: const Icon(Icons.star, color: Colors.amber),
                half: const Icon(
                  Icons.star_half,
                  color: Colors.amber,
                ),
                empty: const Icon(
                  Icons.star_outline,
                  color: Colors.amber,
                )),
            onRatingUpdate: (value) {
              restService.rateTripRequest(
                  {'driverid': activeTrip.driverId, 'rating': value});
            }),
      ]);
    else
      _panelControls = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(children: [
              Text(activeTrip.driverName!,
                  style: TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 48, 48, 48))),
              Text(restService.decrypt(activeTrip.driverPhone!),
                  style: TextStyle(
                      fontSize: 12, color: Color.fromARGB(255, 48, 48, 48))),
            ]),
            _cancelButton
          ]),
          RatingBar(
              itemSize: 25,
              initialRating: activeTrip.driverRating ?? 0,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              ignoreGestures: true,
              ratingWidget: RatingWidget(
                  full: const Icon(Icons.star, color: Colors.amber),
                  half: const Icon(
                    Icons.star_half,
                    color: Colors.amber,
                  ),
                  empty: const Icon(
                    Icons.star_outline,
                    color: Colors.amber,
                  )),
              onRatingUpdate: (value) {}),
        ],
      );

    return Container(
        height: 150,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: themeNotifier.getTheme() == themeNotifier.darkTheme
                ? const Color.fromARGB(255, 48, 48, 48)
                : Colors.grey[200]),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              SizedBox(),
              (driverNotifier.isDrawing) ? Container(
                margin: EdgeInsets.all(10),
                child: SpinKitRing(
                    size: 25, color: Colors.indigoAccent, lineWidth: 3)) : SizedBox(),
            Container(
                margin: EdgeInsets.only(top: 5, right: 20),
                child: Text(
                    (driverNotifier.getTripInfo != null)
                        ? '${driverNotifier.getTripInfo!.distance!.toStringAsFixed(2)} ${'km'.tr()}'
                        : '${'km'.tr()}',
                    style: TextStyle(color: Colors.indigoAccent)))
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * .2,
                    vertical: 10),
                child: _panelControls),
            Text('${activeTrip.price.toString()} ${'currency'.tr()}',
                style: TextStyle(color: Colors.indigoAccent, fontSize: 25)),
          ])
        ]));
  }
}
