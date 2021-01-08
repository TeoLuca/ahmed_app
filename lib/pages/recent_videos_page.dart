import 'package:ahmed_app/models/video.dart';
import 'package:ahmed_app/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class RecentVideosPage extends StatefulWidget {
  @override
  _RecentVideosPageState createState() => _RecentVideosPageState();
}

class _RecentVideosPageState extends State<RecentVideosPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  List<Video> videoList;
  int count = 0;

  void navigateToLastScreen([Video video]) {
    Navigator.pop(context, video);
  }

  void updateListView() async {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Video>> videoListFuture =
          databaseHelper.getRecentVideosList();
      videoListFuture.then((videoList) {
        setState(() {
          this.videoList = videoList;
          this.count = videoList.length;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (videoList == null) {
      videoList = List<Video>();
      updateListView();
    }

    return WillPopScope(
      onWillPop: () {
        navigateToLastScreen();
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Recent Videos'),
        ),
        body: ListView.builder(
          itemCount: count,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(videoList[index].title, maxLines: 1),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  databaseHelper.deleteVideo(videoList[index].id);
                  updateListView();
                },
              ),
              onTap: () {
                navigateToLastScreen(videoList[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
