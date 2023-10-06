import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TesafariNotification {
  int id;
  String title;
  String message;
  Importance importance;
  bool isRead;
  DateTime? timeStamp;
  String dataJson = '';

  TesafariNotification(this.id, this.title, this.message, this.timeStamp,
      this.importance, this.dataJson,
      {this.isRead: false});

  toJsonEncodable() {
    Map<String, dynamic> notificationMap = Map();
    notificationMap['id'] = this.id;
    notificationMap['title'] = this.title;
    notificationMap['message'] = this.message;
    notificationMap['timeStamp'] = this.timeStamp.toString();
    notificationMap['importance'] = _getPriorityLevelString(this.importance);
    notificationMap['isRead'] = this.isRead;
    notificationMap['data'] = this.dataJson;

    return notificationMap;
  }

  String _getPriorityLevelString(Importance importance) {
    if (importance == Importance.defaultImportance) return 'MEDIUM';
    if (importance == Importance.high) return 'HIGH';
    if (importance == Importance.low) return 'LOW';

    return '';
  }
}
