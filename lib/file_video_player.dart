import 'dart:io';

import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class FileVideoPlayer extends StatefulWidget {
  final File videoFile;

  FileVideoPlayer({this.videoFile});

  @override
  _FileVideoPlayerState createState() => _FileVideoPlayerState(videoFile: this.videoFile);
}

class _FileVideoPlayerState extends State<FileVideoPlayer> {
  _FileVideoPlayerState({this.videoFile});

  File videoFile;

  VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    print(videoFile.path);
    setState(() {
      _videoPlayerController = VideoPlayerController.file(videoFile);
    });
    _videoPlayerController
      ..initialize().then((_) {
        _videoPlayerController.setLooping(true);
        setState(() {});
      });
    _videoPlayerController
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(() {});
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            _videoPlayerController.value.initialized
                ? AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController),
                  )
                : Container(),
            Center(
              child: IconButton(
                icon: Icon(
                  _videoPlayerController.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
                onPressed: () {
                  _videoPlayerController.value.isPlaying
                      ? _videoPlayerController.pause()
                      : _videoPlayerController.play();
                  setState(() {});
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
