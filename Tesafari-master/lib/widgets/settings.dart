import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:tesafari/states/restservice.dart';
import 'package:tesafari/states/themenotifier.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tesafari/widgets/components/feedbackform.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final restServiceProvider = Provider.of<RESTService>(context);

    return Consumer<ThemeNotifier>(builder: (context, theme, child) {
      return SafeArea(
          child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigoAccent[400],
          title: Text(
            'settings'.tr(),
            style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: (theme.currentSize == FontSizes.Small)
                    ? theme.fontTheme.titleSmall!.fontSize
                    : (theme.currentSize == FontSizes.Medium)
                        ? theme.fontTheme.titleMedium!.fontSize
                        : theme.fontTheme.titleLarge!.fontSize),
          ),
          elevation: 3,
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            TextButton(
              child: Icon(
                Icons.support_agent_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return FeedbackForm();
                    });
              },
            ),
            TextButton(
                onPressed: () {
                  Share.share(
                      restServiceProvider.getAppStoreUrl);
                },
                child: Icon(Icons.share, color: Colors.white))
          ],
        ),
        body: Column(
          children: <Widget>[
            //Dark Mode Switch
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.dark_mode),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text('darkmode'.tr(),
                            style: (theme.currentSize == FontSizes.Small)
                                ? theme.fontTheme.labelSmall
                                : (theme.currentSize == FontSizes.Medium)
                                    ? theme.fontTheme.labelMedium
                                    : theme.fontTheme.labelLarge),
                      ),
                    ],
                  ),
                  Switch(
                    value: (theme.getTheme() == theme.darkTheme) ? true : false,
                    onChanged: (value) {
                      if (value)
                        theme.setDarkMode();
                      else
                        theme.setLightMode();
                    },
                  )
                ],
              ),
            ),

            //Language Selector
            Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.language),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text('language'.tr(),
                              style: (theme.currentSize == FontSizes.Small)
                                  ? theme.fontTheme.labelSmall
                                  : (theme.currentSize == FontSizes.Medium)
                                      ? theme.fontTheme.labelMedium
                                      : theme.fontTheme.labelLarge),
                        )
                      ],
                    ),
                    DropdownButton(
                      items: [
                        DropdownMenuItem(
                            child: Text("English",
                                style: (theme.currentSize == FontSizes.Small)
                                    ? TextStyle(
                                        fontSize: theme
                                            .fontTheme.bodySmall!.fontSize,
                                        color: (theme.getTheme() ==
                                                theme.darkTheme)
                                            ? Colors.white
                                            : Colors.black)
                                    : (theme.currentSize == FontSizes.Medium)
                                        ? TextStyle(
                                            fontSize: theme
                                                .fontTheme.bodyMedium!.fontSize,
                                            color: (theme
                                                        .getTheme() ==
                                                    theme.darkTheme)
                                                ? Colors.white
                                                : Colors.black)
                                        : TextStyle(
                                            fontSize: theme
                                                .fontTheme.bodyLarge!.fontSize,
                                            color: (theme.getTheme() ==
                                                    theme.darkTheme)
                                                ? Colors.white
                                                : Colors.black)),
                            value: Locale('en', 'US')),
                        DropdownMenuItem(
                            child: Text("አማርኛ",
                                style: (theme.currentSize == FontSizes.Small)
                                    ? TextStyle(
                                        fontSize: theme
                                            .fontTheme.bodySmall!.fontSize,
                                        color: (theme.getTheme() ==
                                                theme.darkTheme)
                                            ? Colors.white
                                            : Colors.black)
                                    : (theme.currentSize == FontSizes.Medium)
                                        ? TextStyle(
                                            fontSize: theme
                                                .fontTheme.bodyMedium!.fontSize,
                                            color: (theme
                                                        .getTheme() ==
                                                    theme.darkTheme)
                                                ? Colors.white
                                                : Colors.black)
                                        : TextStyle(
                                            fontSize: theme
                                                .fontTheme.bodyLarge!.fontSize,
                                            color: (theme.getTheme() ==
                                                    theme.darkTheme)
                                                ? Colors.white
                                                : Colors.black)),
                            value: Locale('am', 'ET'))
                      ],
                      value: context.locale,
                      onChanged: (Locale? value) {
                        context.setLocale(value!);
                      },
                    ),
                  ],
                )),

            //Font Selector
            Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.edit_note_rounded),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text('font'.tr(),
                              style: (theme.currentSize == FontSizes.Small)
                                  ? theme.fontTheme.labelSmall
                                  : (theme.currentSize == FontSizes.Medium)
                                      ? theme.fontTheme.labelMedium
                                      : (MediaQuery.of(context).size.width >
                                                  302 &&
                                              context.locale ==
                                                  Locale('am', 'ET'))
                                          ? theme.fontTheme.labelLarge
                                          : (context.locale ==
                                                  Locale('en', 'US'))
                                              ? theme.fontTheme.labelLarge
                                              : theme.fontTheme.labelMedium),
                        )
                      ],
                    ),
                    DropdownButton<FontSizes>(
                      items: [
                        DropdownMenuItem(
                            child: Text("small".tr(),
                                style: (theme.currentSize == FontSizes.Small)
                                    ? TextStyle(
                                        fontSize: theme
                                            .fontTheme.bodySmall!.fontSize,
                                        color: (theme.getTheme() ==
                                                theme.darkTheme)
                                            ? Colors.white
                                            : Colors.black)
                                    : (theme.currentSize == FontSizes.Medium)
                                        ? TextStyle(
                                            fontSize: theme
                                                .fontTheme.bodyMedium!.fontSize,
                                            color: (theme
                                                        .getTheme() ==
                                                    theme.darkTheme)
                                                ? Colors.white
                                                : Colors.black)
                                        : TextStyle(
                                            fontSize: theme
                                                .fontTheme.bodyLarge!.fontSize,
                                            color: (theme.getTheme() ==
                                                    theme.darkTheme)
                                                ? Colors.white
                                                : Colors.black)),
                            value: FontSizes.Small),
                        DropdownMenuItem(
                            child: Text("medium".tr(),
                                style: (theme.currentSize == FontSizes.Small)
                                    ? TextStyle(
                                        fontSize: theme
                                            .fontTheme.bodySmall!.fontSize,
                                        color: (theme.getTheme() ==
                                                theme.darkTheme)
                                            ? Colors.white
                                            : Colors.black)
                                    : (theme.currentSize == FontSizes.Medium)
                                        ? TextStyle(
                                            fontSize: theme
                                                .fontTheme.bodyMedium!.fontSize,
                                            color: (theme
                                                        .getTheme() ==
                                                    theme.darkTheme)
                                                ? Colors.white
                                                : Colors.black)
                                        : TextStyle(
                                            fontSize: theme
                                                .fontTheme.bodyLarge!.fontSize,
                                            color: (theme.getTheme() ==
                                                    theme.darkTheme)
                                                ? Colors.white
                                                : Colors.black)),
                            value: FontSizes.Medium),
                        DropdownMenuItem(
                            child: Text("large".tr(),
                                style: (theme.currentSize == FontSizes.Small)
                                    ? TextStyle(
                                        fontSize: theme
                                            .fontTheme.bodySmall!.fontSize,
                                        color: (theme.getTheme() ==
                                                theme.darkTheme)
                                            ? Colors.white
                                            : Colors.black)
                                    : (theme.currentSize == FontSizes.Medium)
                                        ? TextStyle(
                                            fontSize: theme
                                                .fontTheme.bodyMedium!.fontSize,
                                            color: (theme
                                                        .getTheme() ==
                                                    theme.darkTheme)
                                                ? Colors.white
                                                : Colors.black)
                                        : TextStyle(
                                            fontSize: theme
                                                .fontTheme.bodyLarge!.fontSize,
                                            color: (theme.getTheme() ==
                                                    theme.darkTheme)
                                                ? Colors.white
                                                : Colors.black)),
                            value: FontSizes.Large)
                      ],
                      value: theme.currentSize,
                      onChanged: (FontSizes? value) {
                        theme.setFontSize(value!);
                      },
                    ),
                  ],
                )),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                (theme.getTheme() == theme.lightTheme)
                    ? Image.asset("lib/images/logo1.png")
                    : Image.asset("lib/images/logo.png"),
                Text("Tesafari © ${DateTime.now().year}",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: (theme.currentSize == FontSizes.Small)
                            ? theme.fontTheme.bodySmall!.fontSize
                            : (theme.currentSize == FontSizes.Medium)
                                ? theme.fontTheme.bodyMedium!.fontSize
                                : theme.fontTheme.bodyLarge!.fontSize)),
                Text('appversion'.tr() + " 2.0.0.1",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: (theme.currentSize == FontSizes.Small)
                            ? theme.fontTheme.bodySmall!.fontSize
                            : (theme.currentSize == FontSizes.Medium)
                                ? theme.fontTheme.bodyMedium!.fontSize
                                : theme.fontTheme.bodyLarge!.fontSize)),
                InkWell(
                  child: Text('about'.tr(),
                      style: TextStyle(color: Colors.indigoAccent)),
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                          Text('website'.tr()),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.white),
                              onPressed: () async {
                                if (await canLaunchUrl(
                                    Uri.https(restServiceProvider.url, '/')))
                                  await launchUrl(
                                      Uri.https(restServiceProvider.url, '/'));
                              },
                              child: Text('go'.tr(),
                                  style: TextStyle(color: Colors.black)))
                        ])));
                  },
                )
              ],
            )
          ],
        ),
      ));
    });
  }
}
