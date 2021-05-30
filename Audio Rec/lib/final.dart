import 'package:audio_recording_in_flutter/models/msg_model.dart';
import 'package:audio_recording_in_flutter/newfile.dart';
import 'package:audio_recording_in_flutter/pages/chat_screen.dart';
import 'package:audio_recording_in_flutter/pages/message_screen.dart';
import 'package:audio_recording_in_flutter/widgets/bottom_input.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

typedef _Fn = void Function();
int count=0;

class screen extends StatefulWidget {
  final double width;
  final double height;
  final Function(String) onAudioSend;
  final Function() onAudioCancel;

  const screen({Key key, @required this.width,@required this.height,@required this.onAudioSend,@required this.onAudioCancel}) : super(key: key);
  @override
  _screenState createState() => _screenState();
}

class _screenState extends State<screen>
    with TickerProviderStateMixin {

  static const styleSomebody = BubbleStyle(
    nip: BubbleNip.leftCenter,
    color: Color(0xfff0f1f5),
    elevation: 1,
    margin: BubbleEdges.only(top: 8, right: 50),
    alignment: Alignment.topLeft,
  );
  static const styleMe = BubbleStyle(
    nip: BubbleNip.rightCenter,
    color: Color(0xfffbbec5),
    elevation: 1,
    margin: BubbleEdges.only(top: 8, left: 50),
    alignment: Alignment.topRight,
  );
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  final String _mPath = 'flutter_sound_example.aac';
  var msgList = [];
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
  Offset positions =Offset(20.0, 20.0);

  @override
  void initState() {
    _recordController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _recordController.repeat(reverse: true);

    _animation = Tween(begin: 1.0, end: 0.0).animate(_recordController)
      ..addListener(() {
        setState(() {});
      });



    _mPlayer.openAudioSession().then((value) {
      setState(() {
        print("shruti");
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _mPlayer.closeAudioSession();
    _mPlayer = null;

    _mRecorder.closeAudioSession();
    _mRecorder = null;
    super.dispose();
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
    await _mRecorder.openAudioSession();
    _mRecorderIsInited = true;
  }

  // ----------------------  Here is the code for recording and playback -------

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
    if (!_mRecorderIsInited || !_mPlayer.isStopped) {
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
  Widget chatBox() {
    return Container(
      margin: const EdgeInsets.only(right: 78.0, left: 18.0, bottom: 16.0),
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
      margin: EdgeInsets.only(right: marginBack, left: 18.0, bottom: 16.0),
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
      var width = MediaQuery
          .of(context)
          .size
          .width;
      var height = MediaQuery
          .of(context)
          .size
          .height;
    return KeyboardSizeProvider(
      smallSize: 500.0,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xff0e2546),
            leading: Row(
              children: [
                SizedBox(
                  width: 13,
                ),

                CircleAvatar(
                  foregroundColor: Theme.of(context).primaryColor,
                  backgroundColor: Colors.grey,
                ),
              ],
            ),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text("Shruti"),
                ],
              ),
            ),
            elevation: 0.7,
            actions: <Widget>[
              Icon(Icons.phone),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.video_call),
              )
            ],
          ),
          body: Consumer<ScreenHeight>(
            builder: (context, _res, child) =>Stack(
              children: [
                Container(
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
                            'Hi Jason. Sorry to bother you. I have a queston for you.'),
                      ),
                      Bubble(
                        style: styleMe,
                        child: const Text("Whats'up?"),
                      ),
                      Bubble(
                        style: styleSomebody,
                        child:
                        const Text(
                            "I've been having a problem with my computer."),
                      ),
                      Bubble(
                        style: styleSomebody,
                        margin: const BubbleEdges.only(top: 4),
                        showNip: false,
                        child: const Text('Can you help me?'),
                      ),
                      Bubble(
                        style: styleMe,
                        child: const Text('Ok'),
                      ),
                      Bubble(
                        style: styleMe,
                        showNip: false,
                        margin: const BubbleEdges.only(top: 4),
                        child: const Text("What's the problem?"),
                      ),
                      (count==0 )? Bubble(
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
                      ):Container(),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: isRecording ? audioBox() : chatBox(),
                ),
                showLockUi
                    ? Positioned(
                  left: widget.width - 62,
                  top: widget.height - 200,
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

              ],
            ),
          ),
          floatingActionButton: Draggable(
            feedback: FloatingActionButton(
              onPressed: (){
                setState(() {
                  count++;
                  print(count);
                  print("shrutii");
                });},

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

                  if (_mRecorder.isRecording && !longRecording) {
                    setState(() {
                      shouldSend = true;
                    });
                    stopRecorder();
                  }
                  _resetUi();
                  _resetTimer();
                },

                child: Icon(
                  Icons.mic,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Color(0xfffbbec5),
            ),
            child: FloatingActionButton(
              onPressed: (){
               setState(() {
                 count++;
                 print(count);
                 print("shrutii");
                            });},

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

                  if (_mRecorder.isRecording && !longRecording) {
                    setState(() {
                      shouldSend = true;
                    });
                    stopRecorder();
                  }
                  _resetUi();
                  _resetTimer();
                },

                child: Icon(
                  Icons.mic,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Color(0xfffbbec5),
            ),
          ),

        ),
      ),
    );
  }
}
