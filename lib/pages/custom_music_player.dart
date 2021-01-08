import 'package:ahmed_app/components/audio_control_buttons.dart';
import 'package:ahmed_app/components/seek_bar.dart';
import 'package:ahmed_app/models/playlist.dart';
import 'package:ahmed_app/models/song.dart';
import 'package:ahmed_app/pages/playlist_page.dart';
import 'package:ahmed_app/pages/settings.dart';
import 'package:ahmed_app/services/database_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class CustomMusicPlayer extends StatefulWidget {
  @override
  _CustomMusicPlayerState createState() => _CustomMusicPlayerState();
}

class _CustomMusicPlayerState extends State<CustomMusicPlayer> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  AudioPlayer _player;
  Playlist playlist;
  String playlistTitle = 'Playlist';

  void choiceAction(String choice) {
    if (choice == Constants.Settings) {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => Settings()));
    } else if (choice == Constants.About) {
      print('Subscribe');
    }
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

  _initSong(AudioSource audioSource) async {
    setState(() {
      playlistTitle = 'Playlist';
    });
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    try {
      await _player.setAudioSource(audioSource);
      await _player.play();
    } catch (e) {
      // catch load errors: 404, invalid url ...
      print("An error occured $e");
    }
  }

  _initPlaylist(int id) async {
    List<Song> songs = await databaseHelper.getSinglePlaylistList(id);

    ConcatenatingAudioSource playlist = ConcatenatingAudioSource(children: []);

    for (int i = 0; i < songs.length; i++) {
      playlist.add(
        AudioSource.uri(
          Uri.parse(songs[i].uri),
          tag: songs[i],
        ),
      );
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    try {
      await _player.setAudioSource(playlist);
      await _player.play();
    } catch (e) {
      // catch load errors: 404, invalid url ...
      print("An error occured $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
        actions: [
          IconButton(
            icon: Icon(Icons.library_music),
            onPressed: () async {
              PlatformFile file = await pickFile();
              if (file != null) {
                _initSong(
                  AudioSource.uri(
                    Uri.parse(file.path),
                    tag: Song(file.path, file.name),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.playlist_play),
            onPressed: () async {
              Playlist playlist = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => PlaylistPage()));
              if (playlist != null) {
                setState(() {
                  this.playlist = playlist;
                  this.playlistTitle = playlist.title;
                });
                _initPlaylist(playlist.id);
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Constants.choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AudioControlButtons(_player),
          StreamBuilder<Duration>(
            stream: _player.durationStream,
            builder: (context, snapshot) {
              final duration = snapshot.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  var position = snapshot.data ?? Duration.zero;
                  if (position > duration) {
                    position = duration;
                  }
                  return SeekBar(
                    duration: duration,
                    position: position,
                    onChangeEnd: (newPosition) {
                      _player.seek(newPosition);
                    },
                  );
                },
              );
            },
          ),
          //-------------------------------------------------------------------------------
          SizedBox(height: 8.0),
          Row(
            children: [
              StreamBuilder<LoopMode>(
                stream: _player.loopModeStream,
                builder: (context, snapshot) {
                  final loopMode = snapshot.data ?? LoopMode.off;
                  final icons = [
                    Icon(Icons.repeat, color: Colors.grey),
                    Icon(Icons.repeat, color: Theme.of(context).primaryColor),
                    Icon(Icons.repeat_one,
                        color: Theme.of(context).primaryColor),
                  ];
                  const cycleModes = [
                    LoopMode.off,
                    LoopMode.all,
                    LoopMode.one,
                  ];
                  final index = cycleModes.indexOf(loopMode);
                  return IconButton(
                    icon: icons[index],
                    onPressed: () {
                      _player.setLoopMode(cycleModes[
                          (cycleModes.indexOf(loopMode) + 1) %
                              cycleModes.length]);
                    },
                  );
                },
              ),
              Expanded(
                child: Text(
                  playlistTitle,
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
              ),
              StreamBuilder<bool>(
                stream: _player.shuffleModeEnabledStream,
                builder: (context, snapshot) {
                  final shuffleModeEnabled = snapshot.data ?? false;
                  return IconButton(
                    icon: shuffleModeEnabled
                        ? Icon(Icons.shuffle,
                            color: Theme.of(context).primaryColor)
                        : Icon(Icons.shuffle, color: Colors.grey),
                    onPressed: () async {
                      final enable = !shuffleModeEnabled;
                      if (enable) {
                        await _player.shuffle();
                      }
                      await _player.setShuffleModeEnabled(enable);
                    },
                  );
                },
              ),
            ],
          ),
          //----------------------------------------------------------------------------
          Container(
            child: StreamBuilder<SequenceState>(
              stream: _player.sequenceStateStream,
              builder: (context, snapshot) {
                final state = snapshot.data;
                final sequence = state?.sequence ?? [];
                return Expanded(
                  child: ListView.builder(
                    itemCount: sequence.length,
                    itemBuilder: (context, index) => Material(
                      color: index == state.currentIndex
                          ? Theme.of(context).primaryColor
                          : null,
                      child: GestureDetector(
                        onTap: () {
                          _player.seek(Duration.zero, index: index);
                        },
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 8),
                            child: Text(
                              sequence[index].tag.title,
                              maxLines: 1,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Constants {
  static const String Settings = 'Settings';
  static const String About = 'About';

  static const List<String> choices = <String>[Settings, About];
}
