import 'package:clickable_list_wheel_view/clickable_list_wheel_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesafari/states/drivernotifier.dart';
import 'package:tesafari/utils/date_localization.dart';

class LocalizedDateModalBottomSheet extends StatelessWidget {
  LocalizedDateModalBottomSheet();

  final enMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  final amMonths = [
    'መስከረም',
    'ጥቅምጥ',
    'ህዳር',
    'ታህሳስ',
    'ጥር',
    'የካቲት',
    'መጋቢት',
    'ሚያዝያ',
    'ግንቦት',
    'ሰኔ',
    'ሀምሌ',
    'ነሃሴ',
    'ፗግሜ'
  ];

  @override
  Widget build(BuildContext context) {
    final driverNotifier = Provider.of<DriverNotifier>(context);

    return StatefulBuilder(builder: (context, setModalState) {
      DateTime _dateTime = driverNotifier.getLeavingDateTime;
      
      String _dateString = getLocalizedDate(context.locale, _dateTime);
      int _daySelectedIndex = context.locale == Locale('en', 'US')
          ? _dateTime.day - 1
          : int.parse(getLocalizedDate(Locale('am', 'ET'), _dateTime)
                  .split(' ')[2]
                  .split('/')[0]) -
              1;
      int _monthSelectedIndex = context.locale == Locale('en', 'US')
          ? _dateTime.month - 1
          : amMonths.indexOf(
              getLocalizedDate(Locale('am', 'ET'), _dateTime).split(' ')[1]);
      int _yearSelectedIndex = _dateTime.year == DateTime.now().year ? 0 : 1;
      bool isPwagme =
          getLocalizedDate(Locale('am', 'ET'), _dateTime).split(' ')[1] == 'ፗግሜ'
              ? true
              : false;
      int dayNum = context.locale == Locale('en', 'US')
          ? driverNotifier.getLeavingDateTime.day - 1
          : int.parse(getLocalizedDate(Locale('am', 'ET'), _dateTime)
                  .split(' ')[2]
                  .split('/')[0]) -
              1;
      int monthNum = context.locale == Locale('en', 'US')
          ? driverNotifier.getLeavingDateTime.month - 1
          : amMonths.indexOf(
              getLocalizedDate(Locale('am', 'ET'), _dateTime).split(' ')[1]);
      int yearNum =
          driverNotifier.getLeavingDateTime.year == DateTime.now().year ? 0 : 1;

      ScrollController _dayScrollController =
          ScrollController(initialScrollOffset: (dayNum * 30));
      ScrollController _monthScrollController =
          ScrollController(initialScrollOffset: (monthNum * 30));
      ScrollController _yearScrollController =
          ScrollController(initialScrollOffset: yearNum * 30);

      return Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                        margin: EdgeInsets.only(top: 15, left: 10),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.grey,
                        )),
                    Container(
                      margin: EdgeInsets.only(top: 15, left: 10),
                      child: Text('$_dateString ',
                          style: TextStyle(
                              fontSize:
                                  (MediaQuery.of(context).size.width > 290)
                                      ? 12
                                      : 10)),
                    ),
                  ],
                ),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: MediaQuery.of(context).size.height * .125,
                height: MediaQuery.of(context).size.height * .25,
                child: ClickableListWheelScrollView(
                  itemCount: 30,
                  itemHeight: 30,
                  scrollController: _dayScrollController,
                  onItemTapCallback: (index) {
                    if (index >= 0 && index < 30) {
                      setModalState(() {
                        DateTime _leavingDateTime =
                            driverNotifier.getLeavingDateTime;
                        if (context.locale == Locale('en', 'US'))
                         driverNotifier.setDate = DateTime(_leavingDateTime.year,
                              _leavingDateTime.month, (index + 1));
                        else {
                          int year = int.parse((getLocalizedDate(
                                  Locale('am', 'ET'), DateTime.now()) as String)
                              .split(' ')[2]
                              .split('/')[1]);

                          driverNotifier.setDate = getLocalizedDate(
                              Locale('en', 'US'),
                              _leavingDateTime,
                              true,
                              year,
                              monthNum + 1,
                              (index + 1));
                        }
                      });
                    }
                  },
                  child: ListWheelScrollView.useDelegate(
                      diameterRatio: .75,
                      controller: _dayScrollController,
                      itemExtent: 30,
                      childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                        if (index < 0 ||
                            index >
                                (isPwagme &&
                                        context.locale == Locale('am', 'ET')
                                    ? ((_dateTime.year % 4 == 3))
                                        ? 5
                                        : 4
                                    : 29))
                          return null;
                        else
                          return ElevatedButton(
                              onPressed: () {},
                              child: Text((index + 1).toString(),
                                  style: TextStyle(
                                      color: (_daySelectedIndex == index)
                                          ? Colors.white
                                          : Colors.black)),
                              style: ElevatedButton.styleFrom(
                                  elevation: 10,
                                  primary: (_daySelectedIndex == index)
                                      ? Colors.indigoAccent
                                      : Colors.white));
                      })),
                ),
              ),
              Container(
                width: 110,
                height: MediaQuery.of(context).size.height * .40,
                child: ClickableListWheelScrollView(
                  itemHeight: 30,
                  itemCount: 12,
                  scrollController: _monthScrollController,
                  onItemTapCallback: (index) {
                    if (index >= 0 &&
                        index <
                            ((context.locale == Locale('en', 'US'))
                                ? 12
                                : 13)) {
                      setModalState(() {
                        DateTime _leavingDateTime =
                            driverNotifier.getLeavingDateTime;

                        if (context.locale == Locale('en', 'US'))
                          driverNotifier.setDate = DateTime(_leavingDateTime.year,
                              (index + 1), _leavingDateTime.day);
                        else {
                          int year = int.parse((getLocalizedDate(
                                  Locale('am', 'ET'), DateTime.now()) as String)
                              .split(' ')[2]
                              .split('/')[1]);

                          driverNotifier.setDate = getLocalizedDate(
                              Locale('en', 'US'),
                              _leavingDateTime,
                              true,
                              year,
                              (index + 1),
                              (index + 1 == 13 && dayNum > 5) ? 1 : dayNum + 1);
                        }
                      });
                    }
                  },
                  child: ListWheelScrollView(
                    diameterRatio: 0.75,
                    controller: _monthScrollController,
                    itemExtent: 30,
                    children: [
                      ...((context.locale == Locale('en', 'US')) ? enMonths : amMonths)
                          .map((month) => ElevatedButton(
                              child: Text(month,
                                  style: TextStyle(
                                      color: ((((context.locale == Locale('en', 'US'))) ? enMonths : amMonths)[
                                                  _monthSelectedIndex] ==
                                              month)
                                          ? Colors.white
                                          : Colors.black)),
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  elevation: 10,
                                  primary: ((((context.locale == Locale('en', 'US')))
                                              ? enMonths
                                              : amMonths)[_monthSelectedIndex] ==
                                          month)
                                      ? Colors.indigoAccent
                                      : Colors.white)))
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.height * .125,
                height: MediaQuery.of(context).size.height * .15,
                child: ClickableListWheelScrollView(
                  itemCount: 2,
                  itemHeight: 30,
                  scrollController: _yearScrollController,
                  onItemTapCallback: (index) {
                    DateTime _leavingDateTime = driverNotifier.getLeavingDateTime;

                    if (index == 0) {
                      setModalState(() {
                        _yearSelectedIndex = index;
                        if (context.locale == Locale('en', 'US'))
                          driverNotifier.setDate = DateTime(DateTime.now().year,
                              _leavingDateTime.month, _leavingDateTime.day);
                        else {
                          int year = int.parse((getLocalizedDate(
                                  Locale('am', 'ET'), DateTime.now()) as String)
                              .split(' ')[2]
                              .split('/')[1]);
                          driverNotifier.setDate = getLocalizedDate(
                              Locale('en', 'US'),
                              _leavingDateTime,
                              true,
                              year,
                              monthNum + 1,
                              dayNum + 1);
                        }
                      });
                    }

                    if (index == 1) {
                      setModalState(() {
                        _yearSelectedIndex = index;
                        if (context.locale == Locale('en', 'US'))
                          driverNotifier.setDate = DateTime(
                              DateTime.now().year + 1,
                              _leavingDateTime.month,
                              _leavingDateTime.day);
                        else {
                          int year = int.parse((getLocalizedDate(
                                  Locale('am', 'ET'),
                                  DateTime(
                                      DateTime.now().year + 1,
                                      DateTime.now().month,
                                      DateTime.now().day)) as String)
                              .split(' ')[2]
                              .split('/')[1]);

                          driverNotifier.setDate = getLocalizedDate(
                              Locale('en', 'US'),
                              _leavingDateTime,
                              true,
                              year,
                              monthNum + 1,
                              dayNum + 1);
                        }
                      });
                    }

                    if (index == 2) {
                      setModalState(() {
                        _yearSelectedIndex = index;
                        if (context.locale == Locale('en', 'US'))
                          driverNotifier.setDate = DateTime(
                              DateTime.now().year + 2,
                              _leavingDateTime.month,
                              _leavingDateTime.day);
                        else {
                          int year = int.parse((getLocalizedDate(
                                  Locale('am', 'ET'),
                                  DateTime(
                                      DateTime.now().year + 2,
                                      DateTime.now().month,
                                      DateTime.now().day)) as String)
                              .split(' ')[2]
                              .split('/')[1]);

                          driverNotifier.setDate = getLocalizedDate(
                              Locale('en', 'US'),
                              _leavingDateTime,
                              true,
                              year,
                              monthNum + 1,
                              dayNum + 1);
                        }
                      });
                    }
                    if (index == 3) {
                      setModalState(() {
                        _yearSelectedIndex = index;
                        if (context.locale == Locale('en', 'US'))
                          driverNotifier.setDate = DateTime(
                              DateTime.now().year + 3,
                              _leavingDateTime.month,
                              _leavingDateTime.day);
                        else {
                          int year = int.parse((getLocalizedDate(
                                  Locale('am', 'ET'),
                                  DateTime(
                                      DateTime.now().year + 3,
                                      DateTime.now().month,
                                      DateTime.now().day)) as String)
                              .split(' ')[2]
                              .split('/')[1]);

                          driverNotifier.setDate = getLocalizedDate(
                              Locale('en', 'US'),
                              _leavingDateTime,
                              true,
                              year,
                              monthNum + 1,
                              dayNum + 1);
                        }
                      });
                    }
                  },
                  child: ListWheelScrollView.useDelegate(
                      diameterRatio: .75,
                      controller: _yearScrollController,
                      itemExtent: 30,
                      childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                        if (index == 0)
                          return ElevatedButton(
                              onPressed: () {},
                              child: Text(
                                  (context.locale == Locale('en', 'US'))
                                      ? DateTime.now().year.toString()
                                      : (getLocalizedDate(Locale('am', 'ET'),
                                              DateTime.now()) as String)
                                          .split(' ')[2]
                                          .split('/')[1],
                                  style: TextStyle(
                                      color: (_yearSelectedIndex == index)
                                          ? Colors.white
                                          : Colors.black)),
                              style: ElevatedButton.styleFrom(
                                  elevation: 10,
                                  primary: (_yearSelectedIndex == index)
                                      ? Colors.indigoAccent
                                      : Colors.white));
                        else if (index == 1)
                          return ElevatedButton(
                              onPressed: () {},
                              child: Text(
                                  (context.locale == Locale('en', 'US'))
                                      ? (DateTime.now().year + 1).toString()
                                      : (getLocalizedDate(
                                                  Locale('am', 'ET'),
                                                  DateTime(
                                                      DateTime.now().year + 1,
                                                      DateTime.now().month,
                                                      DateTime.now().day))
                                              as String)
                                          .split(' ')[2]
                                          .split('/')[1],
                                  style: TextStyle(
                                      color: (_yearSelectedIndex == index)
                                          ? Colors.white
                                          : Colors.black)),
                              style: ElevatedButton.styleFrom(
                                  elevation: 10,
                                  primary: (_yearSelectedIndex == index)
                                      ? Colors.indigoAccent
                                      : Colors.white));
                        else
                          return null;
                      })),
                ),
              )
            ]),
            SizedBox(
                height: 30,
                width: 250,
                child: ElevatedButton(
                    child: Text(
                      'ok'.tr(),
                      style: TextStyle(fontSize: 15),
                    ),
                    onPressed: () {
                      int year = int.parse((getLocalizedDate(
                              Locale('am', 'ET'),
                              DateTime(_dateTime.year, _dateTime.month,
                                  _dateTime.day)) as String)
                          .split(' ')[2]
                          .split('/')[1]);

                      DateTime newDateTime = (context.locale ==
                              Locale('en', 'US'))
                          ? DateTime(
                              _dateTime.year,
                              (_monthScrollController.offset / 30 + 1).toInt(),
                              (_dayScrollController.offset / 30 + 1).toInt())
                          : getLocalizedDate(
                              Locale('en', 'US'),
                              _dateTime,
                              true,
                              year,
                              (_monthScrollController.offset / 30 + 1).toInt(),
                              (_dayScrollController.offset / 30 + 1).toInt());

                      
                      driverNotifier.setDate = newDateTime;
    
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.indigoAccent.shade400),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          // Change your radius here
                          borderRadius: BorderRadius.circular(20),
                        )))))
          ],
        ),
      );
    });
  }
}
