
import 'package:tesafari/states/triphistory.dart';

List sortData(List data,SortType type, bool order) {
  List sortedData = data;
  int inner, numElements = data.length;
  dynamic temp;

  int h = 1;
  while (h <= numElements / 3) h = h * 3 + 1;
  while (h > 0) {
    for (int outer = h; outer <= numElements - 1; outer++) {
      temp = sortedData[outer];
      inner = outer;
      if (type == SortType.bus) {
        if (order == true) {
          while ((inner > h - 1) &&
              sortedData[inner - h].getBusUsed.compareTo(temp.getBusUsed) > 0) {
            sortedData[inner] = sortedData[inner - h];
            inner -= h;
          }
        } else {
          while ((inner > h - 1) &&
              sortedData[inner - h].getBusUsed.compareTo(temp.getBusUsed) < 0) {
            sortedData[inner] = sortedData[inner - h];
            inner -= h;
          }
        }
      }

      if (type == SortType.date) {
        if (order == true) {
          while ((inner > h - 1) &&
              sortedData[inner - h].getDateQuery.compareTo(temp.getDateQuery) >
                  0) {
            sortedData[inner] = sortedData[inner - h];
            inner -= h;
          }
        } else {
          while ((inner > h - 1) &&
              sortedData[inner - h].getDateQuery.compareTo(temp.getDateQuery) <
                  0) {
            sortedData[inner] = sortedData[inner - h];
            inner -= h;
          }
        }
      }

      if (type == SortType.price) {
        if (order == true) {
          while ((inner > h - 1) &&
              sortedData[inner - h].getPricePaid.compareTo(temp.getPricePaid) >
                  0) {
            sortedData[inner] = sortedData[inner - h];
            inner -= h;
          }
        } else {
          while ((inner > h - 1) &&
              sortedData[inner - h].getPricePaid.compareTo(temp.getPricePaid) <
                  0) {
            sortedData[inner] = sortedData[inner - h];
            inner -= h;
          }
        }
      }

      if (type == SortType.status) {
        if (order == true) {
          while ((inner > h - 1) &&
              sortedData[inner - h].getStatus.compareTo(temp.getStatus) > 0) {
            sortedData[inner] = sortedData[inner - h];
            inner -= h;
          }
        } else {
          while ((inner > h - 1) &&
              sortedData[inner - h].getStatus.compareTo(temp.getStatus) < 0) {
            sortedData[inner] = sortedData[inner - h];
            inner -= h;
          }
        }
      }

      sortedData[inner] = temp;
    }
    h = ((h - 1) / 3) as int;
  }

  return sortedData;
}
