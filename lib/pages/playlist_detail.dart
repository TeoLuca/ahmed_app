import 'package:ahmed_app/models/playlist.dart';
import 'package:ahmed_app/models/song.dart';
import 'package:ahmed_app/pages/song_detail.dart';
import 'package:ahmed_app/services/database_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class PlaylistDetail extends StatefulWidget {
  final Playlist playlist;
  final String title;
  PlaylistDetail(this.playlist, this.title);

  @override
  _PlaylistDetailState createState() => _PlaylistDetailState(this.playlist);
}

class _PlaylistDetailState extends State<PlaylistDetail> {
  Playlist playlist;

  _PlaylistDetailState(this.playlist);

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Song> songs;
  int count = 0;

  TextEditingController titleController = TextEditingController();

  void updateListView() async {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Song>> songsFuture =
          databaseHelper.getSinglePlaylistList(playlist.id);
      songsFuture.then((songs) {
        setState(() {
          this.songs = songs;
          this.count = songs.length;
        });
      });
    });
  }

  void playSongs() {
    _showAlertDialog('Songs playing', 'yaaaaa');
  }

  void navigateToLastScreen() {
    Navigator.pop(context, true);
  }

  void _savePlaylist(BuildContext context, Playlist playlist) async {
    bool isTitleInUse = await databaseHelper.isTitleInUse(playlist.title);
    if (isTitleInUse == false) {
      navigateToLastScreen();
      int result;
      if (playlist.id == null) {
        result = await databaseHelper.insertPlaylist(playlist);
      } else {
        result = await databaseHelper.updatePlaylist(playlist);
      }
      if (result != 0) {
        _showAlertDialog('Status', 'Playlist saved successfully');
      } else {
        _showAlertDialog('Status', 'Error occurred while saving Playlist');
      }
    } else {
      _showAlertDialog('Status', 'You already have a Playlist with this title');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  Future<PlatformFile> pickFile() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null) {
      return result.files.single;
    }
    print('Operation Cancelled!');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (playlist.id != null && songs == null) {
      songs = List<Song>();
      updateListView();
    }
    return WillPopScope(
      onWillPop: () {
        navigateToLastScreen();
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            playlist.id == null
                ? Container()
                : IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {},
                  ),
          ],
        ),
        body: widget.playlist.id == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            onPressed: () {
                              playlist.title = titleController.text;
                              _savePlaylist(context, playlist);
                            },
                            child: Text('SAVE', textScaleFactor: 1.5),
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            : ListView.builder(
                itemCount: count,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {},
                    ),
                    title: Text(songs[index].title),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        databaseHelper.deleteSong(playlist.id, songs[index].id);
                        updateListView();
                      },
                    ),
                  );
                },
              ),
        floatingActionButton: widget.playlist.id != null
            ? FloatingActionButton(
                onPressed: () async {
                  PlatformFile file = await pickFile();
                  if (file != null) {
                    Song song = Song(file.path, file.name);
                    _saveSong(song, widget.playlist.id);
                  }
                },
                child: Icon(Icons.add),
                tooltip: 'Add Song',
              )
            : null,
      ),
    );
  }

  void _saveSong(Song song, int id) async {
    int result;
    if (song.id == null) {
      result = await databaseHelper.insertSong(playlist.id, song);
    } else {
      //result = await databaseHelper.updatePlaylist(playlist);
      print('not implemented yet');
    }
    if (result != 0) {
      updateListView();
    } else {
      print('nu merge');
    }
  }
}
