import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/services.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String filePath;
  CustomVideoPlayer(this.filePath);

  @override
  _CustomVideoPlayerState createState() =>
      _CustomVideoPlayerState(this.filePath);
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  String filePath;
  _CustomVideoPlayerState(this.filePath);

  BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BetterPlayer(
        controller: _betterPlayerController,
      ),
    );
  }
}
