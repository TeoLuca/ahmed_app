import 'package:ahmed_app/constants.dart';
import 'package:ahmed_app/models/video.dart';
import 'package:ahmed_app/services/ad_manager.dart';
import 'package:ahmed_app/services/database_helper.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class RecentVideosPage extends StatefulWidget {
  @override
  _RecentVideosPageState createState() => _RecentVideosPageState();
}

class _RecentVideosPageState extends State<RecentVideosPage> {
  BannerAd _bannerAd;

  void _loadBannerAd() {
    _bannerAd
      ..load()
      ..show(anchorType: AnchorType.bottom);
  }

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
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      //adUnitId: AdManager.bannerAdUnitId,
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
    );
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
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
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: AppBar(
                  title: Text('Recent Videos'),
                  shape: appBarShape,
                  elevation: menuElevation,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
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
            ],
          ),
        ),
      ),
    );
  }
}
