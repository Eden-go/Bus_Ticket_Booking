import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:morphable_shape/morphable_shape.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tesafari/model/location.dart';
import 'package:tesafari/model/trip.dart';
import 'package:tesafari/states/drivernotifier.dart';
import 'package:tesafari/states/notificationmanager.dart';
import 'package:tesafari/states/personaldata.dart';
import 'package:tesafari/states/restservice.dart';
import 'package:tesafari/states/themenotifier.dart';
import 'package:tesafari/utils/date_localization.dart';
import 'package:tesafari/widgets/components/activetrippanel.dart';
import 'package:tesafari/widgets/components/localizeddatemodalbottomsheet.dart';
import 'package:tesafari/utils/map_controller_functions.dart' as mapControls;

class TripSlidingPanel extends StatelessWidget {
  final MapController _mapController;
  final PanelController _panelController;

  TripSlidingPanel(this._mapController, this._panelController);

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    final double _screenHeight = MediaQuery.of(context).size.height;
    final driverNotifier = Provider.of<DriverNotifier>(context);
    final restService = Provider.of<RESTService>(context);
    final notificationProvider = Provider.of<NotificationManager>(context);
    final personalData = Provider.of<PersonalData>(context);
    final theme = Provider.of<ThemeNotifier>(context);
    final profitRate = restService.profitRate;
    final vehicleTierList = restService.getVehicleTierList;
    final locationList = restService.getTripLocations;
    RoadInfo? tripInfo = driverNotifier.getTripInfo;
    int priceRatePerPassengerIndex = driverNotifier.getNumPassengers <= 1
        ? 0
        : driverNotifier.getNumPassengers - 1;

    Trip? activeTrip;
    TextEditingController _fromController =
        TextEditingController(text: driverNotifier.getFrom);
    TextEditingController _toController =
        TextEditingController(text: driverNotifier.getTo);
    String date =
        getLocalizedDate(context.locale, driverNotifier.getLeavingDateTime);
    FocusNode? _fromFocusNode = driverNotifier.getFromFocus;
    FocusNode? _toFocusNode = driverNotifier.getToFocus;

    activeTrip = driverNotifier.getActiveTrip();
    notificationProvider.setDriverNotifier = driverNotifier;

    List<Widget> _panelChildren = [
      Container(
        height: 130,
        width: (_screenWidth > 515) ? _screenWidth * .5 : _screenWidth * .9,
        child: Stack(
          children: [
            Container(
                width: (_screenWidth > 515)
                    ? _screenWidth * .45
                    : _screenWidth * .85,
                height: 60,
                margin: EdgeInsets.all(10),
                child: TypeAheadField<TripLocation>(
                    hideOnEmpty: true,
                    hideOnError: true,
                    onSuggestionsBoxToggle: (value) {
                      driverNotifier.setToFocus = null;
                      driverNotifier.setFromFocus = FocusNode();
                    },
                    suggestionsCallback: (value) async {
                      List<TripLocation> locations = [];

                      if (value.isNotEmpty) {
                        print(locationList);
                        for (TripLocation location in locationList) {
                          if (location.name
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                            locations.add(location);
                        }
                      }

                      return locations;
                    },
                    onSuggestionSelected: (suggestion) async {
                      driverNotifier.setFromFocus = null;

                      driverNotifier.setFrom = suggestion.name;
                      driverNotifier.setFromGeoPoint = suggestion.coordinates;

                      GeoPoint? from = driverNotifier.getFromGeoPoint;
                      GeoPoint? to = driverNotifier.getToGeoPoint;

                      await _mapController.addMarker(from!,
                          markerIcon: MarkerIcon(
                              icon: Icon(Icons.location_pin,
                                  size: 75, color: Colors.red)));

                      if (to != null)
                        await driverNotifier.drawTripPath(
                            _mapController, from, to);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                          leading: Icon(Icons.location_pin),
                          title: Text(suggestion.name.tr()));
                    },
                    textFieldConfiguration: TextFieldConfiguration(
                      decoration: InputDecoration(
                          focusColor: Colors.indigoAccent,
                          icon: Icon(Icons.location_pin,
                              color: Colors.indigoAccent),
                          border: UnderlineInputBorder(),
                          suffixText: '              ',
                          labelText: (_fromFocusNode == null)
                              ? 'from'.tr()
                              : 'pick'.tr(),
                          labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: (theme.currentSize == FontSizes.Small)
                                  ? theme.fontTheme.bodySmall!.fontSize
                                  : (theme.currentSize == FontSizes.Medium)
                                      ? (theme.fontTheme.bodyMedium!.fontSize!)
                                      : theme.fontTheme.bodyLarge!.fontSize),
                          hoverColor: Colors.indigoAccent[400]),
                      controller: _fromController,
                    ))),
            Positioned(
              top: 50,
              child: Container(
                width: (_screenWidth > 515)
                    ? _screenWidth * .45
                    : (_screenWidth > 440)
                        ? _screenWidth * .85
                        : _screenWidth * .82,
                height: 60,
                margin: EdgeInsets.all(10),
                child: TypeAheadField<TripLocation>(
                  hideOnEmpty: true,
                  hideOnError: true,
                  onSuggestionsBoxToggle: (value) {
                    driverNotifier.setFromFocus = null;
                    driverNotifier.setToFocus = FocusNode();
                  },
                  suggestionsCallback: (value) async {
                    List<TripLocation> locations = [];

                    if (value.isNotEmpty) {
                      for (TripLocation location in locationList) {
                        if (location.name
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                          locations.add(location);
                      }
                    }

                    return locations;
                  },
                  onSuggestionSelected: (suggestion) async {
                    driverNotifier.setToFocus = null;

                    driverNotifier.setTo = suggestion.name;
                    driverNotifier.setToGeoPoint = suggestion.coordinates;

                    GeoPoint? from = driverNotifier.getFromGeoPoint;
                    GeoPoint? to = driverNotifier.getToGeoPoint;

                    await _mapController.addMarker(to!,
                        markerIcon: MarkerIcon(
                            icon: Icon(Icons.location_pin,
                                size: 75, color: Colors.red)));

                    if (from != null)
                      await driverNotifier.drawTripPath(
                          _mapController, from, to);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      leading: Icon(Icons.location_pin),
                      title: Text(suggestion.name),
                    );
                  },
                  textFieldConfiguration: TextFieldConfiguration(
                    decoration: InputDecoration(
                        focusColor: Colors.indigoAccent,
                        icon: Icon(Icons.location_pin,
                            color: Colors.indigoAccent),
                        border: InputBorder.none,
                        suffixText: '              ',
                        labelText:
                            (_toFocusNode == null) ? 'to'.tr() : 'pick'.tr(),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: (theme.currentSize == FontSizes.Small)
                                ? theme.fontTheme.bodySmall!.fontSize
                                : (theme.currentSize == FontSizes.Medium)
                                    ? (theme.fontTheme.bodyMedium!.fontSize!)
                                    : theme.fontTheme.bodyLarge!.fontSize),
                        hoverColor: Colors.indigoAccent[400]),
                    controller: _toController,
                  ),
                ),
              ),
            ),
            Positioned(
                top: 50,
                left: (_screenWidth > 515)
                    ? _screenWidth * .32
                    : (_screenWidth > 360)
                        ? _screenWidth * .75
                        : _screenWidth * .65,
                child: SizedBox(
                    height: 35,
                    child: OutlinedButton(
                      child: Icon(Icons.swap_vert),
                      onPressed: () {
                        driverNotifier.setFrom = _toController.text;
                        driverNotifier.setTo = _fromController.text;

                        GeoPoint? from = driverNotifier.getFromGeoPoint;
                        GeoPoint? to = driverNotifier.getFromGeoPoint;

                        if (from != null && to != null) {
                          driverNotifier.setFromGeoPoint = to;
                          driverNotifier.setToGeoPoint = from;
                        } else
                          Fluttertoast.showToast(
                              msg: 'selectdestinations'.tr(),
                              toastLength: Toast.LENGTH_SHORT,
                              backgroundColor: Colors.indigoAccent,
                              textColor: Colors.white,
                              gravity: ToastGravity.TOP,
                              fontSize: 16.0,
                              webPosition: 'center');
                      },
                      style: OutlinedButton.styleFrom(
                          primary: Colors.indigoAccent,
                          backgroundColor:
                              ((theme.getTheme() == theme.darkTheme)
                                  ? const Color.fromARGB(255, 48, 48, 48)
                                  : Colors.white),
                          shape: CircleBorder()),
                    )))
          ],
        ),
      ),
      Container(
          height: (_screenWidth > 515) ? 110 : 80,
          margin:
              EdgeInsets.symmetric(horizontal: (_screenWidth > 515) ? 20 : 0),
          child: (_screenWidth > 515)
              ? Container(
                  width: 200,
                  padding: const EdgeInsets.all(15.0),
                  child: OutlinedButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                              '${date.split('/')[1]}-${(context.locale == Locale('en', 'US')) ? driverNotifier.getLeavingDateTime.month : getAmharicMonthIndex(date.split(' ')[1])}-${date.split(' ')[2].split('/')[0]}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: (theme.currentSize ==
                                          FontSizes.Small)
                                      ? theme.fontTheme.bodySmall!.fontSize
                                      : (theme.currentSize == FontSizes.Medium)
                                          ? (theme.fontTheme.bodyMedium!
                                                  .fontSize! -
                                              1)
                                          : (_screenWidth > 606)
                                              ? theme.fontTheme.bodyLarge!
                                                      .fontSize! -
                                                  4
                                              : (theme.fontTheme.bodyMedium!
                                                      .fontSize! -
                                                  1))),
                        ],
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                            enableDrag: false,
                            context: context,
                            builder: (context) {
                              return LocalizedDateModalBottomSheet();
                            });
                      },
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.indigoAccent),
                          backgroundColor: Colors.indigoAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)))),
                )
              : Container(
                  width: 180,
                  padding: const EdgeInsets.all(15.0),
                  child: OutlinedButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                              '${date.split('/')[1]}-${(context.locale == Locale('en', 'US')) ? driverNotifier.getLeavingDateTime.month : getAmharicMonthIndex(date.split(' ')[1])}-${date.split(' ')[2].split('/')[0]}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: (theme.currentSize ==
                                          FontSizes.Small)
                                      ? theme.fontTheme.bodySmall!.fontSize
                                      : (theme.currentSize == FontSizes.Medium)
                                          ? (theme.fontTheme.bodyMedium!
                                                  .fontSize! -
                                              1)
                                          : (_screenWidth > 606)
                                              ? theme
                                                  .fontTheme.bodyLarge!.fontSize
                                              : (theme.fontTheme.bodyMedium!
                                                      .fontSize! -
                                                  1))),
                        ],
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                            enableDrag: false,
                            context: context,
                            builder: (context) {
                              return LocalizedDateModalBottomSheet();
                            });
                      },
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.indigoAccent),
                          backgroundColor: Colors.indigoAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)))),
                )),
    ];
    List<PageViewModel> _pageModelViews = [
      PageViewModel(
          decoration: PageDecoration(
              titleTextStyle: TextStyle(),
              footerPadding: EdgeInsets.symmetric(vertical: 0),
              titlePadding: EdgeInsets.only(top: 0, bottom: 0),
              boxDecoration: BoxDecoration(
                  color: ((theme.getTheme() == theme.darkTheme)
                      ? const Color.fromARGB(255, 100, 100, 100)
                      : Colors.grey[300]!))),
          titleWidget: Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            child: Text('choosecar'.tr(),
                style: TextStyle(
                    fontSize: (theme.currentSize == FontSizes.Large)
                        ? 30
                        : (theme.currentSize == FontSizes.Large)
                            ? 25
                            : 20,
                    color: ((theme.getTheme() == theme.darkTheme)
                        ? Colors.grey[300]!
                        : Colors.grey[600]!),
                    fontFamily: 'Montserrat')),
          ),
          bodyWidget: ListView.builder(
            physics: ScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.all(0),
              itemCount: vehicleTierList.length,
              itemBuilder: (context, index) {
                return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: driverNotifier.getVehicle !=
                                vehicleTierList[index]
                            ? ((theme.getTheme() == theme.darkTheme)
                                ? Color.fromARGB(255, 123, 123, 123)
                                : Colors.white)
                            : Colors.indigoAccent),
                    margin: EdgeInsets.all(7),
                    child: ListTile(
                        selected: driverNotifier.getVehicle ==
                            vehicleTierList[index],
                        onTap: () {
                          driverNotifier.setVehicle = vehicleTierList[index];
                        },
                        selectedColor: Colors.indigoAccent,
                        title: SizedBox(
                            height: 50,
                            child: Image.network(
                                '${(restService.getURL.contains('10.0.2.2')) ? 'http' : 'https'}://${restService.getURL}/${vehicleTierList[index].image}',
                                alignment: Alignment.centerLeft)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vehicleTierList[index].name.tr(),
                                style: TextStyle(
                                    fontSize: 10,
                                    color: driverNotifier.getVehicle ==
                                            vehicleTierList[index]
                                        ? Colors.white
                                        : Colors.grey)),
                            (driverNotifier.getVehicle ==
                                    vehicleTierList[index])
                                ? DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                        icon: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(Icons.people,
                                              color: Colors.white),
                                        ),
                                        value: driverNotifier
                                                    .getNumPassengers !=
                                                0
                                            ? driverNotifier.getNumPassengers
                                            : null,
                                        hint: Text(
                                          '0',
                                          style:
                                              TextStyle(color: Colors.white),
                                        ),
                                        style: TextStyle(color: Colors.white),
                                        dropdownColor: Colors.indigoAccent,
                                        items: List.generate(
                                            vehicleTierList[index]
                                                .priceRates
                                                .length,
                                            (passengerCount) =>
                                                DropdownMenuItem(
                                                    value: passengerCount + 1,
                                                    child: Text(
                                                        (passengerCount + 1)
                                                            .toString()))),
                                        onChanged: (value) {
                                          driverNotifier.setCapacity =
                                              value ?? 0;
                                        }),
                                  )
                                : SizedBox()
                          ],
                        ),
                        trailing: Text(
                            (tripInfo == null)
                                ? (driverNotifier.isDrawing)
                                    ? 'calculating'.tr()
                                    : ''
                                : '${(((tripInfo.distance! * vehicleTierList[index].priceRates[priceRatePerPassengerIndex] * 1.5) + vehicleTierList[index].initialPrice) * (profitRate ?? 1.4)).toStringAsFixed(2)}${'currency'.tr()}',
                            style: TextStyle(
                                color: (driverNotifier.getVehicle ==
                                        vehicleTierList[index])
                                    ? Colors.greenAccent
                                    : Colors.green,
                                fontSize: 11))));
              }))
    ];

    return SlidingUpPanel(
        isDraggable: activeTrip == null,
        color: Colors.grey[200]!,
        controller: _panelController,
        minHeight: (activeTrip == null)
            ? (_screenWidth > 515)
                ? 165
                : 225
            : 155,
        maxHeight: _screenHeight * .85,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        panel: Container(
            child: Column(
          children: (_screenWidth > 515)
              ? [
                  (activeTrip == null)
                      ? Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(),
                              GestureDetector(
                                onTap: () => (_panelController.isPanelOpen)
                                    ? _panelController.close()
                                    : _panelController.open(),
                                child: Container(
                                  margin: EdgeInsets.only(top: 5, left: 50),
                                  width: _screenWidth * .27,
                                  height: 7,
                                  decoration: BoxDecoration(
                                      color: Colors.indigoAccent,
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                              (driverNotifier.isDrawing)
                                  ? Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 15),
                                      child: SpinKitRing(
                                          size: 25,
                                          color: Colors.indigoAccent,
                                          lineWidth: 3),
                                    )
                                  : SizedBox()
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _panelChildren,
                            ),
                          ),
                        ])
                      : ActiveTripPanel(activeTrip, _mapController),
                  Container(
                    height: _screenHeight * .45,
                    child: IntroductionScreen(
                      pages: _pageModelViews,
                      dotsDecorator: DotsDecorator(activeColor: Colors.white),
                      showBackButton: true,
                      showNextButton: true,
                      showDoneButton: true,
                      freeze: true,
                      back: Text('back'.tr()),
                      next: Text('next'.tr()),
                      done: Text('tripbook'.tr()),
                      onDone: () => mapControls.onDoneCallback(
                          _fromController,
                          _toController,
                          _mapController,
                          _panelController,
                          context, {
                        'driver': driverNotifier,
                        'rest': restService,
                        'personal': personalData,
                        'notification': notificationProvider
                      }),
                    ),
                  )
                ]
              : [
                  (activeTrip == null)
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(),
                                GestureDetector(
                                  onTap: () => (_panelController.isPanelOpen)
                                      ? _panelController.close()
                                      : _panelController.open(),
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        top:
                                            (driverNotifier.isDrawing) ? 0 : 15,
                                        left: (driverNotifier.isDrawing)
                                            ? 50
                                            : 20),
                                    width: _screenWidth * .27,
                                    height: 7,
                                    decoration: BoxDecoration(
                                        color: Colors.indigoAccent,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                  ),
                                ),
                                (driverNotifier.isDrawing)
                                    ? Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 15),
                                        child: SpinKitRing(
                                            size: 25,
                                            color: Colors.indigoAccent,
                                            lineWidth: 3),
                                      )
                                    : SizedBox()
                              ],
                            ),
                            ..._panelChildren,
                          ],
                        )
                      : ActiveTripPanel(activeTrip, _mapController),
                  Container(
                    height: _screenHeight * .45,
                    child: IntroductionScreen(
                      pages: _pageModelViews,
                      showBackButton: true,
                      showNextButton: true,
                      showDoneButton: true,
                      freeze: true,
                      dotsDecorator: DotsDecorator(activeColor: Colors.white),
                      back: Text('back'.tr()),
                      next: Text('next'.tr()),
                      done: Text('tripbook'.tr()),
                      onDone: () => mapControls.onDoneCallback(
                          _fromController,
                          _toController,
                          _mapController,
                          _panelController,
                          context, {
                        'driver': driverNotifier,
                        'rest': restService,
                        'personal': personalData,
                        'notification': notificationProvider
                      }),
                    ),
                  )
                ],
        )));
  }
}
