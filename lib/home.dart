import 'dart:io';

import 'package:ahmed_app/file_video_player_chewie.dart';
import 'package:ahmed_app/custom_video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  Future<File> pickFile() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      //File videoFile = File(result.files.single.path);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              //FileVideoPlayer(videoFile: videoFile),
              //FileVideoPlayerChewie(videoFile),
              CustomVideoPlayer(result.files.single.path),
        ),
      );
    } else {
      print('Operation Cancelled!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
        actions: [
          IconButton(
            icon: Icon(Icons.video_collection),
            onPressed: () {
              pickFile();
            },
          )
        ],
      ),
      body: Center(
        child: Text('Open a video'),
      ),
    );
  }
}
