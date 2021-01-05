import 'package:ahmed_app/pages/custom_video_player.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final drawerItems = [
    DrawerItem('Video', Icons.movie),
    DrawerItem('Audio', Icons.music_note),
  ];

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedDrawerIndex = 0;

  _getDrawerItemWidget(int pos, GlobalKey<ScaffoldState> homeScaffoldState) {
    switch (pos) {
      case 0:
        return CustomVideoPlayer(homeScaffoldState);
      case 1:
        return CustomVideoPlayer(homeScaffoldState);
    }
  }

  _onSelectItem(int index) {
    if (_selectedDrawerIndex == index) {
      Navigator.of(context).pop();
    } else {
      setState(() => _selectedDrawerIndex = index);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    var drawerOptions = <Widget>[];
    for (int i = 0; i < widget.drawerItems.length; i++) {
      DrawerItem drawerItem = widget.drawerItems[i];
      drawerOptions.add(ListTile(
        leading: Icon(drawerItem.icon),
        title: Text(drawerItem.title),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i),
      ));
    }
    final GlobalKey<ScaffoldState> _homeScaffoldState =
        GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _homeScaffoldState,
      drawer: SafeArea(
        child: Drawer(
          child: ListView(children: drawerOptions),
        ),
      ),
      body: _getDrawerItemWidget(_selectedDrawerIndex, _homeScaffoldState),
    );
  }
}

class DrawerItem {
  String title;
  IconData icon;

  DrawerItem(this.title, this.icon);
}
