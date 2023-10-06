import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

dynamic getLocalizedDate(Locale contextLocale, DateTime leavingDateTime,
    [bool willConvert = false, int year = 0, int month = 0, int day = 0]) {
  if (contextLocale == Locale('am', 'ET'))
    return _getEthiopianDate(leavingDateTime);
  else {
    if (!willConvert)
      return DateFormat("EEE, MMM dd/yyyy").format(leavingDateTime);
    else {
      return _getGregorianDate(year, month, day, leavingDateTime);
    }
  }
}

String _getEthiopianDate(DateTime leavingDateTime) {
  int dayCounter = 0;
  int monthRange = (leavingDateTime.month == 10 ||
          leavingDateTime.month == 12 ||
          leavingDateTime.month == 1 ||
          leavingDateTime.month == 3 ||
          leavingDateTime.month == 5 ||
          leavingDateTime.month == 7 ||
          leavingDateTime.month == 8 ||
          leavingDateTime.month == 9)
      ? 30
      : 31;
  int index = int.parse(
      '${leavingDateTime.month}${(leavingDateTime.day / 10 >= 1) ? leavingDateTime.day : '0' + leavingDateTime.day.toString()}');
  String dayString, dateString;
  String yearString = ((leavingDateTime.year % 4 == 3)
      ? ((index > 911)
          ? (leavingDateTime.year - 7).toString()
          : (leavingDateTime.year - 8).toString())
      : ((index > 910)
          ? (leavingDateTime.year - 7).toString()
          : (leavingDateTime.year - 8).toString()));
  String monthString =
      ((leavingDateTime.month % 9) + ((leavingDateTime.month > 8) ? 1 : 4))
          .toString();
  bool isLeapYear = (int.parse(yearString) % 4 == 3) ? true : false;
  bool isAfterLeapYear = (int.parse(yearString) % 4 == 0) ? true : false;

  if (index > 100 && index <= 131) dayCounter = 8;
  if (index > 131 && index <= 228) dayCounter = 7;
  if (index > 228 && index <= 331) dayCounter = 9;
  if (index > 331 && index <= 531) dayCounter = 8;
  if (index > 400 && index <= 408) dayCounter = 9;
  if (index > 531 && index <= 731) dayCounter = 7;
  if (index > 600 && index < 608) dayCounter = 8;
  if (index > 731 && index <= 831) dayCounter = 6;
  if (index > 831 && index <= 905) dayCounter = 5;
  if (index > 910 && index <= 1031) dayCounter = 10;
  if (index > 1031 && index <= 1231) dayCounter = 9;

  if (index >= 101 && index <= 131) dayCounter = (isAfterLeapYear) ? 9 : 8;
  if (index > 131 && index <= 229)
    dayCounter = (isAfterLeapYear)
        ? (index >= 201 && index <= 207)
            ? 7
            : 8
        : (isLeapYear)
            ? (index >= 201 && index < 207)
                ? 6
                : 7
            : (index >= 201 && index < 207)
                ? 6
                : 7;
  if (index >
          ((isAfterLeapYear)
              ? 911
              : (isLeapYear)
                  ? 911
                  : 910) &&
      index <= 1031)
    dayCounter = (isAfterLeapYear)
        ? 11
        : (isLeapYear)
            ? (index >= 912)
                ? 10
                : 11
            : 10;
  if (index > 1031 && index <= 1231)
    dayCounter = (isAfterLeapYear)
        ? (index >= 1112)
            ? 10
            : 11
        : (isLeapYear)
            ? (index >= 1112)
                ? 10
                : 11
            : 10;
  if (index > 1100 && index < 1111) dayCounter = (isAfterLeapYear) ? 11 : 10;
  if (index >= 1111) dayCounter = (isAfterLeapYear) ? 10 : 9;

  dayString = (leavingDateTime.day - dayCounter).toString();
  int tempDay = leavingDateTime.day - dayCounter;

  if (tempDay <= 0) {
    if (leavingDateTime.month == 2 &&
        leavingDateTime.day >= 1 &&
        leavingDateTime.day <= ((isAfterLeapYear) ? 29 : 28)) {
      if (isAfterLeapYear)
        dayString = (29 + tempDay).toString();
      else {
        if (isLeapYear)
          dayString = (29 + tempDay).toString();
        else {
          if (leavingDateTime.day >= 1 && leavingDateTime.day < 7)
            dayString = (29 + tempDay).toString();
          else
            dayString = (28 + tempDay).toString();
        }
      }

      if (isAfterLeapYear && index == 208) dayString = '30';
      if (!isAfterLeapYear && index == 207) dayString = '30';
    } else
      dayString = (((tempDay != 0)
                  ? monthRange
                  : (((monthRange == 30 &&
                              index == ((isAfterLeapYear) ? 911 : 910)) ||
                          (monthRange == 31 &&
                              index >= ((isAfterLeapYear) ? 1111 : 1110)))
                      ? 1
                      : monthRange)) +
              tempDay)
          .toString();

    monthString = (monthString == '1')
        ? (tempDay == 0 && monthRange == 30 && index == 911)
            ? '1'
            : '12'
        : (tempDay == 0 &&
                monthRange == 31 &&
                (index == 1109 || index == 1111 || index == 1110))
            ? monthString
            : (int.parse(monthString) - 1).toString();
  }

  if (isLeapYear &&
      leavingDateTime.month == 9 &&
      leavingDateTime.day >= 6 &&
      leavingDateTime.day <= 11) {
    monthString = (leavingDateTime.year % 4 == 2) ? monthString : '13';
    dayString = (leavingDateTime.year % 4 == 2)
        ? dayString
        : (leavingDateTime.day - 5).toString();
  }
  if (!isLeapYear &&
      leavingDateTime.month == 9 &&
      leavingDateTime.day >= 6 &&
      leavingDateTime.day <= 10) {
    monthString = '13';
    dayString = (leavingDateTime.day - 5).toString();
  }

  dateString =
      '${_getAmharicDay(leavingDateTime.weekday)}, ${_getAmharicMonth(monthString)} $dayString/$yearString';

  return dateString;
}

DateTime _getGregorianDate(int year, int month, int day, DateTime dateTime) {
  int enDay;
  DateTime date;
  int monthRange = 30;
  int index =
      int.parse('$month${(day / 10 >= 1) ? day : '0' + day.toString()}');
  int enYear = ((year % 4 == 3)
      ? ((index > 424) ? (year + 8) : (year + 7))
      : ((index > 423) ? (year + 8) : (year + 7)));
  int enMonth = (((month + 8) % 12) + ((month > 4) ? 1 : 0));
  bool isAfterLeapYear = (enYear % 4 == 0) ? true : false;
  int dayCounter = 0;

  //September - October
  if (index >= 101 && index <= 221) {
    dayCounter = 10;
    monthRange = 30;

    if (index > 120 && index <= 130) {
      enMonth += 1;
    }
  }
  //October - December
  if (index >= 222 && index <= 422) {
    dayCounter = 9;
    monthRange = 30;

    if ((index > 321 && index <= 330) || (index <= 230)) enMonth += 1;

    if (enMonth == 0) enMonth = 12;
  }
  //December - Januaray
  if (index >= 423 && index <= 523) {
    dayCounter = 8;
    monthRange = 30;

    if (index > 430) {
      monthRange = 31;
      enMonth -= 1;
    }

    if (enMonth == 0) enMonth = 1;
  }
  //January - February
  if (index >= 524 && index <= 621) {
    dayCounter = (isAfterLeapYear && index <= 621) ? 8 : 7;
    monthRange = 30;

    if (index > 530) enMonth -= 1;
  }
  //Febraury - March
  if (index >= 622 && index <= 722) {
    dayCounter = 9;
    monthRange = 30;

    if (index > 630) {
      monthRange = 31;
      enMonth -= 1;
    }
  }
  //March - May
  if (index >= 723 && index <= 923) {
    dayCounter = 8;
    monthRange = 30;

    if (index > 830) {
      monthRange = 31;
      enMonth -= 1;
    }

    if (index > 730 && index <= 822) enMonth -= 1;
  }
  //May - July
  if (index >= 924 && index <= 1124) {
    dayCounter = 7;
    monthRange = 30;

    if (index > 930 && index <= 1023) enMonth -= 1;
  }
  //July - August
  if (index >= 1125 && index <= 1225) {
    dayCounter = 6;
    monthRange = 30;

    if (index > 1130) {
      monthRange = 31;
      enMonth -= 1;
    }
  }
  //August - September
  if (index >= 1226 && index <= 1306) {
    dayCounter = 5;
    if (index > 1230) enMonth -= 1;
  }

  enDay = (day + dayCounter) % monthRange;
  if (enDay == 0) enDay = monthRange;

  date = DateTime(enYear, enMonth, enDay);
  return date;
}

List<String> getAmharicDestinations(List<String> destinations) {
  List<String> amhDestinations = [];
  destinations.forEach((destination) {
    amhDestinations.add(destination.tr());
  });
  return amhDestinations;
}

String _getAmharicDay(int dayIndex) {
  switch (dayIndex) {
    case 1:
      return 'ሰኞ';
    case 2:
      return 'ማክሰኞ';
    case 3:
      return 'ረብዕ';
    case 4:
      return 'ሀሙስ';
    case 5:
      return 'አርብ';
    case 6:
      return 'ቅዳሜ';
    case 7:
      return 'እሁድ';
    default:
      return '';
  }
}

String _getAmharicMonth(String monthIndex) {
  const monthMap = {
    '1': 'መስከረም',
    '2': 'ጥቅምጥ',
    '3': 'ህዳር',
    '4': 'ታህሳስ',
    '5': 'ጥር',
    '6': 'የካቲት',
    '7': 'መጋቢት',
    '8': 'ሚያዝያ',
    '9': 'ግንቦት',
    '10': 'ሰኔ',
    '11': 'ሀምሌ',
    '12': 'ነሃሴ',
    '13': 'ፗግሜ'
  };

  return monthMap[monthIndex] ?? '';
}

int getAmharicMonthIndex(String month) {
  const monthMap = {
    'መስከረም': 1,
    'ጥቅምጥ': 2,
    'ህዳር': 3,
    'ታህሳስ': 4,
    'ጥር': 5,
    'የካቲት': 6,
    'መጋቢት': 7,
    'ሚያዝያ': 8,
    'ግንቦት': 9,
    'ሰኔ': 10,
    'ሀምሌ': 11,
    'ነሃሴ': 12,
    'ፗግሜ': 13
  };

  return monthMap[month] ?? 0;
}

String getLocalizedTime(Locale locale, String time) {
  String originalLeavingTime = time;
  String leavingTime = originalLeavingTime;
  String firstChar = leavingTime.substring(0, leavingTime.indexOf(':'));

  if (locale == Locale('am', 'ET')) {
    String newChar = ((int.parse(firstChar) + 6) % 12).toString();
    leavingTime = ((newChar == "0") ? "12" : newChar) +
        leavingTime.substring(leavingTime.indexOf(':'));
    leavingTime = leavingTime.split(" ")[0];
  }

  return leavingTime;
}
