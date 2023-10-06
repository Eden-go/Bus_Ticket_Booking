import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesafari/model/trip.dart';
import 'package:tesafari/painters/ticketcontainerdef.dart';
import 'package:tesafari/painters/ticketcontainermin.dart';
import 'package:tesafari/states/drivernotifier.dart';
import 'package:tesafari/states/themenotifier.dart';
import 'package:tesafari/states/triphistory.dart';
import 'package:tesafari/utils/data_sorting.dart';
import 'package:tesafari/utils/date_localization.dart';
import 'package:tesafari/widgets/components/canceldialog.dart';

class Trips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context);
    final tripData = Provider.of<TripHistory>(context);
    final driverNotifer = Provider.of<DriverNotifier>(context);

    List<Trip> _trips = driverNotifer.getRecentTrips;

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.indigoAccent[400],
                title: Text(
                  'trips'.tr(),
                  style: (theme.currentSize == FontSizes.Small)
                      ? theme.fontTheme.titleSmall
                      : (theme.currentSize == FontSizes.Medium)
                          ? theme.fontTheme.titleMedium
                          : theme.fontTheme.titleLarge,
                ),
                elevation: 3,
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.swap_vert_circle_rounded),
                      onPressed: () {
                        tripData.setSortOrder = !tripData.getSortOrder;
                        _trips = sortData(_trips, tripData.getSortType,
                            tripData.getSortOrder) as List<Trip>;
                      }),
                  PopupMenuButton(
                      tooltip: 'sort'.tr(),
                      icon: Icon(Icons.sort),
                      onSelected: (SortType value) {
                        tripData.setSortType = value;
                        _trips = sortData(_trips, value, tripData.getSortOrder)
                            as List<Trip>;
                      },
                      initialValue: tripData.getSortType,
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<SortType>>[
                            PopupMenuItem<SortType>(
                                value: SortType.date,
                                child: Text('datetravelled'.tr(),
                                    style: TextStyle(
                                        color: (tripData.getSortType ==
                                                SortType.date)
                                            ? Theme.of(context)
                                                .textSelectionTheme
                                                .selectionColor
                                            : Colors.black,
                                        fontSize: (theme.currentSize ==
                                                FontSizes.Small)
                                            ? theme
                                                .fontTheme.bodySmall!.fontSize
                                            : (theme.currentSize ==
                                                    FontSizes.Medium)
                                                ? theme.fontTheme.bodyMedium!
                                                    .fontSize
                                                : theme.fontTheme.bodyLarge!
                                                    .fontSize))),
                            PopupMenuItem<SortType>(
                                value: SortType.price,
                                child: Text('pricepaid'.tr(),
                                    style: TextStyle(
                                        color: (tripData.getSortType ==
                                                SortType.price)
                                            ? Theme.of(context)
                                                .textSelectionTheme
                                                .selectionColor
                                            : Colors.black,
                                        fontSize: (theme.currentSize ==
                                                FontSizes.Small)
                                            ? theme
                                                .fontTheme.bodySmall!.fontSize
                                            : (theme.currentSize ==
                                                    FontSizes.Medium)
                                                ? theme.fontTheme.bodyMedium!
                                                    .fontSize
                                                : theme.fontTheme.bodyLarge!
                                                    .fontSize))),
                            PopupMenuItem<SortType>(
                                value: SortType.status,
                                child: Text('status'.tr(),
                                    style: TextStyle(
                                        color: (tripData.getSortType ==
                                                SortType.status)
                                            ? Theme.of(context)
                                                .textSelectionTheme
                                                .selectionColor
                                            : Colors.black,
                                        fontSize: (theme.currentSize ==
                                                FontSizes.Small)
                                            ? theme
                                                .fontTheme.bodySmall!.fontSize
                                            : (theme.currentSize ==
                                                    FontSizes.Medium)
                                                ? theme.fontTheme.bodyMedium!
                                                    .fontSize
                                                : theme.fontTheme.bodyLarge!
                                                    .fontSize)))
                          ])
                ],
                iconTheme: IconThemeData(color: Colors.white)),
            body: SingleChildScrollView(
              child: Column(children: [
                Container(
                    height: MediaQuery.of(context).size.height * .9,
                    width: MediaQuery.of(context).size.width,
                    child: (_trips.length == 0)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image: Image.asset("lib/images/emptyticket.png")
                                    .image,
                                height:
                                    MediaQuery.of(context).size.height * .25,
                              ),
                              Text('notrips'.tr(),
                                  style: (theme.currentSize == FontSizes.Small)
                                      ? theme.fontTheme.displaySmall
                                      : (theme.currentSize == FontSizes.Medium)
                                          ? theme.fontTheme.displayMedium
                                          : theme.fontTheme.displayLarge)
                            ],
                          )
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: _trips.length,
                            itemBuilder: (context, index) {
                              Widget _trip;
                              String ticketStatus = "";

                              if (_trips[index].status == "Pending")
                                ticketStatus = 'pending'.tr();

                              if (_trips[index].status == "Completed")
                                ticketStatus = 'completed'.tr();

                              if (_trips[index].status == "Cancelled")
                                ticketStatus = 'cancelled'.tr();

                              if (_trips[index].status == "Confirmed")
                                ticketStatus = 'confirmed'.tr();

                              bool willOverflow = false;
                              if (theme.currentSize == FontSizes.Large &&
                                  MediaQuery.of(context).size.width < 615)
                                willOverflow = true;

                              if (MediaQuery.of(context).size.width < 465)
                                willOverflow = true;

                              if (!willOverflow) {
                                _trip = Container(
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.all(10),
                                    height: (theme.currentSize == FontSizes.Large)
                                        ? 245
                                        : 185,
                                    child: CustomPaint(
                                        painter: TicketContainerDefaultPainter(
                                            left: 30,
                                            radius: 20,
                                            backColor: (theme.getTheme() ==
                                                    theme.darkTheme)
                                                ? const Color.fromARGB(
                                                    255, 95, 120, 138)
                                                : Colors.white,
                                            shadowColor: (theme.getTheme() ==
                                                    theme.lightTheme)
                                                ? Colors.grey[500]!
                                                : const Color.fromARGB(
                                                    255, 48, 48, 48)),
                                        child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  //Driver Ticket Image
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 5,
                                                                  left: 5),
                                                          child: Icon(
                                                              Icons
                                                                  .directions_car,
                                                              size: 115,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      51,
                                                                      51,
                                                                      51)),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          )),
                                                      Text(
                                                          _trips[index]
                                                              .carType!,
                                                          style: (theme
                                                                      .currentSize ==
                                                                  FontSizes
                                                                      .Small)
                                                              ? theme.fontTheme
                                                                  .bodySmall
                                                              : (theme.currentSize ==
                                                                      FontSizes
                                                                          .Medium)
                                                                  ? theme
                                                                      .fontTheme
                                                                      .bodyMedium
                                                                  : theme
                                                                      .fontTheme
                                                                      .bodyLarge),
                                                    ],
                                                  ),

                                                  //Destination Labels
                                                  Column(children: [
                                                    Text('from'.tr(),
                                                        style: (theme
                                                                    .currentSize ==
                                                                FontSizes.Small)
                                                            ? theme.fontTheme
                                                                .labelSmall
                                                            : (theme.currentSize ==
                                                                    FontSizes
                                                                        .Medium)
                                                                ? theme
                                                                    .fontTheme
                                                                    .labelMedium
                                                                : theme
                                                                    .fontTheme
                                                                    .labelLarge),
                                                    Text(
                                                        '${_trips[index].startString.substring(0, 12)}...',
                                                        style: (theme
                                                                    .currentSize ==
                                                                FontSizes.Small)
                                                            ? theme.fontTheme
                                                                .bodySmall
                                                            : (theme.currentSize ==
                                                                    FontSizes
                                                                        .Medium)
                                                                ? theme
                                                                    .fontTheme
                                                                    .bodyMedium
                                                                : theme
                                                                    .fontTheme
                                                                    .bodyLarge),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text('to'.tr(),
                                                          style: (theme
                                                                      .currentSize ==
                                                                  FontSizes
                                                                      .Small)
                                                              ? theme.fontTheme
                                                                  .labelSmall
                                                              : (theme.currentSize ==
                                                                      FontSizes
                                                                          .Medium)
                                                                  ? theme
                                                                      .fontTheme
                                                                      .labelMedium
                                                                  : theme
                                                                      .fontTheme
                                                                      .labelLarge),
                                                    ),
                                                    Text(
                                                        '${_trips[index].destinationString.substring(0, 12)}...',
                                                        style: (theme
                                                                    .currentSize ==
                                                                FontSizes.Small)
                                                            ? theme.fontTheme
                                                                .bodySmall
                                                            : (theme.currentSize ==
                                                                    FontSizes
                                                                        .Medium)
                                                                ? theme
                                                                    .fontTheme
                                                                    .bodyMedium
                                                                : theme
                                                                    .fontTheme
                                                                    .bodyLarge),

                                                    //Date Info
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 15,
                                                                top: 25),
                                                        child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            5),
                                                                child: Text(
                                                                    'date'.tr(),
                                                                    style: (theme.currentSize ==
                                                                            FontSizes
                                                                                .Small)
                                                                        ? theme
                                                                            .fontTheme
                                                                            .labelSmall
                                                                        : (theme.currentSize ==
                                                                                FontSizes.Medium)
                                                                            ? theme.fontTheme.labelMedium
                                                                            : theme.fontTheme.labelLarge),
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    getLocalizedDate(
                                                                        context
                                                                            .locale,
                                                                        _trips[index]
                                                                            .dateTime),
                                                                    style: (theme.currentSize ==
                                                                            FontSizes
                                                                                .Small)
                                                                        ? theme
                                                                            .fontTheme
                                                                            .bodySmall
                                                                        : (theme.currentSize ==
                                                                                FontSizes.Medium)
                                                                            ? theme.fontTheme.bodyMedium
                                                                            : theme.fontTheme.bodyLarge,
                                                                  ),
                                                                ],
                                                              )
                                                            ])),
                                                  ]),

                                                  //Price, Status and Accept/Remove Buttton
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          30),
                                                              child: Text(
                                                                  ticketStatus,
                                                                  style: (theme
                                                                              .currentSize ==
                                                                          FontSizes
                                                                              .Small)
                                                                      ? theme
                                                                          .fontTheme
                                                                          .bodySmall
                                                                      : (theme.currentSize ==
                                                                              FontSizes
                                                                                  .Medium)
                                                                          ? theme
                                                                              .fontTheme
                                                                              .bodyMedium
                                                                          : theme
                                                                              .fontTheme
                                                                              .bodyLarge),
                                                            ),
                                                            Text(
                                                                _trips[index]
                                                                        .price
                                                                        .toString() +
                                                                    'currency'
                                                                        .tr(),
                                                                style: (theme
                                                                            .currentSize ==
                                                                        FontSizes
                                                                            .Small)
                                                                    ? TextStyle(
                                                                        fontSize:
                                                                            theme.fontTheme.bodySmall!.fontSize! +
                                                                                7,
                                                                        color: (theme.getTheme() == theme.darkTheme)
                                                                            ? Colors
                                                                                .white
                                                                            : Colors
                                                                                .green)
                                                                    : (theme.currentSize ==
                                                                            FontSizes
                                                                                .Medium)
                                                                        ? TextStyle(
                                                                            fontSize: theme.fontTheme.bodyMedium!.fontSize! +
                                                                                7,
                                                                            color: (theme.getTheme() == theme.darkTheme)
                                                                                ? Colors.white
                                                                                : Colors.green)
                                                                        : TextStyle(fontSize: theme.fontTheme.bodyLarge!.fontSize! + 7, color: (theme.getTheme() == theme.darkTheme) ? Colors.white : Colors.green)),
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 10,
                                                                        left:
                                                                            10),
                                                                child:
                                                                    ElevatedButton(
                                                                        child: Icon(
                                                                            Icons
                                                                                .delete,
                                                                            color: Colors
                                                                                .white),
                                                                        onPressed:
                                                                            () {
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                Trip trip = _trips[index];
                                                                                String message;

                                                                                (trip.status == 'Confirmed') ? message = (context.locale == Locale('en', 'US')) ? 'You have not yet travelled with this ticket. Are you sure you want to cancel this order and permenantely delete this ticket?' : "በዚህ ቲኬት እስካሁን አልተጓዙም። እርግጠኛ ኖት ይህን ትእዛዝ መሰረዝ እና ይህን ቲኬት እስከመጨረሻው መሰረዝ ይፈልጋሉ?" : message = 'permanentdelete'.tr();
                                                                                return CancelDialog(trip: trip, message: message);
                                                                              });
                                                                        }))
                                                          ]))
                                                ]))));
                              } else {
                                _trip = Container(
                                    margin: EdgeInsets.all(10),
                                    height:
                                        (theme.currentSize == FontSizes.Large)
                                            ? 535
                                            : 440,
                                    child: CustomPaint(
                                        painter: TicketContainerMinimalPainter(
                                            left: 30,
                                            radius: 20,
                                            backColor: (theme.getTheme() ==
                                                    theme.darkTheme)
                                                ? const Color.fromARGB(
                                                    255, 95, 120, 138)
                                                : Colors.white,
                                            shadowColor: (theme.getTheme() ==
                                                    theme.lightTheme)
                                                ? Colors.grey[500]!
                                                : const Color.fromARGB(
                                                    255, 48, 48, 48)),
                                        child: Container(
                                            child: Container(
                                                child: Column(
                                                    children: <Widget>[
                                              //Driver Ticket Image
                                              Container(
                                                  margin: EdgeInsets.only(
                                                    top: 20,
                                                    bottom: 5,
                                                    right: 20,
                                                  ),
                                                  padding: EdgeInsets.all(40),
                                                  child: Container(
                                                      height: 90,
                                                      width: 100,
                                                      margin: EdgeInsets.all(5),
                                                      child: Icon(
                                                          Icons.directions_car,
                                                          size: 125,
                                                          color: Color.fromARGB(
                                                              255,
                                                              51,
                                                              51,
                                                              51))),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  )),
                                              Text(_trips[index].carType!,
                                                  style: (theme.currentSize ==
                                                          FontSizes.Small)
                                                      ? theme
                                                          .fontTheme.bodySmall
                                                      : (theme.currentSize ==
                                                              FontSizes.Medium)
                                                          ? theme.fontTheme
                                                              .bodyMedium
                                                          : theme.fontTheme
                                                              .bodyLarge),

                                              //Ticket Info
                                              Column(children: [
                                                //Destination Labels
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            5),
                                                                    child: Text(
                                                                        'from'
                                                                            .tr(),
                                                                        style: (theme.currentSize ==
                                                                                FontSizes.Small)
                                                                            ? theme.fontTheme.labelSmall
                                                                            : (theme.currentSize == FontSizes.Medium)
                                                                                ? theme.fontTheme.labelMedium
                                                                                : theme.fontTheme.labelLarge)),
                                                                Text(
                                                                    '${_trips[index].startString.substring(0, 12)}...',
                                                                    style: (theme.currentSize ==
                                                                            FontSizes
                                                                                .Small)
                                                                        ? theme
                                                                            .fontTheme
                                                                            .bodySmall
                                                                        : (theme.currentSize ==
                                                                                FontSizes.Medium)
                                                                            ? theme.fontTheme.bodyMedium
                                                                            : theme.fontTheme.bodyLarge)
                                                              ])),
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            5),
                                                                    child: Text(
                                                                        'to'
                                                                            .tr(),
                                                                        style: (theme.currentSize ==
                                                                                FontSizes.Small)
                                                                            ? theme.fontTheme.labelSmall
                                                                            : (theme.currentSize == FontSizes.Medium)
                                                                                ? theme.fontTheme.labelMedium
                                                                                : theme.fontTheme.labelLarge)),
                                                                Text(
                                                                    '${_trips[index].destinationString.substring(0, 12)}...',
                                                                    style: (theme.currentSize ==
                                                                            FontSizes
                                                                                .Small)
                                                                        ? theme
                                                                            .fontTheme
                                                                            .bodySmall
                                                                        : (theme.currentSize ==
                                                                                FontSizes.Medium)
                                                                            ? theme.fontTheme.bodyMedium
                                                                            : theme.fontTheme.bodyLarge)
                                                              ]))
                                                    ]),

                                                //Date Info
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20),
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 5),
                                                            child: Text(
                                                                'date'.tr(),
                                                                style: (theme
                                                                            .currentSize ==
                                                                        FontSizes
                                                                            .Small)
                                                                    ? theme
                                                                        .fontTheme
                                                                        .labelSmall
                                                                    : (theme.currentSize ==
                                                                            FontSizes
                                                                                .Medium)
                                                                        ? theme
                                                                            .fontTheme
                                                                            .labelMedium
                                                                        : theme
                                                                            .fontTheme
                                                                            .labelLarge),
                                                          ),
                                                          Column(
                                                            children: [
                                                              Text(
                                                                  getLocalizedDate(
                                                                      context
                                                                          .locale,
                                                                      _trips[index]
                                                                          .dateTime),
                                                                  style: (theme
                                                                              .currentSize ==
                                                                          FontSizes
                                                                              .Small)
                                                                      ? theme
                                                                          .fontTheme
                                                                          .bodySmall
                                                                      : (theme.currentSize ==
                                                                              FontSizes
                                                                                  .Medium)
                                                                          ? theme
                                                                              .fontTheme
                                                                              .bodyMedium
                                                                          : theme
                                                                              .fontTheme
                                                                              .bodyLarge),
                                                            ],
                                                          )
                                                        ])),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      //Price, Status and Accept/Remove Buttton
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 30),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                    ticketStatus,
                                                                    style: (theme.currentSize ==
                                                                            FontSizes
                                                                                .Small)
                                                                        ? theme
                                                                            .fontTheme
                                                                            .bodySmall
                                                                        : (theme.currentSize ==
                                                                                FontSizes.Medium)
                                                                            ? theme.fontTheme.bodyMedium
                                                                            : theme.fontTheme.bodyLarge),
                                                                Text(
                                                                    _trips[index]
                                                                            .price
                                                                            .toString() +
                                                                        'currency'
                                                                            .tr(),
                                                                    style: (theme.currentSize ==
                                                                            FontSizes
                                                                                .Small)
                                                                        ? TextStyle(
                                                                            fontSize: theme.fontTheme.bodySmall!.fontSize! +
                                                                                7,
                                                                            color: (theme.getTheme() == theme.darkTheme)
                                                                                ? Colors.white
                                                                                : Colors.green)
                                                                        : (theme.currentSize == FontSizes.Medium)
                                                                            ? TextStyle(fontSize: theme.fontTheme.bodyMedium!.fontSize! + 7, color: (theme.getTheme() == theme.darkTheme) ? Colors.white : Colors.green)
                                                                            : TextStyle(fontSize: theme.fontTheme.bodyLarge!.fontSize! + 7, color: (theme.getTheme() == theme.darkTheme) ? Colors.white : Colors.green)),
                                                                Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top: 10,
                                                                        left:
                                                                            10),
                                                                    child: ElevatedButton(
                                                                        child: Icon(Icons.delete, color: Colors.white),
                                                                        onPressed: () {
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                Trip trip = _trips[index];
                                                                                String message;

                                                                                (trip.status == 'Confirmed') ? message = (context.locale == Locale('en', 'US')) ? 'You have not yet travelled with this ticket. Are you sure you want to cancel this order and permenantely delete this ticket?' : "በዚህ ቲኬት እስካሁን አልተጓዙም። እርግጠኛ ኖት ይህን ትእዛዝ መሰረዝ እና ይህን ቲኬት እስከመጨረሻው መሰረዝ ይፈልጋሉ?" : message = 'permanentdelete'.tr();

                                                                                return CancelDialog(trip: trip, message: message);
                                                                              });
                                                                        }))
                                                              ]))
                                                    ])
                                              ])
                                            ])))));
                              }

                              return _trip;
                            }))
              ]),
            )));
  }
}
