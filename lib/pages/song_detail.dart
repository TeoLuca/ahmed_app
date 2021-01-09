import 'package:ahmed_app/models/song.dart';
import 'package:ahmed_app/services/database_helper.dart';
import 'package:flutter/material.dart';

class SongDetail extends StatefulWidget {
  final Song song;
  final int id;

  SongDetail(this.song, this.id);
  @override
  _SongDetailState createState() => _SongDetailState(this.song);
}

class _SongDetailState extends State<SongDetail> {
  TextEditingController titleController = TextEditingController();
  TextEditingController uriController = TextEditingController();

  DatabaseHelper databaseHelper = DatabaseHelper();
  Song song;
  _SongDetailState(this.song);

  void navigateToLastScreen() {
    Navigator.pop(context, true);
  }

  void _saveSong(BuildContext context, Song song) async {
    navigateToLastScreen();
    int result;
    if (song.id == null) {
      result = await databaseHelper.insertSong(widget.id, song);
    } else {
      //result = await databaseHelper.updatePlaylist(playlist);
      print('not implemented yet');
    }
    if (result != 0) {
      print('merge');
    } else {
      print('nu merge');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        navigateToLastScreen();
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add a song'),
          actions: [
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                song.title = titleController.text;
                song.uri = uriController.text;
                _saveSong(context, song);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: uriController,
                  decoration: InputDecoration(
                    labelText: 'Uri',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        onPressed: () {
                          song.title = titleController.text;
                          song.uri = uriController.text;
                          _saveSong(context, song);
                        },
                        child: Text('SAVE', textScaleFactor: 1.5),
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        onPressed: () {
                          //_delete(task.id);
                        },
                        child: Text('DELETE', textScaleFactor: 1.5),
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
