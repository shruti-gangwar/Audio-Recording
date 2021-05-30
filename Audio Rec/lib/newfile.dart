import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_keyboard_size/screen_height.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

typedef _Fn = void Function();

class BottomInput2 extends StatefulWidget {
  final double width;
  final double height;
  final Function(String) onAudioSend;
  final Function() onAudioCancel;

  const BottomInput2(
      {Key key,
        @required this.width,
        @required this.height,
        @required this.onAudioSend,
        @required this.onAudioCancel})
      : super(key: key);

  @override
  _BottomInput2State createState() => _BottomInput2State();
}

class _BottomInput2State extends State<BottomInput2>
    with TickerProviderStateMixin {
  AnimationController _recordController;
  Animation _animation;
  bool flag = true;
  Stream<int> timerStream;
  StreamSubscription<int> timerSubscription;
  String minutesStr = '00';
  String secondsStr = '00';
  Offset position;
  bool isRecording = false;
  bool longRecording = false;
  double _size = 50.0;
  bool expand = false;
  double oldX = 0;
  double oldY = 0;
  bool shouldActivate = false;
  int tcount = 10;
  var xs = Set();
  var ys = Set();
  int direction = -1;
  double marginBack = 38.0;
  double marginText = 36.0;
  int scount = 0;
  double vheight = 200.0;
  bool showLockUi = false;
  bool shouldSend = true;

  // Audio
  FlutterSoundPlayer _myPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _myRecorder = FlutterSoundRecorder();
  bool _mRecorderIsInited = true;
  bool _myPlayerIsInited = false;
  bool _myplaybackReady = false;
  final String _mPath = 'flutter_sound_example.aac';
  String filePath = "";

  @override
  void initState() {
    _recordController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _recordController.repeat(reverse: true);

    _animation = Tween(begin: 1.0, end: 0.0).animate(_recordController)
      ..addListener(() {
        setState(() {});
      });

    this.position = Offset(widget.width - 60, widget.height - 54);
    this.oldX = widget.width - 60;
    this.oldY = widget.height - 54;

    // Audio settings

    _myPlayer.openAudioSession().then((value) {
      setState(() {
        print("shruti");
        _myPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });

    super.initState();
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      print("shrutiii3");
      var status = await Permission.microphone.request();
      print("shrutiii1");
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _myRecorder.openAudioSession();
    _mRecorderIsInited = true;
  }

  void _updateSize() {
    setState(() {
      _size = expand ? 50.0 : 80.0;
      position = expand ? Offset(oldX, oldY) : Offset(oldX - 15, oldY - 15);
      expand = !expand;
      shouldActivate = !shouldActivate;
    });
  }

  @override
  void dispose() {
    _myPlayer.closeAudioSession();
    _myPlayer = null;

    _myRecorder.closeAudioSession();
    _myRecorder = null;
    super.dispose();
  }

  void record() {
    _myRecorder
        .startRecorder(
      toFile: _mPath,
      codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
    )
        .then((value) {
      setState(() {});
    });
  }

  void stopRecorder() async {
    await _myRecorder.stopRecorder().then((value) {
      setState(() {
        //var url = value;
        _myplaybackReady = true;
      });
    });
  }

  void play() {
    assert(_myPlayerIsInited &&
        _myplaybackReady &&
        _myRecorder.isStopped &&
        _myPlayer.isStopped);
    _myPlayer
        .startPlayer(
        fromURI: _mPath,
        //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
        whenFinished: () {
          setState(() {});
        })
        .then((value) {
      setState(() {});
    });
  }

  void stopPlayer() {
    _myPlayer.stopPlayer().then((value) {
      setState(() {});
    });
  }

  _Fn getRecorderFn() {
    if (!_mRecorderIsInited || !_myPlayer.isStopped) {
      return null;
    }
    return _myRecorder.isStopped ? record : stopRecorder;
  }

  _Fn getPlaybackFn() {
    if (!_myPlayerIsInited || !_myplaybackReady || !_myRecorder.isStopped) {
      return null;
    }
    return _myPlayer.isStopped ? play : stopPlayer;
  }

  Stream<int> stopWatchStream() {
    StreamController<int> streamController;
    Timer timer;
    Duration timerInterval = Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
        counter = 0;
        streamController.close();
      }
    }

    void tick(_) {
      counter++;
      streamController.add(counter);
      if (!flag) {
        stopTimer();
      }
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
  }

  Widget chatBox() {
    return Container(
      margin: const EdgeInsets.only(right: 64.0, left: 8.0, bottom: 4.0),
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
                color: Color.fromRGBO(51, 51, 51, 0.6),
                blurRadius: 0.0,
                offset: Offset(0, 0))
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Material(
              color: Colors.transparent,
              child: InkWell(
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(Icons.sentiment_very_satisfied,
                          color: Colors.grey)),
                  onTap: () {})),
          Expanded(
            child: TextField(
              onTap: () {
                // setState(() {
                //   position = Offset(position.dx, position.dy - 254);
                // });
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write a message',
                  hintStyle: TextStyle(color: Colors.grey)),
            ),
          ),
          Material(
              color: Colors.transparent,
              child: InkWell(
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(
                        Icons.attach_file,
                        size: 22.0,
                        color: Colors.grey,
                      )),
                  onTap: () {})),
          Material(
              color: Colors.transparent,
              child: InkWell(
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(Icons.camera_alt, color: Colors.grey)),
                  onTap: () {}))
        ],
      ),
    );
  }

  Widget audioBox() {
    return Container(
      margin: EdgeInsets.only(right: marginBack, left: 8.0, bottom: 4.0),
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
                color: Color.fromRGBO(51, 51, 51, 0.6),
                blurRadius: 0.0,
                offset: Offset(0, 0))
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AnimatedOpacity(
            opacity: _animation.value,
            duration: Duration(milliseconds: 100),
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                    child: Container(
                      // padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(Icons.mic, color: Colors.red)),
                    onTap: () {})),
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 5,
              alignment: Alignment.centerLeft,
              child: Text("$minutesStr:$secondsStr"),
            ),
          ),
          longRecording
              ? GestureDetector(
              onTap: () {
                if (_myRecorder.isRecording) {
                  setState(() {
                    shouldSend = false;
                    longRecording = false;
                  });
                  stopRecorder();
                }
                _resetUi();
                _resetTimer();
              },
              child: Text("Cancel", textAlign: TextAlign.center))
              : Shimmer.fromColors(
              direction: ShimmerDirection.rtl,
              child: Text(
                "Swipe to cancel",
                textAlign: TextAlign.center,
              ),
              baseColor: Colors.red,
              highlightColor: Colors.yellow),
          SizedBox(width: marginText),
        ],
      ),
    );
  }

  void _resetTimer() {
    if (!longRecording) {
      timerSubscription.cancel();
      timerStream = null;
      setState(() {
        minutesStr = '00';
        secondsStr = '00';
      });
    }
  }

  void _resetUi() {
    //_resetTimer();
    setState(() {
      xs.clear();
      ys.clear();
      tcount = 10;
      isRecording = longRecording ? true : false;
      marginBack = longRecording ? 64.0 : 38.0;
      marginText = longRecording ? 16 : 36.0;
      scount = 0;
      position = Offset(oldX, oldY);
      showLockUi = false;
      vheight = 200;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScreenHeight>(
      builder: (context, _res, child) => Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
            ),
            child: Row(children: [
              ElevatedButton(
                onPressed: getPlaybackFn(),
                //color: Colors.white,
                //disabledColor: Colors.grey,
                child: Icon(_myPlayer.isPlaying ? Icons.play_arrow_rounded : Icons.pause ),
              ),
              SizedBox(
                width: 20,
              ),
              Text(_myPlayer.isPlaying
                  ? 'Playback in progress'
                  : 'Player is stopped'),
            ]),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: isRecording ? audioBox() : chatBox(),
          ),
          showLockUi
              ? Positioned(
            left: widget.width - 62,
            top: widget.height - 180,
            child: Container(
              height: vheight,
              width: 54,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50)),
                  color: Colors.black38),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.lock, color: Colors.white)),
            ),
          )
              : Container(),
          Positioned(
            left: position.dx,
            top: _res.isOpen ? position.dy - _res.keyboardHeight : position.dy,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,

              onTap: () {
                if (longRecording) {
                  setState(() {
                    shouldSend = true;
                    longRecording = false;
                  });
                  if (_myRecorder.isRecording) stopRecorder();
                  _resetUi();
                  _resetTimer();
                }
              },

              onLongPressStart: (_) {
                HapticFeedback.mediumImpact();
                _updateSize();
                setState(() {
                  isRecording = true;
                });
                if (_myRecorder.isStopped) {
                  record();
                }
                timerStream = stopWatchStream();
                timerSubscription = timerStream.listen((int newTick) {
                  setState(() {
                    minutesStr = ((newTick / 60) % 60)
                        .floor()
                        .toString()
                        .padLeft(2, '0');
                    secondsStr =
                        (newTick % 60).floor().toString().padLeft(2, '0');
                    if (secondsStr == '03') showLockUi = true;
                  });
                });
              },

              onLongPressEnd: (_) {
                HapticFeedback.lightImpact();
                _updateSize();
                if (_myRecorder.isRecording && !longRecording) {
                  setState(() {
                    shouldSend = true;
                  });
                  stopRecorder();
                }
                _resetUi();
                _resetTimer();
              },

              onLongPressMoveUpdate: (mu) {
                setState(() {
                  if (tcount == 0) {
                    if (xs.length > ys.length) {
                      direction = 1;
                    } else if (xs.length < ys.length) {
                      direction = 2;
                    } else {
                      direction = -1;
                    }
                  } else {
                    tcount -= 1;
                    xs.add(mu.globalPosition.dx);
                    ys.add(mu.globalPosition.dy);
                  }
                });
                if (direction == 1) {
                  position = Offset(mu.globalPosition.dx - 50, oldY - 16);
                  setState(() {
                    scount += 1;
                    if (scount == 10) {
                      marginBack += 5;
                      if (marginText < 50) marginText += 2;
                      scount = 0;
                    }
                  });
                } else if (direction == 2) {
                  position = Offset(oldX - 10, mu.globalPosition.dy - 50);
                  setState(() {
                    scount += 1;
                    if (scount == 10) {
                      vheight -= 8;
                      scount = 0;
                    }
                  });
                }
                if (mu.globalPosition.dy < widget.height - 150) {
                  // Threshold reached
                  setState(() {
                    longRecording = true;
                    position = Offset(oldX, oldY);
                    marginBack = 64.0;
                    direction = -1;
                    showLockUi = false;
                    //shouldSend = true;
                  });
                }
                if (mu.globalPosition.dx - 50 < 220) {
                  setState(() {
                    shouldSend = false;
                  });
                  if (_myRecorder.isRecording) stopRecorder();
                  _resetUi();
                  _resetTimer();
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16.0),
                child: Material(
                  color: Color(0xff0e2546),
                  borderRadius: BorderRadius.circular(100),
                  child: AnimatedSize(
                    curve: Curves.easeIn,
                    vsync: this,
                    duration: const Duration(milliseconds: 100),
                    child: InkWell(
                      child: Container(
                        width: _size,
                        height: _size,
                        child: Icon(longRecording ? Icons.send : Icons.mic,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}