import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.brightness_2_outlined),
              title: Text('Dark mode'),
              trailing: CupertinoSwitch(
                value: DynamicTheme.of(context).brightness == Brightness.dark
                    ? true
                    : false,
                onChanged: (value) {
                  setState(() {
                    DynamicTheme.of(context).setBrightness(
                        Theme.of(context).brightness == Brightness.dark
                            ? Brightness.light
                            : Brightness.dark);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
