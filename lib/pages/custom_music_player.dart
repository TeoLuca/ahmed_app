import 'package:ahmed_app/components/audio_control_buttons.dart';
import 'package:ahmed_app/components/seek_bar.dart';
import 'package:ahmed_app/constants.dart';
import 'package:ahmed_app/models/playlist.dart';
import 'package:ahmed_app/models/song.dart';
import 'package:ahmed_app/pages/equalizer_page.dart';
import 'package:ahmed_app/pages/playlist_page.dart';
import 'package:ahmed_app/pages/settings.dart';
import 'package:ahmed_app/services/database_helper.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:equalizer/equalizer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class CustomMusicPlayer extends StatefulWidget {
  @override
  _CustomMusicPlayerState createState() => _CustomMusicPlayerState();
}

class _CustomMusicPlayerState extends State<CustomMusicPlayer> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  AudioPlayer _player;
  Playlist playlist;
  String playlistTitle = 'Playlist';
  int playingSongIndex;

  void choiceAction(String choice) {
    if (choice == Constants.Equalizer) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => EqualizerPage()));
    } else if (choice == Constants.Settings) {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => Settings()));
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
      setState(() {
        playingSongIndex = 0;
      });
      await _player.setAudioSource(audioSource);
      await _player.play();
    } catch (e) {
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
      setState(() {
        playingSongIndex = 0;
      });
      await _player.setAudioSource(playlist);
      await _player.play();
    } catch (e) {
      // catch load errors: 404, invalid url ...
      print("An error occured $e");
    }
  }

  void initialize() async {
    Equalizer.init(0);
    Equalizer.setEnabled(true);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String preset = sharedPreferences.getString('PRESET') ?? '';
    if (preset.length == 0) {
      Equalizer.setPreset('Normal');
    } else if (preset.length > 0) {
      Equalizer.setPreset(preset);
    }
  }

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    initialize();
  }

  @override
  void dispose() {
    _player.dispose();
    //Equalizer.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Scaffold(
          appBar: AppBar(
            primary: false,
            shape: appBarShape,
            elevation: menuElevation,
            title: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                ),
                children: [
                  TextSpan(
                    text: 'Bee',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' Player'),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.library_music,
                ),
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
                icon: Icon(
                  Icons.playlist_play,
                ),
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
                icon: Icon(
                  Icons.more_vert,
                ),
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
              //-------------------------------------------------------------------------------
              SizedBox(height: 8.0),
              Row(
                children: [
                  StreamBuilder<LoopMode>(
                    stream: _player.loopModeStream,
                    builder: (context, snapshot) {
                      final loopMode = snapshot.data ?? LoopMode.off;
                      final icons = [
                        Icon(
                          Icons.repeat,
                          color: Colors.grey,
                        ),
                        Icon(Icons.repeat,
                            color: Theme.of(context).primaryColor),
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: DynamicTheme.of(context).data.brightness ==
                                Brightness.light
                            ? Colors.black
                            : DynamicTheme.of(context).data.primaryColor,
                      ),
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
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () {
                            _player.seek(Duration.zero, index: index);
                            setState(() {
                              playingSongIndex = index;
                            });
                          },
                          child: Card(
                            color: playingSongIndex == index
                                ? Colors.yellow
                                : DynamicTheme.of(context).data.cardColor,
                            shape: appBarShape,
                            elevation: itemElevation,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Text(
                                    sequence[index].tag.title,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: playingSongIndex == index
                                          ? Colors.black
                                          : DynamicTheme.of(context)
                                                      .data
                                                      .brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Card(
                color: Theme.of(context).primaryColor,
                elevation: itemElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Constants {
  static const String Equalizer = 'Equalizer';
  static const String Settings = 'Settings';

  static List<String> choices = <String>[Equalizer, Settings];
  //Platform.isAndroid ? <String>[Equalizer, Settings] : <String>[Settings];
}
