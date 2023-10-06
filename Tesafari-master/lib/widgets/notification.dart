import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesafari/states/notificationmanager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tesafari/states/themenotifier.dart';

class NotificationPage extends StatefulWidget {
  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final notificationProvider = Provider.of<NotificationManager>(context);
    var unreadNotifications = notificationProvider.getNotifications;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigoAccent[400],
          title: Text(
            "notifications".tr(),
            style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: (themeNotifier.currentSize == FontSizes.Small)
                    ? themeNotifier.fontTheme.titleSmall!.fontSize
                    : (themeNotifier.currentSize == FontSizes.Medium)
                        ? themeNotifier.fontTheme.titleMedium!.fontSize
                        : themeNotifier.fontTheme.titleLarge!.fontSize),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            TextButton(
                onPressed: () {
                  notificationProvider.deleteAllNotification();
                },
                child: Icon(Icons.delete, color: Colors.white))
          ],
        ),
        body: (unreadNotifications.length != 0)
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: unreadNotifications.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(unreadNotifications[index].title,
                        style: TextStyle(
                            fontWeight: (unreadNotifications[index].isRead)
                                ? FontWeight.normal
                                : FontWeight.bold)),
                    subtitle: Text(unreadNotifications[index].message,
                        style: TextStyle(
                            fontWeight: (unreadNotifications[index].isRead)
                                ? FontWeight.normal
                                : FontWeight.bold)),
                    trailing: PopupMenuButton(
                      child: Icon(Icons.more_vert),
                      onSelected: (String value) {
                        if (value == 'Mark as read') {
                          setState(() {
                            unreadNotifications = notificationProvider
                                .markNotificationAsRead(index);
                          });
                        }

                        if (value == 'Remove')
                          notificationProvider
                              .deleteNotification(unreadNotifications[index]);
                      },
                      itemBuilder: (context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                            value: 'Mark as read',
                            child: Text('markread'.tr(),
                                style: (themeNotifier.currentSize ==
                                        FontSizes.Small)
                                    ? themeNotifier.fontTheme.bodySmall
                                    : (themeNotifier.currentSize ==
                                            FontSizes.Medium)
                                        ? themeNotifier.fontTheme.bodyMedium
                                        : themeNotifier.fontTheme.bodyLarge)),
                        PopupMenuItem<String>(
                            value: 'Remove',
                            child: Text(
                              'remove'.tr(),
                              style:
                                  (themeNotifier.currentSize == FontSizes.Small)
                                      ? themeNotifier.fontTheme.bodySmall
                                      : (themeNotifier.currentSize ==
                                              FontSizes.Medium)
                                          ? themeNotifier.fontTheme.bodyMedium
                                          : themeNotifier.fontTheme.bodyLarge,
                            ))
                      ],
                    ),
                  );
                },
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 20),
                    child: Text('nothing'.tr(),
                        
                        style: 
                            TextStyle(fontSize: (themeNotifier.currentSize == FontSizes.Small) 
                              ? themeNotifier.fontTheme.bodySmall!.fontSize 
                              : (themeNotifier.currentSize == FontSizes.Medium)
                                ? themeNotifier.fontTheme.bodyMedium!.fontSize
                                : themeNotifier.fontTheme.bodyLarge!.fontSize,
                              color: themeNotifier.getTheme() == themeNotifier.darkTheme ? Colors.white : Colors.black)),
                  )
                ],
              ),
      ),
    );
  }
}
