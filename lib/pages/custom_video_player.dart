import 'package:ahmed_app/pages/settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/services.dart';

class CustomVideoPlayer extends StatefulWidget {
  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  _CustomVideoPlayerState();

  BetterPlayerController _betterPlayerController;

  void choiceAction(String choice) {
    if (choice == Constants.Settings) {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => Settings()));
    } else if (choice == Constants.About) {
      print('Subscribe');
    }
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
              setupVideoPlayerController(await pickFile());
            },
          ),
          IconButton(
            icon: Icon(Icons.access_time_rounded),
            onPressed: () {},
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
      body: Column(
        children: [
          _betterPlayerController != null
              ? BetterPlayer(
                  controller: _betterPlayerController,
                )
              : Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: Text('Open a video'),
                  ),
                ),
        ],
      ),
    );
  }
}

class Constants {
  static const String Settings = 'Settings';
  static const String About = 'About';

  static const List<String> choices = <String>[Settings, About];
}
