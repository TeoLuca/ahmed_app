import 'package:ahmed_app/models/video.dart';
import 'package:ahmed_app/pages/recent_videos_page.dart';
import 'package:ahmed_app/pages/settings.dart';
import 'package:ahmed_app/services/database_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomVideoPlayer extends StatefulWidget {
  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  _CustomVideoPlayerState();

  DatabaseHelper databaseHelper = DatabaseHelper();

  BetterPlayerController _betterPlayerController;

  SharedPreferences sharedPreferences;

  List<BoxFit> videoBoxFit = [
    BoxFit.contain,
    BoxFit.cover,
    BoxFit.fill,
    BoxFit.fitHeight,
    BoxFit.fitWidth,
  ];
  int videoBoxFitIndex = 0;

  void setupInitStateAsync() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    setupInitStateAsync();
    super.initState();
  }

  void choiceAction(String choice) async {
    if (choice == Constants.History) {
      Video video = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => RecentVideosPage()));
      if (video != null) {
        if (_betterPlayerController != null) {
          _betterPlayerController
              .setupDataSource(BetterPlayerDataSource.file(video.uri));
        } else {
          setupVideoPlayerController(video.uri);
        }
        sharedPreferences.setString('LAST_PLAYED_VIDEO_URI', video.uri);
      }
    } else if (choice == Constants.Settings) {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => Settings()));
    } else if (choice == Constants.About) {
      print('About page');
    }
  }

  Future<PlatformFile> pickFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: false,
    );
    if (result != null) {
      return result.files.single;
    }
    print('Operation Cancelled!');
    return null;
  }

  Future<PlatformFile> pickSubtitle() async {
    FilePicker.platform.clearTemporaryFiles();
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt'],
    );
    if (result != null) {
      return result.files.single;
    }
    print('Operation Cancelled!');
    return null;
  }

  void setupVideoPlayerController(String path) {
    setState(() {
      BetterPlayerDataSource betterPlayerDataSource =
          new BetterPlayerDataSource(
        BetterPlayerDataSourceType.file,
        path,
      );
      _betterPlayerController = new BetterPlayerController(
        BetterPlayerConfiguration(
          fit: videoBoxFit[videoBoxFitIndex],
          fullScreenByDefault: true,
          autoDetectFullscreenDeviceOrientation: true,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
          autoPlay: true,
          allowedScreenSleep: false,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableSkips: true,
            skipsTimeInMilliseconds: 10000, //10000
            enableSubtitles: false,
            enableQualities: false,
            overflowMenuCustomItems: [
              BetterPlayerOverflowMenuItem(
                Icons.closed_caption,
                'Closed Captions',
                () async {
                  PlatformFile file = await pickSubtitle();
                  if (file != null) {
                    _betterPlayerController.setupSubtitleSource(
                      BetterPlayerSubtitlesSource(
                        type: BetterPlayerSubtitlesSourceType.file,
                        urls: [file.path],
                      ),
                    );
                    print(file.name);
                  }
                },
              )
            ],
          ),
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );
    });
  }

  @override
  void dispose() {
    if (_betterPlayerController != null) {
      _betterPlayerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
        actions: [
          IconButton(
            icon: Icon(Icons.video_library),
            onPressed: () async {
              PlatformFile file = await pickFile();
              if (file != null) {
                Video video = Video(file.path, file.name);
                bool isVideoInDatabase =
                    await databaseHelper.isVideoInDatabase(file.path);
                if (isVideoInDatabase == false) {
                  databaseHelper.insertVideo(video);
                }
                if (_betterPlayerController != null) {
                  _betterPlayerController.setupDataSource(
                    BetterPlayerDataSource.file(file.path),
                  );
                } else
                  setupVideoPlayerController(file.path);
                sharedPreferences.setString('LAST_PLAYED_VIDEO_URI', file.path);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () async {
              String lastPlayedVideoUri =
                  sharedPreferences.getString('LAST_PLAYED_VIDEO_URI');
              if (lastPlayedVideoUri != null) {
                if (_betterPlayerController != null) {
                  _betterPlayerController.setupDataSource(
                      BetterPlayerDataSource.file(lastPlayedVideoUri));
                } else {
                  setupVideoPlayerController(lastPlayedVideoUri);
                }
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Constants.choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        child: _betterPlayerController != null
            ? Column(
                children: [
                  BetterPlayer(
                    controller: _betterPlayerController,
                  ),
                ],
              )
            : Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: Text('Open a video'),
                ),
              ),
      ),
    );
  }
}

class Constants {
  static const String History = 'History';
  static const String Settings = 'Settings';
  static const String About = 'About';

  static const List<String> choices = <String>[History, Settings, About];
}
