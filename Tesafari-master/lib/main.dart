import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tesafari/states/drivernotifier.dart';
import 'package:tesafari/states/triphistory.dart';
import 'package:tesafari/widgets/premium.dart';
import 'package:tesafari/widgets/settings.dart';
import 'package:tesafari/widgets/personal.dart';
import 'package:tesafari/widgets/notification.dart';
import 'package:tesafari/states/themenotifier.dart';
import 'package:tesafari/states/personaldata.dart';
import 'package:tesafari/states/restservice.dart';
import 'package:tesafari/states/notificationmanager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tesafari/widgets/trips.dart';
import 'generated/codegen_loader.g.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//TODO: Check if a bus is inactive a previous ticket can always refer to that bus, and if inactive,
//      notify the user the service is no longer available and delete the ticket from device
//TODO: come up with parent company name
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(EasyLocalization(
    startLocale: Locale('en', 'US'),
    fallbackLocale: Locale('en', 'US'),
    supportedLocales: [Locale('en', 'US'), Locale('am', 'ET')],
    path: "lib/translations",
    assetLoader: CodegenLoader(),
    child: TesafariApp(),
  ));
}

class TesafariApp extends StatelessWidget {
  final List<SingleChildWidget> _stateProviders = [
    ChangeNotifierProvider<NotificationManager>(
        create: (_) => new NotificationManager()),
    ChangeNotifierProvider<ThemeNotifier>(create: (_) => new ThemeNotifier()),
    ChangeNotifierProvider<TripHistory>(create: (_) => new TripHistory()),
    ChangeNotifierProvider<PersonalData>(create: (_) => new PersonalData()),
    ChangeNotifierProvider<RESTService>(create: (_) => new RESTService()),
    ChangeNotifierProvider<DriverNotifier>(create: (_) => new DriverNotifier())
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: _stateProviders,
        child: Consumer<ThemeNotifier>(builder: (context, theme, child) {
          return MaterialApp(
              title: 'Tesafari',
              theme: theme.getTheme(),
              initialRoute: '/',
              debugShowCheckedModeBanner: false,
              routes: {
                '/': (_) => PremiumService(),
                '/personal': (_) => Personal(),
                '/trips': (_) => Trips(),
                '/settings': (_) => Settings(),
                '/notification': (_) => NotificationPage()
              },
              locale: context.locale,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales);
        }));
  }
}
