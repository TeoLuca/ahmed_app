import 'package:ahmed_app/models/playlist.dart';
import 'package:ahmed_app/services/database_helper.dart';
import 'package:flutter/material.dart';

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

  TextEditingController titleController = TextEditingController();

  void navigateToLastScreen() {
    Navigator.pop(context, true);
  }

  void _save(BuildContext context, Playlist playlist) async {
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

  void _delete(int id) async {
    navigateToLastScreen();
    if (id == null) {
      _showAlertDialog('Status', 'New note was deleted');
      return;
    }
    int response = await databaseHelper.deletePlaylist(id);
    if (response != 0) {
      _showAlertDialog('Status', 'Playlist deleted successfully');
    } else {
      _showAlertDialog('Status', 'Error occurred while deleting Playlist');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
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
          title: Text(widget.title),
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
                              _save(context, playlist);
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
                              _delete(playlist.id);
                            },
                            child: Text('DELETE', textScaleFactor: 1.5),
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            : ListView.builder(
                itemCount: 0,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {},
                    ),
                    title: Text('dummy'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {},
                    ),
                  );
                },
              ),
        floatingActionButton: widget.playlist.id != null
            ? FloatingActionButton(
                onPressed: () {},
                child: Icon(Icons.add),
                tooltip: 'Add Song',
              )
            : null,
      ),
    );
  }
}
