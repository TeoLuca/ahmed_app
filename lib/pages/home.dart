import 'package:ahmed_app/constants.dart';
import 'package:ahmed_app/pages/custom_music_player.dart';
import 'package:ahmed_app/pages/custom_video_player.dart';
import 'package:ahmed_app/services/ad_manager.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<void> _initAdMob() {
    return FirebaseAdMob.instance.initialize(appId: AdManager.appId);
  }

  int _selectedIndex = 0;
  final _widgetOptions = [
    CustomVideoPlayer(),
    CustomMusicPlayer(),
    //MyAudioPlayer(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
          child: BottomNavigationBar(
            backgroundColor: Theme.of(context).primaryColor,
            elevation: menuElevation,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.movie),
                label: 'Videos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.music_note),
                label: 'Music',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
