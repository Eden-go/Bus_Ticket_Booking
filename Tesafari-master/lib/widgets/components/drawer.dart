import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:tesafari/states/personaldata.dart';
import 'package:tesafari/states/restservice.dart';
import 'package:tesafari/states/themenotifier.dart';
import 'package:tesafari/utils/date_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class MainDrawer extends StatelessWidget {
  MainDrawer();

  @override
  Widget build(BuildContext context) {
    final personalData = Provider.of<PersonalData>(context);
    final restServiceProvider = Provider.of<RESTService>(context);
    final theme = Provider.of<ThemeNotifier>(context);

    return Drawer(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                color: Colors.grey[300],
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        margin: EdgeInsets.only(top: 30),
                        child:
                            Icon(Icons.person, color: Colors.white, size: 85),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.fromARGB(255, 1, 191, 255),
                                  Color.fromARGB(255, 84, 84, 254)
                                ])),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      InkWell(
                        child: Text(
                            (personalData.getName != '')
                                ? personalData.getName ?? ''
                                : 'guest'.tr(),
                            style: (theme.currentSize == FontSizes.Small)
                                ? TextStyle(
                                    fontSize:
                                        theme.fontTheme.bodySmall!.fontSize! +
                                            3,
                                    color: Colors.indigoAccent)
                                : (theme.currentSize == FontSizes.Medium)
                                    ? TextStyle(
                                        fontSize: theme.fontTheme.bodyMedium!
                                                .fontSize! +
                                            3,
                                        color: Colors.indigoAccent)
                                    : TextStyle(
                                        fontSize: theme.fontTheme.bodyLarge!
                                                .fontSize! +
                                            3,
                                        color: Colors.indigoAccent)),
                        onTap: () {
                          Navigator.pushNamed(context, '/personal');
                        },
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .4,
                child: ListView(
                  children: [
                    ListTile(
                      leading:
                          Icon(Icons.person_rounded, color: Colors.blueGrey),
                      title: Text('profile'.tr(),
                          style: (theme.currentSize == FontSizes.Small)
                              ? TextStyle(
                                  fontSize: theme.fontTheme.bodySmall!.fontSize)
                              : (theme.currentSize == FontSizes.Medium)
                                  ? TextStyle(
                                      fontSize:
                                          theme.fontTheme.bodyMedium!.fontSize!)
                                  : TextStyle(
                                      fontSize:
                                          theme.fontTheme.bodyLarge!.fontSize)),
                      onTap: () {
                        Navigator.pushNamed(context, '/personal');
                      },
                    ),
                    ListTile(
                      leading: Icon(TablerIcons.ticket, color: Colors.blueGrey),
                      title: Text('triphistory'.tr(),
                          style: (theme.currentSize == FontSizes.Small)
                              ? TextStyle(
                                  fontSize: theme.fontTheme.bodySmall!.fontSize)
                              : (theme.currentSize == FontSizes.Medium)
                                  ? TextStyle(
                                      fontSize:
                                          theme.fontTheme.bodyMedium!.fontSize!)
                                  : TextStyle(
                                      fontSize:
                                          theme.fontTheme.bodyLarge!.fontSize)),
                      onTap: () {
                        Navigator.pushNamed(context, '/trips');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.settings, color: Colors.blueGrey),
                      title: Text('settings'.tr(),
                          style: (theme.currentSize == FontSizes.Small)
                              ? TextStyle(
                                  fontSize: theme.fontTheme.bodySmall!.fontSize)
                              : (theme.currentSize == FontSizes.Medium)
                                  ? TextStyle(
                                      fontSize:
                                          theme.fontTheme.bodyMedium!.fontSize!)
                                  : TextStyle(
                                      fontSize:
                                          theme.fontTheme.bodyLarge!.fontSize)),
                      onTap: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.share, color: Colors.blueGrey),
                      title: Text('share'.tr(),
                          style: (theme.currentSize == FontSizes.Small)
                              ? TextStyle(
                                  fontSize: theme.fontTheme.bodySmall!.fontSize)
                              : (theme.currentSize == FontSizes.Medium)
                                  ? TextStyle(
                                      fontSize:
                                          theme.fontTheme.bodyMedium!.fontSize!)
                                  : TextStyle(
                                      fontSize:
                                          theme.fontTheme.bodyLarge!.fontSize)),
                      onTap: () {
                        Share.share(restServiceProvider.getAppStoreUrl);
                      },
                    ),
                    (restServiceProvider.updateExists)
                        ? ListTile(
                            leading:
                                Icon(Icons.upgrade, color: Colors.indigoAccent),
                            title: Text('updates'.tr(),
                                style: (theme.currentSize == FontSizes.Small)
                                    ? TextStyle(
                                        fontSize:
                                            theme.fontTheme.bodySmall!.fontSize)
                                    : (theme.currentSize == FontSizes.Medium)
                                        ? TextStyle(
                                            fontSize: theme.fontTheme
                                                .bodyMedium!.fontSize!)
                                        : TextStyle(
                                            fontSize: theme.fontTheme.bodyLarge!
                                                .fontSize)),
                            onTap: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                    Text('website'.tr()),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.white),
                                        onPressed: () async {
                                          if (await canLaunchUrl(Uri.https(
                                              restServiceProvider.url, '/')))
                                            await launchUrl(Uri.https(
                                                restServiceProvider.url, '/'));
                                        },
                                        child: Text('go'.tr(),
                                            style:
                                                TextStyle(color: Colors.black)))
                                  ])));
                            },
                          )
                        : SizedBox()
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Column(children: [
              Text(
                  'Tesafari © ${(context.locale == Locale('en', 'US')) ? DateTime.now().year : (getLocalizedDate(context.locale, DateTime.now()) as String).split('/')[1]}',
                  style: (theme.currentSize == FontSizes.Small)
                      ? TextStyle(fontSize: theme.fontTheme.bodySmall!.fontSize)
                      : (theme.currentSize == FontSizes.Medium)
                          ? TextStyle(
                              fontSize: theme.fontTheme.bodyMedium!.fontSize!)
                          : TextStyle(
                              fontSize: theme.fontTheme.bodyLarge!.fontSize)),
              Text("${'appversion'.tr()} 2.0.0.1",
                  style: (theme.currentSize == FontSizes.Small)
                      ? TextStyle(fontSize: theme.fontTheme.bodySmall!.fontSize)
                      : (theme.currentSize == FontSizes.Medium)
                          ? TextStyle(
                              fontSize: theme.fontTheme.bodyMedium!.fontSize!)
                          : TextStyle(
                              fontSize: theme.fontTheme.bodyLarge!.fontSize))
            ]),
          )
        ]));
  }
}
