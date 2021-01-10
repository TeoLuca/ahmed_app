import 'package:ahmed_app/pages/bug_page.dart';
import 'package:ahmed_app/pages/suggestion_page.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
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
          Divider(),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                'Feedback',
                style: TextStyle(
                    fontSize: 16, color: Theme.of(context).accentColor),
              )),
          Divider(),
          ListTile(
            title: Text('I Spotted a Bug'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => BugPage()));
            },
          ),
          Divider(),
          ListTile(
            title: Text('I Have a Suggestion'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => SuggestionPage()));
            },
          ),
          Divider(),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                'More Information',
                style: TextStyle(
                    fontSize: 16, color: Theme.of(context).accentColor),
              )),
          Divider(),
          ListTile(
            title: Text('Privacy Policy'),
          ),
          Divider(),
          ListTile(
            title: Text('Terms of Service'),
          ),
          Divider(),
          ListTile(
            title: Text('Other Legal'),
          ),
        ],
      ),
    );
  }
}
