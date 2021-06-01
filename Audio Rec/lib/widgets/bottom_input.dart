import 'dart:async';

import 'package:audio_recording_in_flutter/pages/chat_screen.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_keyboard_size/screen_height.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';


typedef _Fn = void Function();

class BottomInput extends StatefulWidget {
  final double width;
  final double height;
  final int count;
  final Function(String) onAudioSend;
  final Function() onAudioCancel;

  const BottomInput(
      {Key key,
        @required this.width,
        @required this.height,
        @required this.count,
        @required this.onAudioSend,
        @required this.onAudioCancel})
      : super(key: key);

  @override
  _BottomInputState createState() => _BottomInputState();
}

class _BottomInputState extends State<BottomInput>
    with TickerProviderStateMixin {
  static const styleMe = BubbleStyle(
    nip: BubbleNip.rightCenter,
    color: Color(0xfffbbec5),
    elevation: 1,
    margin: BubbleEdges.only(top: 8, left: 50),
    alignment: Alignment.topRight,
  );
  static const styleSomebody = BubbleStyle(
    nip: BubbleNip.leftCenter,
    color: Color(0xfff0f1f5),
    elevation: 1,
    margin: BubbleEdges.only(top: 8, right: 50),
    alignment: Alignment.topLeft,
  );
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
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  final String _mPath = 'flutter_sound_example.aac';
  var msgList = [];
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

    this.position = Offset(widget.width - 60, widget.height - 150);
    this.oldX = widget.width - 60;
    this.oldY = widget.height - 150;

    // Audio settings
    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });

    super.initState();
  }
  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder.openAudioSession();
    _mRecorderIsInited = true;
  }
  void _updateSize() {
    setState(() {
      _size = expand ? 50.0 : 80.0;
      position = expand ? Offset(oldX, oldY) : Offset(
          oldX - 15, oldY - 15);
      expand = !expand;
      shouldActivate = !shouldActivate;
    });
  }


  @override

  void dispose() {
    this._recordController = null;
    _mRecorder.closeAudioSession();
    _mRecorder = null;
    super.dispose();
  }
  void record() {
    _mRecorder
        .startRecorder(
      toFile: _mPath,
      codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
    )
        .then((value) {
      setState(() {});
    });
  }
  void stopRecorder() async {
    await _mRecorder.stopRecorder().then((value) {
      setState(() {
        //var url = value;
        _mplaybackReady = true;
      });
    });
  }
  void play() {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder.isStopped &&
        _mPlayer.isStopped);
    _mPlayer
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
    _mPlayer.stopPlayer().then((value) {
      setState(() {});
    });
  }
  _Fn getRecorderFn() {
    if (!_mRecorderIsInited) {
      return null;
    }
    return _mRecorder.isStopped ? record : stopRecorder;
  }
  _Fn getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder.isStopped) {
      return null;
    }
    return _mPlayer.isStopped ? play : stopPlayer;
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

  Widget AudioBubble(){
    Bubble(
      style: styleMe,
      showNip: false,
      margin: const BubbleEdges.only(top: 4),
      child: Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.all(3),
        height: 50,
        width: 250,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color(0xfffbbec5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
              ),
              onPressed: getPlaybackFn(),
              //color: Colors.white,
              //disabledColor: Colors.grey,
              child: Icon(
                _mPlayer.isPlaying ? Icons
                    .play_arrow_rounded : Icons.pause,
                color: Color(0xff0e2546),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Text(_mPlayer.isPlaying
                ? 'Playback in progress'
                : 'Player is stopped'),
          ]),
        ),
      ),
    );
  }
  Widget chatBox() {
    return Container(
      margin: const EdgeInsets.only(right: 72.0, left: 9.0, bottom: 16.0),
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
      margin: EdgeInsets.only(right: marginBack, left: 9.0, bottom: 16.0),
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
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(Icons.mic, color: Colors.red)),
                    onTap: () {})),
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 48,
              alignment: Alignment.centerLeft,
              child: Text("$minutesStr:$secondsStr"),
            ),
          ),
          longRecording
              ? GestureDetector(
              onTap: () {
                if (_mRecorder.isRecording) {
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
        children:
        [
          Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 58.0),
                  /* decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/background.png"),
                            fit: BoxFit.cover,
                          ),
                        ),*/
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      Bubble(
                        alignment: Alignment.center,
                        color: const Color.fromARGB(255, 212, 234, 244),
                        margin: const BubbleEdges.only(top: 8),
                        child: const Text(
                          'TODAY',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Bubble(
                        style: styleSomebody,
                        child: const Text(
                            'Hi Shruti. Sorry to bother you. I need your help.'),
                      ),
                      Bubble(
                        style: styleMe,
                        child: const Text("Whats'up?"),
                      ),
                      Bubble(
                        style: styleSomebody,
                        child:
                        const Text(
                            "I've been having a problem with my laptop."),
                      ),
                      Bubble(
                        style: styleSomebody,
                        margin: const BubbleEdges.only(top: 4),
                        showNip: false,
                        child: const Text('Can you help me fix that?'),
                      ),
                      Bubble(
                        style: styleMe,
                        child: const Text('yeah sure'),
                      ),
                      Bubble(
                        style: styleMe,
                        showNip: false,
                        margin: const BubbleEdges.only(top: 4),
                        child: const Text("What's the problem?"),
                      ),
                      (count>=1 )? Bubble(
                        style: styleMe,
                        showNip: false,
                        margin: const BubbleEdges.only(top: 4),
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          padding: const EdgeInsets.all(3),
                          height: 50,
                          width: 250,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xfffbbec5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                ),
                                onPressed: getPlaybackFn,
                                //color: Colors.white,
                                //disabledColor: Colors.grey,
                                child: Icon(
                                  _mPlayer.isPlaying ? Icons
                                      .play_arrow_rounded : Icons.pause,
                                  color: Color(0xff0e2546),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(_mPlayer.isPlaying
                                  ? 'Playback in progress'
                                  : 'Playback in progress'),
                            ]),
                          ),
                        ),
                      ):Container(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: isRecording ? audioBox() : chatBox(),
          ),
          showLockUi
              ? Positioned(
            left: widget.width - 62,
            top: widget.height - 250,
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
            top: _res.isOpen ? position.dy - _res.keyboardHeight  : position.dy,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,

              onTap: () {
                if (longRecording) {
                  setState(() {
                    shouldSend = true;
                    longRecording = false;
                  });
                  if (_mRecorder.isRecording) stopRecorder();
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
                if (_mRecorder.isStopped) {
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
                if (_mRecorder.isRecording && !longRecording) {
                  setState(() {
                    count++;
                    print(count);
                    shouldSend = true;
                  });
                  getPlaybackFn();
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
                  if (_mRecorder.isRecording) stopRecorder();
                  _resetUi();
                  _resetTimer();
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 18.0, bottom: 76.0),
                child: Material(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(100),
                  child: AnimatedSize(
                    curve: Curves.easeIn,
                    vsync: this,
                    duration: const Duration(milliseconds: 100),
                    child: InkWell(
                      child: Container(
                        width: _size,
                        height: _size,
                        child: IconButton(
                          onPressed: (){
                            setState(() {
                              shouldSend = true;
                              count++;
                            });
                            getPlaybackFn();
                            _resetUi();
                            _resetTimer();
                          },

                          icon: Icon(longRecording ? Icons.send : Icons.mic,
                              color: Colors.white),
                        ),
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