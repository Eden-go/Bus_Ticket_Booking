import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tesafari/states/drivernotifier.dart';
import 'package:tesafari/states/notificationmanager.dart';
import 'package:tesafari/states/personaldata.dart';
import 'package:tesafari/states/restservice.dart';
import 'package:tesafari/utils/map_controller_functions.dart' as mapControls;
import 'package:tesafari/widgets/components/drawer.dart';
import 'package:tesafari/widgets/components/tripslidingpanel.dart';

class PremiumService extends StatelessWidget {
  final MapController _mapController =
      MapController(initMapWithUserPosition: true);
  final PanelController _panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    final driverNotifier = Provider.of<DriverNotifier>(context);
    final notificationProvider = Provider.of<NotificationManager>(context);
    final personalDataProvider = Provider.of<PersonalData>(context);
    final restServiceProvider = Provider.of<RESTService>(context);
    final double _screenWidth = MediaQuery.of(context).size.width;
    final double _screenHeight = MediaQuery.of(context).size.height;
    final unreadNotificationCount;

    restServiceProvider.setDeviceId = personalDataProvider.getDeviceId;
    if (restServiceProvider.isConnectionAlive &&
        restServiceProvider.deviceId != null)
      notificationProvider
          .getNotificationsFromServer(restServiceProvider.getNotifications());

    unreadNotificationCount = notificationProvider.getUnreadNotificationsCount;

    _mapController.listenerMapSingleTapping.addListener(() =>
        mapControls.mapTouchEventListener(
            _panelController, _mapController, driverNotifier));

    mapControls.reRenderMap(driverNotifier, _mapController);

    return WillPopScope(
      onWillPop: (() {
        driverNotifier.clearAllInputs();
        return Future.value(true);
      }),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.indigoAccent[400],
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            Stack(children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 15),
                child: TextButton(
                  child: Icon(Icons.notifications, color: Colors.indigoAccent),
                  onPressed: () {
                    if (driverNotifier.getFromFocus != null ||
                        driverNotifier.getToFocus != null) {
                      driverNotifier.setFromFocus = null;
                      driverNotifier.setToFocus = null;
                    }

                    driverNotifier.setFrom = null;
                    driverNotifier.setFromGeoPoint = null;
                    driverNotifier.setTo = null;
                    driverNotifier.setToGeoPoint = null;

                    Navigator.pushNamed(context, '/notification');
                  },
                ),
              ),
              unreadNotificationCount != 0
                  ? new Positioned(
                      right: 11,
                      top: 11,
                      child: new Container(
                        padding: EdgeInsets.only(
                            bottom: 5, left: 2, right: 2, top: 1),
                        decoration: new BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(unreadNotificationCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                            textAlign: TextAlign.center),
                      ),
                    )
                  : Container()
            ])
          ],
        ),
        drawer: MainDrawer(),
        body: Stack(children: [
          Container(
            child: OSMFlutter(
              mapIsLoading: SpinKitRotatingCircle(color: Colors.indigoAccent),
              stepZoom: 10,
              initZoom: 10,
              onMapIsReady: (value) async {
                await _mapController.currentLocation();
                await _mapController.enableTracking();
              },
              controller: _mapController,
              userLocationMarker: UserLocationMaker(
                personMarker: MarkerIcon(
                  icon: Icon(
                    Icons.circle,
                    color: Colors.blue,
                    size: 38,
                  ),
                ),
                directionArrowMarker: MarkerIcon(
                  icon: Icon(
                    Icons.circle,
                    color: Colors.blue,
                    size: 38,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              top: (_screenWidth > 515)
                  ? _screenHeight * .65
                  : _screenHeight * .5,
              left: (_screenWidth > 780)
                  ? _screenWidth * .9
                  : (_screenWidth > 500)
                      ? _screenWidth * .87
                      : (_screenWidth > 340)
                          ? _screenWidth * .85
                          : _screenWidth * .75,
              child: FloatingActionButton(
                elevation: 100,
                backgroundColor: Colors.grey[200],
                onPressed: (() async {
                  try {
                    await _mapController.currentLocation();
                    await _mapController.zoomIn();
                  } catch (error) {}
                }),
                child: Icon(
                  Icons.my_location,
                  color: Colors.indigoAccent[400],
                  size: 25,
                ),
              )),
          TripSlidingPanel(_mapController, _panelController)
        ]),
      ),
    );
  }
}
