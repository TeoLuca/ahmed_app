import 'package:ahmed_app/constants.dart';
import 'package:ahmed_app/pages/home.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int themeCode;

  void setupTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      themeCode = sharedPreferences.getInt('THEME') ?? 1;
    });
  }

  @override
  void initState() {
    setupTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Brightness brightness = SchedulerBinding.instance.window.platformBrightness;
    return DynamicTheme(
        defaultBrightness: themeCode == 0
            ? brightness
            : themeCode == 1
                ? Brightness.light
                : Brightness.dark,
        data: (brightness) =>
            brightness == Brightness.light ? appThemeLight : appThemeDark,
        themedWidgetBuilder: (context, theme) {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(statusBarColor: theme.primaryColor),
          );
          setupTheme();
          return new MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: Home(),
          );
        });
  }
}
