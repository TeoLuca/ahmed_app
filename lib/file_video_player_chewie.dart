import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class FileVideoPlayerChewie extends StatefulWidget {
  final File videoFile;

  FileVideoPlayerChewie(this.videoFile);

  @override
  _FileVideoPlayerChewieState createState() =>
      _FileVideoPlayerChewieState(videoFile);
}

class _FileVideoPlayerChewieState extends State<FileVideoPlayerChewie> {
  final File videoFile;

  _FileVideoPlayerChewieState(this.videoFile);

  VideoPlayerController _videoPlayerController;

  ChewieController _chewieController;

  void setupVideoPlayerController() async {
    setState(() {
      _videoPlayerController = VideoPlayerController.file(videoFile);
    });
    await _videoPlayerController.initialize();
    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        fullScreenByDefault: true,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    setupVideoPlayerController();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _chewieController != null
          ? Chewie(
              controller: _chewieController,
            )
          : Container(),
    );
  }
}
