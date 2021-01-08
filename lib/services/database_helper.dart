import 'package:ahmed_app/models/playlist.dart';
import 'package:ahmed_app/models/song.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String tablePlaylists = 'table_playlists';
  String tableSinglePlaylist = 'table_playlist_'; // table_playlist_id

  String colId = 'id';
  String colTitle = 'title';

  String colUri = 'uri';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = new DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'playlist.db';

    Database tasksDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return tasksDatabase;
  }

  void _createDb(Database db, int version) async {
    await db.execute('CREATE TABLE $tablePlaylists'
        '('
        '$colId INTEGER PRIMARY KEY AUTOINCREMENT,'
        '$colTitle TEXT'
        ')');
  }

  //----------------------------- P L A Y L I S T S ------------------------------------------------

  //Get all playlists
  Future<List<Map<String, dynamic>>> getPlaylistsMapList() async {
    Database db = await this.database;
    var result = await db.rawQuery('SELECT * FROM $tablePlaylists');
    return result;
  }

  Future<List<Playlist>> getPlaylistList() async {
    var playlistsMapList = await getPlaylistsMapList();
    int count = playlistsMapList.length;
    List<Playlist> playlists = List<Playlist>();
    for (int i = 0; i < count; i++) {
      playlists.add(Playlist.fromMapToObject(playlistsMapList[i]));
    }
    return playlists;
  }

  Future<int> getPlaylistsCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> map =
        await db.rawQuery('SELECT COUNT * FROM $tablePlaylists');
    int result = Sqflite.firstIntValue(map);
    return result;
  }

  Future<int> insertPlaylist(Playlist playlist) async {
    Database db = await this.database;
    var result = await db.insert(tablePlaylists, playlist.toMap());

    //create table_playlist_id to populate with songs
    if (result != 0) {
      int id = await getPlaylistId(playlist.title);
      await db.execute('CREATE TABLE $tableSinglePlaylist$id'
          '('
          '$colId INTEGER PRIMARY KEY AUTOINCREMENT,'
          '$colTitle TEXT,'
          '$colUri TEXT'
          ')');
    }

    return result;
  }

  Future<int> updatePlaylist(Playlist playlist) async {
    Database db = await this.database;
    var result = await db.rawUpdate('UPDATE $tablePlaylists SET '
        '$colTitle = ${playlist.title} '
        'WHERE $colId = ${playlist.id}');
    return result;
  }

  Future<int> deletePlaylist(int id) async {
    Database db = await this.database;
    var result =
        await db.rawDelete('DELETE FROM $tablePlaylists WHERE $colId = $id');
    return result;
  }

  Future<bool> isTitleInUse(String title) async {
    Database db = await this.database;
    var result = await db
        .rawQuery('SELECT * FROM $tablePlaylists WHERE $colTitle = \"$title\"');
    return result.isEmpty ? false : true;
  }

  Future<int> getPlaylistId(String playlistTitle) async {
    Database db = await this.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tablePlaylists WHERE $colTitle = \"$playlistTitle\"');
    int id = result[0][colId];
    return id;
  }

  //-------------------- S I N G L E  P L A Y L I S T -----------------------------------

  Future<List<Map<String, dynamic>>> getSinglePlaylistMapList(
      int tableId) async {
    Database db = await this.database;
    var result =
        await db.rawQuery('SELECT * FROM $tableSinglePlaylist$tableId');
    return result;
  }

  Future<List<Song>> getSinglePlaylistList(int tableId) async {
    var playlistMapList = await getSinglePlaylistMapList(tableId);
    int count = playlistMapList.length;
    List<Song> playlist = List<Song>();
    for (int i = 0; i < count; i++) {
      playlist.add(Song.fromMapToObject(playlistMapList[i]));
    }
    return playlist;
  }

  Future<List<Map<String, dynamic>>> dropSinglePlaylistTable(int id) async {
    Database db = await this.database;
    var result = await db.rawQuery('DROP TABLE $tableSinglePlaylist$id');
    return result;
  }

  Future<int> getSinglePlaylistCount(int tableId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> map =
        await db.rawQuery('SELECT COUNT * FROM $tableSinglePlaylist$tableId');
    int result = Sqflite.firstIntValue(map);
    return result;
  }

  Future<int> insertSong(int tableId, Song song) async {
    Database db = await this.database;
    var result = await db.insert('$tableSinglePlaylist$tableId', song.toMap());
    return result;
  }

  Future<int> deleteSong(int tableId, int songId) async {
    Database db = await this.database;
    var result = await db.rawDelete(
        'DELETE FROM $tableSinglePlaylist$tableId WHERE $colId = $songId');
    return result;
  }
}
