import './scene/start.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localization.dart';
import 'app_language.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:background_fetch/background_fetch.dart';
import 'dart:convert';
import 'package:location/location.dart';

void backgroundFetchHeadlessTask(String taskId) async {
  print("[BackgroundFetch] Headless event received: $taskId");
  DateTime timestamp = DateTime.now();

  Location location = new Location();

  bool _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    BackgroundFetch.finish(taskId);
    return;
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<Map<String, LocationData>> _locationData = [];
  String json = prefs.getString("locationData");
  if (json != null) {
    _locationData = jsonDecode(json).cast<Map<String, LocationData>>();
  }

  _locationData.insert(0, {timestamp.toString(): await location.getLocation()});

  prefs.setString('locationData', jsonEncode(_locationData));

  BackgroundFetch.finish(taskId);

  if (taskId == 'flutter_background_fetch') {
    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.transistorsoft.customtask",
        delay: 5000,
        periodic: false,
        forceAlarmManager: true,
        stopOnTerminate: false,
        enableHeadless: true
    ));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  runApp(MyApp(
    appLanguage: appLanguage,
  ));
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  final AppLanguage appLanguage;

  MyApp({this.appLanguage});

  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PermissionStatus _permissionGranted;

  Location location = new Location();

  @override
  void initState() {
    super.initState();

    initLocation();
  }

  initLocation() async {
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return;
      }
    }

    LocationData _locationData = await location.getLocation();
    print(_locationData);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLanguage>(
        create: (_) => widget.appLanguage,
        child: Consumer<AppLanguage>(builder: (context, model, child) {
          return MaterialApp(
              title: 'CoronaVirus - Test',
              theme: ThemeData(
                primarySwatch: Colors.green,
                pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                }),
              ),
              locale: model.appLocal,
              supportedLocales: [
                Locale('en', 'US'),
                Locale('hi'),
                Locale('mr'),
                Locale('pa')
              ],
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              home: StartScreen(),
              debugShowCheckedModeBanner: false);
        }));
  }
}
