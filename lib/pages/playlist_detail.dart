import 'package:ahmed_app/constants.dart';
import 'package:ahmed_app/models/playlist.dart';
import 'package:ahmed_app/models/song.dart';
import 'package:ahmed_app/services/ad_manager.dart';
import 'package:ahmed_app/services/database_helper.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_admob/firebase_admob.dart';
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
  BannerAd _bannerAd;

  void _loadBannerAd() {
    _bannerAd
      ..load()
      ..show(anchorType: AnchorType.bottom);
  }

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
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      //adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
    );
    if (playlist.title.length == 0) {
      _loadBannerAd();
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
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
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: AppBar(
                  title: Text(widget.playlist.id == null
                      ? 'Add a Playlist'
                      : playlist.title),
                  shape: appBarShape,
                  elevation: menuElevation,
                  actions: [
                    playlist.id == null
                        ? Container()
                        : IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              TextEditingController editTitleController =
                                  TextEditingController();
                              editTitleController.text = playlist.title;
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('Edit playlist'),
                                  content: TextField(
                                    controller: editTitleController,
                                    decoration: InputDecoration(
                                      labelText: 'Title',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    FlatButton(
                                      onPressed: () async {
                                        setState(() {
                                          playlist.title =
                                              editTitleController.text;
                                        });
                                        int response = await databaseHelper
                                            .updatePlaylist(playlist);
                                        Navigator.pop(context);
                                        if (response != 0) {
                                          _showAlertDialog(
                                              'Status', 'Playlist updated');
                                        } else {
                                          _showAlertDialog(
                                              'Status', 'Error occured');
                                        }
                                      },
                                      child: Text(
                                        'Update',
                                        style: TextStyle(
                                          color: DynamicTheme.of(context)
                                              .data
                                              .primaryColor,
                                        ),
                                      ),
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: DynamicTheme.of(context)
                                              .data
                                              .primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
              widget.playlist.id == null
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                            ),
                          ),
                        ),
                        FlatButton.icon(
                          onPressed: () {
                            playlist.title = titleController.text;
                            _savePlaylist(context, playlist);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                          icon: Icon(
                            Icons.save,
                            color: Colors.black,
                          ),
                          label: Text(
                            'Save Playlist',
                            style: TextStyle(color: Colors.black),
                          ),
                          color: DynamicTheme.of(context).data.primaryColor,
                        )
                      ],
                    )
                  : Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: count,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: itemElevation,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                            child: ListTile(
                              leading: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  TextEditingController editTitleController =
                                      TextEditingController();
                                  editTitleController.text = songs[index].title;
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text('Edit song'),
                                      content: TextField(
                                        controller: editTitleController,
                                        decoration: InputDecoration(
                                          labelText: 'Name',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        FlatButton(
                                          onPressed: () async {
                                            setState(() {
                                              songs[index].title =
                                                  editTitleController.text;
                                            });
                                            int response =
                                                await databaseHelper.updateSong(
                                                    playlist.id, songs[index]);
                                            Navigator.pop(context);
                                            if (response != 0) {
                                              _showAlertDialog(
                                                  'Status', 'Song updated');
                                            } else {
                                              _showAlertDialog(
                                                  'Status', 'Error occured');
                                            }
                                          },
                                          child: Text(
                                            'Update',
                                            style: TextStyle(
                                              color: DynamicTheme.of(context)
                                                  .data
                                                  .primaryColor,
                                            ),
                                          ),
                                        ),
                                        FlatButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: DynamicTheme.of(context)
                                                  .data
                                                  .primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              title: Text(
                                songs[index].title,
                                maxLines: 1,
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  databaseHelper.deleteSong(
                                      playlist.id, songs[index].id);
                                  updateListView();
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
          floatingActionButton: widget.playlist.id != null
              ? FloatingActionButton(
                  backgroundColor: DynamicTheme.of(context).data.primaryColor,
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
