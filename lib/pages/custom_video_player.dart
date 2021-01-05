import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/services.dart';

class CustomVideoPlayer extends StatefulWidget {

  final GlobalKey<ScaffoldState> homeScaffoldState;

  CustomVideoPlayer(this.homeScaffoldState);

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  _CustomVideoPlayerState();

  BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();
  }

  Future<String> pickFile() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      return result.files.single.path;
    }
    print('Operation Cancelled!');
    return null;
  }

  void setupVideoPlayerController(String filePath) {
    setState(() {
      BetterPlayerDataSource betterPlayerDataSource =
          BetterPlayerDataSource(BetterPlayerDataSourceType.file, filePath);
      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          fit: BoxFit.contain,
          fullScreenByDefault: true,
          autoDetectFullscreenDeviceOrientation: true,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
          autoPlay: true,
          allowedScreenSleep: false,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableSkips: false,
          ),
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );
    });
  }

  @override
  void dispose() {
    if(_betterPlayerController!=null) {
      _betterPlayerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            widget.homeScaffoldState.currentState.openDrawer();
          },
        ),
        title: Text('Video Player'),
        actions: [
          IconButton(
            icon: Icon(Icons.video_collection),
            onPressed: () async {
              String filePath = await pickFile();
              if (filePath != null) {
                setupVideoPlayerController(filePath);
              }
            },
          ),
        ],
      ),
      body: _betterPlayerController != null
          ? BetterPlayer(
              controller: _betterPlayerController,
            )
          : Center(
              child: Text('Open a video'),
            ),
    );
  }
}
