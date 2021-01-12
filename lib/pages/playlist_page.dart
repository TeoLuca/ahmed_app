import 'package:ahmed_app/constants.dart';
import 'package:ahmed_app/models/playlist.dart';
import 'package:ahmed_app/pages/playlist_detail.dart';
import 'package:ahmed_app/services/database_helper.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class PlaylistPage extends StatefulWidget {
  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Playlist> playlists;
  int count = 0;

  void updateListView() async {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Playlist>> playlistsFuture = databaseHelper.getPlaylistList();
      playlistsFuture.then((playlists) {
        setState(() {
          this.playlists = playlists;
          this.count = playlists.length;
        });
      });
    });
  }

  void navigateToDetail(Playlist playlist, String title) async {
    bool response = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PlaylistDetail(
                playlist,
                title,
              )),
    );
    if (response == true)
      updateListView();
    else
      _showSnackBar(context, 'Unexpected error occurred');
  }

  void _showSnackBar(BuildContext context, String message) {
    final SnackBar snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 1),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _delete(BuildContext context, int id) async {
    int result = await databaseHelper.deletePlaylist(id);
    var result2 = await databaseHelper.dropSinglePlaylistTable(id);
    if (result != 0 && result2.isEmpty) {
      _showSnackBar(context, 'Playlist deleted successfully');
      updateListView();
    } else {
      _showSnackBar(context, 'Error occurred while deleting Playlist');
      updateListView();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (playlists == null) {
      playlists = List<Playlist>();
      updateListView();
    }
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: AppBar(
                title: Text('Playlists'),
                shape: appBarShape,
                elevation: menuElevation,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 8, right: 8, left: 8),
                shrinkWrap: true,
                itemCount: count,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                    elevation: itemElevation,
                    child: ListTile(
                      leading: IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () {
                          Navigator.pop(
                            context,
                            playlists[index],
                          );
                        },
                      ),
                      title: Text(playlists[index].title, maxLines: 1),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _delete(context, this.playlists[index].id);
                        },
                      ),
                      onTap: () {
                        navigateToDetail(
                            playlists[index], playlists[index].title);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: DynamicTheme.of(context).data.primaryColor,
          onPressed: () {
            navigateToDetail(Playlist(''), 'Add playlist');
          },
          child: Icon(Icons.add),
          tooltip: 'Add Playlist',
        ),
      ),
    );
  }
}
