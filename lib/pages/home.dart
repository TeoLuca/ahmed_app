import 'package:ahmed_app/pages/custom_music_player.dart';
import 'package:ahmed_app/pages/custom_video_player.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Music',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.music_note),
          //   label: 'Test',
          // ),
        ],
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
