import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tesafari/model/trip.dart';
import 'package:tesafari/states/drivernotifier.dart';
import 'package:tesafari/states/notificationmanager.dart';
import 'package:tesafari/states/restservice.dart';
import 'package:easy_localization/easy_localization.dart';

class CancelDialog extends StatefulWidget {
  final Trip? trip;
  final String message;

  CancelDialog({required this.message, this.trip});

  _CancelState createState() => _CancelState();
}

class _CancelState extends State<CancelDialog> {
  @override
  Widget build(BuildContext context) {
    final notificationManager = Provider.of<NotificationManager>(context);
    final restService = Provider.of<RESTService>(context);
    final driverNotifier = Provider.of<DriverNotifier>(context);

    return AlertDialog(
            title: Text('deletetrip'.tr()),
            content: Text(widget.message),
            actions: [
              TextButton(
                child: Text('yes'.tr()),
                onPressed: () async {
                  Trip trip = widget.trip!;

                  if (trip.status == 'Completed') {
                    driverNotifier.deleteTrip(trip);
                  } else {
                    var response = await restService.tripCancelRequest({
                      'id': trip.tripId,
                      'deviceid': restService.deviceId,
                      'driverid': trip.driverId
                    });

                    notificationManager.addNotification(response);

                    if (response.statusCode == 200) {
                      driverNotifier.deleteTrip(trip);
                      driverNotifier.clearAllInputs();
                    } else
                      Fluttertoast.showToast(
                          msg: 'failedrequest'.tr(),
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.TOP,
                          fontSize: 16.0,
                          webPosition: 'center', backgroundColor: Colors.indigoAccent,
                          textColor: Colors.white);
                  }

                  Navigator.pop(context);
                },
              )
            ],
          );
  }
}
