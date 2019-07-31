import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

final String kTitle = 'Momnori Authoring App';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color(0xFFFF0000),
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: kTitle,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        appBarTheme: AppBarTheme(color: Color(0xFFFF0000)),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: MyHomePage(title: kTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  YoutubePlayerController _controller = YoutubePlayerController();
  TextEditingController _idController = TextEditingController();
  TextEditingController _songController = TextEditingController();
  TextEditingController _artistController = TextEditingController();
  TextEditingController _lineController = TextEditingController();
  TextEditingController _typeController = TextEditingController();

  String _videoId = "RmOxBb2xF3o";
  Duration _startPosition;
  Duration _endPosition;
  Color _controlPadColor = Colors.grey;
  bool markStartingPointAfterSubmit = false;
  List<Clip> clips = [];

  void listener() {
    if (_controller.value.playerState == PlayerState.ENDED) {
      _showVideoEndDialog();
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubeScaffold(
      fullScreenOnOrientationChange: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _idController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter youtube \<video id\> or \<link\>"),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    InkWell(
                      onTap: () {
                        String videoId = _idController.text;
                        // If text is link then converting to corresponding id.
                        if (videoId.contains("http")) {
                          videoId = YoutubePlayer.convertUrlToId(videoId);
                        }

                        if (videoId != null && videoId.length > 0) {
                          setState(() {
                            _videoId = videoId;
                          });
                        }

                        // Dismiss Keyboard
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 16.0,
                        ),
                        color: Color(0xFFFF0000),
                        child: Text(
                          "PLAY",
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
              ),
              YoutubePlayer(
                context: context,
                videoId: _videoId,
                flags: YoutubePlayerFlags(
                  mute: false,
                  autoPlay: true,
                  forceHideAnnotation: true,
                  showVideoProgressIndicator: true,
                  disableDragSeek: false,
                ),
                videoProgressIndicatorColor: Color(0xFFFF0000),
                progressColors: ProgressColors(
                  playedColor: Color(0xFFFF0000),
                  handleColor: Color(0xFFFF4433),
                ),
                onPlayerInitialized: (controller) {
                  _controller = controller;
                  _controller.addListener(listener);
                },
              ),
              SizedBox(
                height: 10.0,
              ),
              SizedBox(
                height: 200.0,
                child: GestureDetector(
                  onTap: () {
                    print(_controller.value.isPlaying);
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  },
                  onDoubleTap: () {
                    if (_startPosition == null) {
                      _startPosition = _controller.value.position;
                      setState(() {
                        _controlPadColor = Colors.red.shade300;
                      });
                    } else {
                      _endPosition = _controller.value.position;
                      if (_endPosition < _startPosition) {
                        Duration temp = _startPosition;
                        _startPosition = _endPosition;
                        _endPosition = temp;
                      } else if (_endPosition == _startPosition) {
                        setState(() {
                          _controlPadColor = Colors.grey;
                        });
                        _startPosition = null;
                        _endPosition = null;
                        return;
                      }
                      _controller.pause();

                      Alert(
                        context: context,
                        title: "CREATE",
                        closeFunction: () {
                          processSubmit(false);
                        },
                        content: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: _songController,
                              decoration: InputDecoration(
                                icon: Icon(Icons.music_note),
                                labelText: 'Song',
                              ),
                            ),
                            TextFormField(
                              controller: _artistController,
                              decoration: InputDecoration(
                                icon: Icon(Icons.person),
                                labelText: 'Artist',
                              ),
                            ),
                            TextFormField(
                              controller: _lineController,
                              decoration: InputDecoration(
                                icon: Icon(Icons.format_list_numbered),
                                labelText: 'Line',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            TextFormField(
                              controller: _typeController,
                              decoration: InputDecoration(
                                icon: Icon(Icons.apps),
                                labelText: 'Type',
                              ),
                            ),
                            Card(
                              child: ListTile(
                                title: Text('Start'),
                                subtitle: Text(
                                  _startPosition.toString(),
                                ),
                              ),
                            ),
                            Card(
                              child: ListTile(
                                title: Text('End'),
                                subtitle: Text(
                                  _endPosition.toString(),
                                ),
                              ),
                            ),
                            SwitchListTile(
                              value: markStartingPointAfterSubmit,
                              onChanged: (value) {
                                print(value);
                                setState(() {
                                  markStartingPointAfterSubmit = value;
                                });
                              },
                              title: Text('Mark Start After Submit'),
                            )
                          ],
                        ),
                        buttons: [
                          DialogButton(
                            onPressed: () {
                              processSubmit(true);
                              Navigator.pop(context);
                            },
                            child: Text(
                              "SUBMIT",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          ),
                        ],
                      ).show();
                    }
                  },
                  onHorizontalDragUpdate: (dragDetail) {
                    int newMs = _controller.value.position.inMilliseconds;
                    if (dragDetail.delta.direction > 0) {
                      newMs -= (dragDetail.delta.distance * 1000).toInt();
                    } else {
                      newMs += (dragDetail.delta.distance * 1000).toInt();
                    }
                    _controller.seekTo(
                      Duration(milliseconds: newMs),
                    );
                  },
                  child: Container(
                    color: _controlPadColor,
                  ),
                ),
              ),
              SizedBox(
                height: 300.0,
                child: ListView.builder(
                  itemCount: clips.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                          '${clips[index].artist} - ${clips[index].song}: Line #${clips[index].line} - ${clips[index].type}'),
                      subtitle:
                          Text('${clips[index].start} - ${clips[index].end}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVideoEndDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Video Ended"),
          content: Text("Enter new Youtube URL or ID to create more clips"),
        );
      },
    );
  }

  void processSubmit(bool isSubmit) {
    if (isSubmit) {
      Clip clip = Clip(
        song: _songController.text,
        artist: _artistController.text,
        line: int.parse(_lineController.text),
        type: _typeController.text,
        videoId: _videoId,
        start: _startPosition,
        end: _endPosition,
      );
      setState(() {
        clips.add(clip);
      });
    }

    if (markStartingPointAfterSubmit && isSubmit) {
      _startPosition = _controller.value.position;
    } else {
      setState(() {
        _controlPadColor = Colors.grey;
      });
      _startPosition = null;
    }
    _endPosition = null;
    _controller.play();
  }
}

class Clip {
  String song;
  String artist;
  int line;
  String type;
  String videoId;
  Duration start;
  Duration end;

  Clip({
    this.song,
    this.artist,
    this.line,
    this.type,
    this.videoId,
    this.start,
    this.end,
  });
}
